<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:param name="wg">fm</xsl:param>
	<xsl:template match="/specification">
    <xsl:variable name="artifacts" as="xs:string*">
      <xsl:for-each select="artifact[@workgroup=$wg]">
        <xsl:value-of select="concat('FHIR-core-', @key)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="pages" as="xs:string*">
      <xsl:for-each select="page[@workgroup=$wg]">
        <xsl:value-of select="concat('FHIR-core-', @key)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:text>project = FHIR AND issuetype in ("Change Request", Comment, Question, "Technical Correction") AND status = Submitted AND  Specification = "FHIR Core (FHIR) [FHIR-core]" AND "Work Group" IS EMPTY AND ("Related Artifact(s)" IN (</xsl:text>
    <xsl:value-of select="string-join($artifacts, ',')"/>
    <xsl:text>) OR "Related Page(s)" in (</xsl:text>
    <xsl:value-of select="string-join($pages, ',')"/>
    <xsl:text>))</xsl:text>
	</xsl:template>
</xsl:stylesheet>
