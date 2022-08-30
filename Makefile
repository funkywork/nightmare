.PHONY: dev-deps deps


# [make dev-deps] will download locally the dependencies needed
# to develop the project. Mainly formatting features, and IDE support.
dev-deps:
	opam install dune merlin ocamlformat ocp-indent utop -y


# [make deps] will download locally the dependencies needed
# to build the libraries. That is, all the dependencies referenced
# in the OPAM description files.
deps:
	opam install . --deps-only --with-doc --with-test -y
