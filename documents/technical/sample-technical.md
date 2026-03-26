---
type: technical
title: Document System API Reference
author: Jane Smith
date: March 2026
version: "1.0.0"
toc: true
numbersections: true
---

# Overview

The Markdown + Pandoc Document System converts Markdown source files into multiple output formats using a template-driven pipeline. This reference covers the build system interface, frontmatter schema, template variables, and filter API.

# Build System

## Command Reference

All builds are invoked through `make` with a `SRC` parameter pointing to the source Markdown file.

```bash
make <format> SRC=documents/<subdir>/<file>.md
```

### Formats

| Target     | Output                           |
| ---------- | -------------------------------- |
| `pdf`      | PDF via XeLaTeX                  |
| `html`     | Standalone HTML                  |
| `docx`     | Word document                    |
| `txt`      | Plain text                       |
| `all`      | All of the above                 |
| `pdf-ats`  | ATS-optimized PDF (resume only)  |
| `docx-ats` | ATS-optimized DOCX (resume only) |

### Examples

```bash
make pdf  SRC=documents/reports/quarterly.md
make all  SRC=documents/technical/api-guide.md
make resume
```

### Convenience Targets

```bash
make list     # list all documents with detected types
make clean    # remove output/ directory
make help     # show command reference
```

## Type Detection

The build system extracts the `type` field from YAML frontmatter:

```bash
TYPE=$(pandoc --template='$type$' -t plain "$SRC" | tr -d ' \n')
```

If `type` is absent, the build falls back to `default` templates.

# Frontmatter Schema

## Shared Fields

These fields are recognized by all templates:

| Field            | Type    | Default   | Description                                |
| ---------------- | ------- | --------- | ------------------------------------------ |
| `type`           | string  | `default` | Document type — drives template selection  |
| `title`          | string  | —         | Document title                             |
| `author`         | string  | —         | Author name                                |
| `date`           | string  | —         | Publication date                           |
| `papersize`      | string  | `letter`  | `letter` or `a4`                           |
| `fontsize`       | string  | `11pt`    | Base font size                             |
| `toc`            | boolean | `false`   | Include table of contents                  |
| `numbersections` | boolean | `false`   | Number section headings                    |
| `bibliography`   | string  | —         | Path to `.bib` file (enables `--citeproc`) |

## Technical-Specific Fields

| Field      | Type   | Description                        |
| ---------- | ------ | ---------------------------------- |
| `version`  | string | Version number displayed in header |
| `abstract` | string | Short document description         |

# Templates

## Template Resolution

Templates are resolved in this order:

1. `templates/latex/<type>.tex` — type-specific LaTeX template
2. `templates/latex/default.tex` — fallback for unrecognized types

Similarly for HTML: `templates/html/<type>.html` → `templates/html/default.html`.

## Available Types

| Type            | LaTeX               | HTML                 |
| --------------- | ------------------- | -------------------- |
| `resume`        | `resume.tex`        | `resume.html`        |
| `cover-letter`  | `cover-letter.tex`  | `cover-letter.html`  |
| `letter`        | `letter.tex`        | `letter.html`        |
| `report`        | `report.tex`        | `report.html`        |
| `article`       | `article.tex`       | `article.html`       |
| `presentation`  | beamer (built-in)   | revealjs (built-in)  |
| `invoice`       | `invoice.tex`       | —                    |
| `meeting-notes` | `meeting-notes.tex` | `meeting-notes.html` |
| `technical`     | `technical.tex`     | `technical.html`     |
| `default`       | `default.tex`       | `default.html`       |

# Filters

## ats-hyphen-bullets.lua

Converts Markdown bullet lists to hyphen-prefixed paragraphs for ATS-compliant DOCX output. Applied only via `make docx-ats` for resume builds.

## admonition.lua

Converts fenced divs with admonition classes to styled blocks. Applied automatically to `technical` type builds.

### Supported Classes

| Class     | Renders As             |
| --------- | ---------------------- |
| `note`    | Blue informational box |
| `warning` | Amber warning box      |
| `tip`     | Green tip box          |

### Usage

```markdown
::: note
This is an informational note.
:::

::: warning
Check your dependencies before running this command.
:::

::: tip
You can pass `--dry-run` to preview changes without applying them.
:::
```

::: note
The admonition filter is only applied when `type: technical` is set. For other types, fenced divs pass through as plain divs.
:::

::: warning
LaTeX admonition boxes require the `tcolorbox` package. Run `./setup.sh` to ensure all dependencies are installed.
:::

::: tip
The admonition classes (`note`, `warning`, `tip`) also work in HTML output via CSS classes with matching names.
:::

# Citations

To enable citations, add `bibliography` to frontmatter:

```yaml
bibliography: assets/bibliography/refs.bib
```

The Makefile automatically adds `--citeproc --csl=assets/csl/default.csl` (APA 7th edition).

To use a different citation style:

```yaml
csl: assets/csl/chicago-author-date.csl
```

Cite in text with `[@key]` syntax. References are appended automatically.

Available CSL styles in `assets/csl/`:

- `default.csl` — APA 7th edition
- `chicago-author-date.csl` — Chicago Author-Date
- `ieee.csl` — IEEE

# Troubleshooting

## Font Not Found

```bash
sudo apt install texlive-fonts-extra fonts-texgyre
fc-cache -fv
```

## Type Not Detected

Verify the YAML frontmatter block opens with `---` on the very first line of the file with no blank lines before it.

## Build Verification

```bash
./verify.sh          # check all dependencies and templates
./verify.sh --build  # also run a smoke-test PDF build
```
