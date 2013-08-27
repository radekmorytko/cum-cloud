SRC_DIR=src
LOG_DIR=logs
CHAPTERS_SUBDIR=chapters
PDFLATEX_ENV=TEXINPUTS=$$TEXINPUTS:classes:assets:assets/figures:$(SRC_DIR)
PDFLATEX_OPT=-output-directory $(LOG_DIR)

create_log_dir: 
	@if [ ! -d $(LOG_DIR) ]; then \
		tput setaf 2; \
	 	echo 'Creating logs dir ($(LOG_DIR))'; \
		tput sgr0; \
		mkdir -p $(LOG_DIR)/$(CHAPTERS_SUBDIR); fi

$(LOG_DIR)/thesis.pdf: $(SRC_DIR)/thesis.tex
	@tput setaf 2 
	@echo -e 'Producing $<'
	@tput sgr0 

	$(PDFLATEX_ENV) pdflatex $(PDFLATEX_OPT) $< 
	@mv $@ .

all: create_log_dir $(LOG_DIR)/thesis.pdf 

clean:
	@rm -rf $(LOG_DIR)
	@tput setaf 2 
	@echo -e 'Clean completed'
	@tput sgr0 
	
.PHONY: clean all
.DEFAULT_GOAL := all

