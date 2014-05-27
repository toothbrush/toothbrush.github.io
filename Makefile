preview: site
	./site watch

build: site
	./site build

site: site.hs
	ghc --make site.hs

nothing:
	@echo "Use 'make upload' to upload"

.PHONY: upload nothing build
upload: build
	rsync -av _site/ nfs:/home/public/
