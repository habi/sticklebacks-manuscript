
function Pandoc(doc)
  local style = [=[
#let blockquote(body) = block(
  width: 100%,
  fill: luma(245),
  stroke: (left: 3pt + rgb("#e4003c")),
  inset: (x: 12pt, y: 8pt),
  radius: (right: 3pt),
  above: 6pt,
  below: 6pt,
)[
  #set par(first-line-indent: 0pt)
  #body
]
]=]

  table.insert(
    doc.blocks,
    1,
    pandoc.RawBlock("typst", style)
  )

  return doc
end
