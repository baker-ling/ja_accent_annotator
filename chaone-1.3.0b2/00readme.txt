ChaOne in C
                                                              2007.02.11
                                                              Studio ARC
------------------------------------------------------------------------

C؀جćݱīĬĿChaOnećĹc

=============
1. ݠȷ
=============

ChaOne˜ĎʑԹŭŸŃůďĹęĆXSLTćݱīĬĆĤĞĹcĳĎĿġb
ChaOne in CĎųųőŤū՚ē܂ٔċďbGnomeŗŭŸŧůňćӫȯĵĬĿ
XSLT CũŤŖũŪćĢīlibxsltĬɬ͗ćĹc
ڇ֡ĎLinuxŇţŹňŪœť|ŷŧųċďbďĸġīĩԞĞĬĆĤīĳĈĬ
¿ĤĨĦćĹc
xsltlibĎǛɛصďbhttp://xmlsoft.org/XSLT/ćĹc

=============
2. Ī
=============

2.1 ʸۺų|ŉĎרĪ

ĞĺbŷŹņŠć͑ĤīŇŕũūňĎʸۺų|ŉĲרġĞĹc
ĳĬď܂ٔ۾ċʑٹ҄ǽćĹc

2.2 ŹſŤūŷ|ňĎެݪ

³ĤĆbŗŭŰũŠ܂ٔ۾ċۈ͑ĵĬīŕšŤūײĲÖįެݪĲרġĞĹc

=============
3. ųųőŤū
=============

3.1 configure

./configureĲ܂ٔķĞĹc
ŪŗŷŧųďЊҼĎĈĪĪćĹc
ۘĪķĊĤެ٧ď[ ]ƢĎŇŕũūňÍĬۈįĬĞĹc

  --with-xml
    libxml2ĎŤųŹň|ūެݪ [/usr, /usr/local]
  --with-xslt
    libxsltĎŤųŹň|ūެݪ [/usr, /usr/local]
  --with-kanjicode
    ʸۺų|ŉ [EUC-JP]
  --with-xsltfile-dir
    ŹſŤūŷ|ňĎެݪ [.]

ŹſŤūŷ|ňĎެݪď$őŹćۘĪķĆĢbjőŹćĢٽĤĞĻĳĬb
Ƣɴć$őŹċʑԹĵĬĞĹĎćbĿĈĨjőŹćۘĪķĆĢbإīĩ
ÖĭެݪĲʑĨīĳĈďćĭĞĻĳc

3.2 make

³ĤĆmakeĲ܂ٔķĞĹc

=============
4. ۈ͑ˡ
=============

4.1 ŘūŗĎɽܨ

  chaone {-h | --help}

4.2 Ő|ŸŧųĎɽܨ

  chaone {-v | --version}

4.3 ČޯĎۈ͑ˡ

  chaone [options] [file]

  ƾΏŕšŤūĲۘĪķĊıĬĐbɸݠƾΏīĩƉğپĠc
  ݐΏďޯċɸݠݐΏĬ͑ĤĩĬīc

  Ī҄ǽĊŪŗŷŧų

  {-e | --encoding}

    ƾݐΏĎʸۺų|ŉĲbISO-2022-JPbEUC-JPbShift_JISbUTF-8ĎĦāīĩۘĪĹīc

  {-s | --mode}

    prep: pݨͽŢ|ŉ
      pݨͽĎğĲٔĦc
    chunker:ŁţųūŢ|ŉ
      ŁţųūݨͽĎğĲٔĦc
    chaone:һѤزŢ|ŉ
      һѤزݨͽĎğĲٔĦc
    accent: ŢůŻųň׫٧Ţ|ŉ
      ŢůŻųň׫٧ĎğĲٔĦc

    Ţ|ŉĲۘĪķĊıĬĐbĹęĆĎݨͽĬٔįĬĞĹc

  {-d | --debug}

    stderrċæԖ׫ҌĲݐΏĹīc
    ݐΏʸۺų|ŉďUTF-8؇ĪćĹc

===============
5. ŕšŤūٽ.
===============

00readme.txt: ĳĎŕšŤū
Makefile.in: MakefileĎŹűūňų
configure: Makefile8.ŹůŪŗň
configure.in: configureĎŹűūňų

chaone.c: chaoneŗŭŰũŠŽ|ŹŕšŤū

chaone_t_EUC-JP.xsl: EUC-JPݐΏ͑ŭ|ŀ
chaone_t_ISO-2022-JP.xsl: ISO-2022-JPݐΏ͑ŭ|ŀ
chaone_t_Shift_JIS.xsl: Shift_JISݐΏ͑ŭ|ŀ
chaone_t_UTF-8.xsl: UTF-8ݐΏ͑ŭ|ŀ
chaone_t_main.xsl: XSLTšŤųŕšŤū
prep.xsl: pݨͽ͑XSLTŕšŤū
chunker.xsl: Łţųū͑XSLTŕšŤū
phonetic.xsl: һѤز͑XSLTŕšŤū
accent.xsl: ŢůŻųň׫٧͑XSLTŕšŤū

ea_symbol_table.xml: ёۺʑԹņ|Ŗū
grammar.xml: IPAdic-UniDicʸˡѾņ|Ŗū
pa_word.xml: һѤزޝجņ|Ŗū

chunk_rules.xml: Łţųū͑լ§
FPAfn.xml: FPAfnņ|Ŗū
IPAfn.xml: IPAfnņ|Ŗū

kannjiyomi.xml: ñԁۺȯһņ|Ŗū
ap_rule.xml: ŢůŻųň֧ٽ.լ§
accent_rule.xml: ŢůŻųň׫٧լ§



Њޥ
