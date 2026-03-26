#!/bin/bash
# Setup Script — General-Purpose Markdown + Pandoc Document System
# Installs all required and optional dependencies for the full system.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  Markdown + Pandoc Document System Setup  ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# ── Detect OS ────────────────────────────────────────────────────────────
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}Cannot detect OS. Please install dependencies manually.${NC}"
    exit 1
fi

echo -e "${BLUE}Detected OS:${NC} $OS"
echo ""

check_root() { [ "$EUID" -eq 0 ]; }

# ── Check current status ──────────────────────────────────────────────────
echo -e "${BLUE}Checking installed dependencies:${NC}"
echo "--------------------------------------------"

PANDOC_OK=false; XELATEX_OK=false; MAKE_OK=false; LUA_OK=false; FONTS_OK=false

command -v pandoc    &>/dev/null && { echo -e "${GREEN}✓${NC} pandoc    ($(pandoc --version | head -n1))"; PANDOC_OK=true;   } || echo -e "${YELLOW}○${NC} pandoc    — needs install"
command -v xelatex   &>/dev/null && { echo -e "${GREEN}✓${NC} xelatex";  XELATEX_OK=true; } || echo -e "${YELLOW}○${NC} xelatex   — needs install"
command -v make      &>/dev/null && { echo -e "${GREEN}✓${NC} make";     MAKE_OK=true;    } || echo -e "${YELLOW}○${NC} make      — needs install"
command -v lua       &>/dev/null && { echo -e "${GREEN}✓${NC} lua       ($(lua -v 2>&1 | head -n1))"; LUA_OK=true; } || echo -e "${YELLOW}○${NC} lua       — needs install (for Lua filters)"
fc-list 2>/dev/null | grep -qi "TeX Gyre Termes" && { echo -e "${GREEN}✓${NC} TeX Gyre fonts (body text)"; FONTS_OK=true; } || echo -e "${YELLOW}○${NC} TeX Gyre fonts — needs install"

echo ""

if $PANDOC_OK && $XELATEX_OK && $MAKE_OK && $LUA_OK && $FONTS_OK; then
    echo -e "${GREEN}All dependencies are already installed!${NC}"
    echo ""
    echo -e "Run ${BLUE}./verify.sh${NC} to run a full system check."
    exit 0
fi

# ── Install ───────────────────────────────────────────────────────────────
PACKAGES=""

case $OS in
    ubuntu|debian|pop|linuxmint)
        $PANDOC_OK    || PACKAGES="$PACKAGES pandoc"
        $XELATEX_OK   || PACKAGES="$PACKAGES texlive-xetex texlive-latex-extra texlive-latex-recommended"
        $LUA_OK       || PACKAGES="$PACKAGES lua5.4"
        $FONTS_OK     || PACKAGES="$PACKAGES texlive-fonts-recommended texlive-fonts-extra fonts-texgyre"
        $MAKE_OK      || PACKAGES="$PACKAGES make"
        ;;
    fedora|rhel|centos|rocky|almalinux)
        $PANDOC_OK    || PACKAGES="$PACKAGES pandoc"
        $XELATEX_OK   || PACKAGES="$PACKAGES texlive-xetex"
        $LUA_OK       || PACKAGES="$PACKAGES lua"
        $FONTS_OK     || PACKAGES="$PACKAGES texlive-collection-fontsrecommended texlive-collection-fontsextra"
        $MAKE_OK      || PACKAGES="$PACKAGES make"
        ;;
    arch|manjaro|endeavouros)
        $PANDOC_OK    || PACKAGES="$PACKAGES pandoc"
        $XELATEX_OK   || PACKAGES="$PACKAGES texlive-core"
        $LUA_OK       || PACKAGES="$PACKAGES lua"
        $FONTS_OK     || PACKAGES="$PACKAGES texlive-fontsextra"
        $MAKE_OK      || PACKAGES="$PACKAGES make"
        ;;
    *)
        echo -e "${YELLOW}Unsupported OS: $OS${NC}"
        echo ""
        echo "Please install manually:"
        echo "  - pandoc           https://pandoc.org/installing.html"
        echo "  - texlive-xetex    (or your distro's equivalent)"
        echo "  - lua              https://www.lua.org/download.html"
        echo "  - texlive-fonts-recommended + texlive-fonts-extra"
        echo "  - make"
        exit 1
        ;;
esac

if [ -n "$PACKAGES" ]; then
    echo -e "${YELLOW}Packages to install:${NC} $PACKAGES"
    echo ""

    if check_root; then
        echo -e "${BLUE}Installing...${NC}"
        case $OS in
            ubuntu|debian|pop|linuxmint)
                apt-get update -qq && apt-get install -y $PACKAGES ;;
            fedora|rhel|centos|rocky|almalinux)
                dnf install -y $PACKAGES ;;
            arch|manjaro|endeavouros)
                pacman -Sy --noconfirm $PACKAGES ;;
        esac
    else
        echo -e "${YELLOW}Root privileges required. Please run:${NC}"
        case $OS in
            ubuntu|debian|pop|linuxmint)
                echo -e "  ${BLUE}sudo apt-get update && sudo apt-get install -y $PACKAGES${NC}" ;;
            fedora|rhel|centos|rocky|almalinux)
                echo -e "  ${BLUE}sudo dnf install -y $PACKAGES${NC}" ;;
            arch|manjaro|endeavouros)
                echo -e "  ${BLUE}sudo pacman -Sy $PACKAGES${NC}" ;;
        esac
        exit 1
    fi
fi

# ── Create project directories ────────────────────────────────────────────
echo ""
echo -e "${BLUE}Creating project directories...${NC}"

mkdir -p documents/resumes
mkdir -p documents/cover-letters
mkdir -p documents/letters
mkdir -p documents/reports
mkdir -p documents/articles
mkdir -p documents/presentations
mkdir -p documents/invoices
mkdir -p documents/meeting-notes
mkdir -p documents/technical
mkdir -p templates/latex
mkdir -p templates/html
mkdir -p templates/txt
mkdir -p filters
mkdir -p assets/csl
mkdir -p assets/bibliography
mkdir -p output

echo -e "${GREEN}✓ Directories ready${NC}"

# ── Make scripts executable ───────────────────────────────────────────────
chmod +x setup.sh verify.sh 2>/dev/null || true

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${GREEN}Setup complete!${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Run ${BLUE}./verify.sh${NC}             — verify the installation"
echo "  2. Run ${BLUE}make list${NC}               — list available documents"
echo "  3. Run ${BLUE}make resume${NC}             — build the resume in all formats"
echo "  4. Run ${BLUE}make help${NC}               — see all commands"
echo ""
