preview: site
	./site watch

build: site
	./site build

site: site.hs
	ghc --make site.hs

nothing:
	@echo "Use 'make upload' to upload"

clean:
	rm -f site

.PHONY: upload nothing build clean
upload: build
	rsync -av _site/ nfs:/home/public/
