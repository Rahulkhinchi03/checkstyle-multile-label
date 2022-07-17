#!/bin/bash
set -e

function checkout_from {
  CLONE_URL=$1
  PROJECT=$(echo "$CLONE_URL" | sed -nE 's/.*\/(.*).git/\1/p')
  cd ../
  mkdir -p .ci-temp
  cd .ci-temp
  if [ -d "$PROJECT" ]; then
    echo "Target project $PROJECT is already cloned, latest changes will be fetched"
    cd "$PROJECT"
    git fetch
    cd ../
  else
    for i in 1 2 3 4 5; do git clone "$CLONE_URL" && break || sleep 15; done
  fi
  cd ../
}

checkout_from https://github.com/Rahulkhinchi03/contribution

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

CS_RELEASE_VERSION=checkstyle-1.1
echo CS_RELEASE_VERSION="$CS_RELEASE_VERSION"

cd .ci-temp/checkstyle-multiple-label
LATEST_RELEASE_TAG=checkstyle-1.4
echo LATEST_RELEASE_TAG="$LATEST_RELEASE_TAG"

cd ../

echo remoteRepo="$REMOTE_REPO_PATH"
echo start="$START_REF"
echo release="$RELEASE_NUMBER"

java -jar contribution/releasenotes-builder/target/releasenotes-builder-1.0-all.jar \
        -localRepoPath checkstyle-multiple-label \
        -remoteRepoPath remoteRepo \
        -startRef start \
        -releaseNumber release \
        -githubAuthToken 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 \
        -generateAll
