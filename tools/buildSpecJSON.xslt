<?xml version="1.0" encoding="UTF-8"?>
<!--
  - This transform is executed on the _families.xml file.  It then loads the SPECS-???.xml for each family and all of the specification files referenced in the
  - specs file to produce both the family-specific and the comprehensive ballot JSON files for use by Jira.  (JSON conversion is handled by the imported xmlToJson
  - transform.)
  -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="xsi">
	<xsl:include href="xmlToJson.xslt"/>
	<!-- We use the oldspecs file to check that keys aven't been renamed or removed -->
	<xsl:variable name="oldSpecs" select="document('../tools/temp/SPECS.xml', .)/specifications" as="element(specifications)"/>
	<!--
    - First, we go through all of the families and create a single XML file of all specifications for each
    -->
  <xsl:variable name="familySpecs" as="element(specifications)+">
    <xsl:for-each select="/families/family">
      <xsl:variable name="filename" select="concat('SPECS-', @key, '.xml')"/>
      <xsl:variable name="specs" select="document($filename, .)/specifications" as="element(specifications)?"/>
      <xsl:if test="not($specs)">
        <xsl:message terminate="yes" select="concat('Unable to find specifications for family ', @key, ' - looking for file ', $filename)"/>
      </xsl:if>
      <xsl:apply-templates mode="familySpecs" select="$specs">
        <xsl:with-param name="prefix" select="@key" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:variable>
	<xsl:variable name="ballotSpecs" as="element(specifications)">
    <specifications>
      <xsl:apply-templates mode="ballotSpecs" select="$familySpecs/specification"/>
    </specifications>
	</xsl:variable>
	<xsl:variable name="ballotSummary" as="element(specifications)">
    <xsl:apply-templates mode="ballotSummary" select="$ballotSpecs"/>
	</xsl:variable>
	<xsl:template mode="ballotSummary" match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates mode="ballotSummary" select="@*|node()"/>
    </xsl:copy>
	</xsl:template>
	<xsl:template mode="ballotSummary" match="specification">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="prefix" select="substring-before(@key, '-')"/>
    </xsl:copy>
	</xsl:template>
	<xsl:template mode="familySpecs" match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates mode="familySpecs" select="@*|node()"/>
    </xsl:copy>
	</xsl:template>
	<xsl:template mode="familySpecs" match="@xsi:*"/>
	<xsl:template mode="familySpecs" match="specification/@key">
    <xsl:param name="prefix" tunnel="yes"/>
    <xsl:attribute name="key" select="concat($prefix, '-', .)"/>
	</xsl:template>
	<xsl:template mode="familySpecs" match="@workgroup">
    <!-- This trims the file a little bit - no need to declare a workgroup if it's the same as the default -->
    <xsl:if test="not(ancestor::specification/@defaultWorkgroup=current())">
      <xsl:copy-of select="."/>
    </xsl:if>
	</xsl:template>
	<xsl:template mode="familySpecs" match="specifications">
    <xsl:param name="prefix" tunnel="yes"/>
    <xsl:copy>
      <xsl:attribute name="familyPrefix" select="$prefix"/>
      <xsl:apply-templates mode="familySpecs" select="@*|node()"/>
    </xsl:copy>
	</xsl:template>
	<xsl:template mode="familySpecs" match="specifications/specification">
    <xsl:param name="prefix" tunnel="yes"/>
    <xsl:for-each select="page/@url[.=ancestor::specification/page/otherpage/@url]">
      <xsl:message terminate="yes" select="concat('The same name is present in both page/@url and page/otherpage/@url: ', .)"/>
    </xsl:for-each>
    <xsl:copy>
      <xsl:apply-templates mode="familySpecs" select="@*"/>
      <xsl:variable name="filename" select="concat($prefix, '-', @key, '.xml')"/>
      <xsl:variable name="spec" select="document($filename, .)/specification" as="element(specification)?"/>
      <xsl:if test="not($spec)">
        <xsl:message terminate="yes" select="concat('Unable to find specification ', @name, ' - looking for file ', $filename)"/>
      </xsl:if>
      <xsl:for-each select="$spec">
        <xsl:apply-templates mode="familySpecs" select="@*|node()"/>
      </xsl:for-each>
    </xsl:copy>
	</xsl:template>
	<!--
    - The ballot specs provide an integrated version listing all specs from all families.  (Keys and names get the family added to keep them unique)
    -->
	<xsl:template mode="ballotSpecs" match="specification/@name">
    <xsl:attribute name="name" select="concat(., ' (', ancestor::specifications/@familyPrefix, ')')"/>
	</xsl:template>
	<xsl:template mode="ballotSpecs" match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates mode="ballotSpecs" select="@*|node()"/>
    </xsl:copy>
	</xsl:template>
  <!--
    - Main process
    -->
	<xsl:template match="/">
    <!-- Check to see if any keys have been removed or changed -->
    <xsl:for-each select="$oldSpecs/specification">
      <xsl:variable name="newSpec" select="$ballotSpecs/specification[@key=current()/@key]" as="element(specification)?"/>
      <xsl:if test="not($newSpec)">
        <xsl:message terminate="yes" select="concat('Specification with effective key ', @key, ' has been removed or changed.  Keys should never change - just change the name.  Keys should also not usually be removed.  Instead, set the ''deprecated'' flag to true.  Keys can only be removed if no JIRA tracker references that specification.  If this is the case and the key should really be removed, please coordinate with an administrator.')"/>
      </xsl:if>
      <xsl:for-each select="version">
        <xsl:variable name="newVersion" select="$newSpec/version[@code=current()/@code]" as="element(version)?"/>
        <xsl:if test="not($newVersion)">
          <xsl:message terminate="yes" select="concat('Version with code ', @code, ' in specification ', parent::specification/@key, ' has been removed or changed.  Versions should never change.  Keys should also not be removed.  Versions can only be removed if no JIRA tracker references that version.  If this is the case and the version should really be removed, please coordinate with an administrator.')"/>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="artifact">
        <xsl:variable name="newArtifact" select="$newSpec/artifact[@key=current()/@key]" as="element(artifact)?"/>
        <xsl:if test="not($newArtifact)">
          <xsl:message terminate="yes" select="concat('Artifact with key ', @key, ' in specification ', parent::specification/@key, ' has been removed or changed.  Keys should never change - just change the name.  Keys should also not usually be removed.  Instead, set the ''deprecated'' flag to true.  Keys can only be removed if no JIRA tracker references that artifact.  If this is the case and the key should really be removed, please coordinate with an administrator.')"/>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="page">
        <xsl:variable name="newPage" select="$newSpec/page[@key=current()/@key]" as="element(page)?"/>
        <xsl:if test="not($newPage)">
          <xsl:message terminate="yes" select="concat('Page with key ', @key, ' in specification ', parent::specification/@key, ' has been removed or changed.  Keys should never change - just change the name.  Keys should also not usually be removed.  Instead, set the ''deprecated'' flag to true.  Keys can only be removed if no JIRA tracker references that page.  If this is the case and the key should really be removed, please coordinate with an administrator.')"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
    <!-- Create a JSON file for each family -->
    <xsl:for-each select="$familySpecs">
      <xsl:result-document href="SPECS-{@familyPrefix}.json" method="text" encoding="UTF-8">
        <xsl:apply-templates select="."/>
      </xsl:result-document>
    </xsl:for-each>
    <!-- Capture the full ballot XML file for use in subsequent comparisons to check for key loss -->
    <xsl:result-document href="../json/SPECS.xml" method="xml" version="1.0" indent="yes" encoding="UTF-8" exclude-result-prefixes="xsi">
      <xsl:copy-of select="$ballotSpecs"/>
    </xsl:result-document>
    <xsl:result-document href="SPECS-summary.json" method="text" encoding="UTF-8">
      <xsl:apply-templates select="$ballotSummary"/>
    </xsl:result-document>
    <!-- Spit out the JSON file for the full ballot specs -->
    <xsl:apply-templates select="$ballotSpecs"/>
	</xsl:template>
</xsl:stylesheet>
