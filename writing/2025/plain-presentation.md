---
title: "Plain text presentation slides"
date: 2025-10-22
revised: 2025-10-23
keywords: Markdown, Pandoc, Make, LaTeX, Beamer, teaching
description: |
  I discuss how I organize plain text Markdown files to efficiently generate PDF slide shows with Pandoc and Make.
---


I've been using [Pandoc][pandoc] to generate presentation slides from Markdown files for several years now.
I typically generate PDF slides, though Pandoc offers conversion from Markdown to several other [slide show formats][pandoc-slide-shows].
Pandoc first converts the Markdown to LaTeX (typeset with the [Beamer][ctan-beamer] document class) and then uses a LaTeX engine to create the PDF files. 

I've found that working with plain text forces me to be more intentional and, generally, parsimonious in my use of text and images in a presentation.
Beamer/LaTeX settings, for example, will determine the default font size and  area available for body text.
If I include too much text, it simply runs off the PDF slide;
neither Pandoc nor the LaTeX engine will step in to resize the text to make it fit (typical behaviour in other presentation software that I have used).
LaTeX commands, of course, offer a high degree of customization, and it's certainly possible to adjust the font size and text area.
But I find that it's often not worth the effort.
Instead, I prefer to focus on my *writing*: crafting text that effectively communicates key information in the available space.
Likewise, it requires a fair degree of effort to include more than two or three images in a slide.
Rather than cramming many images onto a single slide, I instead prefer to devote time to carefully selecting an image or two that helps to *communicate* the intended information.

Another advantage of working in plain text is the disaggregation of the slide show into its core components.
For a given slide show, I prepare one or more style sheets in one directory and centralize images (and figures) in another.
I then draft the slide show text in a plain text file, marked up with Pandoc's Markdown conventions, with links to style sheets and images as necessary.
The separation of the components into different files simplifies text updates, style changes, and image replacements.
Pandoc, meanwhile, makes it easy to combine the components into a slide show with a single command.

This setup is ideal for teaching.
When I teach a course, I typically need to prepare at least a dozen different slide shows.
Images can be embedded with a simple syntax: `![Caption](filename.jpg)`;
this facilitates the reuse of images across presentations.
Plain text style files, meanwhile, are easy to modify with a few keystrokes.
[Make][make], moreover, makes it easy to build and rebuild PDF slides with a single, short command;
hence, any changes to styles can easily be applied to every slide show in the course.

In the following, I outline how I use Pandoc, Markdown, and Make to efficiently prepare multiple slide shows with a shared style from a set of plain text files.

# Organization

As noted above, there are three components to a slide show: text, style sheets, and images.
For a given class, let's say "Plain Text 101," I organize these into the following directory structure:

```
PT101/
    Makefile
    images/
        picture.jpg
    slides/
        build/
        source/
            01-intro.md
        styles/
            primarystyle.sty
```

As I discuss [below](#automate-slide-generation-with-make), the `Makefile` uses Pandoc to build the PDF slides into `slides/build`.

The `slides` directory contains two sub-directories: one for slide show Markdown files (`slides/source`) and the other for style sheets (`slides/styles`).

I place the `images` directory in the root project directory, however, because I sometimes use the same images on the course website or in other learning materials. The full course, then, may look like the following:

```
PT101/
    Makefile
    assessments/
    images/
    modules/
    notes/
    slides/
    syllabus/
```

# Markdown for slide shows

Pandoc makes it simple to mark up a plain text file as a slide show.
Details are available in the [Pandoc User Guide][pandoc-slide-shows]. Here is an example:

```
---
title: "Plain text slide shows"
subtitle: "An Introduction"
author: "Mark Down"
date: 2025-10-22
---

# Overview

## How to use columns

::::::{.columns}
:::{.column}
This is the left column.
:::
:::{.column}
This is the right column.
:::
::::::

## How to include images

![Image caption](picture.jpg){height=70%}
```

Pandoc will generate four slides from this file:

1. A title slide with the title, subtitle, author, and date from the metadata centred in the middle of the slide.
1. A section slide with "Overview" centred in the middle of the slide.
1. A slide with the heading "How to use columns" at the top of the slide, and left-aligned text in two columns in the middle of the slide.
1. A slide with the heading "How to include images" at the top of the slide and the image in `images/picture.jpg` embedded in the middle of the slide.
The optional `height` attribute specifies that the height of the image should be no more than 70 percent of the space of the slide available for text.

Note that the fourth slide uses the file name `picture.jpg` to embed the image.
This assumes that `images` will be included as a resource path when the `pandoc` command is executed ([discussed below](#produce-a-slide-show-with-pandoc)).

# How to style slides

By default, Pandoc uses a simple Beamer theme: white background, blue structure text (e.g. headings), and black body text.
You can add a `theme` field to the metadata to select a different Beamer theme (see the Beamer package documentation on [CTAN][ctan-beamer] for available themes):

```
---
title: "Plain text slide shows"
subtitle: "An Introduction"
author: "Mark Down"
date: 2025-10-22
theme: Warsaw
---
```

The default [aspect ratio][pandoc-aspect] for the slides is 4:3, but you can change the ratio by adding an `aspectratio` field to the metadata.
For example, to use a 16:9 ratio:

```
---
title: "Plain text slide shows"
subtitle: "An Introduction"
author: "Mark Down"
date: 2025-10-22
theme: Warsaw
aspectratio: 169
---
```


## Custom style files

Alternatively, you can style the slides yourself.
It's possible to include those commands directly in the metadata; however, as I discussed at the start of this page, I recommend *separating* the style sheets into separate files.
As seen in the directory structure [above](#organization), I place style files in the `slides/styles` sub-directory.
Placing commands in a single file makes it easy to change the style for *all* slide shows.
For example, I might specify a default font in the style sheet; if I decide to change the font later, I only need to update that one file.

Pandoc makes it simple to include a LaTeX style file: add a `\usepackage` command to the `header-includes` field in the metadata:


```
---
title: "Plain text slide shows"
subtitle: "An Introduction"
author: "Mark Down"
date: 2025-10-22
aspectratio: 169
header-includes: |
  \usepackage{slides/styles/primarystyle}
---
```

Note that the path to the style file is relative to the root project directory (`PT101`), rather than relative to the Markdown file.
This setup assumes that `PT101` will be the working directory when the `pandoc` command is executed ([discussed below](#produce-a-slide-show-with-pandoc)).

Additionally, note that the metadata still contains the `aspectratio` field.
This is an option passed directly to the `beamer` document class, and, hence, not a setting that can be configured in the `header-includes` field.

It's also possible to group commands into more than one file.
For example, I occasionally use Chinese and Japanese text in my slides, which requires additional LaTeX commands.
I can, therefore, group those settings into a separate file: `slides/styles/cjkconfig.sty`.
When I need these additional settings, I can use that package along with `primarystyle`:

```
header-includes: |
  \usepackage{slides/styles/cjkconfig}
  \usepackage{slides/styles/primarystyle}
```

## Example style file

Below is an example style file (`primarystyle.sty`) that modifies colours, fonts, and list symbols (refer to the Beamer package documentation on [CTAN][ctan-beamer] for additional details).

```latex
% Required commands
\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{primarystyle}

% Set fonts
\setmainfont{Times New Roman}
\setsansfont{Arial}
\renewcommand{\familydefault}{\sfdefault}

% Set structure colour
\definecolor{myteal}{RGB}{0, 112, 112}
\usecolortheme[named=myteal]{structure}

% Set list symbols
\setbeamertemplate{itemize item}{$\bullet$}
\setbeamertemplate{itemize subitem}{--}
\setbeamertemplate{itemize subsubitem}{$\ast$}
```

These four blocks of commands accomplish the following:

1. As specified in the Overleaf guide, [Writing your own package][overleaf-package], the style file must include the two commands in the first block: `\NeedsTeXFormat` and `\ProvidesPackage`.
Note that I place the name of the package, `primarystyle`, between the curly braces in `\ProvidesPackage{primarystyle}`.
1. The second block of commands sets the main font to Times New Roman and the sans serif font to Arial; it then makes sans serif (Arial) the default font family.
1. The third block of commands defines a colour, `myteal`, and then styles "structure" elements in the slides with that colour. "Structure" elements include heading text and list symbols. Note that `\usecolortheme` is a Beamer-specific command.
1. The fourth block of commands specifies the symbols to use for itemized lists.
The Beamer package uses the "black right-pointing triangle" symbol (`U+25B6`) for lists, but I prefer the LaTeX defaults: bullet, en dash, and asterisk operator.
This block of commands specifies the latter set of symbols.
Note that `\setbeamertemplate` is also a Beamer-specific command.

# Produce a slide show with Pandoc

A single Pandoc command can put together a Markdown file, image file(s), and style file(s) into a PDF slide show.
As discussed above, the command must (1) be executed with `PT101` as the working directory and (2) specify `images` as a "[resource path][pandoc-resource]."
To do so, first change the working directory to `PT101` with `cd`; then execute this command:

```console
$ pandoc -o slides/build/01-intro.pdf \
> -t beamer \
> --resource-path=images \
> --pdf-engine=lualatex \
> slides/source/01-intro.md
```

The above command

- specifies an output path for the PDF slides with the `-o` option
- instructs Pandoc to produce Beamer slides with the `-t` option followed by `beamer`
- instructs Pandoc to look for resources (images) in the `images` directory with the `--resource-path` option
- specifies a LaTeX engine (I tend to use LuaLaTeX, but there are [other options][pandoc-pdf-engine])
- specifies the source Markdown file (`slides/source/01-intro.md`)

# Automate slide generation with Make

The Pandoc command requires a number of options; fortunately, we can simplify the process with Make.
Here is an annotated `Makefile` (intended for the root project directory, as seen [above](#organization)):

```make
# Variables for key directories
sld := slides
img := images
src := source
bld := build
sty := styles

# LaTeX engine
tex := lualatex

# List of Markdown files in `slides/source`
sldmd := $(wildcard $(sld)/$(src)/*.md)

# List of corresponding PDF files to build in `slides/build`
sldpdf := $(subst $(src),$(bld),$(sldmd:.md=.pdf))

# "Phony" target to make all slides
.PHONY: slides
slides: $(sldpdf)

# Pandoc command: make PDF slides in `build` from Markdown files in `source`
$(sld)/$(bld)/%.pdf: $(sld)/$(src)/%.md $(sld)/$(bld)
	pandoc -o $@ -t beamer --resource-path=$(img) --pdf-engine=$(tex) $<

# Make `slides/build` directory, if necessary
$(sld)/$(bld):
	mkdir -p $@
```

This `Makefile` makes it possible to create all PDF slide shows from the source Markdown files with a single, short command:

```console
$ make slides
```

Make will check that each Markdown file in `slides/source` has a corresponding, up-to-date PDF file in `slides/build`.
If it does not, Make will use the Pandoc command shown above to generate the PDF slides.

For example, if I have a slide show, `01-intro.md`, in `slides/source` and I execute `make slides`, then Make will use Pandoc to produce `01-intro.pdf` in `slides/build`.
If I execute `make slides` again, Make will find `01-intro.pdf` and refrain from executing the Pandoc command again.
If, however, I modify `01-intro.md`, then, the next time I enter `make slides`, Make will rebuild `01-intro.pdf` from the updated source file.

Note that this `Makefile` does not make style files a dependency of the slide shows.
As a result, updates to the style files will not automatically trigger a rebuild of the PDF slides.
To force a rebuild any time style files are update, use the following:

```make
# Pandoc command: make PDF slides in `build` from Markdown files in `source`
# (Updates to style files in `styles` trigger a rebuild of the PDF files.)
$(sld)/$(bld)/%.pdf: $(sld)/$(src)/%.md $(sld)/$(bld) $(sldsty)
	pandoc -o $@ -t beamer --resource-path=$(img) --pdf-engine=$(tex) $<
```

[ctan-beamer]: https://www.ctan.org/pkg/beamer
[make]: https://www.gnu.org/software/make/
[overleaf-package]: https://www.overleaf.com/learn/latex/Writing_your_own_package
[pandoc-aspect]: https://pandoc.org/MANUAL.html#variables-for-beamer-slides
[pandoc-pdf-engine]: https://pandoc.org/MANUAL.html#option--pdf-engine
[pandoc-resource]: https://pandoc.org/MANUAL.html#option--resource-path
[pandoc-slide-shows]: https://pandoc.org/MANUAL.html#slide-shows
[pandoc]: https://pandoc.org/
