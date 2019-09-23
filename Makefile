VERSION=$(shell python setup.py --version)

.PHONY: all test install tags upload coverage lint

all:
	@echo 'Available targets: install, test, upload, coverage, lint'

install:
	pip install -U -e .

test:
	python setup.py test

upload: README.md setup.py
	git push --tags origin master
	#hub release create -m v$(VERSION) -m "$$(awk -v RS='' '/\[v$(VERSION)\]/' Changelog.md | tail -n+2)" v$(VERSION)
	rm -f dist/*
	python setup.py bdist_wheel --universal
	twine upload dist/*

coverage:
	coverage erase
	coverage run --source bibu setup.py test
	coverage report
	coverage html

lint:
	flake8 bibu test
