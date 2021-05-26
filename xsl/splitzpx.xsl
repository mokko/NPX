<xsl:stylesheet version="2.0"
    xmlns="http://www.zetcom.com/ria/ws/module"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="z">
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />
	
	<!-- 
	
	splits big files into many small files, each containing one moduleItem
	naming convention.
	-->
	
	<xsl:template match="/">
		<xsl:for-each select="/z:application/z:modules/z:module/@name">
			<xsl:variable name="type" select="."/>
			<xsl:message terminate="no">
				<xsl:value-of select="$type"/>
			</xsl:message>
			<xsl:for-each-group select="/z:application/z:modules/z:module[@name=$type]/z:moduleItem" group-by="@id">
				<!--xsl:message terminate="no">
					<xsl:value-of select="@id"/>
				</xsl:message-->
				<xsl:apply-templates select="current-group()[1]"/>
			</xsl:for-each-group>			
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="/z:application/z:modules/z:module/z:moduleItem">
		<xsl:variable name="id" select="@id"/>
		<xsl:variable name="type" select="../@name"/>
		<!-- alternatively we could go with the first three letters lowercased -->
		<xsl:variable name="prefix">
			<xsl:choose>
				<xsl:when test="$type eq 'Object'">obj</xsl:when>
				<xsl:when test="$type eq 'Multimedia'">mul</xsl:when>
				<xsl:when test="$type eq 'Registrar'">reg</xsl:when>
				<xsl:when test="$type eq 'Exhibition'">exh</xsl:when>
				<xsl:when test="$type eq 'Person'">per</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="yes">
						<xsl:text>ERROR: Unknown module type: </xsl:text>
						<xsl:value-of select="$type"/>
					</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="out_fn" select="concat('parts2/', $prefix, $id, '.xml')"/>
		<xsl:message>
			<xsl:value-of select="$out_fn"/>
		</xsl:message>
		<xsl:result-document href="{$out_fn}">
			<application>
				<modules>
					<module>
						<xsl:attribute name="name">
							<xsl:value-of select="../@name"/>
						</xsl:attribute>
						<xsl:attribute name="totalSize">1</xsl:attribute>
						<xsl:copy-of select="."/>
					</module>
				</modules>
			</application>
		</xsl:result-document>
	</xsl:template>
</xsl:stylesheet>