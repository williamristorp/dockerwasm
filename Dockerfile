FROM scratch
ADD ./target/x86_64-unknown-linux-musl/release/dockerwasm /dockerwasm
CMD [ "/dockerwasm" ]
