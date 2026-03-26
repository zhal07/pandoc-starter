# Creating Documents

## From a sample

The fastest way to start is to copy an existing sample:

```bash
cp documents/reports/sample-report.md documents/reports/my-report.md
```

Open the new file and edit the YAML frontmatter and body content. Build it:

```bash
make pdf SRC=documents/reports/my-report.md
```

Every document type has a sample in its `documents/` subdirectory. Run `make list` to see them all.

## From scratch

Create a new `.md` file in the appropriate `documents/` subdirectory. The file must start with a YAML frontmatter block:

```yaml
---
type: report
title: My Document Title
author: Your Name
date: March 2026
---

Your content starts here.
```

The `type` field is the only **required** field — it tells the build system which template to use. All other fields are type-dependent (see the README or the samples).

### Choosing the right subdirectory

Place your file in the subdirectory matching its type:

| Type            | Directory                  |
| --------------- | -------------------------- |
| `resume`        | `documents/resumes/`       |
| `cover-letter`  | `documents/cover-letters/` |
| `letter`        | `documents/letters/`       |
| `report`        | `documents/reports/`       |
| `article`       | `documents/articles/`      |
| `presentation`  | `documents/presentations/` |
| `invoice`       | `documents/invoices/`      |
| `meeting-notes` | `documents/meeting-notes/` |
| `technical`     | `documents/technical/`     |

The output directory mirrors this structure: `documents/reports/q1.md` produces `output/reports/q1.pdf`.

## Building

```bash
make pdf  SRC=documents/reports/my-report.md    # PDF only
make html SRC=documents/reports/my-report.md    # HTML only
make docx SRC=documents/reports/my-report.md    # Word only
make txt  SRC=documents/reports/my-report.md    # Plain text only
make all  SRC=documents/reports/my-report.md    # All four formats
```

## Frontmatter tips

### Multi-line values

Use `|` for multi-line text blocks like abstracts:

```yaml
abstract: |
  This is the first line of the abstract.
  This continues on a second line.
```

### Quoting strings

Quote values that contain special YAML characters (colons, commas, leading `+`):

```yaml
phone: '+1 555 123 4567'
address: "123 Main St, Suite 200, City"
```

### Lists

Use `- item` syntax for list fields like attendees or invoice items:

```yaml
attendees:
  - Alice (Product)
  - Bob (Engineering)
```

### Nested lists

Invoice items use nested key-value pairs:

```yaml
items:
  - description: Web Development
    quantity: 1
    rate: "$5,000"
    amount: "$5,000"
```

## The type fallback

If the build system can't find a template matching your `type`, it falls back to the `default` template. This means you can set `type: default` (or any unrecognized type) and still get a clean, generic document with title, author, date, and body text.

## Further reading

- [Markdown Features](markdown-features.md) — math, images, tables, footnotes, and other syntax available in all document types
- [Output Formats](output-formats.md) — format-specific behavior for PDF, HTML, DOCX, and TXT
