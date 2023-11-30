<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:template match="/">
    <xsl:value-of select="concat('CDA-', count(specifications/specification[starts-with(@key, 'CDA-')]), '&#x0a;')"/>
    <xsl:value-of select="concat('FHIR-', count(specifications/specification[starts-with(@key, 'FHIR-')]), '&#x0a;')"/>
    <xsl:value-of select="concat('OTHER-', count(specifications/specification[starts-with(@key, 'OTHER-')]), '&#x0a;')"/>
    <xsl:value-of select="concat('V2-', count(specifications/specification[starts-with(@key, 'V2-')]), '&#x0a;')"/>
	</xsl:template>
</xsl:stylesheet>