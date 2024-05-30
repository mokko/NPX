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

<!-- 
-->

	<xsl:template match="/z:application/z:modules/z:module[@name='Object']/z:moduleItem">
		<sammlungsobjekt>
			<xsl:for-each select="z:repeatableGroup[
				@name='ObjConservationTermsGrp'
			]/z:repeatableGroupItem[
				z:vocabularyReference[
					@name ='StatusVoc'
				]/z:vocabularyReferenceItem[
					z:formattedValue = 'aktuell'
				]
			]">
				<datum>
					<xsl:value-of select="z:dataField[@name='DateDat']/z:formattedLanguage"/>
				</datum>
				<leihfähigkeit>
					<!--doppelt-->
					<xsl:value-of select="z:vocabularyReference[@name='LoanVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
				</leihfähigkeit>
				<luftfeuchte>
					<xsl:value-of select="z:vocabularyReference[@name='HumidityVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
				</luftfeuchte>
				<handling>
					<xsl:value-of select="dataField[@name='HandlingClb']/z:value"/>
				</handling>
				<präsentation>
				</präsentation>
				<lagerung>
					<xsl:value-of select="dataField[@name='StorageClb']/z:value"/>
				</lagerung>
				<transport>
					<xsl:value-of select="dataField[@name='TransportClb']/z:value"/>
				</transport>
				<montageRahmenSockel>
					<xsl:value-of select="dataField[@name='MontageFramingClb']/z:value"/>
				</montageRahmenSockel>
				<bemLeih>
					<xsl:value-of select="dataField[@name='LoanNotesClb']/z:value"/>
				</bemLeih>
				<verpackung>
					<xsl:value-of select="dataField[@name='PackingClb']/z:value"/>
				</verpackung>
				<bemerkungen>
					<xsl:value-of select="dataField[@name='NotesClb']/z:value"/>
				</bemerkungen>
				<sicherheit>
					<xsl:value-of select="dataField[@name='SecurityClb']/z:value"/>
				</sicherheit>
				<temperatur>
					<xsl:value-of select="z:vocabularyReference[@name='TemperatureVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
				</temperatur>
				<schädBelast>
					<xsl:value-of select="z:vocabularyReference[@name='ContaminantVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
				</schädBelast>
			</xsl:for-each>
		</sammlungsobjekt>
	</xsl:template>
</xsl:stylesheet>
