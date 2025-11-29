# ----------------------------------------
# Auto: Pull → Build → Install → Commit → Push
# ----------------------------------------

BINARY=target/x86_64-unknown-linux-musl/release/govee
ADDON_BIN=addon/bin/govee
COMMIT_MSG="Auto-build: Update musl govee binary"

.PHONY: pull build-musl install commit push update all

pull:
	git fetch origin
	git pull --rebase origin main

build-musl:
	cargo build --release -p govee --target x86_64-unknown-linux-musl

install:
	cp $(BINARY) $(ADDON_BIN)
	chmod +x $(ADDON_BIN)

commit:
	git add $(ADDON_BIN)
	git commit -m $(COMMIT_MSG) || true

push:
	git push origin main

update: pull build-musl install commit push
	@echo "✔ Update abgeschlossen."

all: update
