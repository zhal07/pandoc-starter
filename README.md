# pandoc-starter - Markdown + Pandoc documentation system

A general-purpose document creation system using Markdown and Pandoc + LaTeX. Write any document in plain Markdown, generate professional PDFs, HTML, DOCX, and TXT outputs.

Supported document types:
- **resume**
- **cover letter**
- **letter**
- **report**
- **article**
- **presentation**
- **invoice**
- **meeting notes**
- **technical documentation**

---

## Quick Start

```bash
./setup.sh          # install dependencies (first time only)
make resume         # build resume in all formats (pdf, html, docx, txt, pdf-ats, docx-ats)
make invoice        # shortcut for any type. No SRC= needed
make build-all      # build every document under documents/
make list           # see all documents
make help           # see all commands
```

See [Creating Documents](help/creating-documents.md) for a step-by-step guide.

---

## Usage

Specific builds require a `SRC` pointing to a Markdown file:

```bash
make pdf  SRC=documents/reports/quarterly.md
make html SRC=documents/cover-letters/sample-cover-letter.md
make all  SRC=documents/articles/my-essay.md
```

### Available formats

| Command         | Output                                           |
| --------------- | ------------------------------------------------ |
| `make pdf`      | PDF via XeLaTeX                                  |
| `make html`     | Standalone HTML                                  |
| `make docx`     | Word document                                    |
| `make txt`      | Plain text                                       |
| `make all`      | All of the above                                 |
| `make pdf-ats`  | ATS-optimized PDF, black/white (resume only)     |
| `make docx-ats` | ATS-optimized DOCX, hyphen bullets (resume only) |

### Per-type shortcuts

Each document type has a shortcut that builds all formats for its sample file. No `SRC=` needed:

```bash
make resume          # pdf, html, docx, txt + pdf-ats, docx-ats
make cover-letter
make letter
make article
make report
make invoice
make meeting-notes
make technical
make presentation    # pdf + html only
```

### Batch builds

Build every `.md` file under a specific subdirectory (output mirrors the full path):

```bash
make build-dir DIR=documents/invoices/Acme-Corp
make build-dir DIR=documents/resumes/2026
```

Build everything under `documents/` at once:

```bash
make build-all
```

Output always mirrors the source path. Nested subdirectories are created automatically:

```
documents/invoices/Acme-Corp/jan-2026.md  →  output/invoices/Acme-Corp/jan-2026.pdf
documents/resumes/2026/my-resume.md       →  output/resumes/2026/my-resume.pdf
```

---

## How it works

Every `.md` source file declares its `type` in YAML frontmatter. The build system reads that field, selects the matching template from `templates/`, and applies the appropriate pandoc options automatically.

```
documents/reports/q1.md   →  Makefile reads type: report
                          →  selects templates/latex/report.tex
                          →  pandoc + xelatex
                          →  output/reports/q1.pdf
```

If no type-specific template exists, the build falls back to `templates/latex/default.tex`.

---

## Directory Structure

```
pandoc-starter/
├── documents/                 ← Your source .md files
│   ├── resumes/
│   ├── cover-letters/
│   ├── letters/
│   ├── reports/
│   ├── articles/
│   ├── presentations/
│   ├── invoices/
│   ├── meeting-notes/
│   └── technical/
├── templates/
│   ├── latex/                 ← LaTeX templates for PDF output
│   ├── html/                  ← HTML templates
│   └── txt/                   ← Plain text templates
├── filters/                   ← Lua filters for pandoc
├── assets/
│   ├── csl/                   ← Citation Style Language files
│   └── bibliography/          ← Shared .bib files
├── output/                    ← Generated files (auto-created, mirrors documents/ including subdirs)
├── help/                      ← Detailed guides on specific topics
├── Makefile
├── setup.sh
├── verify.sh
└── README.md
```

---

## Document Types

### `resume`

```yaml
---
type: resume
author: Your Name
email: you@example.com
phone: '+1 555 123 4567'
location: City, Country
linkedin: linkedin.com/in/yourprofile   # optional
github: github.com/yourusername         # optional
website: yourwebsite.com                # optional
nationality: American                   # optional
---
```

PDF variants:
- `make pdf` : Visual PDF (color, icons, for recruiter handoff)
- `make pdf-ats` : ATS-optimized PDF (black/white, machine-readable)
- `make docx-ats` : ATS-optimized DOCX (hyphen bullets, maximum compatibility)

---

### `cover-letter`

```yaml
---
type: cover-letter
author: Your Name
email: you@example.com
phone: '+1 555 123 4567'
location: City, Country
company: Company Name
position: Job Title
date: March 2026
recipient: Hiring Manager Name       # optional
recipient-title: Director            # optional
website: yourwebsite.com             # optional
linkedin: linkedin.com/in/yourprofile # optional
---
```

---

### `letter`

```yaml
---
type: letter
author: Your Name
email: you@example.com
date: March 25, 2026
recipient: John Smith
recipient-title: Director of Operations   # optional
recipient-company: Acme Corp              # optional
recipient-address: "123 Main St, City"    # optional
subject: Regarding your proposal          # optional
closing: Best regards                     # optional, default: Sincerely
---
```

---

### `report`

```yaml
---
type: report
title: Quarterly Business Review
subtitle: Q1 2026                  # optional
author: Your Name
date: March 2026
organization: Acme Corp            # optional
abstract: |                        # optional
  A brief summary of this report.
toc: true                          # table of contents
numbersections: true               # numbered headings
papersize: a4                      # optional, default: letter
bibliography: assets/bibliography/refs.bib   # optional
---
```

---

### `article`

```yaml
---
type: article
title: My Article Title
author: Your Name
date: March 2026
abstract: |                        # optional
  A short abstract.
toc: false
bibliography: assets/bibliography/refs.bib   # optional
---
```

---

### `presentation`

```yaml
---
type: presentation
title: My Presentation
author: Your Name
date: March 2026
theme: metropolis                  # beamer theme (default: default)
---
```

- `make pdf` → Beamer PDF slides
- `make html` → reveal.js interactive slides

Slide breaks: use `---` (horizontal rule) or `##` level-2 headings.

Speaker notes: wrap in `::: notes` fenced divs:

```markdown
::: notes
These are speaker notes only visible in presenter mode.
:::
```

See [Presentations Guide](help/presentations.md) for columns, incremental lists, themes, and images.

---

### `invoice`

```yaml
---
type: invoice
author: Your Name
email: you@example.com
phone: '+1 555 123 4567'
address: "123 Your Street, City, Country"
date: March 25, 2026
invoice-number: INV-2026-001
due-date: April 25, 2026
client: Client Company Name
client-address: "456 Client Ave, City, Country"
items:
  - description: Web Design & Development
    quantity: 1
    rate: "$5,000"
    amount: "$5,000"
  - description: Monthly Maintenance
    quantity: 3
    rate: "$500"
    amount: "$1,500"
subtotal: "$6,500"
tax-rate: "15%"
tax-amount: "$975"
total: "$7,475"
notes: Payment due within 30 days. Bank transfer preferred.   # optional
---
```

---

### `meeting-notes`

```yaml
---
type: meeting-notes
title: Project Kickoff
date: March 25, 2026
attendees:
  - Alice (Product)
  - Bob (Engineering)
  - Carol (Design)
location: Conference Room B           # optional
---
```

Document body typically uses:
- `## Agenda` section
- `## Discussion` section
- `## Action Items` section (bullet list)

---

### `technical`

```yaml
---
type: technical
title: API Reference Guide
author: Your Name
date: March 2026
version: "2.1.0"
toc: true
numbersections: true
bibliography: assets/bibliography/refs.bib   # optional
---
```

Supports admonition blocks via the `filters/admonition.lua` filter:

```markdown
::: note
This is an informational note.
:::

::: warning
This is a warning.
:::

::: tip
This is a helpful tip.
:::
```

---

## Citations

Add `bibliography: path/to/refs.bib` to your frontmatter. The Makefile automatically enables `--citeproc` and uses `assets/csl/default.csl` (APA style by default).

In your document, cite with `[@authorYEAR]`. References render at the end automatically.

To use a different citation style, swap the CSL file or specify a different one in frontmatter:

```yaml
bibliography: assets/bibliography/refs.bib
csl: assets/csl/chicago-author-date.csl
```

CSL files are available from [Zotero's style repository](https://www.zotero.org/styles).

See [Citations Guide](help/citations.md) for BibTeX format, .bib file examples, and citation syntax.

---

## Per-Document Options

These frontmatter fields are honored by most templates:

| Field            | Default  | Description               |
| ---------------- | -------- | ------------------------- |
| `papersize`      | `letter` | `letter` or `a4`          |
| `fontsize`       | `11pt`   | e.g. `10pt`, `12pt`       |
| `toc`            | `false`  | Include table of contents |
| `numbersections` | `false`  | Number section headings   |
| `bibliography`   | —        | Path to `.bib` file       |
| `csl`            | APA 7th  | Path to `.csl` style file |

---

## Dependencies

| Package                     | Purpose                         | Required    |
| --------------------------- | ------------------------------- | ----------- |
| `pandoc`                    | Document converter              | Yes         |
| `texlive-xetex`             | PDF generation                  | Yes         |
| `texlive-fonts-recommended` | Standard TeX fonts              | Yes         |
| `texlive-fonts-extra`       | Extended fonts (TeX Gyre, etc.) | Yes         |
| `texlive-latex-extra`       | Additional LaTeX packages       | Yes         |
| `lua5.4`                    | Lua filters (admonition, etc.)  | Yes         |
| `make`                      | Build automation                | Recommended |

Run `./setup.sh` to install all dependencies automatically.

---

## Troubleshooting

**Font not found (XeLaTeX)**
```bash
sudo apt install texlive-fonts-extra fonts-texgyre
fc-cache -fv
```

**PDF generation fails**
```bash
make pdf SRC=documents/resumes/sample-resume.md   # check error output
xelatex --version                          # verify xelatex is installed
```

**Type not detected**
Ensure your `.md` file has `type: <typename>` in its YAML frontmatter block.

**YAML multiline values / quoted strings**
If a frontmatter value contains colons, special characters, or spans multiple lines, wrap it in quotes or use a block scalar:
```yaml
recipient-address: "123 Main St, Suite 4"   # quotes for values with commas/colons
abstract: |
  This is a multi-line
  abstract value.
```
The YAML parser is line-based. Unquoted values that contain `:` will cause a parse error.

**Run a full system check**
```bash
./verify.sh           # check dependencies and templates
./verify.sh --build   # also run a smoke-test build
```

---

## Further Reading

| Guide                                                  | Description                                                               |
| ------------------------------------------------------ | ------------------------------------------------------------------------- |
| [Creating Documents](help/creating-documents.md)       | Starting new documents, frontmatter tips, YAML syntax                     |
| [Presentations](help/presentations.md)                 | Beamer/reveal.js slides, columns, themes, speaker notes                   |
| [Citations](help/citations.md)                         | BibTeX files, citation syntax, changing CSL styles                        |
| [Customizing Templates](help/customizing-templates.md) | Pandoc template syntax, modifying fonts/colors/layout, creating new types |
| [Markdown Features](help/markdown-features.md)         | Math, images, tables, footnotes, admonitions, code blocks                 |
| [Output Formats](help/output-formats.md)               | PDF, HTML, DOCX, TXT, ATS variants — format-specific behavior             |
