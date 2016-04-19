---
title: Engineering Proof by Reflection in Agda
authors: Paul van der Walt and Wouter Swierstra
subline: IFL 2012, Oxford.  [<a href="https://hal.inria.fr/hal-00987610">pdf</a>] [<a href="https://github.com/toothbrush/reflection-proofs">code</a>]
---

### Abstract

Download full article here: [pdf](https://hal.inria.fr/hal-00987610).

This paper explores the recent addition to Agda enabling _reflection_,
in the style of Lisp and Template Haskell.  It gives a brief
introduction to using reflection, and details the complexities
encountered when automating certain proofs with _proof by reflection_.
It presents a library that can be used for automatically quoting a
class of concrete Agda terms to a non-dependent, user-defined inductive
data type, alleviating some of the burden a programmer faces when using
reflection in a practical setting.
