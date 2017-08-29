build: site
	./dist/build/site/site rebuild
	chmod g+w _site

site: site.hs
	cabal build
	-hlint -c site.hs

nothing:
	@echo "Use 'make upload' to upload"

clean:
	rm -vrf dist

.PHONY: upload nothing build clean

upload: build
	mkdir -p _site/.well-known/acme-challenge
	rsync -av --delete _site/ nfs:/home/public/
