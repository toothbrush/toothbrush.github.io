---
title: Constraining application behaviour by generating languages
authors: Paul van der Walt
subline: Manuscript. [<a href="http://people.bordeaux.inria.fr/pwalt/code/diaracket.tgz">code</a>]
---

### Abstract

Download full article here: [pdf](http://people.bordeaux.inria.fr/docs/decls.pdf)


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
