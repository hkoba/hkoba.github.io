GENERATOR := /opt/drawio/drawio

DRAWIO_SVGS := $(patsubst %.drawio,%.drawio.svg,$(wildcard *.drawio))

all: $(DRAWIO_SVGS)

loop:
	while inotifywait *.drawio; do make; done

%.drawio.svg: %.drawio
	$(GENERATOR) --export --embed-svg-images -o $@ $^
