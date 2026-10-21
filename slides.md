---
marp: true
theme: default
paginate: true
size: 16:9
math: mathjax
---

<!-- _paginate: false -->
<!-- _footer: "[Sofian Brabez](mailto:sbz@6dev.net) · Rust Toulouse Meetup, 22 October 2026" -->

<style scoped>
footer {
  position: absolute;
  right: 30px;
  bottom: 20px;
  text-align: right;
}
.images {
  position: absolute;
  top: 70%;
  right: 5%;
  transform: translateY(-50%);
  display: flex;
  align-items: center;
  gap: 40px;
}
.images img {
  height: 260px;
}
</style>

# Les pinces du métier #3

Few minutes of Rust tips & tricks

- std::process
- type inference
- impl Trait
- crate regex
- cargo size

<div class="images">
  <img src="assets/rust-logo.svg">
  <img src="assets/ferris.svg">
</div>

---

## std::*

---

## std::process

<style scoped>
pre {
  font-size: 0.60em;
}
</style>

Write simple script with Rust leveraging `std::process`

`from_utf8_lossy(v: &[u8]) -> Cow<'_, str>`: convert slice of bytes to string

```rust
use std::process::Command;

let output = Command::new("cat")                                     // Command
            .args(["/etc/os-release"])                               // Command
            .output()                                                // Result<Output, Error>
            .ok()                                                    // Option<Output>
            .map(|o| String::from_utf8_lossy(&o.stdout).to_string()) // Option<String>
            .unwrap_or_default();                                    // String or empty ""
for line in output.lines() {
    let parts: Vec<&str> = line.split('=').collect();
    println!("{} => {}", parts[0], parts[1]);
}
```

- [std::process](https://doc.rust-lang.org/std/process/index.html)
- [std::string::from_utf8_lossy()](https://doc.rust-lang.org/std/string/struct.String.html#method.from_utf8_lossy)

---

## type inference

Different ways of doing the same thing but (not actually the same)

<style scoped>
pre {
  font-size: 0.60em;
}
table {
  font-size: 0.60em;
}
</style>

```rust
let n = 0u32; 
let n: u32 = 0;
let n = 0 as u32; 
let n = u32::try_from(0_u64);
```

| Syntax | Mechanism | Description |
| :--- | :--- | :--- |
| `let n = 0u32;` | **Literal Suffix (Direct)** | The number `0` is created directly as a `u32`. Most concise for literals. |
| `let n: u32 = 0;` | **Type Annotation** (Inference) | The variable `n` is declared as `u32`, so the compiler infers the literal `0` must be `u32`. |
| `let n = 0 as u32;` | **Type Cast** (Conversion) | The literal `0` (defaulting to `i32`) is explicitly **cast** to `u32`. |

- [Literal](https://doc.rust-lang.org/rust-by-example/types/literals.html)
- [Cast](https://doc.rust-lang.org/rust-by-example/types/cast.html)
---

## impl Trait (1/3)

<style scoped>
pre {
  font-size: 0.60em;
}
</style>

`impl Trait` and `dyn Trait` polymorphism
- via function arguments `fn my_func(param: impl MyTrait) { ... }`
- via return type `fn my_func(...) -> Box<dyn MyTrait> { ... }`

```rust
trait Rustacean {
    fn develop(&self);
}
struct Backend  { lang: String }
struct Embedded { framework: String }
impl Rustacean for Backend { 
    fn develop(&self) { println!("I'm coding with language {}", self.lang); }
}
impl Rustacean for Embedded { 
    fn develop(&self) { println!("I'm using {} framework to develop", self.framework); }
}
enum Kind { Backend, Embedded }
```

- [impl Trait](https://doc.rust-lang.org/rust-by-example/trait/impl_trait.html)

---

## impl Trait (2/3)

<style scoped>
pre {
  font-size: 0.60em;
}
</style>

- static (compile-time)

```rust
fn code(developer: &impl Rustacean) { // code<T: Rustacean>(developer: &T) {
    developer.develop();
}
fn main() {
    let dev_back = Backend { lang: String::from("Rust") };
    let dev_em = Embedded { framework: String::from("Embassy") };

    code(&dev_back); // Resolve at compile-time
    code(&dev_em);   // Resolve at compile-time
}
```

---

## dyn Trait (3/3)

<style scoped>
pre {
  font-size: 0.60em;
}
</style>

- dynamic dispatch (run-time)

```rust
fn new_developer_member(kind: Kind, arg: String) -> Box<dyn Rustacean> {
    match kind {
        Kind::Backend => Box::new(Backend { lang: arg }),
        Kind::Embedded => Box::new(Embedded { framework: arg }),
    }
}
fn main() {
    let team: Vec<Box<dyn Rustacean>> = vec![
        Box::new(Backend { lang: String::from("Rust") }),
        new_developer_member(Kind::Embedded, String::from("Embassy")),
    ];

    for member in team {
        member.develop(); // Resolve at run-time (vtable)
    }
}
```

- [Vtable differences Rust and C++](https://users.rust-lang.org/t/v-tables-differences-between-rust-and-c/92445)
- [How dyn Trait works in memory](https://sofiabelen.github.io/projects/visualizing-rusts-vtables-how-dyn-trait-works-in-memory/)

---



## Crates

https://crates.io

---

## Regex (1/2)

<style scoped>
pre {
  font-size: 0.60em;
}
</style>

If you want to use regular expression you need to the crate `regex` in your
`Cargo.toml`

```
$ cargo add regex
$ cat Cargo.toml
...
[dependencies]
regex = "1.13.1"
```

```rust
use regex::Regex;

let re = Regex::new(r"(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})").unwrap();
let groups = re.captures("2026-10-22").unwrap();
assert_eq!("2026", &groups["year"] /* &groups[1] */);
assert_eq!("10", &groups["month"] /* &groups[2] */);
assert_eq!("22", &groups["day"] /* &groups[3] */);
```


- [Rust regex implementation](https://github.com/rust-lang/regex)

---

## Regex (2/2)

`regex!` macro could also be used (no compile-time check of the pattern)

```rust
use regex::regex;
let re: &Regex = regex!(r"(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})");
let groups = &re.captures("2026-10-22").unwrap();
assert_eq!("2026", &groups["year"]);
```

- [regex!](https://docs.rs/regex/latest/regex/macro.regex.html)
---

## Tools

---

## cargo size (1/2)

<style scoped>
pre {
  font-size: 0.60em;
}
</style>

`llvm-size(1)` tool directly integrated in Rust cargo toolchain to check binary
sections size.

```shell
$ rustup component add llvm-tools
$ cargo install cargo-binutils
```

```shell
$ cargo size [--release] [ -- -A ]
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
   text	   data	    bss	    dec	    hex	filename
4053937	 270072	   3448	4327457	 420821	mybinary

$ cargo --list |egrep -E "objdump|nm|size"
    nm
    objdump
    size

$ cargo nm
$ cargo objdump -- --disassemble-symbols=main
```
- [Cargo binutils project](https://github.com/rust-embedded/cargo-binutils)
---

## Other cargo-size (2/2)

<style scoped>
pre {
  font-size: 0.60em;
}
</style>

```
$ cargo install cargo-size [--force]
```

```
$ cargo-size check [--release]
+----------+----------+----------+------------+--------+-------------------------+
| Package  | Binary   | Size     | Build Type | Target | Timestamp               |
+================================================================================+
| mybinary | mybinary | 19.03 MB | debug      | host   | 2026-10-22 10:05:19 UTC |
+----------+----------+----------+------------+--------+-------------------------+
$ cargo-size -o json check
[
  {
    "package_name": "mybinary",
    "binary_name": "mybinary",
    "size": 19949256,
    "size_formatted": "19.03 MB",
    "build_type": "debug",
    "target": "host",
    "timestamp": "2026-10-22T10:06:35.173657336Z"
  }
]
```

- [cargo-size crates](https://crates.io/crates/cargo-size)

<!-- _paginate: false -->

---

## Sites

---

[https://bookshelf.rs](https://bookshelf.rs)

The website contains links of Rust online books and resources for learning Rust 🦀

---

## The end

Thanks!

- Slides available: [github.com/sbz/rust-tips-toulouse-meetup](https://github.com/sbz/rust-tips-toulouse-meetup)
- Build with [Markdown Presentation Ecosystem](https://marp.app)
