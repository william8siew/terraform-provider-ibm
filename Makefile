TEST?=$$(go list ./... | grep -v 'vendor')
GOFMT_FILES?=$$(find .  -path ./.direnv -prune -false -o -name '*.go' |grep -v vendor)
COVER_TEST?=$$(go list ./... | grep -v 'vendor')
TEST_TIMEOUT?=700m
#HOSTNAME=github.ibm.com
HOSTNAME=registry.terraform.io
NAMESPACE=IBM-Cloud
NAME=ibm
BINARY=terraform-provider-${NAME}
VERSION=0.0.1
OS_ARCH=$$(go env GOOS)_$$(go env GOARCH)
#OS_ARCH=darwin_amd64

default: install

tools:
	@go get golang.org/x/sys/unix
	@go get github.com/kardianos/govendor
	@go get github.com/mitchellh/gox
	@go get golang.org/x/tools/cmd/cover


build: fmtcheck vet
	go build -o ${BINARY}

build_linux: fmtcheck vet
	env OS_ARCH=linux_amd64 env GOOS=linux go build -o ${BINARY}

bin: fmtcheck vet tools
	@TF_RELEASE=1 sh -c "'$(CURDIR)/scripts/build.sh'"

dev: fmtcheck vet tools
	@TF_DEV=1 sh -c "'$(CURDIR)/scripts/build.sh'"

install: build
	sed -i '' '/hashes/d' ./examples/ibm-key-protect/.terraform.lock.hcl
	sed -i '' '/h1:/d' ./examples/ibm-key-protect/.terraform.lock.hcl
	sed -i '' '/]/d' ./examples/ibm-key-protect/.terraform.lock.hcl
	rm -r -f ./examples/ibm-key-protect/.terraform/
	mkdir -p ~/.terraform.d/plugins/${HOSTNAME}/${NAMESPACE}/${NAME}/${VERSION}/${OS_ARCH}
	rm ~/.terraform.d/plugins/${HOSTNAME}/${NAMESPACE}/${NAME}/${VERSION}/${OS_ARCH}/${BINARY} || true
	mv ${BINARY} ~/.terraform.d/plugins/${HOSTNAME}/${NAMESPACE}/${NAME}/${VERSION}/${OS_ARCH}/
	
	pushd ./examples/ibm-key-protect; terraform init; popd

install_linux: build_linux
	sed -i '' '/hashes/d' ./examples/ibm-key-protect/.terraform.lock.hcl
	sed -i '' '/h1:/d' ./examples/ibm-key-protect/.terraform.lock.hcl
	sed -i '' '/]/d' ./examples/ibm-key-protect/.terraform.lock.hcl
	rm -r -f ./examples/ibm-key-protect/.terraform/
	mkdir -p ~/.terraform.d/plugins/${HOSTNAME}/${NAMESPACE}/${NAME}/${VERSION}/linux_amd64
	rm ~/.terraform.d/plugins/${HOSTNAME}/${NAMESPACE}/${NAME}/${VERSION}/linux_amd64/${BINARY} || true
	mv ${BINARY} ~/.terraform.d/plugins/${HOSTNAME}/${NAMESPACE}/${NAME}/${VERSION}/linux_amd64/

test: fmtcheck
	go test -i $(TEST) || exit 1
	echo $(TEST) | \
		xargs -t -n4 go test $(TESTARGS) -timeout=30s -parallel=4

testacc: fmtcheck
	TF_ACC=1 go test $(TEST) -v $(TESTARGS) -timeout $(TEST_TIMEOUT)

testrace: fmtcheck
	TF_ACC= go test -race $(TEST) $(TESTARGS)

cover:
	@go tool cover 2>/dev/null; if [ $$? -eq 3 ]; then \
		go get -u golang.org/x/tools/cmd/cover; \
	fi
	go test $(COVER_TEST) -coverprofile=coverage.out
	go tool cover -html=coverage.out
	rm coverage.out

vet:
	@echo "go vet ."
	@go vet $$(go list ./... | grep -v vendor/) ; if [ $$? -eq 1 ]; then \
		echo ""; \
		echo "Vet found suspicious constructs. Please check the reported constructs"; \
		echo "and fix them if necessary before submitting the code for review."; \
		exit 1; \
	fi

fmt:
	gofmt -w $(GOFMT_FILES)

fmtcheck:
	@sh -c "'$(CURDIR)/scripts/gofmtcheck.sh'"

errcheck:
	@sh -c "'$(CURDIR)/scripts/errcheck.sh'"

vendor-status:
	@govendor status

test-compile: fmtcheck
	@if [ "$(TEST)" = "./..." ]; then \
		echo "ERROR: Set TEST to a specific package. For example,"; \
		echo "  make test-compile TEST=./builtin/providers/aws"; \
		exit 1; \
	fi
	go test -c $(TEST) $(TESTARGS)

.PHONY: build bin dev test testacc testrace cover vet fmt fmtcheck errcheck vendor-status test-compile