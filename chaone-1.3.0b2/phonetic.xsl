<!-- XSLT stylesheet for ChaOne              -->
<!--                     for msxml and exslt -->
<!--                            ver. 1.3.0b2 -->
<!--                        for UniDic 1.3.0 -->
<!-- ChaOne consists of the followings;      -->
<!--  (2) Phonetic Alternation               -->
<!--                2007-02-14 by Studio ARC -->
<!-- Copyright (c) 2004-2007 Studio ARC      -->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:msxml="urn:schemas-microsoft-com:xslt"
  xmlns:ext="http://exslt.org/common"
  exclude-result-prefixes="exsl msxml ext"
  version="1.0"
  xml:lang="ja">

  <xsl:output method="xml" encoding="Shift_JIS" omit-xml-declaration="yes" indent="yes"/>

  <xsl:variable name="IPA_table" select="document('IPAfn.xml')"/>
  <xsl:variable name="FPA_table" select="document('FPAfn.xml')"/>
  <xsl:key name="IPAfn" match="ifn" use="concat(@iType, @iForm, @iConType)"/>
  <xsl:key name="FPAfn" match="ffn" use="concat(@lForm, @lemma, @pron, @fType, @fForm, @fConType)"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="*">
    <xsl:choose>
      <xsl:when test="*">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="S">
    <xsl:copy>
      <xsl:apply-templates mode="chaone"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()" mode="chaone">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="chaone"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="W2[not(@pron)]" mode="chaone">
    <!-- pron属性を持たないW2に対する音韻交替処理 -->
    <!-- W2の子要素である各W1についての処理 -->
    <xsl:variable name="W1-list">
      <xsl:apply-templates select="W1" mode="alt"/>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="pron">
        <xsl:for-each select="ext:node-set($W1-list)/W1">
          <xsl:value-of select="@pron"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:copy-of select="$W1-list"/>
    </xsl:copy>
  </xsl:template>

  <!-- ChaOne inside W2 -->
  <xsl:template match="W1" mode="alt">
    <xsl:variable name="iForm_position">
      <xsl:if test="@iType">
        <xsl:call-template name="calc-iForm_position"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="fForm_position">
      <xsl:call-template name="calc-fForm_position"/>
    </xsl:variable>
    <xsl:variable name="position">
      <xsl:choose>
        <xsl:when test="$iForm_position > 0">
          <xsl:value-of select="$iForm_position"/>
        </xsl:when>
        <xsl:when test="$fForm_position > 0">
          <xsl:value-of select="$fForm_position"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- select 基本形 (here ???) -->

          <xsl:value-of select="1"/>

        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:call-template name="nth_attr">
          <xsl:with-param name="position" select="$position"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="nth_attr">
    <!-- current() = W1/@* -->
    <!-- return nth value (slash separated) of attribute -->
    <xsl:param name="position"/>
    <xsl:attribute name="{name()}">
      <xsl:choose>
        <xsl:when test="contains(., '/')">
          <xsl:call-template name="nth_val">
            <xsl:with-param name="position" select="$position"/>
            <xsl:with-param name="pre" select="substring-before(., '{')"/>
            <xsl:with-param name="post" select="substring-after(., '}')"/>
            <xsl:with-param name="body" select="substring-before(substring-after(., '{'), '}')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="nth_val">
    <!-- current() = W1/@* -->
    <!-- return nth value (slash separated) of attribute -->
    <!-- recursive -->
    <xsl:param name="position"/>
    <xsl:param name="pre"/>
    <xsl:param name="post"/>
    <xsl:param name="body"/>
    <xsl:choose>
      <xsl:when test="$position = 1">
        <xsl:choose>
          <xsl:when test="contains($body, '/')">
            <xsl:value-of select="concat($pre, substring-before($body, '/'), $post)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($pre, $body, $post)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="nth_val">
          <xsl:with-param name="position" select="$position - 1"/>
          <xsl:with-param name="pre" select="$pre"/>
          <xsl:with-param name="post" select="$post"/>
          <xsl:with-param name="body" select="substring-after($body, '/')"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calc-iForm_position">
    <!-- current() = W1 -->
    <!-- returns position (nth) of iForm or position of 基本形 -->
    <xsl:call-template name="calc-iForm_position_main">
      <xsl:with-param name="iType" select="@iType"/>
      <xsl:with-param name="iConType">
        <xsl:call-template name="get_first">
          <xsl:with-param name="list" select="preceding-sibling::W1[1]/@iConType"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="pre" select="substring-before(@iForm, '{')"/>
      <xsl:with-param name="post" select="substring-after(@iForm, '}')"/>
      <xsl:with-param name="iForms" select="substring-before(substring-after(@iForm, '{'), '}')"/>
      <xsl:with-param name="position" select="1"/>
      <xsl:with-param name="kihonkei" select="0"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="get_first">
    <!-- get non null first item -->
    <xsl:param name="list"/>
    <xsl:choose>
      <xsl:when test="contains($list, '{')">
        <xsl:call-template name="get_first_main">
          <xsl:with-param name="pre" select="substring-before($list, '{')"/>
          <xsl:with-param name="post" select="substring-after($list, '}')"/>
          <xsl:with-param name="list" select="substring-before(substring-after($list, '{'), '}')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$list"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get_first_main">
    <xsl:param name="pre"/>
    <xsl:param name="post"/>
    <xsl:param name="list"/>
    <xsl:choose>
      <xsl:when test="contains($list, '/')">
        <xsl:variable name="first" select="substring-before($list, '/')"/>
        <xsl:choose>
          <xsl:when test="string-length($first) = 0">
            <xsl:call-template name="get_first_main">
              <xsl:with-param name="pre" select="$pre"/>
              <xsl:with-param name="post" select="$post"/>
              <xsl:with-param name="list" select="substring-after($list, '/')"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($pre, $first, $post)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($pre, $list, $post)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calc-iForm_position_main">
    <!-- current() = W1 -->
    <!-- returns position (nth) of iForm whose ifn value = 1 -->
    <!-- recursive -->
    <xsl:param name="iType"/>
    <xsl:param name="iConType"/>
    <xsl:param name="pre"/>
    <xsl:param name="post"/>
    <xsl:param name="iForms"/>
    <xsl:param name="position"/>
    <xsl:param name="kihonkei"/>
    <xsl:variable name="iForm">
      <xsl:choose>
        <xsl:when test="contains($iForms, '/')">
          <xsl:value-of select="concat($pre, substring-before($iForms, '/'), $post)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($pre, $iForms, $post)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="iForm_val">
      <xsl:for-each select="$IPA_table">
        <xsl:value-of select="key('IPAfn', concat($iType, $iForm, $iConType))/@val"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$iForm_val = 1">
        <xsl:value-of select="$position"/>
      </xsl:when>
      <xsl:when test="contains($iForms, '/')">
        <xsl:call-template name="calc-iForm_position_main">
          <xsl:with-param name="iType" select="$iType"/>
          <xsl:with-param name="iConType" select="$iConType"/>
          <xsl:with-param name="pre" select="$pre"/>
          <xsl:with-param name="post" select="$post"/>
          <xsl:with-param name="iForms" select="substring-after($iForms, '/')"/>
          <xsl:with-param name="position" select="$position + 1"/>
          <xsl:with-param name="kihonkei">
            <xsl:choose>
              <xsl:when test="($iForm = '基本形') and ($kihonkei = 0)">
                <xsl:value-of select="$position"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$kihonkei"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$kihonkei"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calc-fForm_position">
    <!-- current() = W1 -->
    <!-- returns position (nth) of fForm -->
    <xsl:variable name="fConTypes" select="following-sibling::W1[1]/@fConType"/>
    <xsl:call-template name="calc-fForm_position_main">
      <!-- F(lForm, lemma, pron, fType, fForm, fConType) -->
      <xsl:with-param name="lForm" select="@lForm"/>
      <xsl:with-param name="lemma" select="@lemma"/>
      <xsl:with-param name="pron" select="@pron"/>
      <xsl:with-param name="fType" select="@fType"/>
      <xsl:with-param name="fForm" select="@fForm"/>
      <xsl:with-param name="fConType">
        <xsl:choose>
          <xsl:when test="contains($fConTypes, ',')">
            <xsl:value-of select="substring-before($fConTypes, ',')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$fConTypes"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="position" select="1"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="calc-fForm_position_main">
    <!-- current() = W1 -->
    <!-- returns position (nth) of fForm whose ffn value = 1.0 -->
    <!-- recursive -->
    <xsl:param name="lForm"/>
    <xsl:param name="lemma"/>
    <xsl:param name="pron"/>
    <xsl:param name="fType"/>
    <xsl:param name="fForm"/>
    <xsl:param name="fConType"/>
    <xsl:param name="position"/>
    <xsl:variable name="lForm_1">
      <xsl:call-template name="get_head">
        <xsl:with-param name="list" select="$lForm"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="lemma_1">
      <xsl:call-template name="get_head">
        <xsl:with-param name="list" select="$lemma"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="pron_1">
      <xsl:call-template name="get_head">
        <xsl:with-param name="list" select="$pron"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="fType_1">
      <xsl:call-template name="get_head">
        <xsl:with-param name="list" select="$fType"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="fForm_1">
      <xsl:call-template name="get_head">
        <xsl:with-param name="list" select="$fForm"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="ffn_val">
      <xsl:for-each select="$FPA_table">
        <xsl:value-of select="key('FPAfn', concat($lForm_1, $lemma_1, $pron_1, $fType_1, $fForm_1, $fConType))"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$ffn_val = 1.0">
        <xsl:value-of select="$position"/>
      </xsl:when>
      <xsl:when test="contains($pron, '/')">
        <xsl:call-template name="calc-fForm_position_main">
          <xsl:with-param name="lForm">
            <xsl:call-template name="get_rest">
              <xsl:with-param name="list" select="$lForm"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="lemma">
            <xsl:call-template name="get_rest">
              <xsl:with-param name="list" select="$lemma"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="pron">
            <xsl:call-template name="get_rest">
              <xsl:with-param name="list" select="$pron"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="fType">
            <xsl:call-template name="get_rest">
              <xsl:with-param name="list" select="$fType"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="fForm">
            <xsl:call-template name="get_rest">
              <xsl:with-param name="list" select="$fForm"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="fConType" select="$fConType"/>
          <xsl:with-param name="position" select="$position + 1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get_head">
    <!-- get first item -->
    <xsl:param name="list"/>
    <xsl:variable name="head">
      <xsl:choose>
        <xsl:when test="contains($list, '{')">
          <xsl:call-template name="get_head_main">
            <xsl:with-param name="pre" select="substring-before($list, '{')"/>
            <xsl:with-param name="post" select="substring-after($list, '}')"/>
            <xsl:with-param name="list" select="substring-before(substring-after($list, '{'), '}')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$list"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$head = ''">
        <xsl:value-of select="'null'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$head"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get_head_main">
    <xsl:param name="pre"/>
    <xsl:param name="post"/>
    <xsl:param name="list"/>
    <xsl:choose>
      <xsl:when test="contains($list, '/')">
        <xsl:value-of select="concat($pre, substring-before($list, '/'), $post)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($pre, $list, $post)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get_rest">
    <!-- get rest item -->
    <xsl:param name="list"/>
    <xsl:choose>
      <xsl:when test="contains($list, '{')">
        <xsl:call-template name="get_rest_main">
          <xsl:with-param name="pre" select="substring-before($list, '{')"/>
          <xsl:with-param name="post" select="substring-after($list, '}')"/>
          <xsl:with-param name="list" select="substring-before(substring-after($list, '{'), '}')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$list"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get_rest_main">
    <xsl:param name="pre"/>
    <xsl:param name="post"/>
    <xsl:param name="list"/>
    <xsl:choose>
      <xsl:when test="contains($list, '/')">
        <xsl:value-of select="concat($pre, '{', substring-after($list, '/'), '}', $post)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($pre, '{', $list, '}', $post)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
