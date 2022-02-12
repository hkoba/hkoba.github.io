GENERATOR := marp
OG_GEN := ../../scripts/OpenGraphMeta.pm og_tsv_to_meta

HTMLS := $(patsubst %.md,%.html,$(wildcard *.md))
OG_META := $(patsubst %.og.tsv,%.meta,$(wildcard index.og.tsv))

all: $(HTMLS)

loop:
	while inotifywait index.md; do make; done

%.html: %.md
	$(GENERATOR) -o $@ $^

%.meta: %.og.tsv
	$(OG_GEN) $^ > $@

index.html: $(OG_META)
