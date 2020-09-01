svgfigures = $(wildcard figures/*.svg)
xcffigures = $(wildcard figures/*.xcf)
pdffigures = $(svgfigures:.svg=.pdf)
jpgfigures = $(xcffigures:.xcf=.jpg)
src = $(wildcard *.tex)
texts = $(src:.tex=.txt)

all: thesis

thesis: $(src) $(pdffigures) $(jpgfigures)
	texfot latexmk -halt-on-error -pdf --shell-escape -g -f thesis.tex 2>&1

thesis-print: thesis-print.tex $(src) $(pdffigures) $(jpgfigures)
	texfot latexmk -halt-on-error -pdf --shell-escape -g thesis-print.tex 2>&1

thesis-print.tex: thesis.tex
	sed -e 's/linkcolor={.*}/linkcolor={black}/' \
		-e 's/citecolor={.*}/citecolor={black}/' \
		-e 's/urlcolor={.*}/urlcolor={black}/' \
		-e 's/\\iffalse.*%@ifprint/\\iftrue/' \
		$< > $@

text: $(texts)

.PHONY: clean

clean-thesis:
	latexmk -c

clean-figures:
	rm -f $(pdffigures)
	rm -f $(jpgfigures)
	rm $(texts)

clean: clean-thesis clean-figures

%.pdf: %.svg
	inkscape $< --export-pdf=$@

%.jpg: %.xcf
	util/xcfToJpg.sh $< $@

%.txt: %.tex
	detex $< | sed ':a;N;$$!{/\n$$/!ba}; s/[[:blank:]]*\n[[:blank:]]*/ /g' > $@