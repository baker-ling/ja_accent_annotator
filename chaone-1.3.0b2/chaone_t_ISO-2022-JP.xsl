<!-- XSLT stylesheet for ChaOne                 -->
<!--   stylesheet loader for ISO-2022-JP output -->
<!--                        for msxml and exslt -->
<!--                               ver. 1.3.0b1 -->
<!--                   2007-02-11 by Studio ARC -->
<!-- Copyright (c) 2004-2007 Studio ARC         -->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
  xml:lang="ja">

  <xsl:import href="chaone_t_main.xsl"/>
  <xsl:variable name="encoding" select="'ISO-2022-JP'"/>
  <xsl:output method="xml" encoding="ISO-2022-JP" omit-xml-declaration="yes" indent="yes"/>

</xsl:stylesheet>
