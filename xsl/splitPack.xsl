<xsl:stylesheet version="2.0"
    xmlns="http://www.mpx.org/npx"
    xmlns:n="http://www.mpx.org/npx"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="n">	
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />
	
	<!-- 
	
	splits one big npx files according to rauteModul into three files
		eröffnet.npx: list of opened modules
		nichtEröffnet.npx: all remaining modules
		nichtZugeordnet.npx: no module
	-->
	
	<xsl:template match="/">
		<xsl:variable name="nzIds" select="n:npx/n:sammlungsobjekt[n:rauteModul = '']/n:objId"/>
		<xsl:variable name="eöIds" select="n:npx/n:sammlungsobjekt[					
			n:rauteModul eq '11' or
			n:rauteModul eq '12' or
			n:rauteModul eq '13' or
			n:rauteModul eq '14' or
			n:rauteModul eq '15' or
			n:rauteModul eq '16' or
			n:rauteModul eq '36' or
			n:rauteModul eq '37' or
			n:rauteModul eq '39' or
			n:rauteModul eq '42' or
			n:rauteModul eq '43' or
			n:rauteModul eq '44' or
			n:rauteModul eq '45' or
			n:rauteModul eq '60' or
			n:rauteModul eq '61' or
			n:rauteModul eq '62']/n:objId"/>
		<xsl:variable name="nEöIds" select="n:npx/n:sammlungsobjekt[not(n:objId = $eöIds or n:objId = $nzIds)]/n:objId"/>
		<xsl:message>
			<xsl:text>Sammlungsobjekte gesamt: </xsl:text>
			<xsl:value-of select="count(n:npx/n:sammlungsobjekt/n:objId)"/>
			<xsl:text>&#10;Sammlungsobjekte eröffnet: </xsl:text>
			<xsl:value-of select="count($eöIds)"/>
			<xsl:text>&#10;Sammlungsobjekte nicht eröffnet: </xsl:text>
			<xsl:value-of select="count($nEöIds)"/>
			<xsl:text>&#10;Sammlungsobjekte nicht zugeordnet: </xsl:text>
			<xsl:value-of select="count($nzIds)"/>
			<xsl:text>&#10;Summe Sammlungsobjekte der Pakate: </xsl:text>
			<xsl:value-of select="count($eöIds) + count($nEöIds) + count($nzIds)"/>
			<xsl:text>&#10;</xsl:text>
		</xsl:message>
			
		<xsl:result-document method="xml" href="4-nichtZugeordnet.npx.xml">
			<npx>
				<xsl:attribute name="anzahlSammlungsobjekte">
					<xsl:value-of select="count($nzIds)"/>
				</xsl:attribute>
				<xsl:copy-of select="n:npx/n:multimediaobjekt[n:verknüpftesObjekt = $nzIds]"/>
				<xsl:copy-of select="n:npx/n:sammlungsobjekt[n:objId = $nzIds]"/>
			</npx>
		</xsl:result-document>
		<xsl:result-document method="xml" href="4-eröffnet.npx.xml">
			<npx>
				<xsl:attribute name="anzahlSammlungsobjekte">
					<xsl:value-of select="count($eöIds)"/>
				</xsl:attribute>
				<xsl:copy-of select="n:npx/n:multimediaobjekt[n:verknüpftesObjekt = $eöIds]"/>
				<xsl:copy-of select="n:npx/n:sammlungsobjekt[n:objId = $eöIds]"/>
			</npx>
		</xsl:result-document>
		<xsl:result-document method="xml" href="4-nichtEröffnet.npx.xml">
			<npx>
				<xsl:attribute name="anzahlSammlungsobjekte">
					<xsl:value-of select="count($nEöIds)"/>
				</xsl:attribute>
				<xsl:copy-of select="n:npx/n:multimediaobjekt[n:verknüpftesObjekt = $nEöIds]"/>
				<xsl:copy-of select="n:npx/n:sammlungsobjekt[n:objId = $nEöIds]"/>
			</npx>
		</xsl:result-document>
	</xsl:template>
</xsl:stylesheet>