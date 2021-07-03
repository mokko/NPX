<xsl:stylesheet version="2.0"
    xmlns="http://www.mpx.org/npx"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:npx="http://www.mpx.org/npx"
	xmlns:z="http://www.zetcom.com/ria/ws/module"

    exclude-result-prefixes="npx z">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

    <!-- 
	- Konserv. Auflagen in separate Datei
	- am 2.7 schlägt Cornelia vor, dass wir die Konservatorischen Auflagen leer lassen, wenn wir sie nicht liefern.
	-->

    <xsl:template match="/">
        <npx version="20210607">
			<!--include only smb-freigebene medien!-->
			<xsl:apply-templates select="/z:application/z:modules/z:module[@name='Object']/z:moduleItem" />
        </npx>
    </xsl:template>

	<!-- TOP-LEVEL ELEMENTS -->

	<xsl:template match="/z:application/z:modules/z:module[@name='Object']/z:moduleItem">
		<xsl:variable name="id" select="@id"/>
		<xsl:message>
			<xsl:value-of select="$id"/>
		</xsl:message>
		<sammlungsobjekt>
			<objId>
				<xsl:value-of select="@id"/>
			</objId>
			<!-- kerservatorische Auflagen -->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjConservationTermsGrp']"/>
		</sammlungsobjekt>
	</xsl:template>

	<!-- felder: 
		datum, 
		Status, 
		Leihfähigkeit, 
		Schädl. Belast., 
		Luftfeuchte, 
		Temperatur, 
		Handling, 
		Verpackung, 
		Transport, 
		Lagerung, 
		Sicherheit, 
		Präsentation, 
		MoRASO
		Bemerkungen
		-->
	<xsl:template match="z:repeatableGroup[@name = 'ObjConservationTermsGrp']">
		<freigabe>
			<xsl:for-each select="z:repeatableGroupItem">
				<xsl:text>[</xsl:text>
				<xsl:value-of select="z:vocabularyReference[@name = 'TypeVoc']/z:vocabularyReferenceItem/@name"/>
				<xsl:text>] </xsl:text>
				<xsl:value-of select="z:vocabularyReference[@name = 'ApprovalVoc']/z:vocabularyReferenceItem/@name"/>
                <xsl:if test="position()!=last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
			</xsl:for-each>
		</freigabe>
	</xsl:template>

</xsl:stylesheet>
