PAGES = _site/index.html _site/recipes/index.html
RECIPES_IN = $(wildcard recipes/*.md)
RECIPES_OUT = $(addprefix _site/,${RECIPES_IN:md=html})

GITSHA := $(shell git rev-parse HEAD)

.PHONY: all
all: ${RECIPES_OUT} ${PAGES} _site/css _site/images

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

sort/sort:
	( cd sort && go build )

recipes.md: ${RECIPES_IN} lib/generate_recipes_index.sh sort/sort
	./lib/generate_recipes_index.sh > $@

_site/recipes/index.html: _site/recipes.html | _site/recipes
	cp $< $@

%.md.date: %.md lib/pretty_date.sh
	@lib/pretty_date.sh $< > $@

_site/%.html: %.md %.md.date templates/pandoc-default.html | _site _site/recipes
	pandoc $< \
	  --variable title-prefix="paul" \
	  --variable date="$(shell cat $*.md.date)" \
	  --variable modified="$(shell date +"%d/%B/%Y")" \
	  --variable gitsha="${GITSHA}" \
	  --template templates/pandoc-default.html \
	  --output $@

.PHONY: preview
preview:
	( cd _site && python3 -m http.server )

.PHONY: check
check:
	shellcheck lib/*.sh

.PHONY: clean
clean:
	rm -rf _site

.PHONY: upload
upload: clean all
	mkdir -p _site/.well-known/acme-challenge
	rsync -av --delete _site/ nfs:/home/public/
