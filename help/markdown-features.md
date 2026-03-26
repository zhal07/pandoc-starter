# Markdown Features

This guide covers Markdown features that work across all document types in this system. For slide-specific features (columns, incremental lists, speaker notes), see [Presentations](presentations.md).

---

## Math

Inline math uses single dollar signs: `$E = mc^2$` renders as \$E = mc^2\$.

Display (block) math uses double dollar signs:

```markdown
$$
\int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}
$$
```

**PDF**: Math renders natively via XeLaTeX — no extra options needed.

**HTML**: Pass `--mathjax` (already included for non-resume types). Math renders in the browser via MathJax.

---

## Images

Basic image syntax:

```markdown
![Alt text](path/to/image.png)
```

Control size with Pandoc attributes:

```markdown
![Company logo](assets/logo.png){ width=60% }
![Diagram](assets/diagram.png){ width=4in }
```

Images with captions become `<figure>` elements in HTML and floated figures in LaTeX:

```markdown
![Figure 1: System architecture overview](assets/arch.png){ width=80% }
```

---

## Tables

Pipe table syntax with optional alignment:

```markdown
| Left         | Center |    Right |
| :----------- | :----: | -------: |
| Cell         |  Cell  |     Cell |
| Longer value | Short  | 1,234.56 |
```

Column alignment is controlled by the colon position in the separator row.

---

## Footnotes

```markdown
This claim requires a citation.[^1]

[^1]: Source: Smith et al. (2024), p. 45.
```

Footnotes render as numbered superscripts in the body and collect at the end of the document.

---

## Block Quotes

```markdown
> The best documentation is the kind that doesn't need to exist.
>
> — Unknown
```

Multi-paragraph block quotes work by adding `>` to each line, including blank lines between paragraphs.

---

## Definition Lists

```markdown
Pandoc
:   A universal document converter.

XeLaTeX
:   A TeX engine with native Unicode and font support.
```

---

## Strikethrough

```markdown
~~This text is struck through.~~
```

---

## Code Blocks

Fenced code blocks with optional syntax highlighting:

````markdown
```python
def greet(name):
    return f"Hello, {name}!"
```
````

Supported languages include `python`, `javascript`, `bash`, `latex`, `json`, `yaml`, `sql`, and many more. Highlighting uses the **tango** style in PDF and HTML output.

Inline code uses single backticks: `` `variable_name` ``

---

## Admonition Blocks

Admonition blocks (note, warning, tip) are only available for documents with `type: technical`. They require the `filters/admonition.lua` filter, which the Makefile applies automatically for that type.

```markdown
::: note
This is an informational note.
:::

::: warning
This action cannot be undone.
:::

::: tip
Use `make list` to see all available documents.
:::
```

For all other document types, use block quotes or bold text to highlight important content.

---

## Horizontal Rules

A line of three or more hyphens, asterisks, or underscores creates a horizontal rule:

```markdown
---
```

Note: in presentations, `---` also creates a slide break. See [Presentations](presentations.md).

---

## Smart Punctuation

Pandoc automatically converts:

| Markdown   | Output       |
| ---------- | ------------ |
| `"quoted"` | "quoted"     |
| `'quoted'` | 'quoted'     |
| `--`       | en dash (–)  |
| `---`      | em dash (—)  |
| `...`      | ellipsis (…) |

---

## Raw LaTeX / HTML

You can embed raw LaTeX in documents that output to PDF:

```markdown
\newpage
```

Or raw HTML for HTML output:

```markdown
<details><summary>Click to expand</summary>Hidden content.</details>
```

Pandoc passes raw blocks through to the appropriate output format and ignores them for others.
