LATEXMK := latexmk
FIGENERATOR := python3 tool/figure-generator.py
BITFIELD := npx bit-field
CONTFORM := perl tool/content-formatter.pl
PANDOCMK := tool/pandoc.mk
# set metadata file for pandoc (located in pandoc/data/metadata)
# or eleg-book, eleg-paper, eleg-note
METADATA_FILE  ?= eleg-book

OUTDIR ?= build
BUILDIR := $(PWD)/$(OUTDIR)

ifeq ($(V),)
	TEXOPTS += -quiet
	NOINFO := > /dev/null 2>&1
endif

TOPTEXES ?= main.tex
TEXES := $(shell find . -name "*.tex" | sort)

FIGSRC := $(wildcard drawio/*.drawio)
FIGSRC += $(wildcard dac/*)
SVGSRC := $(wildcard figure/*.svg)

TARGET ?= 嵌入式知识体系总结

export TEXMFHOME=texmf
export TARGET CONTFORM BUILDIR METADATA_FILE

all: $(BUILDIR) pdf

pdf: $(BUILDIR)/$(TARGET).tex
	@if [[ ! -d figures ]]; then make figures; fi
	@$(LATEXMK) $(TEXOPTS) $< || $(LATEXMK) -c $<

pandoc: $(BUILDIR)
	@make -f $(PANDOCMK)

$(BUILDIR)/$(TARGET).tex: $(TOPTEXES) $(BUILDIR)
	@if [[ ! -f $@ ]]; then ln -sf ../$< $@; fi

$(BUILDIR):
	@mkdir -p $@

pandoc-tex: $(BUILDIR)
	@make -f $(PANDOCMK) tex

format: $(TEXES)
	@$(CONTFORM) $^
	@make -f $(PANDOCMK) format

figures: $(FIGSRC) $(SVGSRC)
	@mkdir -p figures
	@for json in dac/*.json; do $(BITFIELD) --fontsize=9 -i $$json > figures/$$(basename $${json%%.*}).svg; done
	$(FIGENERATOR) -c $(SVGSRC) figures/*.svg
	$(FIGENERATOR) $(FIGSRC)

view: pdf
	@$(LATEXMK) -f -pvc -view=pdf $(BUILDIR)/$(TARGET) $(NOINFO) &

pandoc-view: pandoc-tex pdf
	@$(LATEXMK) -f -pvc -view=pdf $(BUILDIR)/$(TARGET) $(NOINFO) &

kill-view:
	@kill $$(ps aux | grep "latexmk -f -pvc" \
		| head -1 | awk '{print $$2}')
	@kill $$(ps aux | grep $(TARGET).pdf \
		| head -1 | awk '{print $$2}')

clean: $(BUILDIR)/$(TARGET).tex
	@$(LATEXMK) -c $<

dist-clean:
	@$(RM) -r $(OUTDIR) auto \
		*.aux *.log *.out *.pdf *.synctex.gz *.toc

clean-figures:
	@$(RM) -r figures

.PHONY: all clean figures pandoc
