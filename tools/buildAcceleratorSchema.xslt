<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
    <xsl:comment>WARNING: This is a generated file.  It must be kept in sync with _accelerators.xml</xsl:comment>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      <xs:simpleType name="Accelerator">
        <xs:restriction base="xs:NMTOKEN">
          <xsl:for-each select="accelerators/accelerator">
            <xs:enumeration value="{@key}"/>
          </xsl:for-each>
        </xs:restriction>
      </xs:simpleType>
    </xs:schema>
  </xsl:template>
</xsl:stylesheet>
