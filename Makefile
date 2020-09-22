.PHONY: build
build: site
	stack exec -- site rebuild
	chmod g+w _site

site: site.hs
	stack build

.PHONY: clean
clean:
	stack clean

.PHONY: upload
upload: build
	mkdir -p _site/.well-known/acme-challenge
	rsync -av --delete _site/ nfs:/home/public/
