# Output Formats

This guide explains format-specific behavior for each output target in the build system.

---

## PDF

**Engine:** XeLaTeX (`--pdf-engine=xelatex`)

**Template selection:** The Makefile looks for `templates/latex/<type>.tex`. If not found, it falls back to `templates/latex/default.tex`.

**Frontmatter options honored:**

| Field            | Effect                              |
| ---------------- | ----------------------------------- |
| `toc: true`      | Inserts a table of contents         |
| `numbersections` | Numbers all section headings        |
| `papersize`      | `letter` (default) or `a4`          |
| `fontsize`       | `10pt`, `11pt` (default), `12pt`    |
| `bibliography`   | Enables `--citeproc` with APA style |

**Syntax highlighting** uses the `tango` style for code blocks (all types except resume and presentation).

**Math** renders natively via XeLaTeX — no extra configuration needed.

---

## HTML

**Mode:** Standalone (`--standalone`), producing a complete `<!DOCTYPE html>` file.

**Template selection:** The Makefile looks for `templates/html/<type>.html`, falling back to `templates/html/default.html`.

**MathJax** is enabled automatically for all non-resume types via `--mathjax`. Inline math (`$...$`) and display math (`$$...$$`) render in the browser.

**Frontmatter options honored:**

| Field          | Effect                           |
| -------------- | -------------------------------- |
| `toc: true`    | Inserts a `<nav id="TOC">` block |
| `bibliography` | Enables `--citeproc`             |

**Resumes** use `--wrap=none` to prevent line wrapping in the HTML source, which helps with copy-paste fidelity.

---

## DOCX

**Reference document:** If `templates/reference.docx` exists, it is passed via `--reference-doc=templates/reference.docx` to control fonts, heading styles, and spacing. This file was generated from Pandoc's built-in defaults and can be customized in Word.

**TOC support:** `toc: true` in frontmatter inserts a Word table of contents field.

**Per-type templates:** DOCX output does not use per-type templates. All types share the same reference document. Structured frontmatter fields (e.g., invoice line items, letter recipient) are not rendered in DOCX — only the body content is included.

**Citations** are processed by `--citeproc` when `bibliography` is present.

---

## TXT

Plain text output uses `--to plain` with a type-specific template when available.

**Types with dedicated TXT templates:**

| Type            | Template                          | Structured fields rendered                                                          |
| --------------- | --------------------------------- | ----------------------------------------------------------------------------------- |
| `letter`        | `templates/txt/letter.txt`        | author, address, location, email, phone, date, recipient, subject, closing          |
| `cover-letter`  | `templates/txt/cover-letter.txt`  | author, location, email, phone, date, recipient, recipient-title, company, position |
| `invoice`       | `templates/txt/invoice.txt`       | all invoice fields including line items, totals                                     |
| `meeting-notes` | `templates/txt/meeting-notes.txt` | title, date, location, attendees list                                               |
| `resume`        | `templates/txt/resume.txt`        | author, contact fields                                                              |

**Types that fall back to `default.txt`:** `report`, `article`, `technical`, `presentation`

For fallback types, only the body content is rendered — frontmatter fields like `title`, `author`, and `date` are not included in the output. Use a dedicated template if you need structured plain-text output for these types.

---

## ATS Variants (resume only)

The resume type has two additional build targets designed for applicant tracking systems:

### `make pdf-ats`

Builds a PDF using `templates/latex/resume-ats.tex` — a black-and-white, machine-readable layout with no color, no icons, and simple formatting. Use this when submitting to job portals that parse PDF text.

### `make docx-ats`

Builds a DOCX using the `filters/ats-hyphen-bullets.lua` filter, which converts bullet points to hyphen characters. Some ATS systems fail to parse Unicode bullets (`•`) correctly; hyphens are universally safe.

### When to use each variant

| Target          | Use case                                               |
| --------------- | ------------------------------------------------------ |
| `make pdf`      | Visual PDF — color, icons, for recruiter handoff       |
| `make pdf-ats`  | ATS submission — black/white, machine-readable         |
| `make docx`     | Standard Word document                                 |
| `make docx-ats` | ATS submission — hyphen bullets, maximum compatibility |

The `make resume` shortcut builds all six outputs automatically (pdf, html, docx, txt, pdf-ats, docx-ats).

---

## Presentations

Presentations use Pandoc's built-in output formats rather than custom templates:

- `make pdf` → **Beamer** PDF slides (`-t beamer --pdf-engine=xelatex`)
- `make html` → **reveal.js** interactive slides (`-t revealjs`)

There are no editable template files in `templates/` for presentations. Styling is controlled via:

- **Beamer**: the `theme` frontmatter field (e.g., `theme: metropolis`)
- **reveal.js**: the `revealjs-url` variable (set in the Makefile)

See [Presentations](presentations.md) for slide syntax, columns, speaker notes, and theme options.
