#!/bin/bash

hyperfine --warmup 4 --export-markdown results.md \
    'cat /etc/dictionaries-common/words | target/release/dockerwasm' \
    'cat /etc/dictionaries-common/words | wasmtime target/wasm32-wasi/release/dockerwasm.wasm' \
    'cat /etc/dictionaries-common/words | podman run --net=host --rm -i dockerwasm' \
    'cat /etc/dictionaries-common/words | podman run --rm -i dockerwasm' \
    'cat /etc/dictionaries-common/words | docker run --net=host --rm -i dockerwasm' \
    'cat /etc/dictionaries-common/words | docker run --rm -i dockerwasm'
