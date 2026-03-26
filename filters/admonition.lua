-- admonition.lua
-- Converts fenced divs with classes 'note', 'warning', or 'tip' into
-- styled admonition blocks for both LaTeX and HTML output.
--
-- Usage in Markdown:
--   ::: note
--   This is a note.
--   :::
--
--   ::: warning
--   This is a warning.
--   :::
--
--   ::: tip
--   This is a helpful tip.
--   :::

local ADMONITIONS = { note = true, warning = true, tip = true }

function Div(el)
  local kind = nil
  for _, class in ipairs(el.classes) do
    if ADMONITIONS[class] then
      kind = class
      break
    end
  end

  if kind == nil then
    return nil
  end

  local format = FORMAT

  -- ── LaTeX output ──────────────────────────────────────────────────────
  if format:match("latex") or format:match("beamer") or format:match("pdf") then
    local env = kind .. "box"
    local begin_env = pandoc.RawBlock("latex", "\\begin{" .. env .. "}")
    local end_env   = pandoc.RawBlock("latex", "\\end{" .. env .. "}")
    local blocks = { begin_env }
    for _, block in ipairs(el.content) do
      table.insert(blocks, block)
    end
    table.insert(blocks, end_env)
    return blocks

  -- ── HTML output ───────────────────────────────────────────────────────
  elseif format:match("html") then
    el.classes = pandoc.List({ kind })
    return el
  end

  -- ── Plain / other formats: strip the div wrapper, keep content ────────
  return el.content
end
