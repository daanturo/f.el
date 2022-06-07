# -*- indent-tabs-mode: t -*-
SHELL := /usr/bin/env bash

EMACS ?= emacs
EASK ?= eask

.PHONY: clean checkdoc lint package install compile test

ci: clean package install compile

package:
	@echo "Packaging..."
	$(EASK) package

install:
	@echo "Installing"
	$(EASK) install

compile:
	@echo "Compiling..."
	$(EASK) compile

test:
	@echo "Testing..."
	$(EASK) ert ./test/*.el

checkdoc:
	@echo "Run checkdoc..."
	$(EASK) checkdoc

lint:
	@echo "Run package-lint..."
	$(EASK) lint

doc:
	@echo "Generating doc..."
	$(EASK) exec $(EMACS) -Q --script bin/docs.el

clean:
	$(EASK) clean-all
