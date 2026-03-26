# Presentations

The `presentation` type produces PDF slides via **Beamer** and HTML slides via **reveal.js**.

```yaml
---
type: presentation
title: My Presentation
author: Your Name
date: March 2026
theme: metropolis
---
```

## Building

```bash
make pdf  SRC=documents/presentations/my-talk.md   # Beamer PDF
make html SRC=documents/presentations/my-talk.md   # reveal.js HTML
```

## Slide breaks

Slides are separated by **level-2 headings** or **horizontal rules**:

```markdown
## First Slide

Content of the first slide.

---

This is the second slide (no heading).

## Third Slide

Content of the third slide.
```

Both methods can be mixed freely.

## Speaker notes

Wrap notes in a fenced div. These only appear in presenter mode (press `S` in reveal.js):

```markdown
## Key Findings

- Revenue grew 15%
- Customer retention improved

::: notes
Mention the Q3 dip was seasonal. Emphasize the retention metric
since the board cares most about this.
:::
```

## Incremental lists

Reveal content one bullet at a time using a fenced div:

```markdown
## Agenda

::: incremental
- Background
- Methodology
- Results
- Recommendations
:::
```

In Beamer, this also works but requires the `\pause` approach. The fenced-div method is the most portable.

## Multi-column layouts

Split a slide into columns:

```markdown
## Comparison

:::::::::::::: columns
::: column
### Option A
- Lower cost
- Slower delivery
:::

::: column
### Option B
- Higher cost
- Faster delivery
:::
::::::::::::::
```

## Images

Standard Markdown image syntax works:

```markdown
## Architecture

![System diagram](path/to/diagram.png){ width=80% }
```

The `{ width=80% }` attribute controls sizing. Use percentages for portability across PDF and HTML.

## Code blocks

Fenced code blocks render with syntax highlighting:

````markdown
## Implementation

```python
def process(data):
    return [transform(x) for x in data]
```
````

## Beamer themes

Set `theme` in frontmatter to any Beamer theme name:

| Theme        | Style                       |
| ------------ | --------------------------- |
| `default`    | Plain, minimal              |
| `metropolis` | Modern, clean (recommended) |
| `madrid`     | Classic, colorful           |
| `berlin`     | Navigation sidebar          |
| `copenhagen` | Navigation dots             |

Full list: [Beamer Theme Matrix](https://hartwork.org/beamer-theme-matrix/)

## Math

LaTeX math works in both PDF and HTML output:

```markdown
## The Model

The cost function is $J(\theta) = \frac{1}{2m} \sum_{i=1}^{m}(h_\theta(x^{(i)}) - y^{(i)})^2$
```

## Tables

Standard Markdown tables render as slides:

```markdown
## Results

| Metric     | Before | After |
| ---------- | ------ | ----- |
| Latency    | 200ms  | 45ms  |
| Throughput | 100/s  | 800/s |
```

## Tips

- Keep slides concise — aim for 5-7 bullet points maximum per slide.
- Use `---` between slides when you don't need a heading.
- Test both PDF and HTML outputs since rendering can differ slightly.
- For reveal.js, open the HTML file in a browser and press `F` for fullscreen, `S` for speaker notes, `O` for overview.

For general Markdown syntax (math, images, tables, footnotes) that works across all document types including presentations, see [Markdown Features](markdown-features.md).
