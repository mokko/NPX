<xsl:stylesheet version="2.0"
	xmlns="http://www.mpx.org/npx"
	xmlns:n="http://www.mpx.org/npx"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="n">
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<!-- 
		input and output format is both npx 
		we join input *.xml files in target dir and join them together join.npx
		making sure that there are no duplicates (multiple records with same id)
	-->
	
	<xsl:template match="/">
		<xsl:variable name="collection" select="collection('.?select=*.npx.xml')"/>
		<npx>
			<xsl:for-each-group select="$collection/n:npx/n:sammlungsobjekt" group-by="n:objId">
				<xsl:sort select="n:objId"/>
				<xsl:copy-of select="current-group()[1]"/>
			</xsl:for-each-group>
			<xsl:for-each-group select="$collection/n:npx/n:multimediaobjekt" group-by="n:mulId">
				<xsl:sort select="n:mulId"/>
				<xsl:copy-of select="current-group()[1]"/>
			</xsl:for-each-group>
		</npx>
	</xsl:template>
</xsl:stylesheet>