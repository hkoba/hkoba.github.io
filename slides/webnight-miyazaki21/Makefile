GENERATOR := marp

PDFS := $(patsubst %.md,%.pdf,$(wildcard *.md))
JPGS := $(patsubst %.md,%.jpg,$(wildcard *.md))

all: $(PDFS) $(JPGS)

loop:
	while inotifywait index.md; do make; done

%.pdf: %.md
	$(GENERATOR) --allow-local-files -o $@ $^

%.jpg: %.md
	$(GENERATOR) --image=jpg --allow-local-files -o $@ $^

%.png: %.md
	$(GENERATOR) --image=png --allow-local-files -o $@ $^

server:
	marp -p --server --allow-local-files .
