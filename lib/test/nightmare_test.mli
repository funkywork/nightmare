(*  MIT License

    Copyright (c) 2022 funkywork

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

(** A very small collection of tools to make writing unit and integration tests
    easier (based on [Alcotest]). *)

(** {1 Unit testing}

    Although it is complicated to give a fairly formal definition of a unit test
    (compared to an integration test or an {i end-to-end test}), here we
    consider a unit test to be a test that simply calculates things
    {i computationally} whereas an integration test embeds a database
    connection. *)

(** {2 Unit test definition} *)

(** [test ?speed ~about ~desc a_test] will define a test for a function or a
    tool described by [about] and with a comprehensive description into [desc].
    It is almost an alias over [Alcotest.test_case]. *)
val test
  :  ?speed:Alcotest.speed_level
  -> about:string
  -> desc:string
  -> ('a -> unit)
  -> 'a Alcotest.test_case

(** [test_equality ?speed ~about ~desc testable a_test] is almost the same of
    {!val:test} except that the test is supposed to return a couple of value
    that have to be equal. It is a shortcut for writting test that only rely on
    the equality of computed values (versus expected value). *)
val test_equality
  :  ?speed:Alcotest.speed_level
  -> about:string
  -> desc:string
  -> 'a Alcotest.testable
  -> (unit -> 'a * 'a)
  -> unit Alcotest.test_case

(** {1 Test helpers} *)

(** [same testable x y] make the test fails if [x] and [y] are not equal
    (according to the meaning of equality defined into the [testable] value). *)
val same : 'a Alcotest.testable -> expected:'a -> computed:'a -> unit

(** {1 Testables}

    Some built-in [testables] (related to Alcotest). *)

(** Testable for {!type:Nightmare_common.Error.t}. *)
val error_testable : Nightmare_common.Error.t Alcotest.testable
