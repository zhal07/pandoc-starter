#!/bin/bash
# Verification Script — General-Purpose Markdown + Pandoc Document System
# Checks all dependencies, validates templates, and runs smoke-test builds.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0; FAIL=0; WARN=0

ok()   { echo -e "${GREEN}✓${NC} $1"; PASS=$((PASS+1)); }
fail() { echo -e "${RED}✗${NC} $1"; FAIL=$((FAIL+1)); }
warn() { echo -e "${YELLOW}!${NC} $1"; WARN=$((WARN+1)); }

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  Markdown + Pandoc Document System — Verify  ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# ── Dependencies ──────────────────────────────────────────────────────────
echo -e "${BLUE}[1] Dependencies${NC}"

command -v pandoc   &>/dev/null && ok "pandoc $(pandoc --version | head -n1 | awk '{print $2}')" || fail "pandoc not found — run ./setup.sh"
command -v xelatex  &>/dev/null && ok "xelatex" || fail "xelatex not found — run ./setup.sh"
command -v make     &>/dev/null && ok "make"     || fail "make not found — run ./setup.sh"
command -v lua      &>/dev/null && ok "lua (for Lua filters)"  || warn "lua not found — filters may not work"

echo ""

# ── Core templates ────────────────────────────────────────────────────────
echo -e "${BLUE}[2] Templates${NC}"

REQUIRED_TEMPLATES=(
  "templates/latex/resume.tex"
  "templates/latex/resume-ats.tex"
  "templates/latex/default.tex"
  "templates/latex/cover-letter.tex"
  "templates/latex/letter.tex"
  "templates/latex/report.tex"
  "templates/latex/article.tex"
  "templates/latex/meeting-notes.tex"
  "templates/latex/invoice.tex"
  "templates/latex/technical.tex"
  "templates/html/resume.html"
  "templates/html/default.html"
  "templates/html/cover-letter.html"
  "templates/html/letter.html"
  "templates/html/report.html"
  "templates/html/article.html"
  "templates/html/meeting-notes.html"
  "templates/html/technical.html"
  "templates/html/invoice.html"
  "templates/txt/resume.txt"
  "templates/txt/default.txt"
  "templates/txt/letter.txt"
  "templates/txt/cover-letter.txt"
  "templates/txt/invoice.txt"
  "templates/txt/meeting-notes.txt"
)

for t in "${REQUIRED_TEMPLATES[@]}"; do
  [ -f "$t" ] && ok "$t" || fail "$t — missing"
done

echo ""

# ── Filters ───────────────────────────────────────────────────────────────
echo -e "${BLUE}[3] Filters${NC}"

[ -f "filters/ats-hyphen-bullets.lua" ]    && ok "filters/ats-hyphen-bullets.lua" || fail "filters/ats-hyphen-bullets.lua — missing"
[ -f "filters/admonition.lua" ]            && ok "filters/admonition.lua"          || warn "filters/admonition.lua — missing (needed for technical docs)"

echo ""

# ── Assets ────────────────────────────────────────────────────────────────
echo -e "${BLUE}[4] Assets${NC}"

[ -f "assets/csl/default.csl" ]            && ok "assets/csl/default.csl"          || warn "assets/csl/default.csl — missing (needed for citations)"
[ -f "templates/reference.docx" ]          && ok "templates/reference.docx"        || warn "templates/reference.docx — optional DOCX style reference"

echo ""

# ── Source documents ──────────────────────────────────────────────────────
echo -e "${BLUE}[5] Source documents${NC}"

[ -f "documents/resumes/sample-resume.md" ]                    && ok "documents/resumes/sample-resume.md"                    || warn "sample-resume.md — missing"
[ -f "documents/cover-letters/sample-cover-letter.md" ]        && ok "documents/cover-letters/sample-cover-letter.md"        || warn "sample-cover-letter.md — missing"

echo ""

# ── Smoke test: type detection ─────────────────────────────────────────────
echo -e "${BLUE}[6] Frontmatter type detection${NC}"

if [ -f "documents/resumes/sample-resume.md" ]; then
  TYPE=$(grep -m1 '^type:' "documents/resumes/sample-resume.md" 2>/dev/null | sed 's/^type:[[:space:]]*//' | tr -d '" \n')
  [ "$TYPE" = "resume" ] && ok "sample-resume.md → type=$TYPE" || fail "sample-resume.md type detection failed (got: '$TYPE', expected: 'resume')"
fi

if [ -f "documents/cover-letters/sample-cover-letter.md" ]; then
  TYPE=$(grep -m1 '^type:' "documents/cover-letters/sample-cover-letter.md" 2>/dev/null | sed 's/^type:[[:space:]]*//' | tr -d '" \n')
  [ "$TYPE" = "cover-letter" ] && ok "sample-cover-letter.md → type=$TYPE" || fail "cover letter type detection failed (got: '$TYPE', expected: 'cover-letter')"
fi

echo ""

# ── Optional: build test ──────────────────────────────────────────────────
if [ "${1}" = "--build" ] || [ "${1}" = "-b" ]; then
  echo -e "${BLUE}[7] Build test (smoke test — building resume)${NC}"
  if make pdf SRC=documents/resumes/resume.md 1>/dev/null 2>&1; then
    ok "make pdf SRC=documents/resumes/resume.md"
  else
    fail "make pdf SRC=documents/resumes/resume.md — build failed (run manually for details)"
  fi
  echo ""
fi

# ── Summary ───────────────────────────────────────────────────────────────
echo "--------------------------------------------"
echo -e "  ${GREEN}Passed: $PASS${NC}   ${RED}Failed: $FAIL${NC}   ${YELLOW}Warnings: $WARN${NC}"
echo "--------------------------------------------"
echo ""

if [ $FAIL -gt 0 ]; then
  echo -e "${RED}Some checks failed. Run ./setup.sh to install missing dependencies.${NC}"
  exit 1
else
  echo -e "${GREEN}System ready. Run 'make help' to get started.${NC}"
  exit 0
fi
