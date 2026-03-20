# localtime

A Quarto shortcode extension for displaying times in the reader's local timezone.

## Installation

```bash
quarto add EllaKaye/localtime
```

## Dependency

This extension loads [Luxon](https://moment.github.io/luxon/) from the jsDelivr CDN (~24 KB gzipped) to handle timezone conversion and date formatting in the browser. Readers will need an internet connection when viewing pages that use this extension.

## Usage

```
{{< localtime YYYY-MM-DD HH:MM TZ >}}
{{< localtime YYYY-MM-DD HH:MM TZ format="..." >}}
```

Where:
- `YYYY-MM-DD` is the date
- `HH:MM` is the time in 24-hour format, **or** `H:MMam` / `H:MM PM` for 12-hour format
  (am/pm is required for 12-hour; if omitted, 24-hour is assumed)
- `TZ` is the source timezone (abbreviation, IANA name, or offset) — see [Supported timezones](#supported-timezones) below
- `format` (optional) controls the output format — see [Format strings](#format-strings) below

### Examples

| Shortcode | Example output |
|---|---|
| `{{< localtime 2026-01-30 13:00 UTC >}}` | `2026-01-30 13:00` (UTC), `2026-01-30 14:00` (CET), `2026-01-30 08:00` (EST) |
| `{{< localtime 2026-01-30 13:00 EST >}}` | `2026-01-30 18:00` (UTC), `2026-01-30 19:00` (CET), `2026-01-30 13:00` (EST) |
| `{{< localtime 2026-01-30 1:00pm EST >}}` | same output as `13:00 EST` above |
| `{{< localtime 2026-01-30 09:00 CET >}}` | `2026-01-30 08:00` (UTC), `2026-01-30 03:00` (EST), `2026-01-30 17:00` (JST) |
| `{{< localtime 2026-01-30 13:00 -05:00 >}}` | `2026-01-30 18:00` (UTC), `2026-01-30 19:00` (CET), `2026-01-30 10:00` (PST) |
| `{{< localtime 2026-01-30 13:00 America/New_York >}}` | same output as `13:00 EST` above |
| `{{< localtime 2026-01-30 13:00 UTC format="full" >}}` | `Friday, 30 January 2026 at 13:00 GMT` (UTC), `Friday, 30 January 2026 at 14:00 CET` (CET), `Friday, 30 January 2026 at 8:00 EST` (EST) |
| `{{< localtime 2026-01-30 13:00 UTC format="%d %B at %H:%M" >}}` | `30 January at 13:00` (UTC), `30 January at 14:00` (CET), `30 January at 08:00` (EST) |

The timezone argument describes where the *input* time is, not an offset to apply to it. For example, `{{< localtime 2026-01-30 13:00 EST >}}` means "this event is at 13:00 Eastern time" — so a reader in GMT (UK) sees `2026-01-30 18:00`, because EST is 5 hours behind GMT. Equivalently, `{{< localtime 2026-01-30 13:00 -05:00 >}}` or `{{< localtime 2026-01-30 13:00 America/New_York >}}` produce the same result.

The shortcode renders the time in the reader's local timezone using JavaScript. If JavaScript is disabled, the original time and timezone are shown as a fallback (the `format` argument has no effect in this case — the fallback always shows the full original datetime).

## 12-hour time input

The time argument can be given in 12-hour format by appending `am` or `pm`.
`am`/`pm` is **case-insensitive** (`am`, `AM`, `Am` are all accepted) and a space before it is optional:

```
{{< localtime 2026-01-30 1:00pm EST >}}
{{< localtime 2026-01-30 1:00 PM EST >}}
{{< localtime 2026-01-30 01:00AM UTC >}}
```

- `12:00am` is treated as midnight (00:00).
- `12:00pm` is treated as noon (12:00).
- If no `am`/`pm` is given, 24-hour format is assumed.

## Format strings

Use the optional `format` named argument to control how the date and time are displayed.

### Presets

| Preset | Format string | Example output |
|--------|--------------|----------------|
| `datetime` | `%Y-%m-%d %H:%M` | `2026-01-30 18:00` |
| `date` | `%Y-%m-%d` | `2026-01-30` |
| `time` | `%H:%M` | `18:00` |
| `time12` | `%-I:%M%P` | `6:00pm` |
| `datetime12` | `%Y-%m-%d %-I:%M%P` | `2026-01-30 6:00pm` |
| `full` | `%A, %-d %B %Y at %H:%M %Z` | `Friday, 30 January 2026 at 18:00 GMT` |
| `full12` | `%A, %-d %B %Y at %-I:%M%P %Z` | `Friday, 30 January 2026 at 6:00pm GMT` |

If no `format` is given, `datetime` is used. The `12` variants use 12-hour clock with no leading zero and lowercase am/pm (e.g. `1:00pm`). For uppercase AM/PM or zero-padding, use a custom format string with `%p` and `%I`.

```
{{< localtime 2026-01-30 13:00 EST format="full" >}}
```

### Custom format tokens

| Token | Meaning | Example |
|-------|---------|---------|
| `%Y` | 4-digit year | `2026` |
| `%m` | Month, 2-digit | `01` |
| `%-m` | Month, no padding | `1` |
| `%d` | Day, 2-digit | `03` |
| `%-d` | Day, no padding | `3` |
| `%H` | Hour, 24h, 2-digit | `08` |
| `%-H` | Hour, 24h, no padding | `8` |
| `%I` | Hour, 12h, 2-digit | `08` |
| `%-I` | Hour, 12h, no padding | `8` |
| `%M` | Minutes, 2-digit | `00` |
| `%-M` | Minutes, no padding | `0` |
| `%p` | AM/PM, uppercase | `PM` |
| `%P` | AM/PM, lowercase | `pm` |
| `%B` | Full month name (locale-aware) | `January` |
| `%b` | Abbreviated month name (locale-aware) | `Jan` |
| `%A` | Full day name (locale-aware) | `Friday` |
| `%a` | Abbreviated day name (locale-aware) | `Fri` |
| `%Z` | Local timezone abbreviation | `GMT` |

The `-` flag removes zero-padding (e.g. `%-H` gives `8` instead of `08`). `%p` gives uppercase `AM`/`PM`; `%P` gives lowercase `am`/`pm`. Month/day names (`%B`, `%b`, `%A`, `%a`) are rendered in the reader's browser locale. `%Z` shows the reader's local timezone abbreviation.

```
{{< localtime 2026-01-30 13:00 EST format="%-d %B %Y at %-I:%M %p (%Z)" >}}
```

## Supported timezones

Three formats are accepted:

### Common abbreviations

| Abbreviation | Offset |
|---|---|
| UTC, GMT | +00:00 |
| NST / NDT | -03:30 / -02:30 |
| AST / ADT | -04:00 / -03:00 |
| EST / EDT | -05:00 / -04:00 |
| CST / CDT | -06:00 / -05:00 |
| MST / MDT | -07:00 / -06:00 |
| PST / PDT | -08:00 / -07:00 |
| AKST / AKDT | -09:00 / -08:00 |
| HST / HDT | -10:00 / -09:00 |
| BST | +01:00 |
| CET / CEST | +01:00 / +02:00 |
| EET / EEST | +02:00 / +03:00 |
| IST | +05:30 |
| JST | +09:00 |
| AEST / AEDT | +10:00 / +11:00 |
| NZST / NZDT | +12:00 / +13:00 |

Also supported: `WET`, `WEST`, `BRT`, `BRST`, `ART`, `UYT`, `COT`, `PET`, `ECT`, `VET`, `BOT`, `AMT`, `GYT`, `CLT`, `CLST`, `PYT`, `PYST`, `SRT`, `WAT`, `CAT`, `SAST`, `EAT`, `MSK`, `TRT`, `IDT`, `IRST`, `IRDT`, `GST`, `AZT`, `AFT`, `PKT`, `UZT`, `SLST`, `NPT`, `BDT`, `BTT`, `MMT`, `ICT`, `WIB`, `HOVT`, `HKT`, `SGT`, `MYT`, `PHT`, `WITA`, `AWST`, `KST`, `WIT`, `TLT`, `ACST`, `ACDT`, `LHST`, `LHDT`, `SBT`, `NCT`, `NFT`, `FJT`, `TOT`, `LINT`, `SST`, `WST`, `MART`, `GAMT`.

Where an abbreviation is ambiguous, the most widely-used interpretation is chosen (e.g. `IST` = India Standard Time +05:30).

### IANA timezone names

Any [IANA timezone name](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) is accepted directly:

```
{{< localtime 2026-01-30 13:00 America/New_York >}}
{{< localtime 2026-01-30 09:00 Europe/Paris >}}
{{< localtime 2026-07-15 10:00 Australia/Sydney >}}
```

IANA names are unambiguous (unlike abbreviations such as `IST`) and precisely identify the timezone including its DST rules.

### UTC offsets

- `+05:30`, `-08:00`
- `+0530`, `-0800`
- `UTC+5`, `UTC-8`, `UTC+5:30`
- `GMT+1`, `GMT-5`
- `+5`, `-8`

## Daylight Saving Time (DST)

DST is handled automatically in the reader's browser. Common abbreviations that observe DST (e.g. `EST`, `CET`) are mapped to their IANA timezone (e.g. `America/New_York`, `Europe/Paris`), and the browser applies the correct offset for each specific date — so writing `EST` for a summer date correctly uses the EDT offset (-04:00), and `CET` for a summer date correctly uses CEST (+02:00). No build-time configuration or explicit DST/standard pair is required.

**Caveats:**

- **MST / Arizona**: Arizona does not observe DST and uses MST (-07:00) year-round. `MST` maps to `America/Denver` which does observe DST, so summer dates would use MDT (-06:00). If you are specifying an Arizona time, use `UTC-7` or `-07:00` directly.
- **AEST / Queensland**: Queensland does not observe DST and uses AEST (+10:00) year-round. `AEST` maps to `Australia/Sydney` which observes DST. Use `UTC+10` or `+10:00` directly for Queensland times.

## Example

Here is the source code for some examples: [example.qmd](example.qmd)

Rendered output: <https://ellakaye.github.io/localtime>

## Notes

This extension was written by Claude Code.

I developed it primarily for use on [rainbowR's meet-ups](https://rainbowr.org/meetups) page.

I got the idea after learning about hammertime in Discord.
