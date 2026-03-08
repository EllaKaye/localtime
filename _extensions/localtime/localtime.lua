-- localtime.lua
-- Quarto shortcode extension to display times in the reader's local timezone.
-- Usage: {{< localtime YYYY-MM-DD HH:MM TZ >}}

local counter = 0

-- Timezone abbreviations mapped to UTC offset in minutes.
-- Where an abbreviation is ambiguous, the most widely-used interpretation is chosen.
local TZ_OFFSETS = {
  -- Universal
  UTC = 0, GMT = 0,

  -- North America
  NST = -210, NDT = -150,       -- Newfoundland
  AST = -240, ADT = -180,       -- Atlantic
  EST = -300, EDT = -240,       -- Eastern
  CST = -360, CDT = -300,       -- Central
  MST = -420, MDT = -360,       -- Mountain
  PST = -480, PDT = -420,       -- Pacific
  AKST = -540, AKDT = -480,     -- Alaska
  HST = -600, HDT = -540,       -- Hawaii

  -- South America
  VET = -240,                   -- Venezuela
  BOT = -240,                   -- Bolivia
  PYT = -240,                   -- Paraguay Standard
  CLT = -240,                   -- Chile Standard
  AMT = -240,                   -- Amazon (Brazil)
  GYT = -240,                   -- Guyana
  COT = -300,                   -- Colombia
  PET = -300,                   -- Peru
  ECT = -300,                   -- Ecuador
  BRT = -180,                   -- Brasilia
  ART = -180,                   -- Argentina
  UYT = -180,                   -- Uruguay
  SRT = -180,                   -- Suriname
  PYST = -180,                  -- Paraguay Summer
  CLST = -180,                  -- Chile Summer
  BRST = -120,                  -- Brasilia Summer

  -- Europe
  WET = 0, WEST = 60,           -- Western Europe
  BST = 60,                     -- British Summer
  CET = 60, CEST = 120,         -- Central Europe
  EET = 120, EEST = 180,        -- Eastern Europe
  MSK = 180,                    -- Moscow
  TRT = 180,                    -- Turkey

  -- Africa
  WAT = 60,                     -- West Africa
  CAT = 120,                    -- Central Africa
  SAST = 120,                   -- South Africa Standard
  EAT = 180,                    -- East Africa

  -- Middle East
  IDT = 180,                    -- Israel Daylight (Israel Standard = +02:00, use UTC+2)
  IRST = 210,                   -- Iran Standard
  IRDT = 270,                   -- Iran Daylight

  -- Asia
  GST = 240,                    -- Gulf
  AZT = 240,                    -- Azerbaijan
  AFT = 270,                    -- Afghanistan
  PKT = 300,                    -- Pakistan
  UZT = 300,                    -- Uzbekistan
  IST = 330,                    -- India Standard (most common global usage)
  SLST = 330,                   -- Sri Lanka
  NPT = 345,                    -- Nepal
  BDT = 360,                    -- Bangladesh
  BTT = 360,                    -- Bhutan
  MMT = 390,                    -- Myanmar
  ICT = 420,                    -- Indochina
  WIB = 420,                    -- Western Indonesia
  HOVT = 420,                   -- Khovd (Mongolia)
  -- CST is taken by US Central; China Standard Time users should use +08:00
  HKT = 480,                    -- Hong Kong
  SGT = 480,                    -- Singapore
  MYT = 480,                    -- Malaysia
  PHT = 480,                    -- Philippines
  WITA = 480,                   -- Central Indonesia
  AWST = 480,                   -- Australian Western Standard
  JST = 540,                    -- Japan
  KST = 540,                    -- Korea
  WIT = 540,                    -- Eastern Indonesia
  TLT = 540,                    -- Timor-Leste

  -- Australia & Pacific
  ACST = 570,                   -- Australian Central Standard
  AEST = 600, AEDT = 660,       -- Australian Eastern
  ACDT = 630,                   -- Australian Central Daylight
  LHST = 630,                   -- Lord Howe Standard
  SBT = 660,                    -- Solomon Islands
  NCT = 660,                    -- New Caledonia
  NFT = 660,                    -- Norfolk Island
  LHDT = 660,                   -- Lord Howe Daylight
  NZST = 720, NZDT = 780,       -- New Zealand
  FJT = 720,                    -- Fiji
  TOT = 780,                    -- Tonga
  LINT = 840,                   -- Line Islands
  SST = -660,                   -- Samoa Standard
  WST = -660,                   -- West Samoa Standard (historical)
  MART = -570,                  -- Marquesas
  GAMT = -540,                  -- Gambier
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

local JS_TEMPLATE = [[<span id="%s" class="localtime" data-utc="%s" data-format="%s">%s</span><script>
(function(){var el=document.getElementById('%s');var d=new Date(el.getAttribute('data-utc'));var fmt=el.getAttribute('data-format')||'%%Y-%%m-%%d %%H:%%M';var P={datetime:'%%Y-%%m-%%d %%H:%%M',date:'%%Y-%%m-%%d',time:'%%H:%%M',time12:'%%I:%%M %%p',full:'%%A, %%d %%B %%Y at %%H:%%M %%Z'};if(P[fmt])fmt=P[fmt];function pad(n){return String(n).padStart(2,'0');}var y=d.getFullYear(),mo=d.getMonth()+1,dy=d.getDate(),h=d.getHours(),mi=d.getMinutes(),h12=h%%12||12,ap=h<12?'AM':'PM';var tz=Intl.DateTimeFormat(undefined,{timeZoneName:'short'}).formatToParts(d).find(function(p){return p.type==='timeZoneName';}).value;el.textContent=fmt.replace(/%%Y/g,y).replace(/%%m/g,pad(mo)).replace(/%%d/g,pad(dy)).replace(/%%H/g,pad(h)).replace(/%%I/g,pad(h12)).replace(/%%M/g,pad(mi)).replace(/%%p/g,ap).replace(/%%B/g,new Intl.DateTimeFormat(undefined,{month:'long'}).format(d)).replace(/%%b/g,new Intl.DateTimeFormat(undefined,{month:'short'}).format(d)).replace(/%%A/g,new Intl.DateTimeFormat(undefined,{weekday:'long'}).format(d)).replace(/%%a/g,new Intl.DateTimeFormat(undefined,{weekday:'short'}).format(d)).replace(/%%Z/g,tz);})();
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

    -- Optional format argument (named kwarg)
    local fmt_attr = "%Y-%m-%d %H:%M"
    if kwargs["format"] then
      fmt_attr = pandoc.utils.stringify(kwargs["format"])
    end

    -- Unique element ID
    counter = counter + 1
    local id = "localtime-" .. counter

    local html = string.format(JS_TEMPLATE, id, utc_iso, fmt_attr, fallback, id)
    return pandoc.RawInline("html", html)
  end
}
