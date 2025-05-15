#!/usr/bin/env zsh

# Modified from: https://github.com/fullheart/my-dev-env/blob/main/osx/docker/colima/install_latest_buildx.sh

# Install brew command, when needed
brew --version
if [ $? != 0 ] ; then
    echo 'ℹ️  First install "brew" command'
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Github CLI, when needed
gh --version
if [ $? != 0 ] ; then
    echo 'ℹ️  First install Github CLI'
    brew install gh
fi

gh auth status
if [ $? != 0 ] ; then;
    gh auth login
fi

DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
BUILDX_SUFFIX='darwin-arm64'
COMPOSE_FILE='docker-compose-darwin-aarch64'

rm *.$RELEASE_FILE_SUFFIX $COMPOSE_FILE
gh release download --repo 'github.com/docker/buildx' --pattern "*.$BUILDX_SUFFIX"
gh release download --repo 'github.com/docker/compose' --pattern "$COMPOSE_FILE"

mkdir -p ~/.docker/cli-plugins
mv -f *.$BUILDX_SUFFIX $DOCKER_CONFIG/cli-plugins/docker-buildx
mv -f $COMPOSE_FILE $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-buildx
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

docker buildx version 
docker compose version 
