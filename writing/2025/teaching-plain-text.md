---
title: "Teaching in Plain Text"
date: 2025-08-06
keywords: Markdown, Pandoc, Vim, teaching
description: |
  I discuss how I use Markdown, Pandoc, and Vim to prepare plain text teaching materials; the advantages of these tools; and the similarities of my approach to the "Docs as Code" approach to technical documentation.
---

A few years ago, I started to use free, open-source software to prepare all of my teaching materials as plain text files. In my view, working directly in plain text offers educators several benefits:

- By using a simple markup language, such as [Markdown][md], educators can quickly draft materials without making decisions about the final format of those materials.
- We can use free, open-source software to convert the plain text content to a variety of formats, such as HTML for course webpages and PDF for printed materials.
- This allows us to maintain a common set of plain text files for a given course, regardless of the mode of course delivery (online, hybrid, or in-person).
- Perhaps most importantly, by deferring decisions about format (font, margins, etc.) for later, plain text also allows writers to focus on *writing*.

Below I offer an overview of how I use open-source tools to prepare plain text teaching materials, with a focus on preparing materials for use on a course website. (Note that the intended reader is an educator without a background in programming; hence, what follows is a basic introduction to these tools.)

# Markdown

I write most of my teaching materials using Markdown. Markdown is a simple markup language that authors can use to mark formatting in the text of a document. As Kieran Healey has noted in [*The Plain Person's Guide to Plain Text Social Science*][plain], Markdown has "become a *de facto* standard" for writing in plain text.

To create a Markdown file, open a plain text editor, such as Notepad (Windows) or TextEdit (Mac; change the settings from rich text to plain text). Enter text in the file and, by convention, save the file with the extension `.md` (e.g. `syllabus.md`).

There are many guides to Markdown out there in addition to Healey's *Guide* (I've included some links below), so I won't devote much space to the specifics of Markdown here. By way of a brief example, sections are marked with hashtag characters (`#`), emphasized text is placed within single asterisk characters (`*`), and strongly emphasized text is placed between double asterisks:

```
# A Section Heading

In this paragraph, *this text is emphasized*.
**This text is strongly emphasized.**
```

Note that there are many "flavours" of Markdown (more on this shortly), each with different conventions and features.

## Markdown Links

Markdown makes it easy to embed hyperlinks in teaching materials. The Markdown syntax for links is simple:

```
[Text that appears on the page.](url)
```

When I teach, I keep a separate file of links to commonly used resources (e.g. the course syllabus, reading schedule, library course reserves, etc.). For example:

```
[Syllabus](<URL>)
[Reading Schedule](<URL>)
[University Library](<URL>)
```

When I need to reference these pages in another document, I simply copy the relevant link from the file and paste it into the announcement, assessment, etc.:

```
Please refer to the
[Syllabus](<URL>)
or to the course
[Reading Schedule](<URL>).
for details.
```

# Pandoc

I use [Pandoc][pandoc] to convert Markdown documents to other formats, such as HTML, PDF, and Microsoft Word docx. Pandoc is open-source software written by John MacFarlane that converts between markup formats. I typically use Pandoc's [version of Markdown][pandoc-md], though [other variants][pandoc-md-variants] are supported.

## Markdown to HTML

I post many of my teaching materials to [Canvas LMS][canvas] (a learning management system). Instructors can add content to Canvas by using a rich text editor with a GUI (graphical user interface), but Canvas also provides a useful HTML editor. I find it convenient simply to paste raw HTML into the HTML editor.

Pandoc is a command line tool; open a terminal to interact with Pandoc through typed commands.  The most basic way to generate HTML from a Markdown file (e.g. `syllabus.md`) is with a command such as the following:

```
pandoc -t html syllabus.md
```

Pandoc converts the Markdown to HTML and prints the result to the terminal window. Note that by default, the HTML is a "fragment"---it lacks a `<head>` element or `<body>` tags. Fortunately, when using the Canvas HTML editor, a fragment is all that we need. Copy the output and paste it into the Canvas editor; Canvas handles the rest of the HTML. For a "standalone" HTML file with `<head>` and `<body>` elements, use the `-s` standalone option:

```
pandoc -s -t html syllabus.md
```

I use a shell "alias" to simplify this process. I use the `zsh` shell, so my configuration file is `.zshrc`. Determine your default shell (`zsh`, `bash`, etc.) and open the corresponding configuration file (`.zshrc`, `.bashrc`, etc.). Add the following line to the file:

```
alias mdhtml="pbpaste | pandoc -f markdown -t html | pbcopy"
```

This creates the alias `mdhtml` (a mnemonic for "Markdown to HTML"). The command after the equals character (`=`) passes the contents of the clipboard to Pandoc, directs Pandoc to convert the text from Markdown to HTML, and copies the output back to the clipboard.

To use this alias, draft teaching materials in a plain text file, select and copy the contents, and enter `mdhtml` on the command line. The clipboard now contains the HTML version, which you can paste into the Canvas HTML editor.

## Markdown to PDF

When I need to distribute a document in class, I use Pandoc to convert my Markdown files to separate PDF files (e.g. `syllabus.pdf`) and then print out the PDF files:

```
pandoc -o syllabus.pdf syllabus.md
```

Note that Pandoc requires an installation of [LaTeX][latex] in order to produce PDF files. Pandoc first converts the files to plain text LaTeX files; then Pandoc uses a LaTeX generator to create the final PDF file. As with Markdown, there are many guides to LaTeX available online. The LaTeX Project has organized a [number of useful links][latex-links], and I found "[The (Not So) Short Introduction to LaTeX2e][latex-short]" and "[LaTeX2e: An unofficial reference manual][latex-unofficial]" particularly useful.

Customization of PDF files with LaTeX is fairly involved, and I plan to write about my approach separately.

# Vim

I do most of my writing with the open-source text editor [Vim][vim]. Vim allows users to rapidly navigate and edit text files with keyboard commands. Follow the [Vim download instructions][vim-download] for details about installation (note that OSX typically has a version of Vim pre-installed). Once installed, open a terminal and enter `vim` to use the text editor.

Vim takes some getting used to. There are many guides to Vim online, but the quickest way to get started may be the build-in tutorial, which can be launched from the command line with `vimtutor`.

Users can also customize also Vim with code written in Vimscript. I found Steve Losh's online guide, "[Learn Vimscript the Hard Way][vimscript]," to be particularly instructive here.

## Customization

I use a custom Vim command to simplify the conversion from Markdown to HTML:

```
let s:cmd="silent !pbpaste | pandoc -f markdown -t html | pbcopy"
command -bar Mdhtml %y+ | exe s:cmd | redraw!
```

I've included a detailed breakdown of this command [below](#markdown-to-html-with-vim). For now, suffice to say that this command takes the content of the active file, converts it from Markdown to HTML with Pandoc, and stores the HTML in the clipboard.

With this command, I can draft a Markdown-formatted document in Vim, enter the `Mdhtml` command when I finish writing, and then simply paste the contents of my clipboard (the HTML version) into the Canvas HTML editor.



---

# Appendix

## Markdown Resources

- John Gruber's [original specification][gruber]
- [CommonMark Markdown specification][commonmark]
- [Pandoc's Markdown][pandoc-md]

## Markdown to HTML with Vim

```
let s:cmd="silent !pbpaste | pandoc -f markdown -t html | pbcopy"
command -bar Mdhtml %y+ | exe s:cmd | redraw!
```

The first line assigns the string in quotation marks (`"`) to the variable `s:cmd`. The second line defines a command, `Mdhtml`, that executes (`exe`) the string as a command.

Contents of the string assigned to `s:cmd`:

- `silent` means that Vim will not show the command line during execution.
- Everything after the exclamation point character (`!`) is executed by the shell.
- `pbpaste |` sends the content of the clipboard to the command that follows the vertical bar character (`|`).
- `pandoc -f markdown -t html |` converts the text from Markdown to HTML and passes the output to the command that follows the vertical bar character.
- `pbcopy` copies the text to the clipboard.

Command on the second line:

- `command` defines a new command, `Mdhtml`.
- `-bar` allows us to group multiple commands together, separated by vertical bar characters (`|`).
- `%y+` "yanks" (copies) the text of the current file to the clipboard.
- `exe s:cmd ` executes the command discussed above.
- `redraw!` instructs Vim to clear and redraw the screen. (Execution of the shell command sometimes disrupts the appearance of the text editor; this resets the appearance.)

[canvas-rich]: https://community.canvaslms.com/t5/Canvas-Basics-Guide/What-is-the-Rich-Content-Editor-RCE/ta-p/12 "Canvas Basics Guide: Rich content editor"
[canvas]: https://www.instructure.com/canvas "Canvas by Instructure"
[commonmark]: https://commonmark.org "CommonMark"
[gruber]: https://daringfireball.net/projects/markdown/syntax "Markdown: Syntax"
[latex-links]: https://www.latex-project.org/help/links/ "LaTeX Project: Useful Links"
[latex-short]: https://ctan.mirror.rafal.ca/info/lshort/english/lshort.pdf "The (Not So) Short Introduction to LaTeX2e"
[latex-unofficial]: https://ctan.org/pkg/latex2e-help-texinfo "LATEX2e: An unofficial reference manual"
[latex]: https://www.latex-project.org/ "LaTeX Project"
[libre]: https://www.libreoffice.org "LibreOffice"
[md]: https://daringfireball.net/projects/markdown/ "Markdown"
[pandoc-md-variants]: https://pandoc.org/MANUAL.html#markdown-variants "Pandoc User's Guide: Markdown variants"
[pandoc-md]: https://pandoc.org/MANUAL.html#pandocs-markdown "Pandoc User's Guide: Pandoc's markdown"
[pandoc]: https://pandoc.org "Pandoc"
[plain]: https://plain-text.co/write-and-edit.html#write-and-edit "The Plain Person's Guide to Plain Text Social Science: Write and edit"
[vim-download]: https://www.vim.org/download.php "Downloading Vim"
[vim]: https://www.vim.org "Vim"
[vimscript]: https://learnvimscriptthehardway.stevelosh.com "Learn Vimsceript the Hard Way"

