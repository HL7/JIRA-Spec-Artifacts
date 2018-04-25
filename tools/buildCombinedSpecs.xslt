<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
    <xsl:text>&#xa;</xsl:text>
    <xsl:comment>WARNING: This is a generated file.  It is derived from all other SPEC-* files.  DO NOT EDIT.</xsl:comment>
    <xsl:text>&#xa;</xsl:text>
    <specifications xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="schemas/specificationList.xsd">
      <xsl:apply-templates select="files/specifications/specification"/>
    </specifications>
	</xsl:template>
	<xsl:template match="specification/@key">
    <xsl:attribute name="key">
      <xsl:value-of select="concat(ancestor::specifications/@familyPrefix, .)"/>
    </xsl:attribute>
	</xsl:template>
	<xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
	</xsl:template>
</xsl:stylesheet>
