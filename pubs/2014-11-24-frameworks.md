---
title: Frameworks compiled from declarations: a language-independent approach
authors: Paul van der Walt, Charles Consel and Emilie Balland
subline: Manuscript. [<a href="https://hal.inria.fr/hal-01236352">pdf</a>] [<a href="https://www.github.com/toothbrush/diaracket">code</a>]
---

### Abstract

Download full text here: [pdf](https://hal.inria.fr/hal-01236352).

Programming frameworks are an accepted fixture in the object-oriented
world, motivated by the need for code reuse, developer guidance, and
restriction.  A new trend is emerging where frameworks require domain
experts to provide declarations using a domain-specific language
(DSL), influencing the structure and behaviour of the resulting
application.  These mechanisms address concerns such as user privacy.
Although many popular open platforms such as Android are based on
declaration-driven frameworks, current implementations provide ad hoc
and narrow solutions to concerns raised by their openness to
non-certified developers.  Most widely used frameworks fail to address
serious privacy leaks, and provide the user with little insight into
application behaviour.

To address these shortcomings, we show that declaration-driven
frameworks can limit privacy leaks, as well as guide developers,
independently from the underlying programming paradigm.  To do so, we
identify concepts that underlie declaration-driven frameworks, and
apply them systematically to both an object-oriented language, Java,
and a dynamic functional language, Racket.  The resulting programming
framework generators are used to develop a prototype mobile
application, illustrating how we mitigate a common class of privacy
leaks.  Finally, we explore the possible design choices and propose
development principles for developing domain-specific language
compilers to produce frameworks, applicable across a spectrum of
programming paradigms.
