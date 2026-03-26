# =============================================================================
# General-Purpose Markdown + Pandoc Document System
# =============================================================================
# Usage:
#   make <format> SRC=documents/<subdir>/<file>.md
#   make resume          (shortcut for the main resume)
#   make list            (list all documents)
#   make help            (show all commands)
#
# Formats: all | pdf | pdf-ats | html | docx | docx-ats | txt
# =============================================================================

SYSTEM_DIR   ?= .
TEMPLATES    ?= $(SYSTEM_DIR)/templates
FILTERS      ?= $(SYSTEM_DIR)/filters
ASSETS       ?= $(SYSTEM_DIR)/assets

OUTPUT_DIR := output

# -----------------------------------------------------------------------------
# Document detection (only when SRC is provided)
# -----------------------------------------------------------------------------

# Extract a YAML frontmatter field from $(SRC).  Usage: $(call yaml,fieldname)
yaml = $(shell awk 'NR==1&&/^---/{f=1;next}f&&/^---/{exit}f&&/^$(1):/{sub(/^$(1):[[:space:]]*/,"");gsub(/["\047 ]/,"");print;exit}' "$(SRC)" 2>/dev/null | tr -d '\n')

ifdef SRC
  TYPE         := $(call yaml,type)
  ifeq ($(TYPE),)
    TYPE       := default
  endif

  # Mirror source path into output/
  #   documents/reports/q1.md  →  output/reports/q1  (stem only)
  SRC_REL      := $(patsubst documents/%,%,$(SRC))
  SRC_BASE     := $(basename $(SRC_REL))
  OUT_BASE     := $(OUTPUT_DIR)/$(SRC_BASE)

  BIBLIOGRAPHY := $(call yaml,bibliography)
  CSL          := $(call yaml,csl)
  HAS_TOC      := $(call yaml,toc)
endif

# -----------------------------------------------------------------------------
# Template resolution: type-specific with fallback to default
# -----------------------------------------------------------------------------
ifdef TYPE
  TEX_TEMPLATE  := $(shell [ -f "$(TEMPLATES)/latex/$(TYPE).tex" ]  && echo "$(TEMPLATES)/latex/$(TYPE).tex"  || echo "$(TEMPLATES)/latex/default.tex")
  HTML_TEMPLATE := $(shell [ -f "$(TEMPLATES)/html/$(TYPE).html" ]   && echo "$(TEMPLATES)/html/$(TYPE).html"  || echo "$(TEMPLATES)/html/default.html")
  TXT_TEMPLATE  := $(shell [ -f "$(TEMPLATES)/txt/$(TYPE).txt" ]     && echo "$(TEMPLATES)/txt/$(TYPE).txt"    || echo "$(TEMPLATES)/txt/default.txt")
endif

# -----------------------------------------------------------------------------
# Shared option blocks
# -----------------------------------------------------------------------------

# Citations: auto-enabled when 'bibliography' field is present in frontmatter
ifneq ($(BIBLIOGRAPHY),)
  ifeq ($(CSL),)
    CSL := $(ASSETS)/csl/default.csl
  endif
  CITEPROC_OPTS := --citeproc --bibliography="$(BIBLIOGRAPHY)" --csl="$(CSL)"
else
  CITEPROC_OPTS :=
endif

# TOC: honor toc: true in frontmatter
ifeq ($(HAS_TOC),true)
  TOC_OPT := --toc
else
  TOC_OPT :=
endif

# DOCX: use reference doc if present
DOCX_REF := $(shell [ -f "$(TEMPLATES)/reference.docx" ] && echo "--reference-doc=$(TEMPLATES)/reference.docx")
PANDOC_DOCX_OPTS = $(DOCX_REF) $(TOC_OPT) $(CITEPROC_OPTS)

# -----------------------------------------------------------------------------
# Per-type pandoc option sets
# -----------------------------------------------------------------------------

ifeq ($(TYPE),resume)
  # Resume: visual template, no TOC, no math, wrap=none for HTML
  PANDOC_PDF_OPTS  = --template=$(TEX_TEMPLATE) --pdf-engine=xelatex
  PANDOC_HTML_OPTS = --template=$(HTML_TEMPLATE) --standalone --wrap=none
  PANDOC_TXT_OPTS  = --to plain --template=$(TXT_TEMPLATE) --standalone
else ifeq ($(TYPE),presentation)
  # Presentations: beamer for PDF, reveal.js for HTML — no custom template needed
  PANDOC_PDF_OPTS  = -t beamer --pdf-engine=xelatex $(CITEPROC_OPTS)
  PANDOC_HTML_OPTS = -t revealjs --standalone \
                     -V revealjs-url=https://unpkg.com/reveal.js@4 $(CITEPROC_OPTS)
  PANDOC_TXT_OPTS  = --to plain --standalone
else
  # All other types: full-featured pipeline (technical adds admonition filter)
  # table-width.lua applied globally to ensure consistent full-width tables in PDF
  LUA_FILTERS := --lua-filter=$(FILTERS)/table-width.lua
  ifeq ($(TYPE),technical)
    LUA_FILTERS += --lua-filter=$(FILTERS)/admonition.lua
  endif
  PANDOC_PDF_OPTS  = --template=$(TEX_TEMPLATE) --pdf-engine=xelatex \
                     $(TOC_OPT) $(CITEPROC_OPTS) --highlight-style=tango $(LUA_FILTERS)
  PANDOC_HTML_OPTS = --template=$(HTML_TEMPLATE) --standalone --mathjax \
                     $(TOC_OPT) $(CITEPROC_OPTS) --highlight-style=tango $(LUA_FILTERS)
  PANDOC_TXT_OPTS  = --to plain --template=$(TXT_TEMPLATE) --standalone
endif

# -----------------------------------------------------------------------------
.PHONY: all pdf pdf-ats html docx docx-ats txt clean list resume help check-src setup \
        cover-letter letter article report invoice meeting-notes technical presentation \
        build-dir build-all
# -----------------------------------------------------------------------------

# Default target
.DEFAULT_GOAL := help

help:
	@echo "Markdown + Pandoc Document System"
	@echo "=================================="
	@echo ""
	@echo "Usage:  make <format> SRC=documents/<subdir>/<file>.md"
	@echo ""
	@echo "Formats:"
	@echo "  all          Build PDF, HTML, DOCX, and TXT"
	@echo "  pdf          Build PDF"
	@echo "  pdf-ats      Build ATS-optimized PDF (resume only)"
	@echo "  html         Build HTML"
	@echo "  docx         Build DOCX"
	@echo "  docx-ats     Build ATS-optimized DOCX (resume only)"
	@echo "  txt          Build plain text"
	@echo ""
	@echo "Shortcuts (build sample file for each type):"
	@echo "  resume         Build all formats for documents/resumes/sample-resume.md"
	@echo "  cover-letter   Build all formats for sample cover letter"
	@echo "  letter         Build all formats for sample letter"
	@echo "  article        Build all formats for sample article"
	@echo "  report         Build all formats for sample report"
	@echo "  invoice        Build all formats for sample invoice"
	@echo "  meeting-notes  Build all formats for sample meeting notes"
	@echo "  technical      Build all formats for sample technical doc"
	@echo "  presentation   Build PDF + HTML for sample presentation"
	@echo ""
	@echo "Batch build:"
	@echo "  build-dir DIR=path  Build all .md files under DIR (mirrors output structure)"
	@echo "  build-all           Build all .md files under documents/"
	@echo ""
	@echo "Utility:"
	@echo "  list         List all documents with their types"
	@echo "  clean        Remove the output directory"
	@echo ""
	@echo "Examples:"
	@echo "  make pdf  SRC=documents/reports/quarterly.md"
	@echo "  make all  SRC=documents/invoices/Acme-Corp/jan-2026.md"
	@echo "  make resume"
	@echo "  make build-dir DIR=documents/invoices/Acme-Corp"
	@echo "  make build-all"
	@echo ""
	@echo "Document types: resume | cover-letter | letter | report | article"
	@echo "                presentation | invoice | meeting-notes | technical"

# -----------------------------------------------------------------------------
# Shortcut targets
# -----------------------------------------------------------------------------

resume:
	@$(MAKE) all      SRC=documents/resumes/sample-resume.md
	@$(MAKE) pdf-ats  SRC=documents/resumes/sample-resume.md
	@$(MAKE) docx-ats SRC=documents/resumes/sample-resume.md

cover-letter:
	@$(MAKE) all SRC=documents/cover-letters/sample-cover-letter.md

letter:
	@$(MAKE) all SRC=documents/letters/sample-letter.md

article:
	@$(MAKE) all SRC=documents/articles/sample-article.md

report:
	@$(MAKE) all SRC=documents/reports/sample-report.md

invoice:
	@$(MAKE) all SRC=documents/invoices/sample-invoice.md

meeting-notes:
	@$(MAKE) all SRC=documents/meeting-notes/sample-meeting.md

technical:
	@$(MAKE) all SRC=documents/technical/sample-technical.md

presentation:
	@$(MAKE) pdf html SRC=documents/presentations/sample-presentation.md

# -----------------------------------------------------------------------------
# Utility targets
# -----------------------------------------------------------------------------

setup:
ifdef OUT_BASE
	@mkdir -p $(dir $(OUT_BASE))
else
	@mkdir -p $(OUTPUT_DIR)
endif

check-src:
	@test -n "$(SRC)"  || { echo "ERROR: SRC is required. Usage: make <target> SRC=path/to/file.md"; exit 1; }
	@test -f "$(SRC)"  || { echo "ERROR: File not found: $(SRC)"; exit 1; }

list:
	@echo "Available documents:"
	@echo ""
	@yf() { awk "NR==1&&/^---/{f=1;next}f&&/^---/{exit}f&&/^$$1:/{sub(/^$$1:[[:space:]]*/,\"\");gsub(/[\"\\047]/,\"\");print;exit}" "$$2" 2>/dev/null | tr -d '\n'; }; \
	find documents -name "*.md" | sort | while read f; do \
		t=$$(yf type "$$f"); \
		ti=$$(yf title "$$f"); \
		printf "  %-52s [type=%-16s] %s\n" "$$f" "$${t:-unset}" "$${ti}"; \
	done

clean:
	rm -rf $(OUTPUT_DIR)
	@echo "Output directory removed."

# Build all .md files under a given directory tree, mirroring output structure.
# Usage: make build-dir DIR=documents/invoices/Acme-Corp
build-dir:
	@test -n "$(DIR)" || { echo "ERROR: DIR is required.  Usage: make build-dir DIR=documents/invoices/Acme-Corp"; exit 1; }
	@test -d "$(DIR)" || { echo "ERROR: Directory not found: $(DIR)"; exit 1; }
	@echo "Building all documents under $(DIR)..."
	@find "$(DIR)" -name "*.md" | sort | while read f; do \
		echo ""; \
		echo "--- $$f ---"; \
		$(MAKE) all SRC="$$f" || true; \
	done
	@echo ""
	@echo "Done building $(DIR)."

# Build every .md file under documents/
build-all:
	@echo "Building all documents under documents/..."
	@find documents -name "*.md" | sort | while read f; do \
		echo ""; \
		echo "--- $$f ---"; \
		$(MAKE) all SRC="$$f" || true; \
	done
	@echo ""
	@echo "Done building all documents."

# -----------------------------------------------------------------------------
# Build targets
# -----------------------------------------------------------------------------

all: check-src setup pdf html docx txt
	@echo ""
	@echo "All formats generated:"
	@ls -lh "$(dir $(OUT_BASE))" 2>/dev/null | grep "$(notdir $(OUT_BASE))" || true

pdf: check-src setup
	@echo "[pdf] $(SRC) → $(OUT_BASE).pdf  (type: $(TYPE))"
	@pandoc "$(SRC)" -o "$(OUT_BASE).pdf" $(PANDOC_PDF_OPTS)
	@echo "      Done."

pdf-ats: check-src setup
	@if [ "$(TYPE)" = "resume" ]; then \
		echo "[pdf-ats] $(SRC) → $(OUT_BASE)-ats.pdf"; \
		pandoc "$(SRC)" -o "$(OUT_BASE)-ats.pdf" \
			--template=$(TEMPLATES)/latex/resume-ats.tex \
			--pdf-engine=xelatex; \
		echo "      Done."; \
	else \
		echo "pdf-ats only applies to documents with type: resume"; \
	fi

docx-ats: check-src setup
	@if [ "$(TYPE)" = "resume" ]; then \
		echo "[docx-ats] $(SRC) → $(OUT_BASE)-ats.docx"; \
		pandoc "$(SRC)" -o "$(OUT_BASE)-ats.docx" \
			$(PANDOC_DOCX_OPTS) --lua-filter=$(FILTERS)/ats-hyphen-bullets.lua; \
		echo "      Done."; \
	else \
		echo "docx-ats only applies to documents with type: resume"; \
	fi

html: check-src setup
	@echo "[html] $(SRC) → $(OUT_BASE).html  (type: $(TYPE))"
	@pandoc "$(SRC)" -o "$(OUT_BASE).html" $(PANDOC_HTML_OPTS)
	@echo "      Done."

docx: check-src setup
	@echo "[docx] $(SRC) → $(OUT_BASE).docx  (type: $(TYPE))"
	@pandoc "$(SRC)" -o "$(OUT_BASE).docx" $(PANDOC_DOCX_OPTS)
	@echo "      Done."

txt: check-src setup
	@echo "[txt] $(SRC) → $(OUT_BASE).txt  (type: $(TYPE))"
	@pandoc "$(SRC)" -o "$(OUT_BASE).txt" $(PANDOC_TXT_OPTS)
	@echo "      Done."
