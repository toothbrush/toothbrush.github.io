---
title: Declaration-driven Frameworks: a Language-agnositic Approach
authors: Paul van der Walt, Charles Consel and Emilie Balland
subline: Manuscript.
---

### Abstract

Download full article here: [pdf](http://people.bordeaux.inria.fr/docs/progfw.pdf)


Programming frameworks are an accepted fixture in the
object-oriented world, motivated by the need for code reuse, developer
guidance, and restriction.  Notably, open platforms, offering "app
stores" to non-certified developers, rely on frameworks.  A new trend
is emerging where frameworks supporting open platforms utilise
domain-specific declarations to address concerns such as privacy. These
declarations drive the structure and behaviour of the resulting
application. Although many popular platforms such as Android are based
on declaration-driven frameworks, their current implementations provide ad hoc and narrow
solutions to concerns raised by their openness.  In particular, most
widely used frameworks are limited to a single programming paradigm and
domain, and ignore serious privacy leaks.

To address these shortcomings, we show that declaration-driven
frameworks can provide privacy guarantees and guide developers in a
wide spectrum of programming paradigms. To do so, we identify concepts
that underlie declaration-driven frameworks. We apply them uniformly
to both an object-oriented language, Java, and a dynamically typed
functional language, Racket. 
The resulting programming frameworks are used to develop a realistic
prototype mobile application, illustrating how we mitigate a common
class of privacy attacks. Finally, we propose principles for
developing declaration-driven frameworks applicable across a spectrum
of programming paradigms.
