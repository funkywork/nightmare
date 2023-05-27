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

(** Suspensions allow a succession of tasks to be executed (in the form of
    promises) to be arbitrarily called in an HTML document. *)

(** [allow ()] Exports the [nightmare_js] object for recording suspensions.*)
val allow : unit -> unit

(** {1 Basic idea}

    Suspensions allow the construction of sequentially executed JavaScript
    operations that will be executed once the DOM is fully loaded. For example,
    imagine this HTML document in which several [<script>] have been inserted:

    {@html[
      <div>
       <script>
         nightmare_js.suspend( function() { console.log(1);} );
       </script>
       <h1> Hello World</h1>
        <script>
         nightmare_js.suspend( function() { console.log(2);} );
       </script>
      </div>
      <script>console.log(3);</script>
      <script>nightmare_js.mount();</script>
    ]}

    Will be displayed in the development console: [3, 1, 2] because the
    [console.log(3)] is not suspended, so it does not wait for the DOM to be
    fully loaded.

    {1 When is it useful}

    Even if in the context of a classical application, suspensions may seem
    anecdotal, they can be very useful to invoke OCaml code exported from the
    DOM, for example to load several applications. *)
