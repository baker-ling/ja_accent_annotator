# ジャアン - JAAn
  Japanese Accent Annotator

JAAn is a project to build a Japanese accent annotator and learn more Python in the process.

Right now the code for JAAn is entirely in jaan.ipynb. Pretty soon I will take it out of the Jupyter notebook, turn it into a CLI tool, and  

JAAn relies on fugashi and UniDic to tokenize text. Eventually I will try making a custom dictionary to correct some weird behavior from UniDic. So far I have noticed that the first parsing from standard written Japanese version of UniDic parses '日本語' as ['にっぽん', 'ご'] while I think ['にほん', 'ご'] should be the preferred parsing. Also, 語/ご has an aConType of 'C3' (suffixes to yield accent on final mora of what it attaches too) whereas I think it should be 'C4' (suffixes to yield an unaccented (平板型) word).

JAAn relies on ChaOne to combine the short word unit token sequences from fugashi/UniDic into accent phrases. ChaOne can be downloaded from https://osdn.net/projects/galateatalk/releases/p5346. I did not include it in this repository because the ChaOne download files from the OSDN.net galateatalk repository do not include license files.

- Brian D. Baker