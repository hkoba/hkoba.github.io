GENERATOR := ../../scripts/gen-revealjs.pl
GEN_META  := ../../scripts/OpenGraphMeta.pm og_tsv_to_meta

HTMLS := $(patsubst %.md,%.html,$(wildcard *.md))

all: $(HTMLS)

loop:
	while inotifywait index.md; do make; done

%.html: %.md
	$(GENERATOR) -r -o $@ $^

%.meta: %.og.tsv
	$(GEN_META) $^ > $@
