JS=axle.js lib/client.js index.js

%.js: %.coffee
	coffee -b -c $<

all: $(JS)

publish: clean $(JS)
	npm publish

npminstall:
	npm install

test: $(JS)
	mocha --compilers coffee:coffee-script/register \
		-b -u tdd --recursive -R spec -C test

clean:
	@rm -fr $(JS)

.PHONY: clean test
