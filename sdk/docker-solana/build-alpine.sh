#!/usr/bin/env bash
set -ex

cd "$(dirname "$0")"/../..
eval "$(ci/channel-info.sh)"
source ci/rust-version.sh

CHANNEL_OR_TAG=
if [[ -n "$CI_TAG" ]]; then
  CHANNEL_OR_TAG=$CI_TAG
else
  CHANNEL_OR_TAG=$CHANNEL
fi

if [[ -z $CHANNEL_OR_TAG ]]; then
  echo Unable to determine channel or tag to publish into, exiting.
  echo "^^^ +++"
  exit 0
fi

cd "$(dirname "$0")"
rm -rf usr/
../../ci/docker-run.sh "$rust_stable_docker_image" \
  scripts/cargo-install-all.sh sdk/docker-solana/usr

cp -f ../../scripts/run.sh usr/bin/solana-run.sh
cp -f ../../fetch-spl.sh usr/bin/
(
  cd usr/bin
  ./fetch-spl.sh
)

docker build -f Dockerfile.alpine -t ${SDB_SOL_DOCKER_IMG:-kindtek/solana-sdb-alpine_debug}:${SDB_SOL_DOCKER_TAG:-latest_debug} .
docker tag ${SDB_SOL_DOCKER_IMG:-kindtek/solana-sdb-alpine_debug}:$SDB_SOL_DOCKER_TAG "${SDB_SOL_DOCKER_IMG:-kindtek/solana-sdb-alpine_debug}:latest"
docker tag $SDB_SOL_DOCKER_IMG:$SDB_SOL_DOCKER_TAG kindtek/solana-alpine:latest

docker push ${SDB_SOL_DOCKER_IMG:-kindtek/solana-sdb-alpine_debug}:${SDB_SOL_DOCKER_TAG:-latest_debug}
