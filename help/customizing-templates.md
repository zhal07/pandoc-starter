# Customizing Templates

## How templates work

When you run `make pdf SRC=documents/reports/my-report.md`, the build system:

1. Reads `type: report` from the file's YAML frontmatter
2. Looks for `templates/latex/report.tex`
3. If found, passes it to pandoc via `--template=templates/latex/report.tex`
4. If not found, falls back to `templates/latex/default.tex`

The same logic applies for HTML (`templates/html/`) and TXT (`templates/txt/`).

## Pandoc template syntax

Templates use pandoc's template language. The most common patterns:

### Variables

Frontmatter fields become variables. Use `$variable$` to insert them:

```latex
\title{$title$}
\author{$author$}
```

### Conditionals

Wrap optional sections in `$if()$`:

```latex
$if(abstract)$
\begin{abstract}
$abstract$
\end{abstract}
$endif$
```

With an else branch:

```latex
$if(closing)$
$closing$,
$else$
Sincerely,
$endif$
```

### Loops

Iterate over list fields with `$for()$`:

```latex
$for(attendees)$
\item $attendees$
$endfor$
```

With a separator:

```html
$for(attendees)$$attendees$$sep$, $endfor$
```

### The body

`$body$` is where pandoc inserts the converted Markdown content:

```latex
\begin{document}
$body$
\end{document}
```

### Syntax highlighting

LaTeX templates should include:

```latex
$if(highlighting-macros)$
$highlighting-macros$
$endif$
```

HTML templates should include:

```html
$if(highlighting-css)$
<style>$highlighting-css$</style>
$endif$
```

## Modifying an existing template

The safest approach is to edit the template file directly. For example, to change the report's heading color:

1. Open `templates/latex/report.tex`
2. Find the color definition:
   ```latex
   \definecolor{headingcolor}{RGB}{20,40,70}
   ```
3. Change to your preferred color:
   ```latex
   \definecolor{headingcolor}{RGB}{180,30,30}
   ```
4. Rebuild: `make pdf SRC=documents/reports/sample-report.md`

### Common modifications

| What to change        | Where to look                             |
| --------------------- | ----------------------------------------- |
| Fonts                 | `\setmainfont{}` / `\setsansfont{}` block |
| Margins               | `\geometry{}` block                       |
| Colors                | `\definecolor{}` lines                    |
| Header/footer         | `\fancyhead` / `\fancyfoot` lines         |
| Section heading style | `\titleformat{}` blocks                   |
| Line spacing          | `\linespread{}` or `\setstretch{}`        |

## Creating a new document type

To add a new type (e.g., `memo`):

1. **Create the LaTeX template** at `templates/latex/memo.tex`. Start by copying the closest existing template (e.g., `letter.tex`) and adapting it.

2. **Create the HTML template** at `templates/html/memo.html` (optional — falls back to `default.html`).

3. **Create a sample document** at `documents/memos/sample-memo.md`:
   ```yaml
   ---
   type: memo
   title: Weekly Update
   author: Your Name
   date: March 2026
   to: Team Lead
   ---

   Content here.
   ```

4. **Build it** — no Makefile changes needed. The system auto-detects the `type` and finds the matching template:
   ```bash
   make pdf SRC=documents/memos/sample-memo.md
   ```

## Fonts

The system uses **TeX Gyre** font families (available via `texlive-fonts-extra`):

| Template font     | TeX Gyre family | Similar to      |
| ----------------- | --------------- | --------------- |
| Body text (serif) | TeX Gyre Termes | Times New Roman |
| Headings (sans)   | TeX Gyre Heros  | Helvetica/Arial |
| Code (mono)       | TeX Gyre Cursor | Courier         |

To use a different font, change the `\setmainfont{}` call in the template. Any font installed on your system works with XeLaTeX:

```latex
\setmainfont{Libertinus Serif}[Ligatures=TeX]
```

Check available fonts with `fc-list | grep -i "font name"`.

## Presentations

Presentations use Pandoc's built-in Beamer (PDF) and reveal.js (HTML) output formats. There are **no editable template files** in `templates/` for the `presentation` type — styling is controlled via the `theme` frontmatter field (Beamer) or the `revealjs-url` variable (reveal.js).

To customize presentation appearance beyond the built-in themes, use Beamer's `\setbeamercolor` / `\setbeamerfont` commands in a raw LaTeX block at the top of your document, or supply a custom reveal.js CSS file via the `css` frontmatter field.

## Tips

- Always test changes with `make pdf SRC=...` after editing a template.
- LaTeX comments (`%`) are ignored by LaTeX but **not** by pandoc's template engine. Avoid putting `$variable$` syntax inside comments.
- When in doubt, examine the pandoc default templates for reference: `pandoc -D latex` or `pandoc -D html`.

For details on how each output format uses templates, see [Output Formats](output-formats.md).
