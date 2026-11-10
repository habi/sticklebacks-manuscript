#!/usr/bin/env python3
"""Diff two manubot builds of the manuscript with pandiff.

The `output` branch holds one build per commit of `main`; each build's commit
message says "This build is based on .../commit/<sha>". For both revisions,
the script takes the built `manuscript.docx` (citations, figure numbers and
images already rendered by manubot), converts it to markdown and diffs the
two versions with pandiff.

Images are stored under a hash of their content, so unchanged figures are
identical in both versions and only changed figures show up in the diff.

Revisions can be tags, branches, SHAs (also ones that only exist on GitHub),
or 'latest' for the newest build.

Examples:
    python3 pandiff_commits.py --old v1.0                      # vs. HEAD
    python3 pandiff_commits.py --old v1.0 --new latest -o diff.pdf
    python3 pandiff_commits.py --old 68187e6 --new 109fc2c -o diff.docx
    python3 pandiff_commits.py --old v1.0 --new latest -o diff.html -- --standalone

The output format follows the extension of `-o` (markdown on the terminal
without it). Anything after `--` is passed on to pandiff unchanged.

For `.pdf`, pandiff itself would go through LaTeX, which fails on its output.
Instead, the diff is made as HTML (<ins>/<del>), converted with pandoc to
typst (insertions green and underlined, deletions red and struck through)
and compiled with `typst`.

For a diff with Word's own formatting, use `--keep` and compare the two
saved .docx files in Word (Review → Compare).
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

OUTPUT_BRANCH = "output"
ARTIFACT = "manuscript.docx"

# docx -> markdown: write each image to $MEDIA_DIR/<sha1>.<ext>
MEDIA_FILTER = r"""
local media_dir = os.getenv("MEDIA_DIR")

function Image(el)
  -- drop the tiny ORCID/GitHub/Mastodon icons next to the author names
  local width = tonumber((el.attributes.width or ""):match("^([%d.]+)in$"))
  if width and width < 0.5 then return {} end
  -- without size attributes, pandiff keeps images as markdown (not raw HTML),
  -- so they also end up in a docx
  el.attributes.width, el.attributes.height = nil, nil
  local mimetype, contents = pandoc.mediabag.lookup(el.src)
  if not contents then return el end
  local ext = el.src:match("%.(%w+)$") or "bin"
  local path = media_dir .. "/" .. pandoc.utils.sha1(contents) .. "." .. ext
  local f = io.open(path, "wb")
  f:write(contents)
  f:close()
  el.src = path
  return el
end
"""

# Colors for the typst/PDF output
TYPST_HEADER = """\
#show underline: set text(fill: rgb("#1a7f37"))
#show strike: set text(fill: rgb("#cf222e"))
// captions already start with manubot's "Figure 3:", so drop typst's numbering
#show figure.caption: it => it.body
"""

# HTML -> typst
TYPST_FILTER = r"""
-- Typst turns 'https://...' in plain text into a link, which breaks when
-- a diff marker sits in the middle of it (the diff may also split the URL
-- across several pieces of text): escape every slash in plain text.
function Str(el)
  if not el.text:find("/", 1, true) then return nil end
  local out = {}
  for part, slash in el.text:gmatch("([^/]*)(/?)") do
    if #part > 0 then table.insert(out, pandoc.Str(part)) end
    if #slash > 0 then table.insert(out, pandoc.RawInline("typst", "\\/")) end
  end
  return out
end

-- Internal links (#section) point to labels typst may not know: keep the text
function Link(el)
  if el.target:sub(1, 1) == "#" then return el.content end
  return el
end

-- pandoc 3.1.3 writes e.g. '#emph[4](4)', which typst reads as a function
-- call: escape a '(' or '[' directly following such an element.
local wrapped = {Emph = true, Strong = true, Underline = true, Strikeout = true,
                 Superscript = true, Subscript = true, SmallCaps = true,
                 Link = true, Span = true, Quoted = true, Cite = true}

function Inlines(inlines)
  local out = pandoc.Inlines({})
  local escape_next = false
  for _, el in ipairs(inlines) do
    if escape_next and el.t == "Str" and el.text:match("^[%(%[]") then
      out:insert(pandoc.RawInline("typst", "\\" .. el.text:sub(1, 1)))
      if #el.text > 1 then out:insert(pandoc.Str(el.text:sub(2))) end
    else
      out:insert(el)
    end
    escape_next = wrapped[el.t] or false
  end
  return out
end
"""


def git(*args, cwd, binary=False):
    """Run a git command and return its stdout."""
    return subprocess.run(
        ["git", *args], cwd=cwd, check=True, capture_output=True, text=not binary
    ).stdout


def run(cmd, **kwargs):
    """Run a command, exit if it fails."""
    if subprocess.run(cmd, **kwargs).returncode != 0:
        sys.exit(f"Failed: {' '.join(map(str, cmd))}")


def output_ref(repo, fetch):
    """Return the ref of the output branch, fetching it from origin if asked."""
    if fetch:
        try:
            git("fetch", "--quiet", "origin", OUTPUT_BRANCH, cwd=repo)
        except subprocess.CalledProcessError:
            print(f"Could not fetch origin/{OUTPUT_BRANCH}, using the local copy",
                  file=sys.stderr)
    for ref in (f"origin/{OUTPUT_BRANCH}", OUTPUT_BRANCH):
        try:
            git("rev-parse", "--verify", "--quiet", ref, cwd=repo)
            return ref
        except subprocess.CalledProcessError:
            pass
    sys.exit(f"No '{OUTPUT_BRANCH}' branch found")


def based_on(build, repo):
    """The source commit named in a build's commit message."""
    message = git("log", "-1", "--format=%B", build, cwd=repo)
    match = re.search(r"build is based on\s+\S*/commit/([0-9a-f]{40})", message)
    return match.group(1) if match else "?"


def build_of(rev, repo, ref):
    """Return the commit on the output branch whose build is based on `rev`."""
    if rev == "latest":
        build = git("rev-parse", ref, cwd=repo).strip()
    else:
        try:
            sha = git("rev-parse", "--verify", "--quiet", f"{rev}^{{commit}}",
                      cwd=repo).strip()
        except subprocess.CalledProcessError:
            if not re.fullmatch(r"[0-9a-f]{7,40}", rev):
                sys.exit(f"Unknown revision: {rev}")
            sha = rev  # not in the local clone, but maybe built on the output branch
        build = git("log", ref, "--extended-regexp",
                    "--grep=build is based on", f"--grep=/commit/{sha}[0-9a-f]*",
                    "--all-match", "--format=%H", "-1", cwd=repo).strip()
    if not build:
        sys.exit(f"No build of {rev} on {ref}. The newest build is based on "
                 f"{based_on(ref, repo)[:7]}. Push and wait for the build, "
                 f"or pass 'latest' or that commit.")
    print(f"{rev}: build {build[:7]} on {ref}, based on {based_on(build, repo)[:7]}",
          file=sys.stderr)
    return build


def docx_to_markdown(rev, repo, ref, tmp, name):
    """Save the built docx of `rev` and convert it to markdown; return both paths."""
    build = build_of(rev, repo, ref)
    docx, md = tmp / f"{name}.docx", tmp / f"{name}.md"
    try:
        docx.write_bytes(git("show", f"{build}:{ARTIFACT}", cwd=repo, binary=True))
    except subprocess.CalledProcessError:
        sys.exit(f"Build {build[:7]} has no {ARTIFACT}")
    env = {**os.environ, "MEDIA_DIR": str(tmp / "media")}
    run(["pandoc", str(docx), "--from", "docx", "--to", "markdown",
         "--wrap=none", "--lua-filter", str(tmp / "media.lua"),
         "--output", str(md)], env=env)
    return docx, md


def make_pdf(old_md, new_md, output, pandiff_args, tmp, title):
    """pandiff -> HTML -> pandoc -> typst -> PDF."""
    if shutil.which("typst") is None:
        sys.exit("typst not found on PATH")
    html, typ = tmp / "diff.html", tmp / "diff.typ"
    (tmp / "typst.lua").write_text(TYPST_FILTER, encoding="utf-8")
    (tmp / "header.typ").write_text(TYPST_HEADER, encoding="utf-8")
    run(["pandiff", *pandiff_args, "--to", "html", "--output", str(html),
         str(old_md), str(new_md)])
    # pandiff exits with 0 even if pandoc fails, so check for the file
    if not html.exists():
        sys.exit("pandiff did not produce any output")
    run(["pandoc", str(html), "--from", "html", "--to", "typst", "--standalone",
         "--lua-filter", str(tmp / "typst.lua"),
         "--include-in-header", str(tmp / "header.typ"),
         "--metadata", f"title={title}", "--output", str(typ)])
    run(["typst", "compile", "--root", "/", str(typ), str(output)])
    return typ


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("--old", required=True, help="old revision, e.g. v1.0")
    parser.add_argument("--new", default="HEAD",
                        help="new revision (default: HEAD); 'latest' is the newest build")
    parser.add_argument("-o", "--output", help="output file; format from the extension")
    parser.add_argument("--no-fetch", action="store_true",
                        help="do not fetch the output branch from origin first")
    parser.add_argument("--keep", action="store_true",
                        help="also save the two built .docx files (for Word's Compare), "
                             "and the .typ for PDFs")
    parser.add_argument("pandiff_args", nargs="*", help="extra arguments for pandiff (after --)")
    args = parser.parse_args()

    for tool in ("pandiff", "pandoc"):
        if shutil.which(tool) is None:
            sys.exit(f"{tool} not found on PATH")

    repo = git("rev-parse", "--show-toplevel", cwd=Path(__file__).resolve().parent).strip()
    ref = output_ref(repo, fetch=not args.no_fetch)
    output = Path(args.output).resolve() if args.output else None

    # The extracted images must outlive the temporary directory for a docx
    # output (pandoc embeds them when writing); they are only read while
    # this block runs, so a temporary directory is fine.
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp = Path(tmpdir)
        (tmp / "media").mkdir()
        (tmp / "media.lua").write_text(MEDIA_FILTER, encoding="utf-8")
        old_docx, old_md = docx_to_markdown(args.old, repo, ref, tmp, "old")
        new_docx, new_md = docx_to_markdown(args.new, repo, ref, tmp, "new")

        if args.keep:
            target = output.parent if output else Path.cwd()
            for f, rev in ((old_docx, args.old), (new_docx, args.new)):
                kept = target / f"manuscript_{rev.replace('/', '_')}.docx"
                shutil.copy(f, kept)
                print(f"Kept {kept}", file=sys.stderr)

        if output and output.suffix.lower() == ".pdf":
            typ = make_pdf(old_md, new_md, output, args.pandiff_args, tmp,
                           title=f"Changes {args.old} → {args.new}")
            if args.keep:
                shutil.copy(typ, output.with_suffix(".typ"))
                print(f"Kept {output.with_suffix('.typ')}", file=sys.stderr)
        else:
            cmd = ["pandiff", *args.pandiff_args, str(old_md), str(new_md)]
            if output:
                cmd[1:1] = ["--output", str(output)]
            run(cmd)
            if output and not output.exists():
                sys.exit("pandiff did not produce any output")

    if output:
        print(f"Wrote {args.output}", file=sys.stderr)


if __name__ == "__main__":
    main()
