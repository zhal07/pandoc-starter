-- Convert bullet lists to hyphen-prefixed paragraphs for ATS compliance.
-- This keeps output strictly ASCII and avoids decorative bullet glyphs in DOCX.
function BulletList(items)
  local blocks = {}
  for _, item in ipairs(items) do
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      local inlines = { pandoc.Str("-") , pandoc.Space() }
      for _, inline in ipairs(first.c) do
        table.insert(inlines, inline)
      end
      table.insert(blocks, pandoc.Para(inlines))
    else
      -- Fallback: keep original blocks if structure is unexpected.
      for _, block in ipairs(item) do
        table.insert(blocks, block)
      end
    end
  end
  return blocks
end
