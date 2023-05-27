/*
MIT License

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
SOFTWARE.
*/

//Provides: caml_is_a_promise
function caml_is_a_promise(value) {
    return Boolean(value && typeof value.then === 'function');
}

//Provides: caml_print_error
function caml_print_error(error) {
    const message = "The promise does not handle the following exception";
    console.error(message);
    console.error(error);
}

//Provides: CAMLWrappedPromise
function CAMLWrappedPromise(value) {
    /* Wraps a promise in an object to make it safe. The approach is more than 
     * greatly inspired by :
     *   - https://github.com/aantron/promise
     *   - https://github.com/dbuenzli/brr/blob/master/src/fut.ml#L6
     */
    this.wrapped = value;
}

//Provides: caml_wrap_promise
//Requires: CAMLWrappedPromise, caml_is_a_promise
function caml_wrap_promise(value) {
    // Wraps a promise in a `CAMLWrappedPromise` object if necessary.
    if (caml_is_a_promise(value)) { 
        return new CAMLWrappedPromise(value);
    } else return value;
}

//Provides: caml_unwrap_promise
//Requires: CAMLWrappedPromise
function caml_unwrap_promise(value) {
    // Wraps the promise in a `CAMLWrappedPromise` if necessary.
    if (value instanceof CAMLWrappedPromise) {
        return value.wrapped;
    } else return value;
}

//Provides: caml_construct_promise
//Requires: caml_wrap_promise
function caml_construct_promise(handler) {
    // Builds a promise by wrapping in its value.
    const safePromise = new globalThis.Promise(function(resolve, reject) {
        const wrappedResolver = function(value) {
            const wrapped = caml_wrap_promise(value);
            resolve(wrapped); 
        };
        handler(wrappedResolver, reject);
    });
    return safePromise;
}

//Provides: caml_resolve_promise
//Requires: caml_wrap_promise
function caml_resolve_promise(value) {
    // Solve a promise by wrapping up its value.
    const wrapped = caml_wrap_promise(value);
    return globalThis.Promise.resolve(wrapped);
}

// Provides: caml_then_promise
// Requires: caml_unwrap_promise, caml_print_error
function caml_then_promise(promise, handler) {
    // Safe wrapper around `then`.
    const safeHandler = function (value) {
        try {
            const unwrapped = caml_unwrap_promise(value);
            return handler(unwrapped);
        } catch (exception) {
            // Should maybe improved
            caml_print_error(exception);
            return new globalThis.Promise(function(){});
        };
    };
    return promise.then(safeHandler);
};

//Provides: caml_then_with_rejection
//Requires: caml_unwrap_promise, caml_print_error
function caml_then_with_rejection(promise, resolver, rejecter) {
    // Safe wrapper around `then` with rejection.
    const safeResolver = function(value) {
        const unwrapped = caml_unwrap_promise(value);
        return resolver(unwrapped);
    };
    const safeRejecter = function(value) {
        try { return rejecter(value); }
        catch (exception) {
            caml_print_error(exception);
            return new globalThis.Promise(function(){});
        }
    };
    return promise.then(safeResolver, safeRejecter);
}

//Provides: caml_catch_promise
//Requires: caml_print_error
function caml_catch_promise(promise, handler) {
    // Safe wrapper around `catch`.
    const safeHandler = function (errorValue) {
        try { return handler(errorValue); }
        catch (exception) {
            caml_print_error(exception);
            return new globalThis.Promise(function(){});
        }
    };
    return promise.catch(safeHandler);
};

//Provides: caml_set_timeout_promise
function caml_set_timeout_promise(duration) {
    // A promisified version of setTimeout
    return new globalThis.Promise(
        function(resolve) { 
            setTimeout(function() {resolve(); }, duration);
        }
    );
}