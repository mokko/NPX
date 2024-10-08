<xsl:stylesheet version="2.0"
    xmlns="http://www.mpx.org/npx"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:npx="http://www.mpx.org/npx"
	xmlns:z="http://www.zetcom.com/ria/ws/module"

    exclude-result-prefixes="npx z">
	<xsl:import href="mm_v2.xsl"/>
	<xsl:import href="so_v2.xsl"/>
	
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

    <!-- 
	Fragen an Cornelia:	
	- Soll ich [s:n] unterdrucken, wenn es nur einen Wert gibt? Ich mach' das mal.
	- Soll ich Gewicht jetzt in eigenes Feld schreiben, d.h. nicht in Maße? 
	  Das war früher mal von CF gewünscht, ging damals nicht, geht jetzt, wäre aber 
	  eine Unregelmäßigkeit in meinen Mapping.
	  
	  /m:application/m:modules/m:module[
                        @name = 'Multimedia']/m:moduleItem[@id = '{mulId}' and 
                        ./m:repeatableGroup[@name ='MulApprovalGrp']
                        /m:repeatableGroupItem/m:vocabularyReference[@name='TypeVoc']/m:vocabularyReferenceItem[@id= '1816002'] and
                        ./m:repeatableGroup[@name ='MulApprovalGrp']
                        /m:repeatableGroupItem/m:vocabularyReference[@name='ApprovalVoc']/m:vocabularyReferenceItem[@id= '4160027']                    
                        ]
	-->

    <xsl:template match="/">
        <npx version="20240607">
			<xsl:comment>
npx format is a dumbed-down version of the old mpx, designed to be convertable to csv.
1. Elements are typically called as in MuseumPlus's GUI.
3. Elements inside the record (or items) are called fields.
2. Empty fields are supposed to appear as empty elements and may not be repeated.
4. Fields are ordered alphabetically.
5. All qualifiers are resolved in the elements according to a specified schema.
6. Multipe entries are resolved in text using ; as separator.
			</xsl:comment>
		
			<!--
				mm 
				include only smb-freigebene medien!
			-->
			<xsl:apply-templates select="/z:application/z:modules/z:module[@name = 'Multimedia']/z:moduleItem[
				z:repeatableGroup[@name = 'MulApprovalGrp']
					/z:repeatableGroupItem/z:vocabularyReference[
						@name = 'TypeVoc']/z:vocabularyReferenceItem[
						@name = 'SMB-digital'] and 
				z:repeatableGroup[@name = 'MulApprovalGrp']
					/z:repeatableGroupItem/z:vocabularyReference[
						@name = 'ApprovalVoc']/z:vocabularyReferenceItem[
						@name = 'Ja']
				]" />
				
			<!--so-->
			<xsl:apply-templates select="/z:application/z:modules/z:module[@name='Object']/z:moduleItem" />
        </npx>
    </xsl:template>


	<!-- named Templates -->
	<xsl:template name="sortQ">
		<xsl:text>[s:</xsl:text>
		<xsl:value-of select="z:dataField[@name='SortLnu']/z:value"/>
		<xsl:text>] </xsl:text>
	</xsl:template>
</xsl:stylesheet>
