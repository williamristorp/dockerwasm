# Dockerwasm

A quick project to compare "containerization" techniques.

## Prerequisites

Make sure you have the following `rustup` targets added:

```bash
rustup target add x86_64-unknown-linux-musl
rustup target add wasm32-wasi
```

This test uses [`wasmtime`](https://github.com/bytecodealliance/wasmtime). You can install it as such (copied from their Github README):

```bash
curl https://wasmtime.dev/install.sh -sSf | bash
```

Lastly, the container tests use `docker` and `podman`, which you can install through your system's package manager.

## Setup

Compile the project to the various targets:

```bash
cargo build -r --target x86_64-unknown-linux-musl
cargo build -r --target wasm32-wasi
cargo build -r
```

Build images:

```bash
docker build -t dockerwasm .
podman build -t dockerwasm .
```

## Running

```bash
cat /etc/dictionaries-common/words | target/release/dockerwasm
cat /etc/dictionaries-common/words | wasmtime target/wasm32-wasi/release/dockerwasm.wasm
cat /etc/dictionaries-common/words | docker run --rm -i dockerwasm
cat /etc/dictionaries-common/words | docker run --net=host --rm -i dockerwasm
cat /etc/dictionaries-common/words | podman run --rm -i dockerwasm
cat /etc/dictionaries-common/words | podman run --net=host --rm -i dockerwasm
```

All of the above should return 0 and stdout should be "234937\n".

## Benchmark

For benchmarking, I've used [`hyperfine`](https://github.com/sharkdp/hyperfine). See [`run_hyperfine.sh`](run_hyperfine.sh) for the command used. You can run this benchmark yourself, and it'll create a file `results.md`. This is the result of running the benchmark on my laptop:

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `cat /etc/dictionaries-common/words \| target/release/dockerwasm` | 5.9 ± 0.3 | 5.4 | 6.8 | 1.00 |
| `cat /etc/dictionaries-common/words \| wasmtime target/wasm32-wasi/release/dockerwasm.wasm` | 33.6 ± 1.3 | 32.1 | 38.4 | 5.67 ± 0.33 |
| `cat /etc/dictionaries-common/words \| podman run --net=host --rm -i dockerwasm` | 278.2 ± 22.5 | 245.1 | 308.3 | 46.99 ± 4.31 |
| `cat /etc/dictionaries-common/words \| podman run --rm -i dockerwasm` | 305.0 ± 44.2 | 240.9 | 385.9 | 51.52 ± 7.80 |
| `cat /etc/dictionaries-common/words \| docker run --net=host --rm -i dockerwasm` | 363.6 ± 26.6 | 327.2 | 416.9 | 61.41 ± 5.23 |
| `cat /etc/dictionaries-common/words \| docker run --rm -i dockerwasm` | 645.6 ± 51.6 | 578.6 | 757.5 | 109.05 ± 9.93 |


As you can see, the native binary is, as expected, the fastest. Second is WASM not too far behind, around 5 times slower. Third is Podman, now nearing 50 times slower execution than the native binary. And lastly Docker, reaching a whopping 100 times the native binary's execution time when sandboxing its network.
