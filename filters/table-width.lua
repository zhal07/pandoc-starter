-- table-width.lua
-- Distribute column widths evenly for tables that have no explicit widths.
-- This ensures consistent full-width longtable output in PDF (LaTeX) builds.

local function get_width(colwidth)
  if type(colwidth) == "number" then
    return colwidth
  elseif type(colwidth) == "table" then
    -- pandoc 2.17+ uses a tagged table: {t="ColWidth", width=n} or {t="ColWidthDefault"}
    if colwidth.t == "ColWidth" and colwidth.width then
      return colwidth.width
    end
  end
  return 0
end

local function make_width(w)
  -- Use pandoc.ColWidth constructor if available (pandoc 2.17+)
  if pandoc and pandoc.ColWidth then
    return pandoc.ColWidth(w)
  end
  return w
end

function Table(el)
  local n = #el.colspecs
  if n == 0 then return el end

  -- Sum explicit widths; if none are set, redistribute equally
  local total = 0
  for _, spec in ipairs(el.colspecs) do
    total = total + get_width(spec[2])
  end

  if total < 0.01 then
    local per_col = 1.0 / n
    local w = make_width(per_col)
    for i = 1, n do
      el.colspecs[i] = { el.colspecs[i][1], w }
    end
  end

  return el
end
