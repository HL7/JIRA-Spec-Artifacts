<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="xsi">
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:template match="workgroups">
    <xsl:call-template name="doArray">
      <xsl:with-param name="name" select="'workgroup'"/>
    </xsl:call-template>
	</xsl:template>
	<xsl:template match="accelerators">
    <xsl:call-template name="doArray">
      <xsl:with-param name="name" select="'accelerator'"/>
    </xsl:call-template>
	</xsl:template>
	<xsl:template match="families">
    <xsl:call-template name="doArray">
      <xsl:with-param name="name" select="'family'"/>
    </xsl:call-template>
	</xsl:template>
	<xsl:template match="specifications">
    <xsl:call-template name="doArray">
      <xsl:with-param name="name" select="'specification'"/>
    </xsl:call-template>
	</xsl:template>
	<xsl:template match="specification">
    <xsl:text>{</xsl:text>
    <xsl:call-template name="doAttributes"/>
    <xsl:if test="artifactPageExtension">
      <xsl:text>,</xsl:text>
      <xsl:call-template name="doNamedArray">
        <xsl:with-param name="name" select="'artifactPageExtension'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="version">
      <xsl:text>,</xsl:text>
      <xsl:call-template name="doNamedArray">
        <xsl:with-param name="name" select="'version'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="page">
      <xsl:text>,</xsl:text>
      <xsl:call-template name="doNamedArray">
        <xsl:with-param name="name" select="'page'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="artifact">
      <xsl:text>,</xsl:text>
      <xsl:call-template name="doNamedArray">
        <xsl:with-param name="name" select="'artifact'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:text>}</xsl:text>
	</xsl:template>
	<xsl:template match="version">
<!--    <xsl:value-of select="concat('{&quot;name&quot;:&quot;', @code, '&quot;,&quot;key&quot;:&quot;', @code, '&quot;,&quot;foo&quot;:[{&quot;bar&quot;:&quot;n/a&quot;}]}')"/>-->
    <xsl:value-of select="concat('{&quot;key&quot;:&quot;', @code, '&quot;,&quot;name&quot;:&quot;', @code)"/>
    <xsl:if test="@deprecated='true'"> [deprecated]</xsl:if>
    <xsl:text>","foo":[{"bar":"n/a"}]}</xsl:text>
    <xsl:if test="position()!=last()">,</xsl:if>
	</xsl:template>
	<xsl:template match="artifact">
    <xsl:text>{</xsl:text>
    <xsl:call-template name="doAttributes"/>
    <xsl:if test="otherpage">
      <xsl:text>,</xsl:text>
      <xsl:call-template name="doNamedArray">
        <xsl:with-param name="name" select="'otherpage'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:text>}</xsl:text>	
	</xsl:template>
	<xsl:template match="page">
    <xsl:text>{</xsl:text>
    <xsl:call-template name="doAttributes"/>
    <xsl:if test="otherpage">
      <xsl:text>,</xsl:text>
      <xsl:call-template name="doNamedArray">
        <xsl:with-param name="name" select="'otherpage'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:text>}</xsl:text>	
	</xsl:template>
	<xsl:template match="artifactPageExtension">
    <xsl:value-of select="concat('&quot;', @value, '&quot;')"/>
	</xsl:template>
	<xsl:template match="*">
    <xsl:text>{</xsl:text>
    <xsl:call-template name="doAttributes"/>
    <xsl:text>}</xsl:text>	
	</xsl:template>
	<xsl:template name="doAttributes">
    <xsl:for-each select="@*[not(contains(name(.), ':'))]">
      <xsl:choose>
        <xsl:when test="local-name(.)=('deprecated')">
          <xsl:value-of select="concat('&quot;', local-name(.), '&quot;:')"/>
          <xsl:call-template name="escapeText">
            <xsl:with-param name="text" select="."/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('&quot;', local-name(.), '&quot;:&quot;')"/>
          <xsl:call-template name="escapeText">
            <xsl:with-param name="text" select="."/>
          </xsl:call-template>
          <xsl:text>"</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="position()!=last()">,</xsl:if>
    </xsl:for-each>
	</xsl:template>
  <xsl:template name="escapeText">
    <xsl:param name="text"/>
    <xsl:choose>
      <xsl:when test="contains($text, '&quot;')">
        <xsl:value-of select="substring-before($text, '&quot;')"/>
        <xsl:text>\"</xsl:text>
        <xsl:call-template name="escapeText">
          <xsl:with-param name="text" select="substring-after($text, '&quot;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="doNamedArray">
    <xsl:param name="name"/>
    <xsl:value-of select="concat('&quot;', $name, '&quot;:')"/>
    <xsl:call-template name="doArray">
      <xsl:with-param name="name" select="$name"/>
    </xsl:call-template>
  </xsl:template>
	<xsl:template name="doArray">
    <xsl:param name="name"/>
    <xsl:text>[</xsl:text>
    <xsl:for-each select="*[local-name(.)=$name]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()">,</xsl:if>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
	</xsl:template>
</xsl:stylesheet>
