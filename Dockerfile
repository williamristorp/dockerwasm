FROM scratch
ADD ./target/x86_64-unknown-linux-musl/release/dockerwasm /run
CMD [ "/run" ]
