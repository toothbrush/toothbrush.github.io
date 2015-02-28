build: site
	./dist/build/site/site rebuild

site: site.hs
	cabal build
	hlint -c site.hs

nothing:
	@echo "Use 'make upload' to upload"

clean:
	rm -vrf dist

.PHONY: upload nothing build clean
upload: build
	rsync --delete -av _site/ nfs:/home/public/
