SHELL = bash

PAGES = _site/index.html
.PHONY: all
all: ${PAGES}

_site:
	mkdir -p ./_site

_site/index.html: index.md | _site
	pandoc $< --template templates/pandoc-default.html --standalone --output $@

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
