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

(** As endpoints render certain attributes (such as [href] or [src]) useless,
    this module re-exports the attributes of certain tags without these useless
    attributes to render certain expressions invalid such as :

    {[
      a_of ~a [ a_href "google.be" ] my_endpoint my_param [ txt "my link" ]
    ]}

    Allowing to avoid that a given attribute overwrites the one computed by the
    endpoint. *)

module Without_source : sig
  type a =
    [ Html_types.common
    | `Hreflang
    | `Media
    | `Rel
    | `Target
    | `Mime_type
    | `Download
    ]

  type base =
    [ Html_types.common
    | `Target
    ]

  type button =
    [ Html_types.common
    | `Autofocus
    | `Disabled
    | `Form
    | `Formenctype
    | `Formnovalidate
    | `Formtarget
    | `Name
    | `Text_Value
    | `Button_Type
    ]

  type blockquote = Html_types.common

  type del =
    [ Html_types.common
    | `Datetime
    ]

  type ins =
    [ Html_types.common
    | `Datetime
    ]

  type embed =
    [ Html_types.common
    | `Height
    | `Mime_type
    | `Width
    ]

  type form =
    [ Html_types.common
    | `Accept_charset
    | `Enctype
    | `Name
    | `Target
    | `Autocomplete
    | `Novalidate
    ]

  type iframe =
    [ Html_types.common
    | `Allowfullscreen
    | `Allowpaymentrequest
    | `Name
    | `Sandbox
    | `Seamless
    | `Width
    | `Height
    | `Referrerpolicy
    ]

  type link =
    [ Html_types.common
    | Html_types.subressource_integrity
    | `Hreflang
    | `Media
    | `Sizes
    | `Mime_type
    ]

  type object_ =
    [ Html_types.common
    | `Form
    | `Mime_type
    | `Height
    | `Width
    | `Name
    | `Usemap
    ]

  type script =
    [ Html_types.common
    | Html_types.subressource_integrity
    | `Async
    | `Charset
    | `Defer
    | `Mime_type
    ]

  type source =
    [ Html_types.common
    | `Mime_type
    | `Media
    ]
end
