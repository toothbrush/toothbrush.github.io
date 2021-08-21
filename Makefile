GITSHA := $(shell git rev-parse HEAD)

.PHONY: all
all: preview

sort/sort:
	( cd sort && go build )

.PHONY: preview
preview:
	bundle exec jekyll serve

.PHONY: check
check:
	shellcheck lib/*.sh

.PHONY: clean
clean:
	rm -rf _site

