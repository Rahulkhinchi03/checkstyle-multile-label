#!/bin/bash
set -e

source ./.ci/util.sh

checkForVariable() {
  VAR_NAME=$1
  if [ -v "${!VAR_NAME}" ]; then
    echo "Error: Define $1 environment variable"
    exit 1
  fi
}

checkForVariable "READ_ONLY_TOKEN"

checkout_from https://github.com/checkstyle/contribution

cd .ci-temp/contribution/releasenotes-builder
mvn -e --no-transfer-progress clean compile package
cd ../../../

if [ -d .ci-temp/checkstyle-multiple-label ]; then
  cd .ci-temp/checkstyle-multiple-label/
  git reset --hard origin/master
  git pull origin master
  git fetch --tags
  cd ../../
else
  cd .ci-temp/
  git clone https://github.com/Rahulkhinchi03/checkstyle-multiple-label
  cd ../
fi

CS_RELEASE_VERSION=checkstyle-1.2
echo CS_RELEASE_VERSION="$CS_RELEASE_VERSION"

cd .ci-temp/checkstyle-multiple-label
LATEST_RELEASE_TAG=$(curl -s https://api.github.com/repos/Rahulkhinchi03/checkstyle-multiple-label/releases/latest \
                       | jq ".tag_name")
echo LATEST_RELEASE_TAG="$LATEST_RELEASE_TAG"

cd ../

java -jar contribution/releasenotes-builder/target/releasenotes-builder-1.0-all.jar \
        -localRepoPath checkstyle-multiple-label \
        -remoteRepoPath Rahulkhinchi03/checkstyle-multiple-label \
        -startRef "$LATEST_RELEASE_TAG" \
        -releaseNumber "$CS_RELEASE_VERSION" \
        -githubAuthToken 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 \
        -generateAll
