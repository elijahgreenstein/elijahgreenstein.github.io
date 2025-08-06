# Default Pykari Makefile

BLD := _build

.PHONY: generate
generate:
	pykari

.PHONY: clean
clean:
	rm -rf $(BLD)