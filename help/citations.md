# Citations and Bibliography

## Setup

Citations require two things:

1. A `.bib` file containing your references
2. The `bibliography` field in your document's frontmatter

```yaml
---
type: report
title: Literature Review
bibliography: assets/bibliography/refs.bib
---
```

The build system automatically enables `--citeproc` and applies the default citation style (APA 7th) when it detects a `bibliography` field.

## Creating a .bib file

BibTeX files contain structured reference entries. Create one in `assets/bibliography/`:

```bibtex
@article{smith2024,
  author  = {Smith, John and Doe, Jane},
  title   = {A Study of Document Systems},
  journal = {Journal of Technical Writing},
  year    = {2024},
  volume  = {12},
  number  = {3},
  pages   = {45--67},
  doi     = {10.1234/jtw.2024.001}
}

@book{johnson2023,
  author    = {Johnson, Alice},
  title     = {Modern Documentation Practices},
  publisher = {Tech Press},
  year      = {2023},
  edition   = {2nd}
}

@inproceedings{lee2025,
  author    = {Lee, David},
  title     = {Markdown in Enterprise Settings},
  booktitle = {Proceedings of DocConf 2025},
  year      = {2025},
  pages     = {112--120}
}

@online{pandoc2024,
  author = {MacFarlane, John},
  title  = {Pandoc User's Guide},
  url    = {https://pandoc.org/MANUAL.html},
  year   = {2024}
}
```

### Common entry types

| Type             | Use for                   |
| ---------------- | ------------------------- |
| `@article`       | Journal papers            |
| `@book`          | Books                     |
| `@inproceedings` | Conference papers         |
| `@online`        | Websites, web resources   |
| `@thesis`        | Masters/PhD dissertations |
| `@report`        | Technical reports         |
| `@misc`          | Anything else             |

## Citing in your document

Use `[@key]` syntax to cite references in the body text:

```markdown
Recent work has shown improvements in document systems [@smith2024].

According to @johnson2023, automation reduces errors by 40%.

Multiple sources confirm this [@smith2024; @lee2025; @pandoc2024].
```

These render differently depending on style:

| Syntax                   | APA rendering (default)        |
| ------------------------ | ------------------------------ |
| `[@smith2024]`           | (Smith & Doe, 2024)            |
| `@johnson2023`           | Johnson (2023)                 |
| `[@smith2024; @lee2025]` | (Lee, 2025; Smith & Doe, 2024) |
| `[@smith2024, p. 52]`    | (Smith & Doe, 2024, p. 52)     |
| `[-@smith2024]`          | (2024) — suppress author name  |

## Changing citation style

The system defaults to APA 7th edition (`assets/csl/default.csl`). The project includes additional styles:

- `assets/csl/chicago-author-date.csl`
- `assets/csl/ieee.csl`

Override per-document by adding `csl` to frontmatter:

```yaml
---
type: report
title: IEEE-Style Paper
bibliography: assets/bibliography/refs.bib
csl: assets/csl/ieee.csl
---
```

### Installing more styles

Download CSL files from [Zotero's CSL repository](https://www.zotero.org/styles) and place them in `assets/csl/`:

```bash
curl -L -o assets/csl/harvard.csl \
  "https://www.zotero.org/styles/harvard-cite-them-right"
```

Then reference it in your frontmatter: `csl: assets/csl/harvard.csl`

## Reference list

Pandoc automatically appends a reference list at the end of your document. To control where it appears, add a heading:

```markdown
## Conclusion

Final thoughts here.

## References

<!-- pandoc inserts the bibliography here -->
```

If no `## References` heading exists, the list appears at the very end.

## Tips

- Most academic databases (Google Scholar, IEEE Xplore, ACM DL) can export BibTeX entries directly.
- Reference managers like Zotero, Mendeley, and JabRef export `.bib` files natively.
- Keep one shared `.bib` file in `assets/bibliography/` for cross-document reuse.
- The citation key (e.g., `smith2024`) is your choice — use something memorable like `authorYear`.
- A sample `.bib` file is included at `assets/bibliography/sample.bib` for reference.
