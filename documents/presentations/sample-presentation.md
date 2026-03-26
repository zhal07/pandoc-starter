---
type: presentation
title: The Markdown + Pandoc Document System
author: Jane Smith
date: March 2026
theme: default
---

## The Problem

- Documents created in Word are fragile
- Formatting takes hours every time
- No version control
- Only one output format

::: notes
Explain the pain of proprietary formats and manual formatting. The audience
should relate to spending time on formatting instead of content.
:::

---

## The Solution

Write once in **Markdown**. Generate everything else.

::: notes
Key message: Markdown is the single source of truth. All formats are derived.
:::

---

## What is Pandoc?

> "Pandoc is a universal document converter."

- Reads Markdown (and many other formats)
- Outputs to PDF, HTML, DOCX, slides, EPUB, and more
- Extensible with Lua filters and custom templates

---

## How it Works

```
document.md
    ↓
  pandoc
    ↓
document.pdf  document.html  document.docx
```

The source never changes. The output format is a parameter.

---

## Document Types

| Type            | Use Case            |
| --------------- | ------------------- |
| `resume`        | Job applications    |
| `cover-letter`  | Job applications    |
| `report`        | Business / research |
| `article`       | Essays, blog posts  |
| `presentation`  | Slides (this file!) |
| `invoice`       | Freelance billing   |
| `meeting-notes` | Team meetings       |
| `technical`     | API docs, guides    |

---

## A Slide with Math

Einstein's famous equation:

$$E = mc^2$$

And inline: the area of a circle is $A = \pi r^2$.

---

## Demo: One Command

```bash
make all SRC=documents/reports/quarterly.md
```

Produces:

- `output/reports/quarterly.pdf`
- `output/reports/quarterly.html`
- `output/reports/quarterly.docx`
- `output/reports/quarterly.txt`

---

## Thank You

Questions?

`make help` to get started.
