nothing:
	@echo "Use 'make upload' to upload"

.PHONY: upload nothing
upload:
	rsync -av _site/ nfs:/home/public/
