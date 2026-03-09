# Planned improvements

## Bug fix

### `%Z` crash in JavaScript

In the JavaScript template (`localtime.lua` line 196), the code calls `.find(...).value` to get the reader's timezone abbreviation. If `.find()` returns `undefined` (which can happen in some environments), calling `.value` on it throws a `TypeError` and crashes the script for that shortcode — leaving the fallback text visible.

**Fix:** split into two steps with a null check:
```js
var tzPart = ...find(function(p){return p.type==='timeZoneName';});
var tz = tzPart ? tzPart.value : '';
```

---

## Code improvements

### Duplicate default format string

The default format `%Y-%m-%d %H:%M` is hardcoded in two places: once in the Lua (line 247) and once in the JavaScript template. The Lua copy is actually never used — `data-format` is always set on the HTML element, so the JavaScript `||` fallback never fires. If the default is ever changed, it would need updating in two places.

**Fix:** set `fmt_attr = ""` in Lua when no `format` kwarg is given. The JavaScript `||` fallback then handles the default, and the format string lives in one place only.

### Input range validation

The Lua code validates that dates and times *look right* (via regex) but doesn't check that values are in range. Month `13`, day `32`, hour `25`, or minute `99` all pass silently. The arithmetic still works (the normalization handles overflow), but the document author gets no warning that something is wrong.

**Fix:** add `io.stderr:write` warnings after parsing for out-of-range values (month 1–12, day 1–31, hour 0–23, minute 0–59). The shortcode would still render — just with a warning in the terminal during `quarto render`.

---

## Documentation gaps

### `WST` missing from README

`WST = -660` (West Samoa Standard Time, historical) is in the Lua timezone table but absent from the README's "Also supported" abbreviations list.

**Fix:** add `WST` to the list.

### Fallback text ignores `format`

When JavaScript is disabled, the fallback text always shows the original datetime and timezone (e.g. `2026-01-30 13:00 UTC`), regardless of any `format` kwarg. This is intentional (more information is better when JS is off), but it isn't documented.

**Fix:** add a brief note to the README clarifying this behaviour.

---

## Things considered but not worth changing

- **IE11 compatibility** — IE reached end of life in 2022; not worth special-casing.
- **Seconds precision** — minute-level granularity is appropriate for events.
- **DST awareness** — proper DST support would require shipping a full IANA timezone database, which is massive scope creep. The static offsets are correct for the intended use case (author specifies a known offset for a known event).
- **ID counter collisions** — the incremental `localtime-1`, `localtime-2`, … IDs are not truly globally unique, but collisions are not a real risk in normal Quarto use.
