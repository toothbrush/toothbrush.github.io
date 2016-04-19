---
title: Constraining application behaviour by generating languages
authors: Paul van der Walt
subline: 8th European Lisp Symposium, Apr 2015, London. [<a href="https://hal.inria.fr/hal-01140459">pdf</a>] [<a href="https://www.github.com/toothbrush/diaracket">code</a>]
---

### Abstract

Download article [here](https://hal.inria.fr/hal-01140459), or full
proceedings
[here](http://www.european-lisp-symposium.org/editions/2015/ELS2015.pdf).

Writing a platform for reactive applications which enforces operational
constraints is difficult, and has been approached in various ways. In
this experience report, we detail an approach using an embedded DSL
which can be used to specify the structure and permissions of a
program in a given application domain. 
Once the developer has specified which components an
application will consist of, and which permissions each one needs, the
specification itself evaluates to a new, tailored, language.
The final implementation of the application is then written in this
specialised environment where precisely the API calls associated with
the permissions which have been granted, are made available.

Our prototype platform targets the domain of mobile computing, and is
implemented using Racket. It demonstrates resource access control (*e.g.,*
camera, address book, *etc.*) and tries to prevent leaking of private
data. Racket is shown to be an extremely effective platform for
designing new programming languages and their run-time libraries.  We
demonstrate that this approach allows reuse of an inter-object
communication layer, is convenient for the application developer
because it provides high-level building blocks to structure the
application, and provides increased control to the platform owner,
preventing certain classes of errors by the developer.
