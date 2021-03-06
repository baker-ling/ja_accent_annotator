# JAAn (/dʒaːN/)
  Japanese Accent Annotator

JAAn is a project to build a Japanese accent annotator and learn more Python in the process.

Right now the code for JAAn is entirely in jaan.ipynb and jaan.py, which are almost identical. Pretty soon I will eliminate the Jupyter notebook, turn it into a CLI tool, and add an option to covert to JSL romanziation.

JAAn relies on fugashi and UniDic to tokenize text. Eventually I will try making a custom dictionary to correct some weird behavior from UniDic. So far I have noticed that the first parsing from the standard written Japanese version of UniDic parses '日本語' as ['にっぽん', 'ご'] while I think ['にほん', 'ご'] should be the preferred parsing. Also, 語/ご has an aConType of 'C3' (suffixing to yield accent on final mora of what it attaches too) whereas I think it should be 'C4' (suffixing to yield an unaccented (平板型) word).

JAAn relies on ChaOne to combine the short-unit word token sequences from fugashi/UniDic into accent phrases. ChaOne is covered by a separate license from JAAn. (See https://github.com/baker-ling/ja_accent_annotator/blob/master/chaone-1.3.0b2/license.txt for details.)

- Brian D. Baker
