SRC_DIR=src
LOG_DIR=logs
CHAPTERS_SUBDIR=chapters
PDFLATEX_ENV=TEXINPUTS=$$TEXINPUTS:classes:assets:assets/figures:$(SRC_DIR)
BIBINPUTS_ENV=BIBINPUTS=$$BIBINPUTS:../$(SRC_DIR)
PDFLATEX_OPT=-output-directory $(LOG_DIR)

THESIS_SRC=$(SRC_DIR)/thesis.tex
THESIS_DST=$(LOG_DIR)/thesis.pdf 

create_log_dir: 
	@if [ ! -d $(LOG_DIR) ]; then \
		tput setaf 2; \
	 	echo 'Creating logs dir ($(LOG_DIR))'; \
		tput sgr0; \
		mkdir -p $(LOG_DIR)/$(CHAPTERS_SUBDIR); fi

thesis:
	@tput setaf 2 
	@echo -e 'Producing $(THESIS_SRC)'
	@tput sgr0 

	$(PDFLATEX_ENV) pdflatex $(PDFLATEX_OPT) $(THESIS_SRC)
	cd $(LOG_DIR) && $(BIBINPUTS_ENV) bibtex thesis.aux
	@mv $(THESIS_DST) .

all: create_log_dir thesis

clean:
	@rm -rf $(LOG_DIR)
	@tput setaf 2 
	@echo -e 'Clean completed'
	@tput sgr0 
	
.PHONY: clean all
.DEFAULT_GOAL := all

