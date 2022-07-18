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

	<xsl:template match="/n:npx/n:sammlungsobjekt">
		<!-- Do i have to eliminate linked multimedia records as well? Probably!-->
		<xsl:choose>
		<xsl:when test="
			n:verwaltendeInstitution eq 'Ethnologisches Museum, Staatliche Museen zu Berlin' 
			or n:verwaltendeInstitution eq 'Museum für Asiatische Kunst, Staatliche Museen zu Berlin'
		">
            <xsl:copy>
              <xsl:apply-templates select='@* | node()'/>
            </xsl:copy>
		</xsl:when>
		<xsl:otherwise>
			<xsl:message>
				<xsl:text>ANDERE VERWALTENDE INSTITUTIONEN WERDEN AUSSORTIERT</xsl:text>
				<xsl:value-of select="n:identNr"/>
			</xsl:message>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>