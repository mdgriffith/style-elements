.PHONY: spellcheck
spellcheck: $(shell find src -name '*.elm')
	./tests/spellcheck.sh $(shell find src -name '*.elm')
