# localtime

A Quarto shortcode extension for displaying times in the reader's local timezone.

## Installation

```bash
quarto add EllaKaye/localtime
```

## Usage

```
{{< localtime YYYY-MM-DD HH:MM TZ >}}
{{< localtime YYYY-MM-DD HH:MM TZ format="..." >}}
```

Where:
- `YYYY-MM-DD` is the date
- `HH:MM` is the time (24-hour format)
- `TZ` is the source timezone (abbreviation or offset) - see [Supported timezones](#supported-timezones) below
- `format` (optional) controls the output format — see [Format strings](#format-strings) below

### Examples

| Shortcode | Example output |
|---|---|
| `{{< localtime 2026-01-30 13:00 UTC >}}` | `2026-01-30 13:00` (UTC), `2026-01-30 14:00` (CET), `2026-01-30 08:00` (EST) |
| `{{< localtime 2026-01-30 13:00 EST >}}` | `2026-01-30 18:00` (UTC), `2026-01-30 19:00` (CET), `2026-01-30 13:00` (EST) |
| `{{< localtime 2026-01-30 09:00 CET >}}` | `2026-01-30 08:00` (UTC), `2026-01-30 03:00` (EST), `2026-01-30 17:00` (JST) |
| `{{< localtime 2026-01-30 13:00 -05:00 >}}` | `2026-01-30 18:00` (UTC), `2026-01-30 19:00` (CET), `2026-01-30 10:00` (PST) |
| `{{< localtime 2026-01-30 13:00 UTC format="full" >}}` | `Friday, 30 January 2026 at 13:00 GMT` (UTC), `Friday, 30 January 2026 at 14:00 CET` (CET), `Friday, 30 January 2026 at 08:00 EST` (EST) |
| `{{< localtime 2026-01-30 13:00 UTC format="%d %B at %H:%M" >}}` | `30 January at 13:00` (UTC), `30 January at 14:00` (CET), `30 January at 08:00` (EST) |

The timezone argument describes where the *input* time is, not an offset to apply to it. For example, `{{< localtime 2026-01-30 13:00 EST >}}` means "this event is at 13:00 Eastern time" — so a reader in GMT (UK) sees `2026-01-30 18:00`, because EST is 5 hours behind GMT. Equivalently, `{{< localtime 2026-01-30 13:00 -05:00 >}}` produces the same result.

The shortcode renders the time in the reader's local timezone using JavaScript. If JavaScript is disabled, the original time and timezone are shown as a fallback (the `format` argument has no effect in this case — the fallback always shows the full original datetime).

## Format strings

Use the optional `format` named argument to control how the date and time are displayed.

### Presets

| Preset | Format string | Example output |
|--------|--------------|----------------|
| `datetime` | `%Y-%m-%d %H:%M` | `2026-01-30 18:00` |
| `date` | `%Y-%m-%d` | `2026-01-30` |
| `time` | `%H:%M` | `18:00` |
| `time12` | `%I:%M %p` | `06:00 PM` |
| `full` | `%A, %d %B %Y at %H:%M %Z` | `Friday, 30 January 2026 at 18:00 GMT` |

If no `format` is given, `datetime` is used (current behavior, unchanged).

```
{{< localtime 2026-01-30 13:00 EST format="full" >}}
```

### Custom format tokens

| Token | Meaning | Example |
|-------|---------|---------|
| `%Y` | 4-digit year | `2026` |
| `%m` | 2-digit month | `01` |
| `%d` | 2-digit day | `30` |
| `%H` | Hour, 24h, 2-digit | `18` |
| `%I` | Hour, 12h, 2-digit | `06` |
| `%M` | Minutes, 2-digit | `00` |
| `%p` | AM/PM | `PM` |
| `%B` | Full month name (locale-aware) | `January` |
| `%b` | Abbreviated month name (locale-aware) | `Jan` |
| `%A` | Full day name (locale-aware) | `Friday` |
| `%a` | Abbreviated day name (locale-aware) | `Fri` |
| `%Z` | Local timezone abbreviation | `GMT` |

Month/day names (`%B`, `%b`, `%A`, `%a`) are rendered in the reader's browser locale. `%Z` shows the reader's local timezone abbreviation.

```
{{< localtime 2026-01-30 13:00 EST format="%d %B %Y at %I:%M %p (%Z)" >}}
```

## Supported timezones

**Common abbreviations:**

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

Where an abbreviation is ambiguous, the most widely-used interpretation is chosen (e.g. `IST` = India Standard Time +05:30). For any timezone not in either list, use an offset directly (e.g. `+05:30`, `UTC+8`, `-03:00`).

### Daylight Saving Time (DST) auto-correction

For the following timezone pairs, the extension automatically applies the correct offset based on the date. You can write `CET` for a summer date and it will use CEST (+02:00) automatically — a build-time note is printed to the terminal when this happens.

| Standard | DST | Standard offset | DST offset |
|---|---|---|---|
| CET | CEST | +01:00 | +02:00 |
| WET | WEST | +00:00 | +01:00 |
| EET | EEST | +02:00 | +03:00 |
| EST | EDT | -05:00 | -04:00 |
| CST | CDT | -06:00 | -05:00 |
| MST | MDT | -07:00 | -06:00 |
| PST | PDT | -08:00 | -07:00 |
| AKST | AKDT | -09:00 | -08:00 |
| AEST | AEDT | +10:00 | +11:00 |
| NZST | NZDT | +12:00 | +13:00 |

**Caveats:**

- **MST / Arizona**: Arizona does not observe DST and uses MST year-round. If you are specifying an Arizona time, use `+07:00` directly instead of `MST` to avoid auto-correction to MDT in summer.
- **AEST / Queensland**: Queensland does not observe DST and uses AEST year-round. Use `+10:00` directly to avoid auto-correction to AEDT in summer.
- **Explicit wrong-season abbreviation**: If you write the DST abbreviation (e.g. `CEST`) for a date that is not in DST, a warning is emitted at build time but the specified offset is used (your explicit choice is honoured).

**Offset formats** (any timezone):

- `+05:30`, `-08:00`
- `+0530`, `-0800`
- `UTC+5`, `UTC-8`, `UTC+5:30`
- `GMT+1`, `GMT-5`
- `+5`, `-8`

## Example

Here is the source code for some examples: [example.qmd](example.qmd)

Rendered output: <https://ellakaye.github.io/localtime>

## Notes

This extension was written by Claude Code. 

I developed it primarily for use on [rainbowR's meet-ups](https://rainbowr.org/meetups) page.

I got the idea after learning about hammertime in Discord.