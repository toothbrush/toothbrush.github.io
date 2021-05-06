SHELL = bash

_site:
	mkdir -p ./_site

_site/index.html: index.html | _site
	pandoc $< --output $@

.PHONY: preview
preview:
	@echo "TODO find a simple directory-server."

.PHONY: clean
clean:
	rm -rf _site

.PHONY: upload
upload: build
	mkdir -p _site/.well-known/acme-challenge
	rsync -av --delete _site/ nfs:/home/public/
