<xsl:stylesheet version="2.0"
    xmlns="http://www.mpx.org/npx"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:npx="http://www.mpx.org/npx"
	xmlns:z="http://www.zetcom.com/ria/ws/module"

    exclude-result-prefixes="npx z">
	
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

    <xsl:template match="/">
        <npx version="20240529">
			<!--include only smb-freigebene medien!-->
			<xsl:apply-templates select="/z:application/z:modules/z:module[@name='Object']/z:moduleItem" />
        </npx>
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
		<xsl:message>GET HERE</xsl:message>
		<konservatorischeAuflagen>
			<!-- there should be only ever one current group in ObjConservationTermsGrp -->
			<beleuchtung>
				<!-- todo-->
			</beleuchtung>
			<bemerkungen>
				<xsl:value-of select="dataField[@name='NotesClb']/z:value"/>
			</bemerkungen>
			<bemLeih>
				<xsl:value-of select="dataField[@name='LoanNotesClb']/z:value"/>
			</bemLeih>
			<datum>
				<xsl:value-of select="z:dataField[@name='DateDat']/z:formattedLanguage"/>
			</datum>
			<handling>
				<xsl:value-of select="dataField[@name='HandlingClb']/z:value"/>
			</handling>
			<lagerung>
				<xsl:value-of select="dataField[@name='StorageClb']/z:value"/>
			</lagerung>
			<leihfähigkeit>
				<!--doppelt-->
				<xsl:value-of select="z:vocabularyReference[@name='LoanVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
			</leihfähigkeit>
			<luftfeuchte>
				<xsl:value-of select="z:vocabularyReference[@name='HumidityVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
			</luftfeuchte>
			<montageRahmenSockel>
				<xsl:value-of select="dataField[@name='MontageFramingClb']/z:value"/>
			</montageRahmenSockel>
			<präsentation>
				<!-- todo-->
			</präsentation>
			<schädBelast>
				<xsl:value-of select="z:vocabularyReference[@name='ContaminantVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
			</schädBelast>
			<sicherheit>
				<xsl:value-of select="dataField[@name='SecurityClb']/z:value"/>
			</sicherheit>
			<temperatur>
				<xsl:value-of select="z:vocabularyReference[@name='TemperatureVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
			</temperatur>
			<transport>
				<xsl:value-of select="dataField[@name='TransportClb']/z:value"/>
			</transport>
			<verpackung>
				<xsl:value-of select="dataField[@name='PackingClb']/z:value"/>
			</verpackung>
			<!-- nur für aktuell-->
			<zustandKurz>
				<!-- todo-->
			</zustandKurz>
			<zustandKurzBemerkung>
				<!-- todo-->
			</zustandKurzBemerkung>
		</konservatorischeAuflagen>
	</xsl:template>
</xsl:stylesheet>
