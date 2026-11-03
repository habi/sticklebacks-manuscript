
function Pandoc(doc)
  local style = [=[  
#let blockquote(body) = block(
  width: 100%,
  fill: rgb(211, 211, 211),
  stroke: (left: 2pt + rgb(230, 0, 46), top: 2pt + rgb(230, 0, 46)),
  inset: (x: 12pt, y: 8pt),
  above: 12pt,
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
