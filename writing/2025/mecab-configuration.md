---
title: "Some Notes on Configuring MeCab"
date: 2025-07-08
revised: 2025-08-06
keywords: MeCab
description: A description
---

I recently had occasion to install [MeCab][mecab], the Japanese text tokenizer and part of speech tagger, on a new Mac. In the past, I followed Mark Ravina's [guide to installing MeCab on a Mac][ravina], but this time I followed a slightly different process (namely, I did not find it necessary to get write privileges on `/usr/local` and I chose to clone the code from `git` rather than download the zipped archive of the source code).

Below I provide an overview of the installation process, as well as an example of how I configured MeCab for a custom output format.

# Installation

Installation instructions are available on the MeCab [home page][mecab], but I chose to work with the GitHub repository itself.

First, I cloned the repository:

```console
$ git clone https://github.com/taku910/mecab.git
```

Then, I changed into the `mecab` subdirectory of the repository:

```console
$ cd mecab/mecab/
```

Installation instructions are detailed in `INSTALL`, and basically follow the [UNIX installation][mecab-unix] instructions on the MeCab home page. To ensure that MeCab used UTF-8 encoding, I included the `--with-charset=utf8` option to configure the Makefile:

```console
$ ./configure --with-charset=utf8
$ make check
$ sudo make install
```

This installs `mecab` into `/usr/local/bin` and creates a configuration file, `/usr/local/etc/mecabrc`. More on the configuration file in a moment.

MeCab also requires a dictionary. For this step, I changed into the IPADic directory in the repository:

```console
$ cd ../mecab-ipadic/
```

Installation instructions are, again, detailed in `INSTALL`. Once again, I set character encoding to UTF-8:

```console
$ ./configure --with-charset=utf8
$ make check
$ sudo make install
```

This installs the IPADic dictionary into `/usr/local/lib/mecab/dic/ipadic`. Basic MeCab usage is detailed on the [Mecab home page][mecab-usage].

```console
$ mecab
すもももももももものうち
```

This should output:

```console
すもも  名詞,一般,*,*,*,*,すもも,スモモ,スモモ
も      助詞,係助詞,*,*,*,*,も,モ,モ
もも    名詞,一般,*,*,*,*,もも,モモ,モモ
も      助詞,係助詞,*,*,*,*,も,モ,モ
もも    名詞,一般,*,*,*,*,もも,モモ,モモ
の      助詞,連体化,*,*,*,*,の,ノ,ノ
うち    名詞,非自立,副詞可能,*,*,*,うち,ウチ,ウチ
EOS
```

# Additional Dictionaries

The [National Institute for Japanese Language and Linguistics][ninjal] also offers the more specialized "[Unidic][unidic]" dictionaries. First, I installed ["Unidic for Contemporary Written Japanese" (現代書き言葉)][unidic-cwj]. 

To download the dictionary (`unidic-cwj-202302`), click the download button (ライセンスに同意して最新版をダウンロード [agree to the license and download newest version]). Move `unidic-cwj-202302` and its contents from the `Downloads` directory to the directory of MeCab dictionaries, `/usr/local/lib/mecab/dic`. To open the dictionary directory, simply enter:

```console
$ open /usr/local/lib/mecab/dic
```

I often work with Meiji, Taishō, and early Shōwa documents, so I also installed the ["Modern Literary UniDic" (近代文語UniDic)][unidic-modern]. 

Once again, use the link to download a directory (`unidic-kindai-bungo`), and then move the directory to `/usr/local/lib/mecab/dic`.

# Dictionary Configuration

The default configuration file for MeCab is `/usr/local/etc/mecabrc`. Most lines are comments that begin with a semi-colon character (`;`). The dictionary directory is set as follows:

```
dicdir =  /usr/local/lib/mecab/dic/ipadic
```

We can check the dictionary used by MeCab with the `-D` option:

```console
$ mecab -D
```

The `filename` should be `/usr/local/lib/mecab/dic/ipadic/sys.dic`.

To use a different dictionary, we need to specify a different directory. We can do so by creating our own configuration file in our home directory. Change into the home directory and open a new configuration file, `.mecabrc`, with Vim:

```console
$ cd ~ && vim .mecabrc
```

We can specify a different dictionary directory here (note that the first line is a comment):

```
; MeCab configuration file
dicdir = /usr/local/lib/mecab/dic/unidic-cwj-202302
```

Now, `mecab -D` should output a `filename` that corresponds to the directory containing the "Unidic for Contemporary Written Japanese."

# Output Format

There are a number of ways to interact with MeCab, such as the [RMeCab library][rmecab] for R and the [Fugashi library][fugashi] for Python. For my purposes, I often want to tokenize a batch of documents all at once, and then do some exploratory analysis. For this, I find that it is simpler to configure MeCab to produce CSV files, and then load the CSV files as data frames in Python or R.

The default UniDic output is lengthy. For example:

```console
$ mecab
すもももももももものうち
```

produces:

```console
すもも	名詞,普通名詞,一般,*,*,*,スモモ,李,すもも,スモモ,すもも,スモモ,和,*,*,*,*,*,*,体,スモモ,スモモ,スモモ,スモモ,0,C2,*,15660352771596800,56972
も	助詞,係助詞,*,*,*,*,モ,も,も,モ,も,モ,和,*,*,*,*,*,*,係助,モ,モ,モ,モ,*,"動詞%F2@-1,形容詞%F4@-2,名詞%F1",*,10324972564259328,37562
もも	名詞,普通名詞,一般,*,*,*,モモ,桃,もも,モモ,もも,モモ,和,*,*,*,*,*,*,体,モモ,モモ,モモ,モモ,0,C3,*,10425303000293888,37927
も	助詞,係助詞,*,*,*,*,モ,も,も,モ,も,モ,和,*,*,*,*,*,*,係助,モ,モ,モ,モ,*,"動詞%F2@-1,形容詞%F4@-2,名詞%F1",*,10324972564259328,37562
もも	名詞,普通名詞,一般,*,*,*,モモ,桃,もも,モモ,もも,モモ,和,*,*,*,*,*,*,体,モモ,モモ,モモ,モモ,0,C3,*,10425303000293888,37927
の	助詞,格助詞,*,*,*,*,ノ,の,の,ノ,の,ノ,和,*,*,*,*,*,*,格助,ノ,ノ,ノ,ノ,*,名詞%F1,*,7968444268028416,28989
うち	名詞,普通名詞,副詞可能,*,*,*,ウチ,内,うち,ウチ,うち,ウチ,和,*,*,チ促,基本形,*,*,体,ウチ,ウチ,ウチ,ウチ,0,C3,*,881267193291264,3206
EOS
```

The token is followed by a tab character; part-of-speech and morphological details that follow are separated by commas.

The MeCab documentation details how to [set the output format][mecab-format]. I generally want the token, the lemma, the lemma reading, and any part of speech information. I also want to know if the token was marked as known or "unknown" ("UNK", "未知語形態素"), and I want to mark new lines ("EOS"). To do so, I set the following "keys" for the "node", "unk", and "eos" format in my `.mecabrc` configuration file:

```
node-format-basic = %m,%f[7],%f[6],%f[0],%f[1],%f[2],%f[3],1\n
unk-format-basic = %m,%m,%m,%f[0],%f[1],%f[2],%f[3],0\n
eos-format-basic = EOS,,,,,,,2\n
```

Note that each key is appended with `basic`. We can now produce output with those fields by invoking `mecab` with the `-O` flag set to `basic`:

```console
$ mecab -Obasic
すもももももももものうち
```

This produces:

```console
すもも,李,スモモ,名詞,普通名詞,一般,,1
も,も,モ,助詞,係助詞,,,1
もも,桃,モモ,名詞,普通名詞,一般,,1
も,も,モ,助詞,係助詞,,,1
もも,桃,モモ,名詞,普通名詞,一般,,1
の,の,ノ,助詞,格助詞,,,1
うち,内,ウチ,名詞,普通名詞,副詞可能,,1
EOS,,,,,,,2
```

Each line now has eight fields:

1. Original token (`%m`)
1. Lemma (`%f[7]`)
1. Lemma reading (`%f[6]`)
1. Part of speech, field 1 (`%f[0]`)
1. Part of speech, field 2 (`%f[1]`)
1. Part of speech, field 3 (`%f[2]`)
1. Part of speech, field 4 (`%f[3]`)
1. "Known" token (`1`), "unknown" token (`0`), "end of string" (`2`).

It is now easy to create CSV files of tokenized text, with part-of-speech information. Let's say we have a Japanese text file, `maihime.txt`. We can produce a CSV file of tokens with:

```console
$ mecab -Obasic maihime.txt > maihime.csv
```

Likewise, we can process an entire directory of files, `texts`, and write the tokenized output to CSV files in `tokens` with a simple `for` loop:

```console
$ for file in texts/*.txt ; \
> do \
> filename=${file%.txt} \
> output=tokens/${filename##*/}.csv \
> mecab -Obasic ${file} > ${output} ; \
> done
```

Note that this can create problems if the text contains comma characters (`,`) ; the comma token will appear to have additional fields separated by the token itself. To prevent this, a simple `sed` command can replace all ASCII comma characters (`,`) with CJK comma characters (`、`):

```console
$ sed -i '' 's/,/、/g;' FILE.txt
```

Likewise, text that contains double quotes characters (`"`) can pose a problem when reading the output CSV file. We can similarly replace these with CJK double quotes characters (`”`):

```console
$ sed -i '' 's/"/”/g;' FILE.txt
```

Other fields can be specified as found under "出力フォーマット" (output format) in the [documentation][mecab-format]. Note that `%f` and `%F` specify certain features. The list of features by field number is available in the [Unidic FAQ][unidic-faq], as are [Japanese versions of the field codes][unidic-col_name]. Paul O'Leary McCann, author of the [Fugashi][fugashi] Python package, provides an English-language overview of the fields in the `README` for his [unidic-py][unidic-py] package.


[fugashi]: https://github.com/polm/fugashi "Fugashi GitHub page"
[mecab-format]: https://taku910.github.io/mecab/format.html "MeCab documentation: Output format"
[mecab-unix]: https://taku910.github.io/mecab/#install-unix "MeCab documentation: Installation"
[mecab-usage]: https://taku910.github.io/mecab/#usage-tools "MeCab documentation: Usage"
[mecab]: https://taku910.github.io/mecab/ "MeCab documentation"
[ninjal]: https://www.ninjal.ac.jp "National Institute for Japanese Language and Linguistics"
[ravina]: https://laits.utexas.edu/~mr56267/Japanese_Text_Mining/MeCab_RMeCab.html#installing-on-mac "Installing MeCab, RMeCab and UniDic: On Mac"
[rmecab]: https://github.com/IshidaMotohiro/RMeCab "RMeCab GitHub page"
[unidic-col_name]: https://clrd.ninjal.ac.jp/unidic/faq.html#col_name "Unidic FAQ"
[unidic-cwj]: https://clrd.ninjal.ac.jp/unidic/download.html#unidic_bccwj "Unidic for Contemporary Written Japanese download page"
[unidic-faq]: https://clrd.ninjal.ac.jp/unidic/faq.html "Unidic FAQ"
[unidic-modern]: https://clrd.ninjal.ac.jp/unidic/download_all.html#unidic_kindai "Modern Literary UniDic download page"
[unidic-py]: https://github.com/polm/unidic-py "unidic-py GitHub page"
[unidic]: https://clrd.ninjal.ac.jp/unidic/ "Unidic"

