IMAGE_TAG := ikngtty/fanza-watcher:use-inner-api
ENV_FILE_OPTION := $(if $(wildcard .env),--env-file=.env,)

.PHONY: run build build_and_run

run:
	docker run --rm --name=fanza-watcher $(ENV_FILE_OPTION) $(IMAGE_TAG) $(ARGS)

build:
	docker build . -t=$(IMAGE_TAG)

build_and_run:
	$(MAKE) build
	$(MAKE) run
