all: test

build: clean
	appsody stack package

test: build
	appsody stack validate --no-package

clean:
	echo "Nothing to do"
