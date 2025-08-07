IMAGE_TAG := ikngtty/fanza-watcher
ENV_FILE_OPTION := $(shell if [ -f .env ]; then echo "--env-file .env"; fi)

.PHONY: run build build_and_run

run:
	docker run --rm --name=fanza-watcher $(ENV_FILE_OPTION) $(IMAGE_TAG) $(ARGS)

build:
	docker build . -t=$(IMAGE_TAG)

build_and_run:
	$(MAKE) build
	$(MAKE) run
