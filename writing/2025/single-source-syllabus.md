---
title: "A Single Source Syllabus"
date: 2025-05-14
revised: 2025-08-06
keywords: Markdown, LaTeX, Pandoc, Make, teaching
description: |
  I discuss how I use Markdown, LaTeX, Pandoc, and Make to prepare different different documents in different formats from a single plain-text source.
---

In my teaching, I often produce documents such as course syllabi in several formats. For each course, I typically post an HTML copy of the syllabus on the course website on [Canvas LMS][canvas]; I provide a PDF copy for download and optional printing; and I occasionally distribute a copy as a Microsoft Word docx document to the department office for review. There are some considerations that must be taken into account when preparing a document for these different outputs. The most basic issues centre on titles and headings. To explain these issues, I'll first explain how [Pandoc][pandoc] produces PDF files from plain text, then I'll discuss some specifics of Canvas LMS pages, and finally I'll conclude with a discussion of how to automate document production with [Make][make].

# Pandoc, LaTeX, and PDF Files

As explained in the [user guide][pandoc_user], Pandoc creates a PDF from another format by first converting the original document to LaTeX and then using a LaTeX engine to convert the plain text to PDF. [LaTeX][latex_project] is software that generates PDF files from plain-text files; authors include LaTeX commands to specify formatting. Emphasized (italicized) and boldface text is marked as follows:

```latex
\emph{This text is in italics.}
\textbf{And this text is in boldface.}
```

Each LaTeX document requires a document "class," such as a book or article. For a syllabus, I use the "article" class. A LaTeX article can include a title; subsequent sections of the document are divided into sections, sub-sections, and sub-sub-sections. Sections correspond to level-one Markdown headings; the title corresponds to the title specified in the [metadata block][pandoc_meta]. When I use Pandoc, I typically opt for the [YAML metadata block][pandoc-yaml]. Hence, I might begin a basic syllabus as follows:


```markdown
---
title: "ASIA 101 Introduction to Modern Asia"
---

# Course information

## General information

- Credit value: 3
- Prerequisites: None
```

A basic Pandoc command to convert this to LaTeX is:

```console
$ pandoc -s -o syllabus.tex syllabus.md
```

This command includes the `-s` option to create a "standalone" document. Here is the output (with much of the header removed to focus on the content):

```latex
\title{ASIA 101 Introduction to Modern Asia}
\author{}
\date{}

\begin{document}
\maketitle

\section{Course information}\label{course-information}

\subsection{General information}\label{general-information}

\begin{itemize}
\tightlist
\item
  Credit value: 3
\item
  Prerequisites: None
\end{itemize}

\end{document}
```

The document begins after `\begin{document}`. The LaTeX engine will create the title, author, and date at `\maketitle`. Note that the level-one Markdown heading, `# Course Information`, is now a section with a label:

```latex
\section{Course information}\label{course-information}
```

On its own, this would serve as a satisfactory syllabus. Issues arise, however, when producing an HTML copy.

# Pandoc and HTML

Here is a basic command to convert the above Markdown to HTML:

```console
$ pandoc -s -o syllabus.html syllabus.md
```

This results in the following HTML (here I have removed the HTML `<head>` to show only the body content):

```html
<header id="title-block-header">
<h1 class="title">ASIA 101 Introduction to Modern Asia</h1>
</header>
<h1 id="course-information">Course information</h1>
<h2 id="general-information">General information</h2>
<ul>
<li>Credit value: 3</li>
<li>Prerequisites: None</li>
</ul>
```

Note that Pandoc has rendered both the `title` from the YAML metadata block and the "Course information" heading as level-one `<h1>` HTML tags. I would prefer, however, only a single, top-level `<h1>` tag on the page.

I also want to transfer the HTML to Canvas LMS to create a course page. Canvas, however, reserves `<h1>` tags for the title of the page, entered separately from the content of the page. Canvas will convert any `<h1>` tags entered by users into paragraph `<p>` tags and adjust the font to a larger size.

The basic Pandoc commands shown above will not satisfactorily create HTML and PDF copies from the same Markdown source.

# Effective Pandoc Options

Pandoc, however, makes it possible to resolve these issues through various command options and variable settings.

First, I will move the metadata for the PDF to a separate YAML file, `pdf-meta.yaml` (here I have also added an author and specified the PDF font):

```yaml
title: "ASIA 101 Introduction to Modern ASIA"
author: "Dr. Elijah Greenstein"
mainfont: "Palatino"
```

The syllabus itself now begins with:

```markdown
# Course information
```

Next, I can prepare two different Pandoc commands. The first generates the PDF:

```console
$ pandoc --metadata-file=pdf-meta.yaml -o syllabus.pdf syllabus.md
```

By including the `--metadata-file` option, I direct Pandoc to include my YAML file when generating the PDF.

This second command generates HTML and copies it to my clipboard:

```console
$ pandoc -t html --shift-heading-level-by=1 syllabus.md | pbcopy
```

Note that I have included `--shift-heading-level-by=1`. With this option, Pandoc will now shift all of the Markdown headings one level when producing HTML tags. The result is:

```html
<h2 id="course-information">Course information</h2>
<h3 id="general-information">General information</h3>
<ul>
<li>Credit value: 3</li>
<li>Prerequisites: None</li>
</ul>
```

Note that the "Course information" heading is now marked by a level-two heading tag `<h2>`. I can now paste the contents of my clipboard into the Canvas HTML text editor and write the title directly into the Canvas GUI.

# How to `make` Multiple Outputs

Of course, I don't want to have to write out these commands each time I revise my syllabus. The solution here is [Make][make]: software used to build other software. Make follows "rules" to create "target" files from "prerequisite" files through command line actions. I won't discuss Make at length here, but Kieran Healy provides useful discussion in *[The Plain Person's Guide to Plain Text Social Science][plain]*. In short, users specify actions in a `Makefile`. Here is a rule to generate a PDF from a Markdown file (note that in an actual `Makefile`, each indentation must use a "tab" character rather than spaces):


```make
syllabus.pdf: syllabus.md
	pandoc --metadata-file=pdf-meta.yaml \
	-o syllabus.pdf syllabus.md
```

Here, `syllabus.pdf` is the target and `syllabus.md` is the prerequisite. To use Make, set the working directory of the terminal to the directory containing the `Makefile` and enter `make` on the command line. Critically, Make will only execute the action under two conditions:

1. the target file does not exist or 
2. the modification time of the dependency file is *after* that of the target file.

Any time I revise `syllabus.md`, I can use the `make` command to generate a new PDF. I can also add a rule to generate an HTML copy:

```make
syllabus.html: syllabus.md
	pandoc -o $@ $<
	cat $@ | pbcopy
```

Here I have also used two automatic variables to simplify the rule: `$<` refers to the first prerequisite (`syllabus.html`) and `$@` refers to the target file.

Note that under this rule, Make first generates a local HTML copy with Pandoc; then it uses the `cat` command to read the HTML file and copy its contents to the clipboard with `pbcopy`.

The command `make` will only create the first "target" in the file. In order to create both copies of the syllabus at once, I include a "phony" target, `syllabus`, that has two prerequisites: the PDF version and the PDF copy. Here is a full example `Makefile` (note the use of automatic variables for the PDF rule, too):

```make
.PHONY: syllabus
syllabus: syllabus.pdf syllabus.html

syllabus.pdf: syllabus.md pdf-meta.yaml
	pandoc --metadata-file=pdf-meta.yaml -o $@ $<

syllabus.html: syllabus.md
	pandoc -o $@ $<
	cat $@ | pbcopy
```

With this `Makefile`, when I enter `make` or `make syllabus` on the command line, Make

1. generates a PDF copy of my syllabus with Pandoc,
1. generates an HTML copy of my syllabus with Pandoc, and
1. copies the contents of the HTML copy to my clipboard (which I can paste into the syllabus page on Canvas).

# From a Single Source

As described above, Pandoc and Make facilitate the generation of documents in multiple formats from a single plain-text source. It is simple to add additional directives to the `Makefile` as needed, such as a rule to create a Microsoft Word version of the syllabus. Writing the syllabus itself in a single file ensures that output files share common content regardless of the format. Automation with Make, moreover, both simplifies document generation (a command of only a single word, `make`, is needed) and guarantees that documents are consistently generated with each revision.

[canvas]: https://www.instructure.com/canvas
[latex_project]: https://www.latex-project.org/get/
[make]: https://www.gnu.org/software/make/
[pandoc_meta]: https://pandoc.org/MANUAL.html#metadata-blocks
[pandoc_user]: https://pandoc.org/MANUAL.html#creating-a-pdf
[pandoc-yaml]: https://pandoc.org/MANUAL.html#extension-yaml_metadata_block
[pandoc]: https://pandoc.org
[plain]: https://plain-text.co/pull-it-together.html#automation-with-make
[yaml]: https://yaml.org

