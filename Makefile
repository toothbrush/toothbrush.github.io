build: site
	./site rebuild

preview: site
	./site watch

site: site.hs
	ghc --make site.hs
	hlint -c site.hs

nothing:
	@echo "Use 'make upload' to upload"

clean:
	rm -f site

.PHONY: upload nothing build clean
upload: build
	rsync -av _site/ nfs:/home/public/
