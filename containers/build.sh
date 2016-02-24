#!/bin/bash

. $NVM_DIR/nvm.sh

debug() {
  echo "npm: $(npm -v)"
  echo "npm cache: $(npm config get cache)"
  echo "npm tmp: $(npm config get tmp)"
  echo "npm proxy:"
  echo "   - http: $(npm config get http-proxy)"
  echo "   - https: $(npm config get https-proxy)"
  echo "npm registry: $(npm config get registry)"
}

prep() {
  git init . && git remote add origin "${REPO}"
  git pull origin $BRANCH
  git checkout $COMMIT

  nvm use $NODE_VERSION

  npm config set proxy $http_proxy
  npm config set https-proxy $https_proxy
  npm config set registry http://registry.npmjs.org/
  npm config set strict-ssl false
  npm config set progress false
  npm config set unsafe-perm true
}

build() {
  [ "$DEBUG" == "true" ] && debug
  [ "$DEBUG" == "true" ] && node_opts="-dd" || node_opts=""

  NODE_ENV=production npm ${node_opts} install

  time npm test
  return $?
}

prep && build
