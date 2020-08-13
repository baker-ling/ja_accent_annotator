<!-- XSLT stylesheet for ChaOne              -->
<!--                     for msxml and exslt -->
<!--                            ver. 1.3.0b2 -->
<!--  (4) postprocessing                     -->
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

  <xsl:variable name="pos_sys" select="document('pos_sys.xml')"/>
  <xsl:key name="r_pos" match="pos" use="@name"/>
  <xsl:key name="r_cType" match="ctype" use="@name"/>
  <xsl:key name="r_cForm" match="cform" use="@name"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="*">
    <xsl:element name="{name()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>

  </xsl:template>

  <xsl:template match="S">
    <xsl:element name="S">
      <xsl:apply-templates mode="postp"/>
    </xsl:element>

  </xsl:template>

  <xsl:template match="*" mode="postp">
    <xsl:element name="{name()}">
      <xsl:for-each select="@*">
        <xsl:call-template name="reduce_psys_val"/>
      </xsl:for-each>
      <xsl:apply-templates mode="postp"/>
    </xsl:element>

  </xsl:template>

  <xsl:template match="W1" mode="postp">
    <xsl:element name="{name()}">
      <xsl:for-each select="@*">
        <xsl:call-template name="reduce_psys_val"/>
      </xsl:for-each>
    </xsl:element>

  </xsl:template>

  <xsl:template name="reduce_psys_val">
    <!-- current() = */@* -->
    <!-- return reduced value of the attribute -->
    <xsl:attribute name="{name()}">
      <xsl:choose>
        <xsl:when test="(name() = 'pos') or (name() = 'cType') or (name() = 'cForm')">
          <xsl:call-template name="calc_psys_val">
            <xsl:with-param name="pre" select="''"/>
            <xsl:with-param name="org" select="."/>
            <xsl:with-param name="mode" select="concat('r_', name())"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="calc_psys_val">
    <xsl:param name="pre"/>
    <xsl:param name="org"/>
    <xsl:param name="mode"/>
    <xsl:variable name="head">
      <xsl:value-of select="$pre"/>
      <xsl:call-template name="ext_head">
        <xsl:with-param name="str" select="$org"/>
        <xsl:with-param name="delim" select="'-'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="$pos_sys">
      <xsl:choose>
        <xsl:when test="key($mode, $head)/child::*">
          <xsl:call-template name="calc_psys_val">
            <xsl:with-param name="pre" select="concat($head, '-')"/>
            <xsl:with-param name="org" select="substring-after($org, '-')"/>
            <xsl:with-param name="mode" select="$mode"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="key($mode, $head)">
          <xsl:value-of select="concat($head, key($mode, $head)/@add)"/>
        </xsl:when>
        <xsl:when test="string-length($pre)">
          <xsl:value-of select="concat($pre, '一般')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'unk'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="ext_head">
    <xsl:param name="str"/>
    <xsl:param name="delim"/>
    <xsl:choose>
      <xsl:when test="contains($str, $delim)">
        <xsl:value-of select="substring-before($str, $delim)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$str"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
