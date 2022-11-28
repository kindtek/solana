#!/usr/bin/env bash
set -ex

cd "$(dirname "$0")"


platform=()
if [[ $(uname -m) = arm64 ]]; then
  # Ref: https://blog.jaimyn.dev/how-to-build-multi-architecture-docker-images-on-an-m1-mac/#tldr
  platform+=(--platform linux/amd64)
fi

docker build "${platform[@]}" -t kindtek/rust .

read -r rustc version _ < <(docker run kindtek/rust rustc --version)
[[ $rustc = rustc ]]
docker tag kindtek/rust:latest kindtek/rust:"$version"
docker push kindtek/rust:"$version"
docker push kindtek/rust:latest
