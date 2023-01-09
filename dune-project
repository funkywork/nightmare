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
 (synopsis "An adHoc framework for writing web application using OCaml")
 (description "An adHoc framework (that should fit well with Dream) for writting OCaml web application")
 (depends
  (ocaml (>= 4.14.0))
  (dune (>= 3.0.0))
  (lwt (>= 5.6.1))
  (odoc :with-doc)
  (alcotest :with-test)))
