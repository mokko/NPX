<xsl:stylesheet version="2.0"
    xmlns="http://www.mpx.org/npx"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:npx="http://www.mpx.org/npx"
	xmlns:z="http://www.zetcom.com/ria/ws/module"

    exclude-result-prefixes="npx z">
	
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<!-- zustandKurz-->
	<xsl:template match="z:repeatableGroup[
			@name='ObjConditionGrp'
		]/z:repeatableGroupItem[
			z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = 'aktuell'
		]">
		<!--xsl:message>
			<xsl:text>ZUUUUSTAND KURZ </xsl:text>
		</xsl:message-->
		<xsl:variable name="condition" select="z:dataField[@name='ConditionClb']"/>
		<xsl:variable name="notes" select="z:dataField[@name='NotesClb']"/>
		<zustandKurz>
			<xsl:if test="$condition ne ''">
				<xsl:value-of select="$condition"/>
			</xsl:if>
			<xsl:if test="$condition ne '' and $notes ne ''">
				<xsl:text>; </xsl:text>
			</xsl:if>
			<xsl:if test="$notes ne ''">
				<xsl:value-of select="$notes"/>
			</xsl:if>
		</zustandKurz>
	</xsl:template>

	<!-- Beleuchtung-->
	<xsl:template match="z:repeatableGroup[
			@name = 'ObjIlluminationGrp'  		
		]/z:repeatableGroupItem[
			z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = 'Aktuell'
		]">
		<xsl:variable name="text" select="z:dataField[@name='NotesClb']"/>
		<xsl:variable name="uv" select="z:vocabularyReference[@name='UVVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
		<xsl:variable name="lux" select="z:vocabularyReference[@name='LuxVoc']/z:vocabularyReferenceItem/z:formattedValue"/>

		<xsl:message>
			<xsl:text>BELEUCHTUNG: </xsl:text>
			<xsl:value-of select="$text"/>
			<xsl:text>|</xsl:text>
			<xsl:value-of select="$uv"/>
			<xsl:text>|</xsl:text>
			<xsl:value-of select="$lux"/>
		</xsl:message>

		<beleuchtung>
			<xsl:if test="$text ne ''">
				<xsl:value-of select="$text"/>
			</xsl:if>
			<xsl:if test="$uv ne '' or lux ne ''">
				<xsl:text>; </xsl:text>
			</xsl:if>
			<xsl:if test="$uv ne '' or lux ne ''">
				<xsl:text>UV: </xsl:text>
				<xsl:value-of select="$uv"/>
			</xsl:if>
			<xsl:if test="$uv ne '' and $lux ne ''">
				<xsl:text>; </xsl:text>
			</xsl:if>
			<xsl:if test="$lux ne ''">
				<xsl:text>Lux: </xsl:text>
				<xsl:value-of select="$lux"/>
			</xsl:if>
		</beleuchtung>
	</xsl:template>

	<xsl:template match="z:repeatableGroup[
				@name='ObjConservationTermsGrp'
			]/z:repeatableGroupItem[
				z:vocabularyReference[
					@name ='StatusVoc'
				]/z:vocabularyReferenceItem[
					z:formattedValue = 'aktuell'
				]
			]">
		<!-- there should be only ever one current group in ObjConservationTermsGrp -->
		<KABemerkungen>
			<xsl:value-of select="z:dataField[@name='NotesClb']/z:value"/>
		</KABemerkungen>
		<KABemLeih>
			<xsl:value-of select="z:dataField[@name='LoanNotesClb']/z:value"/>
		</KABemLeih>
		<KADatum>
			<xsl:value-of select="z:dataField[@name='DateDat']/z:formattedLanguage"/>
		</KADatum>
		<KAHandling>
			<xsl:value-of select="z:dataField[@name='HandlingClb']/z:value"/>
		</KAHandling>
		<KALagerung>
			<xsl:value-of select="z:dataField[@name='StorageClb']/z:value"/>
		</KALagerung>
		<KALeihfähigkeit>
			<!--doppelt-->
			<xsl:value-of select="z:vocabularyReference[@name='LoanVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
		</KALeihfähigkeit>
		<KALuftfeuchte>
			<xsl:value-of select="z:vocabularyReference[@name='HumidityVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
		</KALuftfeuchte>
		<KAMontageRahmenSockel>
			<xsl:value-of select="z:dataField[@name='MontageFramingClb']/z:value"/>
		</KAMontageRahmenSockel>
		<KAPräsentation>
			<xsl:value-of select="z:dataField[@name='DisplayClb']/z:value"/>
		</KAPräsentation>
		<KASchädBelast>
			<xsl:value-of select="z:vocabularyReference[@name='ContaminantVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
		</KASchädBelast>
		<KASicherheit>
			<xsl:value-of select="z:dataField[@name='SecurityClb']/z:value"/>
		</KASicherheit>
		<KATemperatur>
			<xsl:value-of select="z:vocabularyReference[@name='TemperatureVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
		</KATemperatur>
		<KATransport>
			<xsl:value-of select="z:dataField[@name='TransportClb']/z:value"/>
		</KATransport>
		<KAVerpackung>
			<xsl:value-of select="z:dataField[@name='PackingClb']/z:value"/>
		</KAVerpackung>
	</xsl:template>
</xsl:stylesheet>
