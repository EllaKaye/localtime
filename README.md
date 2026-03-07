# localtime

A Quarto shortcode extension for displaying times in the reader's local timezone.

## Installation

```bash
quarto add ellakaye/localtime
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

The shortcode renders the time in `YYYY-MM-DD HH:MM` format in the reader's local timezone, using JavaScript. If JavaScript is disabled, the original time and timezone are shown as a fallback.

## Supported timezones

**Common abbreviations:**

| Abbreviation | Offset |
|---|---|
| UTC, GMT | +00:00 |
| EST | -05:00 |
| EDT | -04:00 |
| CST | -06:00 |
| CDT | -05:00 |
| MST | -07:00 |
| MDT | -06:00 |
| PST | -08:00 |
| PDT | -07:00 |
| CET | +01:00 |
| CEST | +02:00 |
| BST | +01:00 |
| JST | +09:00 |
| AEST | +10:00 |
| AEDT | +11:00 |
| NZST | +12:00 |
| NZDT | +13:00 |

**Offset formats:**

- `+05:30`, `-08:00`
- `+0530`, `-0800`
- `UTC+5`, `UTC-8`, `UTC+5:30`
- `GMT+1`, `GMT-5`
- `+5`, `-8`
