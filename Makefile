all: test

test: build
	appsody stack validate --no-package

build: clean
	appsody stack package --image-namespace boson --image-registry quay.io --verbose

publish: test
	./ci/publish.sh
clean:
	echo "Nothing to do"
