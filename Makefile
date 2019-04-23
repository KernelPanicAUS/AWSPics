IMAGE:=awspics
IMAGE_TAG:=latest
PROJECT_DIR:=/opt/awspics

.PHONY: setup lint build clean deploy authors

ifeq ($(origin AWS_PROFILE), undefined)
AWS_PROFILE = default
endif

setup:
	@docker build -f Dockerfile . -t $(IMAGE):$(IMAGE_TAG)

lint: setup
	@docker \
		run \
		--mount type=bind,source=`pwd`,target=$(PROJECT_DIR) \
		--workdir $(PROJECT_DIR) \
		$(IMAGE):$(IMAGE_TAG) \
		cfn-lint app.yml

build: setup lint
	@docker \
		run \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--mount type=bind,source=`pwd`,target=$(PROJECT_DIR) \
		--workdir $(PROJECT_DIR) \
		$(IMAGE):$(IMAGE_TAG) \
		./bin/build-lambdas.sh

clean:
	rm -rf dist/*.zip

deploy: setup
	@docker \
		run \
		-e AWS_PROFILE=$(AWS_PROFILE) \
		--mount type=bind,source=$(HOME)/.aws,target=/root/.aws \
		$(IMAGE):$(IMAGE_TAG) \
		aws s3 ls

AUTHORS:
	@$(file >$@,# This file lists all individuals having contributed content to the repository.)
	@$(file >>$@,# For how it is generated, see `make AUTHORS`.)
	@echo "$(shell git log --format='\n%aN <%aE>' | LC_ALL=C.UTF-8 sort -uf)" >> $@
