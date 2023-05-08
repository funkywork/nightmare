# Nightmare

> **Warning** _Nightmare_ is still _Work In Progress_.

A set of components that fit, a priori, relatively well with the web framework
([OCaml](https://ocaml.org)) [Dream](https://aantron.github.io/dream/) to try to
build, at best, and quickly, dynamic web applications.

**Nightmare** was very much inspired by the development of
[Muhokama](https://github.com/xvw/muhokama/), a forum written in
[OCaml](https://ocaml.org) which has had many of its components imported
directly into **Nightmare**. The set of ideas implemented in this "adhoc
framework" comes from different sources of inspiration which we will try to list
meticulously in an appropriate section.

Even though the framework is intended to be as agnostic as possible, it has been
designed to blend in naturally with [Dream](https://aantron.github.io/dream/),
hence the name chosen.

## Setting up the development environment

Setting up a development environment is quite common. We recommend setting up a
local switch to collect dependencies locally. Here are the commands to enter to
initiate the environment:

```shellsession
opam update
opam switch create . ocaml-base-compiler.5.0.0 --deps-only -y
eval $(opam env)
```

After initializing the switch, you can collect the development and project
dependencies using `make`:

```shellsession
make dev-deps
make deps
```

Now you should be able to easily start contributing to **Nightmare**.

> **Note** If you are not using [GNU/Make](https://www.gnu.org/software/make/)
> (or equivalent), you can refer to the [Makefile](Makefile) and observe the
> `dev-deps` and `deps` rules to get the commands to run.
