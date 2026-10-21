# Marp slide deck build
#
# Targets:
#   make            Build the PDF (same as `make pdf`)
#   make pdf        Render slides.md -> out/slides.pdf
#   make png        Render slides as images -> out/slides/
#   make pptx       Render slides.md -> out/slides.pptx
#   make watch      Live-reload slide preview in the browser
#   make clean      Remove the out/ directory
#   make open       Build PDF and open it with the system viewer

MARP      ?= marp
OUT       ?= out
SRC       ?= slides.md
NUM       ?= slides-num.md
ALLOW_LOCAL = --allow-local-files
PY        ?= python3

# generated copy of the deck with line numbers added to every `rust` code block
$(NUM): $(SRC)
	$(PY) scripts/add_line_numbers.py $< $@

.PHONY: all pdf png pptx watch clean open

all: pdf

$(OUT)/slides.pdf: $(NUM)
	$(MARP) $(ALLOW_LOCAL) --pdf $< -o $@

pdf: $(OUT)/slides.pdf

png: $(NUM)
	$(MARP) $(ALLOW_LOCAL) --images png $< -o $(OUT)/slides

pptx: $(NUM)
	$(MARP) --pptx $< -o $(OUT)/slides.pptx

watch: $(SRC)
	$(MARP) --watch $(SRC)

clean:
	rm -rf $(OUT)/*

open: pdf
	@# xdg-open $(OUT)/slides.pdf
	mupdf $(OUT)/slides.pdf
