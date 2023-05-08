(lang dune 3.0)

;; Project configuration
(name nightmare)
(version dev)
(generate_opam_files true)

;; Project description
(source (github funkywork/nightmare))
(license MIT)
(authors "Funkywork")
(maintainers "Funkywork")

;; Packages description

(package
 (name nightmare)
 (synopsis "An ad-hoc framework for writing web application using OCaml")
 (description "An ad-hoc framework (that should fit well with Dream) for writting OCaml web application")
 (depends
  (ocaml (>= 5.0.0))
  (dune (>= 3.0.0))
  (lwt (>= 5.6.1))
  (preface (>= 1.0.0))
  (odoc :with-doc)
  (alcotest :with-test)))

(package
 (name nightmare_dream)
 (synopsis "Glue between Nightmare and Dream")
 (description "An overlay built on top of Dream for using Nightmare tools")
 (depends
  (ocaml (>= 5.0.0))
  (dune (>= 3.0.0))
  (dream (>= 1.0.0~alpha4))
  (nightmare (= :version))))

(package
 (name nightmare_tyxml)
 (synopsis "Glue between Nightmare and TyXML")
 (description "Facilitates interaction between Nightmare and TyXML")
 (depends
  (ocaml (>= 5.0.0))
  (dune (>= 3.0.0))
  (tyxml (>= 4.5.0))
  (nightmare (= :version))))

(package
 (name nightmare_js)
 (synopsis "The JavaScript Runtime for Nightmare JS Application")
 (description "A list of helpers to deal with Nightmare inside a Js_of_ocaml application")
 (depends
  (ocaml (>= 5.0.0))
  (dune (>= 3.0.0))
  (lwt (>= 5.6.1))
  (preface (>= 1.0.0))
  (js_of_ocaml-compiler (>= 5.2.0))
  (js_of_ocaml-ppx (>= 5.2.0))
  (js_of_ocaml-lwt (>= 5.2.0))
  (nightmare (= :version))))
