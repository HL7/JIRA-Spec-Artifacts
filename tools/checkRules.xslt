<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:template match="/">
    <xsl:for-each select="specifications/specification[not(@deprecated='true')]">
      <xsl:if test="starts-with(@key, 'FHIR-') and @key != 'FHIR-core'">
        <xsl:for-each select="version[not(@deprecated='true' or @code='current')]">
          <xsl:variable name="prefix" select="if (contains(@code, '-')) then substring-before(@code, '-') else @code"/>
          <xsl:variable name="suffix" select="if (contains(@code, '-')) then substring-after(@code, '-') else ''"/>
          <xsl:if test="not(matches($prefix, '\d+\.\d+\.\d'))">
            <xsl:message terminate="yes" select="concat('Specification ', parent::specification/@key, ' contains non-deprecated version ', @code, ' that does not follow semantic versioning rules.  Verion must be in the style ''0.0.0'', optionally followed by ''-[suffix]'' where the suffix is a value such as ''ballot''.')"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
      <xsl:if test="starts-with(@key, 'FHIR-') and @url and not(contains(@url, 'hl7.org/implement/standards')) and not(contains(@url, 'hl7.org/permalink/')) and not(contains(@url, 'hl7.org/documentcenter'))">
        <xsl:for-each select="version[not(@deprecated='true') and not(@url)]">
            <xsl:message terminate="yes" select="concat('Specification ', parent::specification/@key, ' with url ', parent::specification/@url, ' contains non-deprecated version ', @code, ' that does not have a url.')"/>
        </xsl:for-each>
      </xsl:if>
      <xsl:if test="not(@url)">
        <xsl:choose>
          <xsl:when test="starts-with(@key, 'FHIR-') or starts-with(@key, 'CDA-')">
            <xsl:message terminate="yes" select="concat('Specification ', @key, ' does not have a URL defined.  URLs are required for CDA and FHIR projects.')"/>
          </xsl:when>
          <xsl:when test="exists(@ciBuildUrl)">
            <xsl:message terminate="yes" select="concat('Specification ', @key, ' has a ciBuild URL but does not have a URL defined.  If using the IG publisher, a URL must be specified.')"/>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      <xsl:for-each select="page">
        <xsl:if test="contains(@name, '\')">
            <xsl:message terminate="yes" select="concat('Specification ', ancestor::specification/@key, ' page ', @name, ' contains the character ''\'' which is not allowed.')"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
	</xsl:template>
</xsl:stylesheet>