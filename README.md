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

## Setup

```bash
cargo build -r --target x86_64-unknown-linux-musl && docker build -t dockerwasm .
cargo build -r --target wasm32-wasi
cargo build -r
```

## Running

Run release:

```bash
cat /etc/dictionaries-common/words | target/release/dockerwasm
```

Run Docker (simple):

```bash
cat /etc/dictionaries-common/words | docker run --rm -i dockerwasm
```

Run Docker (host network):

```bash
cat /etc/dictionaries-common/words | docker run --net=host --rm -i dockerwasm
```

Run WASM:

```bash
cat /etc/dictionaries-common/words | wasmtime target/wasm32-wasi/release/dockerwasm.wasm
```

All of the above should return 0 and stdout should be "234937\n".

## Benchmark

For benchmarking, I've used [`hyperfine`](https://github.com/sharkdp/hyperfine). See [`run_hyperfine.sh`](run_hyperfine.sh) for the command used. You can run this benchmark yourself, and it'll create a file `results.md`. This is the result of running the benchmark on my laptop:

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `cat /etc/dictionaries-common/words \| target/release/dockerwasm` | 6.4 ± 0.4 | 5.9 | 8.9 | 1.00 |
| `cat /etc/dictionaries-common/words \| wasmtime target/wasm32-wasi/release/dockerwasm.wasm` | 33.6 ± 0.7 | 32.8 | 36.0 | 5.25 ± 0.32 |
| `cat /etc/dictionaries-common/words \| docker run --net=host --rm -i dockerwasm` | 352.7 ± 32.8 | 308.2 | 422.2 | 55.12 ± 6.00 |
| `cat /etc/dictionaries-common/words \| docker run --rm -i dockerwasm` | 644.1 ± 44.8 | 584.9 | 698.9 | 100.67 ± 9.04 |

This shows that running the native binary, as expected, is the fastest. Not too far behind is WASM, about 5.25 times slower. Next comes the Docker container without network separation at about 55.12 times slower compared to the native binary. And lastly, the Docker container with its own network, a whopping 100.67 times slower than the native binary.
