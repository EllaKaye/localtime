-- localtime.lua
-- Quarto shortcode extension to display times in the reader's local timezone.
-- Usage: {{< localtime YYYY-MM-DD HH:MM TZ >}}

local counter = 0

-- Timezone abbreviations mapped to UTC offset in minutes
local TZ_OFFSETS = {
  -- Universal
  UTC = 0, GMT = 0,
  -- North America
  EST = -300, EDT = -240,
  CST = -360, CDT = -300,
  MST = -420, MDT = -360,
  PST = -480, PDT = -420,
  AST = -240, ADT = -180,
  NST = -210, NDT = -150,
  AKST = -540, AKDT = -480,
  HST = -600, HDT = -540,
  -- Europe
  WET = 0, WEST = 60,
  CET = 60, CEST = 120,
  EET = 120, EEST = 180,
  BST = 60, IST = 60,
  -- Asia
  MSK = 180,
  GST = 240,
  PKT = 300,
  IST_INDIA = 330, -- India
  BST_BD = 360,    -- Bangladesh
  ICT = 420,
  WIB = 420,
  CST_CN = 480,    -- China
  HKT = 480,
  SGT = 480,
  JST = 540,
  KST = 540,
  ACST = 570,
  AEST = 600, AEDT = 660,
  NZST = 720, NZDT = 780,
}

local function is_leap_year(y)
  return (y % 4 == 0 and y % 100 ~= 0) or (y % 400 == 0)
end

local DAYS_IN_MONTH = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

local function days_in_month(m, y)
  if m == 2 and is_leap_year(y) then return 29 end
  return DAYS_IN_MONTH[m]
end

-- Normalize a datetime after arithmetic (handles day/month/year boundaries)
local function normalize_datetime(year, month, day, hour, minute)
  -- Normalize minutes -> hours
  hour = hour + math.floor(minute / 60)
  minute = minute % 60

  -- Normalize hours -> days
  day = day + math.floor(hour / 24)
  hour = hour % 24

  -- Normalize days forward
  while day > days_in_month(month, year) do
    day = day - days_in_month(month, year)
    month = month + 1
    if month > 12 then month = 1; year = year + 1 end
  end

  -- Normalize days backward
  while day < 1 do
    month = month - 1
    if month < 1 then month = 12; year = year - 1 end
    day = day + days_in_month(month, year)
  end

  return year, month, day, hour, minute
end

-- Parse a timezone string, return offset in minutes from UTC (positive = east)
-- Returns nil if unrecognised
local function parse_tz(tz_str)
  if not tz_str or tz_str == "" then return 0 end

  tz_str = tz_str:upper()

  -- Direct abbreviation lookup
  if TZ_OFFSETS[tz_str] then
    return TZ_OFFSETS[tz_str]
  end

  -- Handle UTC+X, UTC-X, GMT+X, GMT-X (e.g. UTC+5, UTC+5:30, UTC-8)
  local prefix, sign, h, m = tz_str:match("^([UG][TC][CT]?)([%+%-])(%d+):?(%d*)$")
  if prefix and sign and h then
    local offset = tonumber(h) * 60 + (tonumber(m) or 0)
    return sign == "+" and offset or -offset
  end

  -- Handle bare +HH:MM or -HH:MM or +HHMM or -HHMM
  local sign2, h2, m2 = tz_str:match("^([%+%-])(%d%d):?(%d%d)$")
  if sign2 and h2 and m2 then
    local offset = tonumber(h2) * 60 + tonumber(m2)
    return sign2 == "+" and offset or -offset
  end

  -- Handle bare +H or -H
  local sign3, h3 = tz_str:match("^([%+%-])(%d+)$")
  if sign3 and h3 then
    local offset = tonumber(h3) * 60
    return sign3 == "+" and offset or -offset
  end

  return nil
end

-- Convert input datetime + timezone to a UTC ISO 8601 string
local function to_utc_iso(year, month, day, hour, minute, tz_offset_minutes)
  -- Subtract the offset to get UTC
  local total_minutes = hour * 60 + minute - tz_offset_minutes
  local utc_hour = math.floor(total_minutes / 60)
  local utc_minute = total_minutes % 60
  if utc_minute < 0 then utc_minute = utc_minute + 60; utc_hour = utc_hour - 1 end

  local utc_year, utc_month, utc_day, utc_h, utc_m =
    normalize_datetime(year, month, day, utc_hour, utc_minute)

  return string.format("%04d-%02d-%02dT%02d:%02d:00Z",
    utc_year, utc_month, utc_day, utc_h, utc_m)
end

local JS_TEMPLATE = [[<span id="%s" class="localtime" data-utc="%s">%s</span><script>
(function(){var el=document.getElementById('%s');var d=new Date(el.getAttribute('data-utc'));var y=d.getFullYear();var mo=String(d.getMonth()+1).padStart(2,'0');var dy=String(d.getDate()).padStart(2,'0');var h=String(d.getHours()).padStart(2,'0');var mi=String(d.getMinutes()).padStart(2,'0');el.textContent=y+'-'+mo+'-'+dy+' '+h+':'+mi;})();
</script>]]

return {
  ["localtime"] = function(args, kwargs, meta, raw_args)
    -- Collect positional args as strings
    local parts = {}
    for _, arg in ipairs(args) do
      table.insert(parts, pandoc.utils.stringify(arg))
    end

    if #parts < 2 then
      io.stderr:write("[localtime] Error: expected at least date and time arguments\n")
      return pandoc.RawInline("html", "<span class='localtime-error'>[localtime: invalid args]</span>")
    end

    local date_str = parts[1]  -- e.g. "2026-01-30"
    local time_str = parts[2]  -- e.g. "13:00"
    local tz_str   = parts[3]  -- e.g. "UTC", "EST", "+05:30" (optional, defaults to UTC)

    -- Parse date
    local year, month, day = date_str:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
    if not year then
      io.stderr:write("[localtime] Error: invalid date format '" .. date_str .. "' (expected YYYY-MM-DD)\n")
      return pandoc.RawInline("html", "<span class='localtime-error'>[localtime: bad date]</span>")
    end
    year, month, day = tonumber(year), tonumber(month), tonumber(day)

    -- Parse time
    local hour, minute = time_str:match("^(%d%d?):(%d%d)$")
    if not hour then
      io.stderr:write("[localtime] Error: invalid time format '" .. time_str .. "' (expected HH:MM)\n")
      return pandoc.RawInline("html", "<span class='localtime-error'>[localtime: bad time]</span>")
    end
    hour, minute = tonumber(hour), tonumber(minute)

    -- Parse timezone
    local tz_offset = parse_tz(tz_str or "UTC")
    if tz_offset == nil then
      io.stderr:write("[localtime] Warning: unrecognised timezone '" .. (tz_str or "") .. "', assuming UTC\n")
      tz_offset = 0
      tz_str = "UTC"
    end

    -- Build UTC ISO string
    local utc_iso = to_utc_iso(year, month, day, hour, minute, tz_offset)

    -- Fallback text: original time with timezone
    local fallback = string.format("%s %s %s", date_str, time_str, tz_str or "UTC")

    -- Unique element ID
    counter = counter + 1
    local id = "localtime-" .. counter

    local html = string.format(JS_TEMPLATE, id, utc_iso, fallback, id)
    return pandoc.RawInline("html", html)
  end
}
