GITSHA := $(shell git rev-parse HEAD)

.PHONY: preview
preview:
	bundle exec jekyll serve

.PHONY: clean
clean:
	rm -rf _site
