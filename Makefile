# Makefile to generate HTML pages from reStructuredText files in ``$(SRC)``.
# This Makefile replicates the file structure in ``$(SRC)`` in
# ``$(BLD)/$(OUT)``.
#
# - Generate HTML files from RST files (and copy any CSS in
#   ``$(SRC)/$(STATIC)``) with ``make`` or ``make docs``.
# - Add and commit files in ``build`` with ``make commit``.
# - Remove HTML files in ``$(BLD)/$(OUT)`` that lack corresponding source files
#   in ``$(SRC)`` with ``make prune``.
# - Push ``$(GHP)`` branch to GitHub with ``make push``.
# - Remove files from ``$(BLD)/$(OUT)`` with ``make clean``.

SRC := source
BLD := build
OUT := docs
GHP := gh-pages
GIT := $(BLD)/.git
STATIC := static
MSG := "Update docs"

RST := $(wildcard $(SRC)/*.rst)
HTML := $(subst $(SRC),$(BLD)/$(OUT),$(RST:.rst=.html))

SRC_CSS := $(wildcard $(SRC)/$(STATIC)/*.css)
OUT_CSS := $(subst $(SRC),$(BLD)/$(OUT),$(SRC_CSS))

.PHONY : docs
docs : $(GIT) css html

.PHONY : commit
commit : docs
	cd $(BLD) && if [[ $$(git status --porcelain) ]]; then \
		git status; \
		git commit -am $(MSG) && git push origin $(GHP); \
	fi

$(GIT) :
	rm -rf $(BLD)
	git clone .git --branch $(GHP) $(BLD)
	rm -rf $(BLD)/$(OUT)
	mkdir $(BLD)/$(OUT)

.PHONY : html
html : $(HTML)
$(BLD)/$(OUT)/%.html : $(SRC)/%.rst $(OUT_CSS)
	rst2html5.py $< $@ \
		--link-stylesheet \
		--stylesheet-path="./$(BLD)/$(OUT)/$(STATIC)/styles.css"

.PHONY : css
css : $(OUT_CSS)

$(BLD)/$(OUT)/$(STATIC)/%.css : $(SRC)/$(STATIC)/%.css $(BLD)/$(OUT)/$(STATIC)
	cp $< $@

$(BLD)/$(OUT)/$(STATIC) :
	mkdir $(BLD)/$(OUT)/$(STATIC)

.PHONY : prune
prune :
	for htmlfile in $(shell find $(BLD)/$(OUT) -name *.html); do \
		if [ ! -e $(SRC)/$$(basename $${htmlfile} .html).rst ]; then \
		rm $${htmlfile}; \
		echo "Removed '$${htmlfile}'"; \
		fi \
		done

.PHONY : push
push :
	git checkout $(GHP)
	git push
	git checkout main

.PHONY : clean
clean :
	rm -rf $(BLD)
