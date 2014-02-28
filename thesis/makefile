SRC_DIR=src
LOG_DIR=logs
PDFLATEX_ENV=TEXINPUTS=$$TEXINPUTS:classes:assets:assets/figures:assets/drawings:assets/listings:$(SRC_DIR)
BIBINPUTS_ENV=BIBINPUTS=$$BIBINPUTS:../$(SRC_DIR)
PDFLATEX_OPT=-output-directory $(LOG_DIR)

THESIS_SRC=$(SRC_DIR)/thesis.tex
THESIS_DST=$(LOG_DIR)/thesis.pdf 
THESIS_RAW=$(SRC_DIR)/thesis

create_log_dir: 
	@if [ ! -d $(LOG_DIR) ]; then \
		tput setaf 2; \
	 	echo 'Creating logs dir ($(LOG_DIR))'; \
		tput sgr0; \
		cd $(LOG_DIR) && ln -s ../$(THESIS_SRC) && cd .. ; \
		mkdir -p $(LOG_DIR)/appendices; \
		mkdir -p $(LOG_DIR)/chapters; fi

thesis:
	@tput setaf 2 
	@echo -e 'Producing $(THESIS_SRC)'
	@tput sgr0 

	$(PDFLATEX_ENV) pdflatex $(PDFLATEX_OPT) $(THESIS_SRC)
	/usr/share/texmf-texlive/scripts/glossaries/makeglossaries -d logs thesis
	cd $(LOG_DIR) && $(BIBINPUTS_ENV) bibtex thesis.aux && cd ..
	$(PDFLATEX_ENV) pdflatex $(PDFLATEX_OPT) $(THESIS_SRC)
	cd $(LOG_DIR)
	@mv $(THESIS_DST) .

all: create_log_dir thesis

clean:
	@rm -rf $(LOG_DIR)
	@tput setaf 2 
	@echo -e 'Clean completed'
	@tput sgr0 
	
.PHONY: clean all
.DEFAULT_GOAL := all

