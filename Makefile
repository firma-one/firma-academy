# firma-academy — agent skill library
#
# Common targets:
#   make build            package every agent's skills into dist/<agent>/*.zip
#   make build-<agent>    package one agent (e.g. make build-pm-copilot)
#   make build-plugins    package every agent as an installable plugin archive
#                         into dist/plugins/<agent>.zip
#   make validate         sanity-check plugin/marketplace manifests + skills
#   make test             run any skill scripts' self-checks (demo modes)
#   make clean            remove dist/
#   make list             list agents and their skills

SHELL := /bin/bash
AGENTS_DIR := agents
DIST_DIR := dist

.PHONY: build build-plugins validate clean list test

build:
	@./scripts/build-skills.sh

build-%:
	@./scripts/build-skills.sh $*

build-plugins:
	@./scripts/build-plugins.sh

validate:
	@./scripts/validate.sh

clean:
	@rm -rf $(DIST_DIR)
	@echo "removed $(DIST_DIR)/"

list:
	@for a in $(AGENTS_DIR)/*/; do \
		[ -d "$$a/skills" ] || continue; \
		echo "$$(basename $$a):"; \
		for s in $$a/skills/*/; do \
			[ -f "$$s/SKILL.md" ] && echo "  - $$(basename $$s)"; \
		done; \
	done

# Run each dashboard-style script in its demo mode to prove it still executes.
test:
	@set -e; \
	for py in $$(find $(AGENTS_DIR) -name 'compute_metrics.py'); do \
		echo "==> $$py --demo"; \
		python3 "$$py" --demo --out /tmp/_skilltest.png >/dev/null && echo "  ok"; \
	done; \
	echo "all script self-checks passed"
