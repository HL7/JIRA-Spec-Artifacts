<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:template match="/">
    <xsl:for-each select="specifications/specification[not(@deprecated='true')]">
      <xsl:if test="starts-with(@key, 'FHIR-')">
        <xsl:for-each select="version[not(@deprecated='true' or @code='current')]">
          <xsl:variable name="prefix" select="if (contains(@code, '-')) then substring-before(@code, '-') else @code"/>
          <xsl:variable name="suffix" select="if (contains(@code, '-')) then substring-after(@code, '-') else ''"/>
          <xsl:if test="not(matches($prefix, '\d+\.\d+\.\d'))">
            <xsl:message select="concat('Specification ', parent::specification/@key, ' contains non-deprecated version ', @code, ' that does not follow semantic versioning rules.  Verion must be in the style ''0.0.0'', optionally followed by ''-[suffix]'' where the suffix is a value such as ''ballot''.')"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
	</xsl:template>
</xsl:stylesheet>