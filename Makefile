IMAGE_TAG := ikngtty/fanza-watcher

.PHONY: run build build_and_run

run:
	docker run --rm --name=fanza-watcher $(IMAGE_TAG) $(ARGS)

build:
	docker build . -t=$(IMAGE_TAG)

build_and_run:
	$(MAKE) build
	$(MAKE) run
