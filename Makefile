JS=axle.js lib/client.js index.js
TWERP=`which twerp`

%.js: %.coffee
	coffee -b -c $<

all: $(JS)

publish: clean $(JS)
	npm publish

npminstall:
	npm install

test:
	$(TWERP) $(MY_TWERP_OPTIONS) `find test -name '*_test.coffee'`

stublesstest:
	NO_STUB=1 $(MAKE) test

clean:
	@rm -fr $(JS)

.PHONY: clean test
