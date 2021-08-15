<xsl:stylesheet version="2.0"
    xmlns="http://www.mpx.org/npx"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:n="http://www.mpx.org/npx"
	xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="n">
	
	<!-- FIX 
		This transformation is supposed to correct mistakes in the data
		Input and output: npx
	-->
	<xsl:template match='@* | node()'>
            <xsl:copy>
              <xsl:apply-templates select='@* | node()'/>
            </xsl:copy>
	</xsl:template>	

	<!--
		Transport-DS aussortieren: III C 45608 (93)
	-->
	<xsl:template match="/n:npx/n:sammlungsobjekt[starts-with(n:identNr, 'III C 45608 (')]">
		<xsl:message>
			<xsl:text>Transport-DS für Township Wall aussortieren: </xsl:text>
			<xsl:value-of select="n:identNr"/>
		</xsl:message>
	</xsl:template>
</xsl:stylesheet>