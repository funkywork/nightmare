(*  MIT License
    Copyright (c) 2023 funkywork
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE. *)

open Nightmare_test
open Nightmare_common

type errors = Nightmare_common.Error.t = ..

type errors +=
  | Error_a of
      { x : int
      ; y : string
      }
  | Error_b of
      { foo : string
      ; bar : int
      }
  | Unhandled_error of
      { a : string
      ; b : string
      }

let () =
  Error.register
    ~id:"nightmare.test.error_a"
    ~title:"Error a"
    ~description:"The error a"
    ~pp:(fun ppf (x, y) -> Format.fprintf ppf "Error a {x = %d; y = %s}" x y)
    (function
     | Error_a { x; y } -> Some (x, y)
     | _ -> None)
    (fun (x, y) -> Error_a { x; y })
    (fun (xa, ya) (xb, yb) -> Int.equal xa xb && String.equal ya yb)
;;

let () =
  Error.register
    ~id:"nightmare.test.error_ba"
    ~title:"Error b"
    ~description:"The error b"
    ~pp:(fun ppf (foo, bar) ->
      Format.fprintf ppf "Error b {foo = %s; bar = %d}" foo bar)
    (function
     | Error_b { foo; bar } -> Some (foo, bar)
     | _ -> None)
    (fun (foo, bar) -> Error_b { foo; bar })
    (fun (fooa, bara) (foob, barb) ->
      String.equal fooa foob && Int.equal bara barb)
;;

let test_handle_error_a =
  test_equality
    ~about:"handle"
    ~desc:"when the error (a) is registered, it should handle it"
    Alcotest.(pair error_testable string)
    (fun () ->
      let source_error = Error_a { x = 42; y = "ocaml" } in
      let expected = source_error, "Error a {x = 42; y = ocaml}"
      and computed =
        Error.handle source_error (fun { pp; _ } given_error ->
          given_error, Format.asprintf "%a" pp given_error)
      in
      expected, computed)
;;

let test_handle_error_b =
  test_equality
    ~about:"handle"
    ~desc:"when the error (b) is registered, it should handle it"
    Alcotest.(pair error_testable string)
    (fun () ->
      let source_error = Error_b { bar = 42; foo = "ocaml" } in
      let expected = source_error, "Error b {foo = ocaml; bar = 42}"
      and computed =
        Error.handle source_error (fun { pp; _ } given_error ->
          given_error, Format.asprintf "%a" pp given_error)
      in
      expected, computed)
;;

let test_handle_error_unhandled_error =
  test_equality
    ~about:"handle"
    ~desc:"when the error is not registered, it should be handle [Unknown]"
    Alcotest.(pair error_testable string)
    (fun () ->
      let source_error = Unhandled_error { a = "unhandled"; b = "error" } in
      let expected = Error.Unknown, "Unknown error"
      and computed =
        Error.handle source_error (fun { pp; _ } given_error ->
          given_error, Format.asprintf "%a" pp given_error)
      in
      expected, computed)
;;

let test_interaction_with_result =
  test_equality
    ~about:"error + result"
    ~desc:"when error are buried into result it should preserve-it (succeed)"
    Alcotest.(result int error_testable)
    (fun () ->
      let expected = Ok 15
      and computed =
        10 |> Result.ok |> Result.map (( + ) 2) |> Result.map (( + ) 3)
      in
      expected, computed)
;;

let test_interaction_with_result_failure_with_a =
  test_equality
    ~about:"error + result"
    ~desc:
      "when error are buried into result it should preserve-it (fail with \
       error a)"
    Alcotest.(result int string)
    (fun () ->
      let expected = Error "Error a {x = 12; y = error}"
      and computed =
        10
        |> Result.ok
        |> (fun res ->
             Result.bind res (fun x ->
               if x = 12
               then Error (Unhandled_error { a = "unhandled"; b = "error" })
               else Ok x))
        |> Result.map (( + ) 2)
        |> (fun res ->
             Result.bind res (fun x ->
               if x = 12 then Error (Error_a { x; y = "error" }) else Ok x))
        |> (fun res ->
             Result.bind res (fun x ->
               if x > 12
               then Error (Error.With_message { message = "invalid" })
               else Ok x))
        |> (fun res ->
             Result.bind res (fun x ->
               if x = 12 then Error (Error_a { x; y = "error" }) else Ok x))
        |> Result.map (( + ) 3)
        |> fun res ->
        Result.bind res (fun x ->
          if x = 15 then Error (Error_b { bar = x; foo = "error" }) else Ok x)
        |> Result.map_error (fun error ->
             Error.handle error (fun { pp; _ } -> Format.asprintf "%a" pp))
      in
      expected, computed)
;;

let test_interaction_with_result_failure_with_b =
  test_equality
    ~about:"error + result"
    ~desc:
      "when error are buried into result it should preserve-it (fail with \
       error b)"
    Alcotest.(result int string)
    (fun () ->
      let expected = Error "Error b {foo = error; bar = 15}"
      and computed =
        10
        |> Result.ok
        |> (fun res ->
             Result.bind res (fun x ->
               if x = 12
               then Error (Unhandled_error { a = "unhandled"; b = "error" })
               else Ok x))
        |> Result.map (( + ) 2)
        |> (fun res ->
             Result.bind res (fun x ->
               if x > 12 then Error (Error_a { x; y = "error" }) else Ok x))
        |> (fun res ->
             Result.bind res (fun x ->
               if x > 12
               then Error (Error.With_message { message = "invalid" })
               else Ok x))
        |> (fun res ->
             Result.bind res (fun x ->
               if x > 12 then Error (Error_a { x; y = "error" }) else Ok x))
        |> Result.map (( + ) 3)
        |> fun res ->
        Result.bind res (fun x ->
          if x = 15 then Error (Error_b { bar = x; foo = "error" }) else Ok x)
        |> Result.map_error (fun error ->
             Error.handle error (fun { pp; _ } -> Format.asprintf "%a" pp))
      in
      expected, computed)
;;

let test_interaction_with_result_failure_with_unhandled =
  test_equality
    ~about:"error + result"
    ~desc:
      "when error are buried into result it should preserve-it (fail with \
       unhandled error)"
    Alcotest.(result int string)
    (fun () ->
      let expected = Error "Unknown error"
      and computed =
        10
        |> Result.ok
        |> (fun res ->
             Result.bind res (fun x ->
               if x < 12
               then Error (Unhandled_error { a = "unhandled"; b = "error" })
               else Ok x))
        |> Result.map (( + ) 2)
        |> (fun res ->
             Result.bind res (fun x ->
               if x > 12 then Error (Error_a { x; y = "error" }) else Ok x))
        |> (fun res ->
             Result.bind res (fun x ->
               if x > 12
               then Error (Error.With_message { message = "invalid" })
               else Ok x))
        |> (fun res ->
             Result.bind res (fun x ->
               if x > 12 then Error (Error_a { x; y = "error" }) else Ok x))
        |> Result.map (( + ) 3)
        |> fun res ->
        Result.bind res (fun x ->
          if x = 15 then Error (Error_b { bar = x; foo = "error" }) else Ok x)
        |> Result.map_error (fun error ->
             Error.handle error (fun { pp; _ } -> Format.asprintf "%a" pp))
      in
      expected, computed)
;;

let test_interaction_with_result_failure_with_message =
  test_equality
    ~about:"error + result"
    ~desc:
      "when error are buried into result it should preserve-it (fail with \
       message)"
    Alcotest.(result int string)
    (fun () ->
      let expected = Error "message: invalid"
      and computed =
        10
        |> Result.ok
        |> (fun res ->
             Result.bind res (fun x ->
               if x > 12
               then Error (Unhandled_error { a = "unhandled"; b = "error" })
               else Ok x))
        |> Result.map (( + ) 2)
        |> (fun res ->
             Result.bind res (fun x ->
               if x > 12 then Error (Error_a { x; y = "error" }) else Ok x))
        |> (fun res ->
             Result.bind res (fun x ->
               if x = 12
               then Error (Error.With_message { message = "invalid" })
               else Ok x))
        |> (fun res ->
             Result.bind res (fun x ->
               if x > 12 then Error (Error_a { x; y = "error" }) else Ok x))
        |> Result.map (( + ) 3)
        |> fun res ->
        Result.bind res (fun x ->
          if x = 15 then Error (Error_b { bar = x; foo = "error" }) else Ok x)
        |> Result.map_error (fun error ->
             Error.handle error (fun { pp; _ } -> Format.asprintf "%a" pp))
      in
      expected, computed)
;;

let cases =
  ( "Error"
  , [ test_handle_error_a
    ; test_handle_error_b
    ; test_handle_error_unhandled_error
    ; test_interaction_with_result
    ; test_interaction_with_result_failure_with_a
    ; test_interaction_with_result_failure_with_b
    ; test_interaction_with_result_failure_with_unhandled
    ; test_interaction_with_result_failure_with_message
    ] )
;;
