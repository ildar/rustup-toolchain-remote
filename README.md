This is a "proxy" toolchain for using of a remote installation of Rust/Cargo etc.
from the "light" local PC installation.

## Installation

1. Start as in the manual:
> $ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none -y

2. copy this whole project folder to the `toolchains/` folder:
> $ mkdir -p ~/.rustup/toolchains ; cp -a ../rustup-toolchain-remote ~/.rustup/toolchains/

3. make it default
> $ rustup default rustup-toolchain-remote

4. test it!
> $ rustc -vV

