SWIFT ?= swift

.PHONY: format lint build test validate docs docs-serve

format:
	./scripts/format.sh

lint:
	./scripts/lint.sh

build:
	./scripts/build.sh

test:
	./scripts/test.sh

validate:
	./scripts/validate.sh

docs:
	./scripts/docs.sh

docs-serve:
	./scripts/docs.sh serve
