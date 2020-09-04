import fugashi
from lxml import etree
from typing import List
import csv
import collections

UnidicFeaturesUnk = collections.namedtuple('UnidicFeaturesUnk', ['pos1', 'pos2', 'pos3', 'pos4', 'cType', 'cForm'])

def annotate_accent (japanese_text: str) -> str:
    #run morphological analysis on input string
    tagger = fugashi.Tagger()
    words = tagger(japanese_text)
    
    #convert list of tagged tokens to xml tree
    xml_tree = tagger_output_to_xml(words)
    
    #run phonological processes on morphemes in xml_tree
    ChaOne = etree.XSLT(etree.parse('./chaone-1.3.0b2/chaone_t_main.xsl'))
    transformed_tree = ChaOne(xml_tree)
    
    #use tranformed xml tree to construct an annotated string
    annotated_string = transformed_tree_to_annotated_kana(transformed_tree)
    return annotated_string

def annotate_accent_nbest(japanese_text: str, num: int = 3) -> List[str]:
    assert(isinstance(japanese_text, str))
    
    #run morphological analysis on input string
    tagger = fugashi.Tagger()
    parsings_as_raw_output_strings = tagger.nbest(japanese_text, num).strip().split('EOS')
    annotated_strings = []
    
    for parsing in parsings_as_raw_output_strings:
        if parsing != '':
            #convert list of tagged tokens to xml tree
            xml_tree = raw_tagger_output_to_xml(parsing)
    
            #run phonological processes on morphemes in xml_tree
            ChaOne = etree.XSLT(etree.parse('./chaone-1.3.0b2/chaone_t_main.xsl'))
            transformed_tree = ChaOne(xml_tree)
    
            #use tranformed xml tree to construct an annotated string
            annotated_strings.append(transformed_tree_to_annotated_kana(transformed_tree))

    return annotated_strings

def raw_tagger_output_to_xml(parsing):
    xml_tree = etree.Element('S')
    words = parsing.strip().splitlines()
    for word in words:
        surface, features = word.split('\t')
        feature_list = next(csv.reader([features]))
        if len(feature_list) > 6:
            is_unk = False
            feature_tuple = fugashi.UnidicFeatures29(*feature_list)
        else:
            is_unk = True
            feature_tuple = UnidicFeaturesUnk(*feature_list)
        
        # ChaSen output format required by ChaOne:
        # (OUTPUT_FORMAT "<cha:W1 orth="%m" pron="%?U/%m/%a0/" pos="%U(%P-)"%?T/ cType="%T "//%?F/ cForm="%F "//%?I/ %i0//>%m\n")

        
        # (OUTPUT_FORMAT "<cha:W1 
        word_element = etree.Element('W1')
        # orth=\"%m\" 
        word_element.set('orth', str(surface))
        # pron=\"%?U/%m/%a0/\" pos=\"%U(%P-)\"
        if is_unk:
            word_element.set('pron', str(surface))
            word_element.set('pos', '未知語')
        else:
            word_element.set('pron', feature_tuple.pron)
            pos = feature_tuple.pos1
            if feature_tuple.pos2 != '*':
                pos += '-' + feature_tuple.pos2
                if feature_tuple.pos3 != '*':
                    pos += '-' + feature_tuple.pos3
                    if feature_tuple.pos4 != '*':
                        pos += '-' + feature_tuple.pos4
            word_element.set('pos', pos)
        #%?T/ cType=\"%T \"//%?F/ cForm=\"%F \"//
        if feature_tuple.cType is not None and feature_tuple.cType != '*':
            word_element.set('cType', feature_tuple.cType)
            word_element.set('cForm', feature_tuple.cForm)

        #%?I/ %i0 ///>\n")
        if feature_tuple.orthBase is not None and feature_tuple.orthBase != '*':
            word_element.set('orthBase', feature_tuple.orthBase)
        if feature_tuple.pronBase is not None and feature_tuple.pronBase != '*':
            word_element.set('pronBase', feature_tuple.pronBase)

        if feature_tuple.lForm is not None and feature_tuple.lForm != '*':
            word_element.set('lForm', feature_tuple.lForm)
        if feature_tuple.lemma is not None and feature_tuple.lemma != '*':
            word_element.set('lForm', feature_tuple.lemma)
        if feature_tuple.goshu is not None and feature_tuple.goshu != '*':
            word_element.set('goshu', feature_tuple.goshu)
        if feature_tuple.iType is not None and feature_tuple.iType != '*':
            word_element.set('iType', feature_tuple.iType)
        if feature_tuple.iForm is not None and feature_tuple.iForm != '*':
            word_element.set('iForm', feature_tuple.iForm)
        if feature_tuple.fType is not None and feature_tuple.fType != '*':
            word_element.set('fType', feature_tuple.fType)
        if feature_tuple.fForm is not None and feature_tuple.fForm != '*':
            word_element.set('fForm', feature_tuple.fForm)
        if feature_tuple.iConType is not None and feature_tuple.iConType != '*':
            word_element.set('iConType', feature_tuple.iConType)
        if feature_tuple.fConType is not None and feature_tuple.fConType != '*':
            word_element.set('fConType', feature_tuple.fConType)
        if feature_tuple.type is not None and feature_tuple.type != '*':
            word_element.set('type', feature_tuple.type)

        if feature_tuple.kana is not None and feature_tuple.kana != '*':
            word_element.set('kana', feature_tuple.kana)
        if feature_tuple.kanaBase is not None and feature_tuple.kanaBase != '*':
            word_element.set('kanaBase', feature_tuple.kanaBase)

        if feature_tuple.form is not None and feature_tuple.form != '*':
            word_element.set('form', feature_tuple.form)
        if feature_tuple.formBase is not None and feature_tuple.formBase != '*':
            word_element.set('formBase', feature_tuple.formBase)

        if feature_tuple.aType is not None and feature_tuple.aType != '*':
            word_element.set('aType', feature_tuple.aType)
        if feature_tuple.aConType is not None and feature_tuple.aConType != '*':
            word_element.set('aConType', feature_tuple.aConType)
        if feature_tuple.aModType is not None and feature_tuple.aModType != '*':
            word_element.set('aModType', feature_tuple.aModType)

        if feature_tuple.lid is not None and feature_tuple.lid != '*':
            word_element.set('lid', feature_tuple.lid)
        if feature_tuple.lemma_id is not None and feature_tuple.lemma_id != '*':
            word_element.set('lemma_id', feature_tuple.lemma_id)

        xml_tree.append(word_element)
    return xml_tree

def tagger_output_to_xml(words):
    xml_tree = etree.Element('S')
    for word in words:
        # (OUTPUT_FORMAT "<cha:W1 
        word_element = etree.Element('W1')
        # orth=\"%m\" 
        word_element.set('orth', str(word))
        # pron=\"%?U/%m/%a0/\" pos=\"%U(%P-)\"
        if word.is_unk:
            word_element.set('pron', str(word))
            word_element.set('pos', '未知語')
        else:
            word_element.set('pron', word.feature.pron)
            pos = word.feature.pos1
            if word.feature.pos2 != '*':
                pos += '-' + word.feature.pos2
                if word.feature.pos3 != '*':
                    pos += '-' + word.feature.pos3
                    if word.feature.pos4 != '*':
                        pos += '-' + word.feature.pos4
            word_element.set('pos', pos)
        #%?T/ cType=\"%T \"//%?F/ cForm=\"%F \"//
        if word.feature.cType is not None and word.feature.cType != '*':
            word_element.set('cType', word.feature.cType)
            word_element.set('cForm', word.feature.cForm)

        #%?I/ %i0 ///>\n")
        if word.feature.orthBase is not None and word.feature.orthBase != '*':
            word_element.set('orthBase', word.feature.orthBase)
        if word.feature.pronBase is not None and word.feature.pronBase != '*':
            word_element.set('pronBase', word.feature.pronBase)

        if word.feature.lForm is not None and word.feature.lForm != '*':
            word_element.set('lForm', word.feature.lForm)
        if word.feature.lemma is not None and word.feature.lemma != '*':
            word_element.set('lForm', word.feature.lemma)
        if word.feature.goshu is not None and word.feature.goshu != '*':
            word_element.set('goshu', word.feature.goshu)
        if word.feature.iType is not None and word.feature.iType != '*':
            word_element.set('iType', word.feature.iType)
        if word.feature.iForm is not None and word.feature.iForm != '*':
            word_element.set('iForm', word.feature.iForm)
        if word.feature.fType is not None and word.feature.fType != '*':
            word_element.set('fType', word.feature.fType)
        if word.feature.fForm is not None and word.feature.fForm != '*':
            word_element.set('fForm', word.feature.fForm)
        if word.feature.iConType is not None and word.feature.iConType != '*':
            word_element.set('iConType', word.feature.iConType)
        if word.feature.fConType is not None and word.feature.fConType != '*':
            word_element.set('fConType', word.feature.fConType)
        if word.feature.type is not None and word.feature.type != '*':
            word_element.set('type', word.feature.type)

        if word.feature.kana is not None and word.feature.kana != '*':
            word_element.set('kana', word.feature.kana)
        if word.feature.kanaBase is not None and word.feature.kanaBase != '*':
            word_element.set('kanaBase', word.feature.kanaBase)

        if word.feature.form is not None and word.feature.form != '*':
            word_element.set('form', word.feature.form)
        if word.feature.formBase is not None and word.feature.formBase != '*':
            word_element.set('formBase', word.feature.formBase)

        if word.feature.aType is not None and word.feature.aType != '*':
            word_element.set('aType', word.feature.aType)
        if word.feature.aConType is not None and word.feature.aConType != '*':
            word_element.set('aConType', word.feature.aConType)
        if word.feature.aModType is not None and word.feature.aModType != '*':
            word_element.set('aModType', word.feature.aModType)

        if word.feature.lid is not None and word.feature.lid != '*':
            word_element.set('lid', word.feature.lid)
        if word.feature.lemma_id is not None and word.feature.lemma_id != '*':
            word_element.set('lemma_id', word.feature.lemma_id)

        xml_tree.append(word_element)
    return xml_tree

def split_mora(kana: str) -> List[str]:
    mora_list = []
    vowel_deleters = {'ャ', 'ュ', 'ョ', 'ァ', 'ィ', 'ゥ', 'ェ', 'ォ'}
    for i in range(0, len(kana_string)):
        if i > 0 and kana_string[i] in vowel_deleters and mora_list[-1][-1] != kana_string[i]:
            mora_list[-1] = mora_list[-1] + kana_string[i]
        else:
            mora_list.append(kana_string[i])
    return mora_list
    
def transformed_tree_to_annotated_kana(tree):
    annotated_string = ''
    current_pitch_level = 'L'
    for ap in tree.getroot():
        if ap.get('pron') == '*':
            annotated_string += ap.get('orth') + ' '
        else:
            accented_mora = int(ap.get('aType'))
            mora_from_ap_start = 0
            if accented_mora == 1 and current_pitch_level == 'L':
                annotated_string += '↗'
                current_pitch_level = 'H'
            for w2 in ap:
                word_pron = w2.get('pron')
                if accented_mora == 0:
                    if current_pitch_level == 'H' or w2.get('pos')[0:3] == '助動詞':
                        annotated_string += word_pron + ' ' 
                    else:
                        mora_list = split_mora(word_pron)
                        annotated_string += mora_list[0] + '↗' + ''.join(mora_list[1:])
                        current_pitch_level = 'H'
                else:
                    mora_list = split_mora(word_pron)
                    for mora in mora_list:
                        annotated_string += mora
                        mora_from_ap_start += 1
                        if mora_from_ap_start == 1 and current_pitch_level == 'L':
                            annotated_string += '↗'
                            current_pitch_level = 'H'
                        if mora_from_ap_start == accented_mora:
                            annotated_string += '↘'
                            current_pitch_level = 'L'
                    annotated_string += ' '
    return annotated_string.strip()


text1 = """僕が最初に読んだ日本語長編小説は吉本ばななの「キッチン」だ。
短編小説は村上春樹の作品を決行読んでいるけど、"""
text2 = """日本語の小説はあまり読んでいない。
日英翻訳者としてこのままでいいのかな…"""
print(annotate_accent(text1))
print(annotate_accent(text2))
print(annotate_accent_nbest('日本語'))