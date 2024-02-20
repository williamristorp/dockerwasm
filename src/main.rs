use std::io::{self, Read, Write};

fn main() {
    let mut buf = String::new();
    io::stdin().lock().read_to_string(&mut buf).unwrap();

    let words = buf.split_whitespace().count();
    writeln!(io::stdout().lock(), "{words}").unwrap();
}
