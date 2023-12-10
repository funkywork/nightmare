(lang dune 3.0)

;; Project configuration
(name nightmare)
(generate_opam_files true)

;; Project description
(source (github funkywork/nightmare))
(license MIT)
(authors "Funkywork")
(maintainers "Funkywork")

;; Packages description

(package
 (name nightmare-test)
 (synopsis "Test utilities for Nightmare")
 (description "Some shortcuts for writting test for a Nightmare application (or library)")
 (depends
  (ocaml (>= 5.0.0))
  (lwt (>= 5.6.1))
  alcotest))

(package
 (name nightmare)
 (synopsis "An ad-hoc framework for writing web application using OCaml")
 (description "An ad-hoc framework (that should fit well with Dream) for writting OCaml web application")
 (depends
  (ocaml (>= 5.0.0))
  (lwt (>= 5.6.1))
  (preface (>= 1.0.0))
  (alcotest :with-test)
  (nightmare-test (and (= :version) :with-test))))

(package
 (name nightmare-dream)
 (synopsis "Glue between Nightmare and Dream")
 (description "An overlay built on top of Dream for using Nightmare tools")
 (depends
  (ocaml (>= 5.0.0))
  (dream (>= 1.0.0~alpha5))
  (nightmare (= :version))))

(package
 (name nightmare-tyxml)
 (synopsis "Glue between Nightmare and TyXML")
 (description "Facilitates interaction between Nightmare and TyXML")
 (depends
  (ocaml (>= 5.0.0))
  (tyxml (>= 4.6.0))
  (nightmare (= :version))))

(package
 (name nightmare_js)
 (synopsis "The JavaScript Runtime for Nightmare JS Application")
 (description "A list of helpers to deal with Nightmare inside a Js_of_ocaml application")
 (depends
  (ocaml (>= 5.0.0))
  (lwt (>= 5.6.1))
  (preface (>= 1.0.0))
  (js_of_ocaml-compiler (>= 5.5.2))
  (js_of_ocaml-ppx (>= 5.5.2))
  (js_of_ocaml-lwt (>= 5.5.2))
  (nightmare (= :version))))

(package
  (name nightmare_js-vdom)
  (synopsis "A companion library and glue for ocaml-vdom and Nightmare")
  (description "Provides additional HTML tags and attributes for the ocaml-vdom library and adds support for Nightmare services")
  (depends
    (ocaml (>= 5.0.0))
    (tyxml (>= 4.5.0))
    (vdom (>= 0.3))
    (nightmare-tyxml (= :version))
    (nightmare_js (= :version))))
