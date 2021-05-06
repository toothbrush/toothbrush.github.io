SHELL = bash

PAGES = _site/index.html
.PHONY: all
all: ${PAGES} _site/css _site/images

_site/css: $(wildcard css/*) | _site
	mkdir -p $@
	cp $^ $@

_site/images: $(wildcard images/*) | _site
	mkdir -p $@
	cp $^ $@

_site:
	mkdir -p $@

_site/index.html: index.md templates/pandoc-default.html | _site
	pandoc $< \
	  --variable modified="$(shell date +"%d/%B/%Y")" \
	  --template templates/pandoc-default.html \
	  --standalone \
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
