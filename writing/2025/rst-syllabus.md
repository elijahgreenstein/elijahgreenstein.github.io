---
title: "How to Structure reStructuredText for Quick Updates"
date: 2025-05-20
revised: 2025-08-05
keywords: reStructuredText, docutils, markup, teaching
description: |
  A discussion of the use of reStructuredText substitutions for frequently updated documents, with a course syllabus as an example.
---

The reStructuredText support for [text substitutions][rst_subst] offers a simple way to manage periodic updates to a body of documents. Consider a project with multiple documents that reference a shared set of details such as locations, dates, and times. It would be a time-consuming and possibly error-prone process to change each document every time a detail changed. Text substitutions, however, make it possible to centralize the content of a detail (the actual location or date) in a single file. A single edit to that file and rebuild of project documents is now all that is necessary to update project details.

# reStructuredText Substitutions

A reStructuredText in-line substitution is simple---we place substitution text between vertical line `|` characters to create a [substitution reference][rst_subst_ref] and then use the [`replace` directive][rst_replace] to create a substitution definition:

```rst
Here is some |substitution text|.

.. |substitution text| replace:: substituted text
```

[Docutils][docutils] processes this into:

> Here is some substituted text.

# A Syllabus Example

As a teacher, some of the documents that I update most frequently are my course syllabi and home pages. These often include details about the course such as:

1. The course code
1. My contact information
1. My office location and office hours
1. Important course links
1. Links to useful resources
1. Class meeting times
1. The classroom

Some of these details change every term, such as the class meeting times and the classroom. Some change occasionally, such as useful resources. Still others change only infrequently, such as the course code or my email. reStructuredText substitution references are so simple, however, that I might use them even for the course code or my email to hedge, for example, against cases in which I might teach a course at a different institution.

Below are a set of examples to illustrate how to use reStructuredText substitutions to prepare a syllabus (`syllabus.rst`) and home page (`home.rst`) with substitution definitions and [hyperlink targets][rst_hyperlink] centralized on a separate page (`subst.rst`). The savvy reader might also notice the use of [list tables][rst_list_tables] to prepare simple tables.

## Example Syllabus

```rst
|course_code| Syllabus
======================

Course Information
------------------

Communication
^^^^^^^^^^^^^

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Contact information
     - Office hours
   * - * Email: |email|_
       * |forum|_
     - * |office hours|
       * |office|

Course Format
^^^^^^^^^^^^^

.. list-table::
   :widths: 30 40 30

   * - |format|
     - |class time|
     - |classroom|_

Learning Resources
------------------

* |documentation|_
* |primer|_

.. include:: subst.rst
```

## Example Home Page

```rst
Welcome to |course_code|: Introduction to ``rst``!
==================================================

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Instructor contact
     - Learning resources
   * - * Email: |email|_
       * Office hours:

         * |office hours|
         * |office|
     - * |documentation|_
       * |primer|_

.. include:: subst.rst
```

## Example Substitution File


```rst
.. _classroom: classroom/information/page
.. _documentation: https://docutils.sourceforge.io/docs/index.html
.. _forum: course/page/forum
.. _primer: https://docutils.sourceforge.io/docs/user/rst/quickstart.html

.. |class time| replace:: MWF 11:00 AM -- 12:00 PM
.. |classroom| replace:: A Building, Room 202
.. |course_code| replace:: RST101
.. |documentation| replace:: Docutils Project Documentation Overview
.. |email| replace:: email@address
.. |format| replace:: In-person
.. |forum| replace:: General discussion board
.. |office hours| replace:: Mondays 12:00 PM -- 1:00 PM
.. |office| replace:: Another Building, Room 101
.. |primer| replace:: A ReStructuredText Primer
```

## Putting It All Together

A few things to notice:

- Both `syllabus.rst` and `home.rst` contain an [`include` directive][rst_include] that directs the reStructuredText processor (i.e. [Docutils][docutils]) to include the contents of `subst.rst`.
- Some of the in-line substitution references are also hyperlink references (e.g. `|documentation|_`). Hence, they require both a hyperlink target and a substitution definition in `subst.rst`.
- Docutils will replace `|email|` with `email@address`. Since `email@address` is a [standalone hyperlink][rst_standalone], the substitution reference `|email|` does not require a hyperlink reference (namely, `|email|_`). Docutils will render the standalone `email@address` as a hyperlink to `mailto:email@address`.
- I have separated the hyperlink references and substitution definitions in `subst.rst` and organized them alphabetically. This makes it easy to review and update hyperlinks and/or substitution text.

We can now easily generate HTML from our source files:

```
rst2html5 syllabus.rst syllabus.html
rst2html5 home.rst home.html
```

I'll leave it to the reader to generate these results separately. Suffice to say that Docutils makes all specified substitutions; `|office hours|`, for example, becomes "Mondays 12:00 PM -- 1:00 PM."

At the start of a new term, it is now easy to update key details with a simple edit to `subst.rst` alone. Of course, more substantial revisions to the syllabus, such as a change to the course description or assessments, require editing that file directly.


[docutils]: https://docutils.sourceforge.io "Docutils: Documentation Utilities"
[rst_hyperlink]: https://docutils.sourceforge.io/docs/ref/rst/restructuredtext.html#hyperlink-targets "reStructuredText Markup Specification"
[rst_include]: https://docutils.sourceforge.io/docs/ref/rst/directives.html#including-an-external-document-fragment "reStructuredText Directives: Include"
[rst_list_tables]: https://docutils.sourceforge.io/docs/ref/rst/directives.html#list-table "reStructuredText Directives: List tables"
[rst_replace]: https://docutils.sourceforge.io/docs/ref/rst/directives.html#replacement-text "reStructuredText Directives: Replacement text"
[rst_standalone]: https://docutils.sourceforge.io/docs/ref/rst/restructuredtext.html#standalone-hyperlinks "reStructuredText Markup Specification: Standalone hyperlinks"
[rst_subst_ref]: https://docutils.sourceforge.io/docs/ref/rst/restructuredtext.html#substitution-references "reStructuredText Markup Specification: Substitution references"
[rst_subst]: https://docutils.sourceforge.io/docs/ref/rst/restructuredtext.html#substitution-definitions "reStructuredText Markup Specification: Substitution definitions"

