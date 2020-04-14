PROJECT=gdrive2discord
UID=$(shell id -u)
GID=$(shell id -g)
VERSION=$(shell git describe --always)
SHELL = /bin/bash
local: FORCE
	@echo spawning docker container
	@docker run --rm=true \
		-v ${PWD}/:/go/src/github.com/RISE-Project-STI2D/gdrive2discord/ \
		-v ${PWD}/Makefile:/go/Makefile \
		-v ${PWD}/bin:/go/bin \
		-w /go/src/github.com/RISE-Project-STI2D/gdrive2discord/ \
		golang:1.4-cross \
		make -f /go/Makefile $(PROJECT)-linux-amd64 UID=${UID} GID=${GID} VERSION=${VERSION}

run-local: local
	bin/$(PROJECT)-linux-amd64 configuration.json

opfa: FORCE
	@echo spawning docker container
	@docker run --rm=true \
		-v ${PWD}/:/go/src/github.com/RISE-Project-STI2D/gdrive2discord/ \
		-v ${PWD}/Makefile:/go/Makefile \
		-v ${PWD}/bin:/go/bin \
		-w /go/src/github.com/RISE-Project-STI2D/gdrive2discord/ \
		golang:1.4-cross \
		make -f /go/Makefile $(PROJECT)-linux-amd64 UID=${UID} GID=${GID} VERSION=${VERSION}

all: FORCE
	@echo spawning docker container
	@docker run --rm=true \
		-v ${PWD}/:/go/src/github.com/optionfactory/gdrive2slack/ \
		-v ${PWD}/Makefile:/go/Makefile \
		-v ${PWD}/bin:/go/bin \
		-w /go/src/github.com/optionfactory/gdrive2slack/ \
		golang:1.4-cross \
		make -f /go/Makefile build UID=${UID} GID=${GID} VERSION=${VERSION}

clean: FORCE
	-rm -rf bin/$(PROJECT)-*

build: \
	$(PROJECT)-linux-386 $(PROJECT)-linux-amd64 $(PROJECT)-linux-arm \
	$(PROJECT)-darwin-386 $(PROJECT)-darwin-amd64 \
	$(PROJECT)-dragonfly-386 $(PROJECT)-dragonfly-amd64 \
	$(PROJECT)-freebsd-386 $(PROJECT)-freebsd-amd64 $(PROJECT)-freebsd-arm \
	$(PROJECT)-netbsd-386 $(PROJECT)-netbsd-amd64 $(PROJECT)-netbsd-arm \
	$(PROJECT)-openbsd-386 $(PROJECT)-openbsd-amd64 \
	$(PROJECT)-solaris-amd64 \
	$(PROJECT)-windows-386 $(PROJECT)-windows-amd64


$(PROJECT)-linux-%: GOOS = linux
$(PROJECT)-darwin-%: GOOS = darwin
$(PROJECT)-dragonfly-%: GOOS = dragonfly
$(PROJECT)-freebsd-%: GOOS = freebsd
$(PROJECT)-netbsd-%: GOOS = netbsd
$(PROJECT)-openbsd-%: GOOS = openbsd
$(PROJECT)-solaris-%: GOOS = solaris
$(PROJECT)-windows-%: GOOS = windows
$(PROJECT)-windows-%: EXT = .exe

$(PROJECT)-%-amd64: GOARCH = amd64
$(PROJECT)-%-386: GOARCH = 386
$(PROJECT)-%-arm: GOARCH = arm

$(PROJECT)-%: format *.go
	@echo building for $(GOOS):$(GOARCH)
	@GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 go get -installsuffix netgo ./...
	@if [ "${GOOS}" == "linux" -a "${GOARCH}" == "amd64" ]; then \
		GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 go test -a -tags netgo -installsuffix netgo -ldflags "-X main.version $(VERSION)" ./...; \
	fi
	@GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 go install -a -tags netgo -installsuffix netgo -ldflags "-X main.version $(VERSION)"
	@if [ "${GOOS}" == "linux" -a "${GOARCH}" == "amd64" ]; then \
		mv "/go/bin/${PROJECT}${EXT}" "/go/bin/${PROJECT}-${GOOS}-${GOARCH}${EXT}"; \
	else \
		mv "/go/bin/${GOOS}_${GOARCH}/${PROJECT}${EXT}" "/go/bin/${PROJECT}-${GOOS}-${GOARCH}${EXT}"; \
		rm -rf "/go/bin/${GOOS}_${GOARCH}/"; \
	fi
	@chown ${UID}:${GID} "/go/bin/${PROJECT}-${GOOS}-${GOARCH}${EXT}"

format:
	@echo reformatting
	@gofmt -w=true -s=true .

FORCE:
