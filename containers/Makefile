AWSURL		:= $(ECR_REPO).dkr.ecr.us-east-1.amazonaws.com
DOCKER      := $(which docker)
BUILDID 	:= $(shell uuidgen)

define worker.yml
$(BUILDID):
    image: $(IMAGE)
    container_name: $(BUILDID)
    environment:
        REPO: {{repo}}
        BRANCH: {{branch}}
        COMMIT: {{commit}}
        {{#environment}}
        {{key}}: {{value}}
        {{/environment}}
    labels:
        author: {{author}}
        vender: cc.co.denzuko.docker-microservices
    volumes_from:
        - dpcs-node-depends-{{dpcsDepsVersion}}:ro
    volumes:
        - /node_modules:/srv/node_modules
enddef

define base-dockerfile
FROM ubuntu:14.04.3
MAINTAINER 0xFC13F74B - https://about.me/dwightaspencer

ENV LC_ALL=C DEBIAN_FRONTEND=noninteractive TZ=America/Denver no_proxy="localhost,127.0.0.0/8,172.17.42.1/16,.consul" NODE_VERSION=4.2.1 NVM_VERSION=0.26.1 NVM_DIR=/usr/local/nvm PROFILE=/etc/profile

# Provisioning stage 1
RUN apt-get update &&\
    apt-get install -y --no-install-recommends python-software-properties git python-pip\
        curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev \
        libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev \
        apt-transport-https ca-certificates wget s3cmd && \
    update-ca-certificates &&\
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ | tee /etc/timezone >/dev/null &&\
    curl -sLk https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh >/tmp/nvm-install.sh &&\
    chmod +x /tmp/nvm-install.sh && /tmp/nvm-install.sh &&\
    . $NVM_DIR/nvm.sh && nvm install $NODE_VERSION &&\
    apt-get autoremove && apt-get clean -y all && apt-get autoclean all &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/dpkg/dpkg.cfg.d/02apt-speedup
enddef

define worker-dockerfile
FROM $(ECRREPO)$(AWSURL)/base:1.0.0
MAINTAINER 0xFC13F74B - https://about.me/dwightaspencer

WORKDIR /srv
ADD build.sh /tmp/build.sh
ENTRYPOINT /tmp/build.sh
RUN /bin/chmod +x /tmp/build.sh
enddef

a$(1): b c
    touch a$(1)

endef


.PHONY: build release deploy all

all:
	@echo "Usage: IMAGE=worker ECR_REPO=0000000 SEMVER=1.0.0 make deploy"

build:
	@$(DOCKER) build -t $(ECR_REPO).$(AWSURL)/$(IMAGE):$(SEMVER) $(IMAGE)/.
	@$(DOCKER) rmi $(ECR_REPO).$(AWSURL)/$(IMAGE):latest
	@$(DOCEKR) tag $(ECR_REPO).$(AWSURL)/$(IMAGE):$(SEMVER) $(ECR_REPO)/$(IMAGE):latest

release: build
	@eval `aws ecr get-login`
	@$(DOCKER) push $(ECR_REPO).$(AWSURL)/$(IMAGE):$(SEMVER)
	@$(DOCKER) pull $(ECR_REPO).$(AWSURL)/$(IMAGE):$(SEMVER)

deploy: release
	@$(DOCKER) run --name -d $(IMAGE)-$(SEMVER) $(ECR_REPO).$(AWSURL)/$(IMAGE):$(SEMVER)
