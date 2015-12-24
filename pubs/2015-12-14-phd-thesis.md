---
title: A language-independent methodology for compiling declarations into open platform frameworks
authors: Paul van der Walt
subline: PhD thesis, 2015. [<a href="http://people.bordeaux.inria.fr/pwalt/docs/vanderWalt-thesis.pdf">pdf</a>]
---

### Abstract

Download full manuscript here: [pdf](http://people.bordeaux.inria.fr/pwalt/docs/vanderWalt-thesis.pdf)

Download slides here: [pdf](http://people.bordeaux.inria.fr/pwalt/docs/slides-defence.pdf)


In the domain of open platforms, it has become common to use
application programming frameworks extended with declarations that
express permissions of applications.  This is a natural reaction to
ever more widespread adoption of mobile and pervasive computing
devices. Their wide adoption raises privacy and safety concerns for
users, as a result of the increasing number of sensitive resources a
user is sharing with non-certified third-party application developers.
However, the approach to designing these declaration languages and the
frameworks that enforce their requirements is often ad hoc, and
limited to a specific combination of application domain and
programming language. Moreover, most widely used frameworks fail to
address serious privacy leaks, and, crucially, do not provide the user
with insight into application behaviour.

This dissertation presents a generalised methodology for developing
declaration-driven frameworks in a wide spectrum of host programming
languages. We show that rich declaration languages, which express
modularity, resource permissions and application control flow, can be
compiled into frameworks that provide strong guarantees to end
users. Compared to other declaration-driven frameworks, our
methodology provides guidance to the application developer based on
the specifications, and clear insight to the end user regarding the
use of their private resources.

Contrary to previous work, the methodology we propose does not depend
on a specific host language, or even on a specific programming
paradigm. We demonstrate how to implement declaration-driven
frameworks in languages with static type systems, completely dynamic
languages, object-oriented languages, or functional languages.  The
efficacy of our approach is shown through prototypes in the domain of
mobile computing, implemented in two widely differing host programming
languages, demonstrating the generality of our approach.
