<?xml version="1.0" encoding="UTF-8"?>
<!--
  - This transform is executed on the _families.xml file.  It then loads the SPECS-???.xml for each family and all of the specification files referenced in the
  - specs file to produce both the family-specific and the comprehensive ballot JSON files for use by Jira.  (JSON conversion is handled by the imported xmlToJson
  - transform.)  It also performs validation against various general and some product-family-specific checks.
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
        <xsl:message terminate="yes" select="concat('ERROR: Unable to find specifications for family ', @key, ' - looking for file ', $filename)"/>
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
      <xsl:message terminate="yes" select="concat('ERROR: The same name is present in both page/@url and page/otherpage/@url: ', .)"/>
    </xsl:for-each>
    <xsl:copy>
      <xsl:apply-templates mode="familySpecs" select="@*"/>
      <xsl:variable name="filename" select="concat($prefix, '-', @key, '.xml')"/>
      <xsl:variable name="spec" select="document($filename, .)/specification" as="element(specification)?"/>
      <xsl:variable name="specKey" select="@key"/>
      <xsl:if test="not($spec)">
        <xsl:message terminate="yes" select="concat('ERROR: Unable to find specification ', @name, ' - looking for file ', $filename)"/>
      </xsl:if>
      <xsl:for-each select="$spec">
        <xsl:apply-templates mode="familySpecs" select="@*|node()">
          <xsl:with-param name="spec" tunnel="yes" select="$specKey"/>
        </xsl:apply-templates>
      </xsl:for-each>
    </xsl:copy>
	</xsl:template>
	<xsl:template mode="familySpecs" match="artifact|page">
    <xsl:param name="prefix" tunnel="yes"/>
    <xsl:param name="spec" tunnel="yes"/>
    <xsl:variable name="key" select="concat($prefix, '-', $spec, '-', @key)"/>
    <xsl:choose>
      <xsl:when test="@deprecated='true' or self::page"/>
      <xsl:when test="not(@id)">
        <xsl:message terminate="yes" select="concat('ERROR: id attribute is mandatory for artifacts that are not deprecated - ', $key)"/>
      </xsl:when>
      <xsl:when test="contains($prefix, 'FHIR') and not(matches(string(@id), '^([A-Z][a-z]+)+/[A-Za-z0-9\-\.]{1,64}$'))">
        <xsl:message terminate="yes" select="concat('ERROR: In FHIR artifact ', $key, ', id value of ', @id, ' does not follow the pattern ResourceName/id')"/>
      </xsl:when>
<!--
      <xsl:when test="contains($prefix, 'CDA') and not(matches(@id, '^[0-2](\.(0|[1-9][0-9]*))+$'))">
        <xsl:message terminate="yes" select="concat('ERROR: In CDA artifact ', $key, ', id value of ', @id, ' is not an OID', matches(@id, '^[0-2](\\.(0|[1-9][0-9]*))+$'))"/>
      </xsl:when>
-->
    </xsl:choose>    
    <xsl:copy>
      <xsl:apply-templates mode="familySpecs" select="@*"/>
      <xsl:attribute name="key" select="$key"/>
      <xsl:attribute name="spec" select="$spec"/>
      <xsl:apply-templates mode="familySpecs" select="node()"/>
    </xsl:copy>
	</xsl:template>
	<xsl:template mode="familySpecs" match="*[@deprecated='true']/@name">
    <xsl:attribute name="name" select="concat(., ' [deprecated]')"/>
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
    <!-- Check cross-specification validation rules -->
    <xsl:for-each select="$ballotSpecs/specification[not(@deprecated='true') and starts-with(@key, 'FHIR-')]">
      <xsl:choose>
        <xsl:when test="@defaultWorkgroup='uk' and not(starts-with(@gitUrl, 'https://github.com/NHSDigital/'))">
          <xsl:message terminate="yes" select="concat('ERROR: FHIR HL7 UK specifications that are not deprecated must have a gitUrl attribute that starts with ''https://github.com/NHSDigital/'' ', @key)"/>
        </xsl:when>
        <xsl:when test="@defaultWorkgroup='eu' and not(starts-with(@gitUrl, 'https://github.com/HL7-eu/'))">
          <xsl:message terminate="yes" select="concat('ERROR: FHIR HL7 EU specifications that are not deprecated must have a gitUrl attribute that starts with ''https://github.com/HL7-eu/'' ', @key)"/>
        </xsl:when>
        <xsl:when test="starts-with(@defaultWorkgroup,'au-') and not(starts-with(@gitUrl, 'https://github.com/hl7au/'))">
          <xsl:message terminate="yes" select="concat('ERROR: FHIR HL7 AU specifications that are not deprecated must have a gitUrl attribute that starts with ''https://github.com/hl7au/'' ', @key)"/>
        </xsl:when>
        <xsl:when test="not(@defaultWorkgroup='eu') and not(starts-with(@defaultWorkgroup,'au-')) and not(starts-with(@gitUrl, 'https://github.com/HL7/'))">
          <xsl:message terminate="yes" select="concat('ERROR: FHIR HL7 International specifications that are not deprecated must have a gitUrl attribute that starts with ''https://github.com/HL7/'' ', @key)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:for-each select="$ballotSpecs/specification[not(starts-with(@ciUrl, 'http://build.fhir.org')) and not(@deprecated='true') and starts-with(@key, 'FHIR-')]">
      <xsl:message select="concat('WARNING: FHIR specifications that are not deprecated SHOULD have a ciUrl attribute that starts with ''http://build.fhir.org'' ', @key, ' - actual was: ', @ciUrl)"/>
    </xsl:for-each>
    <xsl:for-each select="$ballotSpecs/specification[not(starts-with(@url, 'http://hl7.org/fhir')) and not(@deprecated='true') and starts-with(@key, 'FHIR-')]">
      <xsl:message select="concat('WARNING: FHIR specifications that are not deprecated SHOULD have a url attribute that starts with ''http://hl7.org/fhir'' ', @key, ' - actual was: ', @url)"/>
    </xsl:for-each>
    <xsl:for-each select="$ballotSpecs/specification[@ballotUrl]">
      <xsl:choose>
        <xsl:when test="@defaultWorkgroup='eu' and not(starts-with(@ballotUrl, 'http://hl7.eu/'))">
          <xsl:message terminate="yes" select="concat('ERROR: If present, ballotUrl must start with ''http://hl7.eu/'' ', @key, ' - actual was: ', @ballotUrl)"/>
        </xsl:when>
        <xsl:when test="starts-with(@defaultWorkgroup,'au-') and not(starts-with(@ballotUrl, 'http://hl7.org.au/'))">
          <xsl:message terminate="yes" select="concat('ERROR: If present, ballotUrl must start with ''http://hl7.org.au/'' ', @key, ' - actual was: ', @ballotUrl)"/>
        </xsl:when>
        <xsl:when test="not(@defaultWorkgroup='eu') and not(starts-with(@defaultWorkgroup,'au-')) and not(starts-with(@ballotUrl, 'http://hl7.org/') or starts-with(@ballotUrl, 'http://cds-hooks.hl7.org/'))">
          <xsl:message terminate="yes" select="concat('ERROR: If present, ballotUrl must start with ''http://hl7.org/'' ', @key, ' - actual was: ', @ballotUrl)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:for-each select="distinct-values($ballotSpecs/specification/@gitUrl)">
      <xsl:if test="count($ballotSpecs/specification[@gitUrl=current()])!=1">
        <xsl:variable name="dupSpecs" select="string-join($ballotSpecs/specification[@gitUrl=current()]/@key, ', ')"/>
        <xsl:message select="concat('WARNING: Multiple FHIR specifications with the same gitUrl of ''', ., ''': ', $dupSpecs)"/>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="$ballotSpecs/specification[@gitUrl[not(starts-with(., 'https://github.com/'))]]">
      <xsl:message select="concat('ERROR: GitUrl for specification ', @key, ' must start with ''https://github.com/'': ', @gitUrl)"/>
    </xsl:for-each>
    <xsl:for-each select="$ballotSpecs/specification[@gitUrl[not(starts-with(., 'https://github.com/HL7/'))]]">
      <xsl:message select="concat('WARNING: GitUrl for specification ', @key, ' SHOULD must start with ''https://github.com/HL7/'': ', @gitUrl)"/>
    </xsl:for-each>
    <xsl:for-each select="distinct-values($ballotSpecs/specification/@url)">
      <xsl:if test="count($ballotSpecs/specification[@url=current()])!=1">
        <xsl:variable name="dupSpecs" select="string-join($ballotSpecs/specification[@url=current()]/@key, ', ')"/>
        <xsl:message terminate="yes" select="concat('ERROR: Multiple FHIR specifications with the same url of ''', ., ''': ', $dupSpecs)"/>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="distinct-values($ballotSpecs/specification/@ciUrl)">
      <xsl:if test="count($ballotSpecs/specification[@ciUrl=current()])!=1">
        <xsl:variable name="dupSpecs" select="string-join($ballotSpecs/specification[@ciUrl=current()]/@key, ', ')"/>
        <xsl:message terminate="yes" select="concat('ERROR: Multiple FHIR specifications with the same ciUrl of ''', ., ''': ', $dupSpecs)"/>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="distinct-values($ballotSpecs/specification/@ballotUrl)">
      <xsl:if test="count($ballotSpecs/specification[@ballotUrl=current()])!=1">
        <xsl:variable name="dupSpecs" select="string-join($ballotSpecs/specification[@ballotUrl=current()]/@key, ', ')"/>
        <xsl:message terminate="yes" select="concat('ERROR: Multiple FHIR specifications with the same ballotUrl of ''', ., ''': ', $dupSpecs)"/>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="distinct-values($ballotSpecs/specification/@ballotUrl)">
      <xsl:if test="count($ballotSpecs/specification[@ballotUrl=current()])!=1">
        <xsl:variable name="dupSpecs" select="string-join($ballotSpecs/specification[@ballotUrl=current()]/@key, ', ')"/>
        <xsl:message terminate="yes" select="concat('ERROR: Multiple FHIR specifications with the same ballotUrl of ''', ., ''': ', $dupSpecs)"/>
      </xsl:if>
    </xsl:for-each>
    <!-- Check to see if any keys have been removed or changed -->
    <xsl:for-each select="$oldSpecs/specification">
      <xsl:variable name="newSpec" select="$ballotSpecs/specification[@key=current()/@key]" as="element(specification)?"/>
      <xsl:if test="not($newSpec)">
        <xsl:message terminate="yes" select="concat('ERROR: Specification with effective key ', @key, ' has been removed or changed.  Keys should never change - just change the name.  Keys should also not usually be removed.  Instead, set the ''deprecated'' flag to true.  Keys can only be removed if no JIRA tracker references that specification.  If this is the case and the key should really be removed, please coordinate with an administrator.')"/>
      </xsl:if>
      <xsl:for-each select="version">
        <xsl:variable name="newVersion" select="$newSpec/version[@code=current()/@code]" as="element(version)?"/>
        <xsl:if test="not($newVersion)">
          <xsl:message terminate="yes" select="concat('ERROR: Version with code ', @code, ' in specification ', parent::specification/@key, ' has been removed or changed.  Versions should never change.  Keys should also not be removed.  Versions can only be removed if no JIRA tracker references that version.  If this is the case and the version should really be removed, please coordinate with an administrator.')"/>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="artifact">
        <xsl:variable name="newArtifact" select="$newSpec/artifact[@key=current()/@key]" as="element(artifact)?"/>
        <xsl:if test="not($newArtifact)">
          <xsl:message terminate="yes" select="concat('ERROR: Artifact with key ', @key, ' in specification ', parent::specification/@key, ' has been removed or changed.  Keys should never change - just change the name.  Keys should also not usually be removed.  Instead, set the ''deprecated'' flag to true.  Keys can only be removed if no JIRA tracker references that artifact.  If this is the case and the key should really be removed, please coordinate with an administrator.')"/>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="page">
        <xsl:variable name="newPage" select="$newSpec/page[@key=current()/@key]" as="element(page)?"/>
        <xsl:if test="not($newPage)">
          <xsl:message terminate="yes" select="concat('ERROR: Page with key ', @key, ' in specification ', parent::specification/@key, ' has been removed or changed.  Keys should never change - just change the name.  Keys should also not usually be removed.  Instead, set the ''deprecated'' flag to true.  Keys can only be removed if no JIRA tracker references that page.  If this is the case and the key should really be removed, please coordinate with an administrator.')"/>
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
    <xsl:result-document href="versions.json" method="text" encoding="UTF-8">
      <xsl:text>[</xsl:text>
      <xsl:for-each select="distinct-values($ballotSpecs/specification/version/@code)">
        <xsl:sort select="."/>
        <xsl:if test="position()!=1">,</xsl:if>
        <xsl:value-of select="concat('{&quot;key&quot;:&quot;', ., '&quot;,&quot;name&quot;:&quot;', ., '&quot;}')"/>
      </xsl:for-each>
      <xsl:text>]</xsl:text>
    </xsl:result-document>
    <!-- Spit out the JSON file for the full ballot specs -->
    <xsl:apply-templates select="$ballotSpecs"/>
	</xsl:template>
</xsl:stylesheet>
