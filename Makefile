SHELL = bash

PAGES = _site/index.html _site/recipes/index.html
RECIPES_IN = $(wildcard recipes/*.md)
RECIPES_OUT = $(addprefix _site/,${RECIPES_IN:md=html})

.PHONY: all
all: ${PAGES} ${RECIPES_OUT} _site/css _site/images

_site/css: $(wildcard css/*) | _site
	mkdir -p $@
	cp $^ $@

_site/images: $(wildcard images/*) | _site
	mkdir -p $@
	cp $^ $@

_site/recipes: | _site
	mkdir -p $@

_site:
	mkdir -p $@

_site/recipes/index.html: recipes.md templates/pandoc-default.html | _site/recipes
	pandoc $< \
	  --variable title-prefix="paul" \
	  --variable modified="$(shell date +"%d/%B/%Y")" \
	  --template templates/pandoc-default.html \
	  --output $@

_site/index.html: index.md templates/pandoc-default.html | _site
	pandoc $< \
	  --variable title-prefix="paul" \
	  --variable modified="$(shell date +"%d/%B/%Y")" \
	  --template templates/pandoc-default.html \
	  --output $@

_site/recipes/%.html: recipes/%.md | _site/recipes
	pandoc $< \
	  --variable title-prefix="paul" \
	  --variable modified="$(shell date +"%d/%B/%Y")" \
	  --template templates/pandoc-default.html \
	  --output $@

.PHONY: preview
preview:
	( cd _site && python3 -m http.server )

.PHONY: clean
clean:
	rm -rf _site

.PHONY: upload
upload: build
	mkdir -p _site/.well-known/acme-challenge
	rsync -av --delete _site/ nfs:/home/public/
