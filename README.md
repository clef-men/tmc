## Synopsis

This project is part of the [Iris Masterplan](https://julesjacobs.com/slides/iris-masterplan.pdf).
It aims at verifying program transformations from the OCaml compiler.

## Building

Assuming that you have [opam](https://opam.ocaml.org/) (>= 2.0) installed, run the following commands, which create a local opam switch, install dependencies and compile Coq proofs:

```
opam update --all --repositories
opam switch create . --yes --deps-only --repos default,coq-released=https://coq.inria.fr/opam/released,iris-dev=git+https://gitlab.mpi-sws.org/iris/opam.git
eval $(opam env)
make
```
