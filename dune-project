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
  (ocaml (>= 4.14.0))
  (dune (>= 3.0.0))
  (lwt (>= 5.6.1))
  (odoc :with-doc)
  (alcotest :with-test)))

(package
 (name nightmare_dream)
 (synopsis "Glue between Nightmare and Dream")
 (description "An overlay built on top of Dream for using Nightmare tools")
 (depends
  (ocaml (>= 4.14.0))
  (dune (>= 3.0.0))
  (dream (>= 1.0.0~alpha4))
  (nightmare (= :version))
  (odoc :with-doc)
  (alcotest :with-test)))
