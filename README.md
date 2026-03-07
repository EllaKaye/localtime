# localtime

A Quarto shortcode extension for displaying times in the reader's local timezone.

## Installation

```bash
quarto add EllaKaye/localtime
```

## Usage

```
{{< localtime YYYY-MM-DD HH:MM TZ >}}
```

Where:
- `YYYY-MM-DD` is the date
- `HH:MM` is the time (24-hour format)
- `TZ` is the source timezone (abbreviation or offset)

### Examples

| Shortcode | Example output |
|---|---|
| `{{< localtime 2026-01-30 13:00 UTC >}}` | `2026-01-30 13:00` (UTC), `2026-01-30 14:00` (CET), `2026-01-30 08:00` (EST) |
| `{{< localtime 2026-01-30 13:00 EST >}}` | `2026-01-30 18:00` (UTC), `2026-01-30 19:00` (CET), `2026-01-30 13:00` (EST) |
| `{{< localtime 2026-01-30 09:00 CET >}}` | `2026-01-30 08:00` (UTC), `2026-01-30 03:00` (EST), `2026-01-30 17:00` (JST) |
| `{{< localtime 2026-01-30 13:00 +05:30 >}}` | `2026-01-30 07:30` (UTC), `2026-01-30 08:30` (CET), `2026-01-30 02:30` (EST) |

The timezone argument describes where the *input* time is, not an offset to apply to it. For example, `{{< localtime 2026-01-30 13:00 EST >}}` means "this event is at 13:00 Eastern time" — so a reader in UTC (UK) sees `2026-01-30 18:00`, because EST is 5 hours behind UTC. Equivalently, `{{< localtime 2026-01-30 13:00 -05:00 >}}` produces the same result.

The shortcode renders the time in `YYYY-MM-DD HH:MM` format in the reader's local timezone, using JavaScript. If JavaScript is disabled, the original time and timezone are shown as a fallback.

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

Also supported: `WET`, `WEST`, `BRT`, `BRST`, `ART`, `UYT`, `COT`, `PET`, `ECT`, `VET`, `BOT`, `AMT`, `GYT`, `CLT`, `CLST`, `PYT`, `PYST`, `SRT`, `WAT`, `CAT`, `SAST`, `EAT`, `MSK`, `TRT`, `IDT`, `IRST`, `IRDT`, `GST`, `AZT`, `AFT`, `PKT`, `UZT`, `SLST`, `NPT`, `BDT`, `BTT`, `MMT`, `ICT`, `WIB`, `HOVT`, `HKT`, `SGT`, `MYT`, `PHT`, `WITA`, `AWST`, `KST`, `WIT`, `TLT`, `ACST`, `ACDT`, `LHST`, `LHDT`, `SBT`, `NCT`, `NFT`, `FJT`, `TOT`, `LINT`, `SST`, `MART`, `GAMT`.

Where an abbreviation is ambiguous, the most widely-used interpretation is chosen (e.g. `IST` = India Standard Time +05:30). For any timezone not in either list, use an offset directly (e.g. `+05:30`, `UTC+8`, `-03:00`).

**Offset formats** (any timezone):

- `+05:30`, `-08:00`
- `+0530`, `-0800`
- `UTC+5`, `UTC-8`, `UTC+5:30`
- `GMT+1`, `GMT-5`
- `+5`, `-8`
