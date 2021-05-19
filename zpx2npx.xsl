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
	Fragen an Cornelia:	
	- Soll ich [s:n] unterdrucken, wenn es nur einen Wert gibt? Ich mach' das mal.
	- Soll ich Gewicht jetzt in eigenes Feld schreiben, d.h. nicht in Maße? 
	  Das war früher mal von CF gewünscht, ging damals nicht, geht jetzt, wäre aber 
	  eine Unregelmäßigkeit in meinen Mapping.
	-->

    <xsl:template match="/">
        <npx version="20210516">
			<!--include only smb-freigebene medien!-->
			<xsl:apply-templates select="/z:application/z:modules/z:module[
				@name = 'Multimedia']/z:moduleItem/z:repeatableGroup[
				@name = 'MulApprovalGrp']/z:repeatableGroupItem/z:vocabularyReference[
				@name = 'TypeVoc']/z:vocabularyReferenceItem[
				@name = 'SMB-digital']/../../../z:repeatableGroupItem/z:vocabularyReference[
				@name = 'ApprovalVoc']/z:vocabularyReferenceItem[@name = 'Ja']
				/../../../.." />
			<xsl:apply-templates select="/z:application/z:modules/z:module[@name='Object']/z:moduleItem" />
        </npx>
    </xsl:template>

	<!-- TOP-LEVEL ELEMENTS -->

	<xsl:template match="/z:application/z:modules/z:module[@name='Multimedia']/z:moduleItem">
		<multimediaobjekt>
			<bearbDatum>
				<xsl:value-of select="z:systemField[@name='__lastModified']/z:value"/>
			</bearbDatum>
			<!--datum-->
			<xsl:apply-templates select="z:dataField[@name = 'MulDateTxt']"/>
			<!--dateiname-->
			<xsl:apply-templates select="z:dataField[@name='MulOriginalFileTxt']"/>
			<!--farbe-->
			<xsl:apply-templates select="z:vocabularyReference[@name = 'MulColorVoc']"/>
			<!--freigabe-->
			<xsl:apply-templates select="z:repeatableGroup[@name = 'MulApprovalGrp']"/>
			<!--function-->
			<xsl:apply-templates select="z:vocabularyReference[@name = 'MulCategoryVoc']"/>
			<!--inhaltAnsicht-->
			<xsl:apply-templates select="z:vocabularyReference[@name = 'MulSubjectTxt']"/>
			<mulId>
				<xsl:value-of select="@id"/>
			</mulId>
			<!-- Typ -->
			<xsl:apply-templates select="z:vocabularyReference[@name = 'MulTypeVoc']"/>
			<!-- urhebFotograf -->
			<xsl:apply-templates select="z:moduleReference[@name = 'MulPhotographerPerRef']"/>
			<!-- verknüpftesObjekt-->
			<xsl:apply-templates select="z:composite[@name = 'MulReferencesCre']"/>
		</multimediaobjekt>
	</xsl:template>

	<xsl:template match="/z:application/z:modules/z:module[@name='Object']/z:moduleItem">
		<xsl:variable name="id" select="@id"/>
		<xsl:message>
			<xsl:value-of select="$id"/>
		</xsl:message>
		<sammlungsobjekt>
			<!-- anzahlTeile-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjNumberObjectsGrp']"/>

			<!-- ausstellung -->
			<ausstellung>
				<xsl:for-each select="/z:application/z:modules/z:module[
					@name = 'Exhibition']/z:moduleItem[1]/z:repeatableGroup[
					@name = 'ExhTitleGrp']/z:repeatableGroupItem/z:dataField[
					@name = 'TitleClb']/z:value">
					<xsl:if test="starts-with(.,'HUFO -')">
						<xsl:value-of select="."/>
					</xsl:if>
					<xsl:if test="position()!=last()">
						<xsl:text>; </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</ausstellung>
			<ausstellungSektion>
				<xsl:value-of select="/z:application/z:modules/z:module[
					@name = 'Registrar']/z:moduleItem/z:moduleReference[
					@name = 'RegObjectRef']/z:moduleReferenceItem[
					@moduleItemId = $id]/../../z:virtualField[
					@name = 'RegSectionVrt']"/>
			</ausstellungSektion>
			<bearbDatum>
				<xsl:value-of select="z:systemField[@name='__lastModified']/z:value"/>
			</bearbDatum>
			<bereich>
				<xsl:value-of select="z:vocabularyReference[@name = 'ObjOrgGroupVoc']/z:vocabularyReferenceItem/@name"/>
			</bereich>
			<!--erwerbDatum-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjAcquisitionDateGrp']"/> 
			<!--erwerbungsart-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjAcquisitionMethodGrp']"/>
			<!--erwerbVon-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjAcquisitionMethodGrp']"/>
			<!--erwerbNotizAusgabe-->
			<xsl:apply-templates select="z:repeatableGroup[
				@name='ObjAcquisitionNotesGrp' and 
				./z:repeatableGroupItem/z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = 'Notiz'
				]"/>
			<!-- geogrBezug-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjGeograficGrp']"/>
			<!-- identNr-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjObjectNumberGrp']"/>
			<!--maße -->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjDimAllGrp']"/>
			<!--materialTechnik-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjMaterialTechniqueGrp' and 
				./z:repeatableGroupItem/z:vocabularyReference/z:vocabularyReferenceItem/@name = 'Ausgabe']"/>
			<objId>
				<xsl:value-of select="@id"/>
			</objId>
			<!-- onlineBeschreibung -->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjTextOnlineGrp']"/>
			<!-- todo multiple sachbegriffe-->
			<sachbegriff>
				<xsl:value-of select="z:dataField[@name='ObjTechnicalTermClb']"/>
			</sachbegriff>
			<!--veräußerer-->
			<xsl:apply-templates select="z:moduleReference[@name='ObjPerAssociationRef' and 
			./z:moduleReferenceItem/z:vocabularyReference/z:vocabularyReferenceItem/@name='Veräußerer']"/>
			<verwaltendeInstitution>
				<xsl:value-of select="z:moduleReference[@name='ObjOwnerRef']/z:moduleReferenceItem/z:formattedValue"/>
			</verwaltendeInstitution>
		</sammlungsobjekt>
	</xsl:template>

	<!-- MEDIA:ALL OTHERS ALPHABETICALLY -->
	<xsl:template match="z:dataField[@name = 'MulDateTxt']">
		<datum>
			<xsl:value-of select="z:value"/>
		</datum>
	</xsl:template>

	<xsl:template match="z:dataField[@name = 'MulOriginalFileTxt']">
		<dateinameNeu>
			<xsl:value-of select="../@id"/>
			<xsl:analyze-string select="z:value" regex="(\.\w+)">
				<xsl:matching-substring>
					<xsl:value-of select="regex-group(1)"/>
				</xsl:matching-substring>
			</xsl:analyze-string>
		</dateinameNeu>
	</xsl:template>

	<xsl:template match="z:vocabularyReference[@name = 'MulColorVoc']">
		<farbe>
			<xsl:value-of select="z:vocabularyReferenceItem/@name"/>
		</farbe>
	</xsl:template>

	<xsl:template match="z:repeatableGroup[@name = 'MulApprovalGrp']">
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

	<xsl:template match="z:vocabularyReference[@name = 'MulCategoryVoc']">
		<function>
			<xsl:value-of select="z:vocabularyReferenceItem/@name"/>
		</function>
	</xsl:template>

	<xsl:template match="z:vocabularyReference[@name = 'MulSubjectTxt']">
		<inhaltAnsicht>
			<xsl:value-of select="z:value"/>
		</inhaltAnsicht>
	</xsl:template>

	<xsl:template match="z:vocabularyReference[@name = 'MulTypeVoc']">
		<typ>
			<xsl:value-of select="z:vocabularyReferenceItem/@name"/>
		</typ>
	</xsl:template>

	<xsl:template match="z:moduleReference[@name = 'MulPhotographerPerRef']">
		<urhebFotograf>
			<xsl:value-of select="z:moduleReferenceItem/z:formattedValue"/>
		</urhebFotograf>
	</xsl:template>

	<xsl:template match="z:composite[@name = 'MulReferencesCre']">
		<verknüpftesObjekt>
			<xsl:value-of select="z:compositeItem/z:moduleReference/z:moduleReferenceItem/@moduleItemId"/>
		</verknüpftesObjekt>
	</xsl:template>


	<!-- OBJECTS:ALL OTHERS ALPHABETICALLY -->


	<xsl:template match="z:repeatableGroup[@name='ObjNumberObjectsGrp']">
		<xsl:variable name="len" select="count(z:repeatableGroupItem)"/>
		<anzahlTeile>
			<xsl:for-each select="z:repeatableGroupItem">
				<xsl:sort select="z:dataField[@name='SortLnu']/z:value"/>
				<xsl:if test="len &gt; 1">
					<xsl:call-template name="sortQ"/> 
				</xsl:if>
				<xsl:value-of select="z:dataField[@name='NumberLnu']/z:value"/>
				<!--Bemerkungen missing -->
                <xsl:if test="position()!=last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
			</xsl:for-each>
		</anzahlTeile>
	</xsl:template>

	<xsl:template match="z:repeatableGroup[@name='ObjAcquisitionDateGrp']">
		<xsl:variable name="len" select="count(z:repeatableGroupItem)"/>
		<erwerbDatum>
			<xsl:for-each select="z:repeatableGroupItem">
				<xsl:sort select="z:dataField[@name='SortLnu']/z:value"/>
				<xsl:if test="len &gt; 1">
					<xsl:call-template name="sortQ"/> 
				</xsl:if>
				<xsl:value-of select="z:dataField[@name = 'DateFromTxt']"/>
                <xsl:if test="position()!=last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
			</xsl:for-each>
		</erwerbDatum>
	</xsl:template>			 

	<xsl:template match="z:repeatableGroup[@name='ObjAcquisitionMethodGrp']">
		<xsl:variable name="len" select="count(z:repeatableGroupItem)"/>
		<erwerbungsart>
			<xsl:for-each select="z:repeatableGroupItem">
				<xsl:value-of select="z:vocabularyReference[@name = 'MethodVoc']/z:vocabularyReferenceItem/@name"/>
                <xsl:if test="position()!=last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
			</xsl:for-each>
		</erwerbungsart>
	</xsl:template>			 




	<xsl:template match="z:repeatableGroup[@name='ObjAcquisitionNotesGrp']">
		<erwerbNotizAusgabe>
			<xsl:value-of select="z:repeatableGroupItem/z:dataField[@name = 'MemoClb']"/>
		</erwerbNotizAusgabe>
	</xsl:template>

	<xsl:template match="z:repeatableGroup[@name='ObjGeograficGrp']">
		<xsl:variable name="len" select="count(z:repeatableGroupItem)"/>
		<geogrBezug>
			<xsl:for-each select="z:repeatableGroupItem">
				<xsl:sort select="z:dataField[@name='SortLnu']/z:value"/>
				<xsl:if test="len &gt; 1">
					<xsl:call-template name="sortQ"/> 
				</xsl:if>
				<!-- not sure if I should pick @name oder z:formattedValue-->
				<xsl:value-of select="z:vocabularyReference[@name='PlaceVoc']/z:vocabularyReferenceItem/@name"/>

				<xsl:if test="z:vocabularyReference[@name='GeopolVoc']">
					<xsl:text> [</xsl:text>
						<xsl:value-of select="z:vocabularyReference[@name='GeopolVoc']/z:vocabularyReferenceItem/@name"/>
					<xsl:text>]</xsl:text>
				</xsl:if>
                <xsl:if test="position()!=last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
			</xsl:for-each>		
		</geogrBezug>
	</xsl:template>

	<xsl:template match="z:repeatableGroup[@name='ObjObjectNumberGrp']">
		<xsl:variable name="len" select="count(z:repeatableGroupItem)"/>
		<identNr>
			<xsl:for-each select="z:repeatableGroupItem">
				<xsl:sort select="z:dataField[@name='SortLnu']/z:value"/>
				<xsl:if test="len &gt; 1">
					<xsl:call-template name="sortQ"/> 
				</xsl:if>
				<xsl:value-of select="z:virtualField[@name='NumberVrt']"/>

                <xsl:if test="position()!=last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
			</xsl:for-each>		
		</identNr>
	</xsl:template>

	<xsl:template match="z:repeatableGroup[@name='ObjDimAllGrp']">
		<maße>
			<xsl:for-each select="z:repeatableGroupItem">
				<xsl:sort select="z:dataField[@name='SortLnu']/z:value"/>
				<xsl:call-template name="sortQ"/>
				<xsl:if test="z:vocabularyReference[@name='UnitDdiVoc']">
					<xsl:value-of select="z:moduleReference[@name='TypeDimRef']"/>
					<xsl:text>: </xsl:text>
				</xsl:if>
				
				<xsl:value-of select="z:virtualField[@name='PreviewVrt']/z:value"/>
				<!--
				<xsl:value-of select="z:dataField[@name='WeightNum']/z:value"/>
				xsl:if test="z:vocabularyReference[@name='UnitDdiVoc']">
					<xsl:text> [</xsl:text>
					<xsl:value-of select="z:vocabularyReference[@name='UnitDdiVoc']/z:vocabularyReferenceItem/@name"/>
					<xsl:text>]</xsl:text>
				</xsl:if-->
                <xsl:if test="position()!=last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
			</xsl:for-each>		
		</maße>
	</xsl:template>
	
	<xsl:template match="z:repeatableGroup[@name='ObjMaterialTechniqueGrp']">
		<materialTechnikAusgabe>
			<xsl:for-each select="z:repeatableGroupItem[z:vocabularyReference/z:vocabularyReferenceItem/@name = 'Ausgabe']">
				<xsl:sort select="z:dataField[@name='SortLnu']/z:value"/>
				<!-- there should be only ever one Ausgabe, but I am not sure that is really true-->
				<!-- xsl:call-template name="sortQ"/-->
				<xsl:value-of select="z:dataField[@name='ExportClb']"/>
                <xsl:if test="position()!=last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
			</xsl:for-each>		
		</materialTechnikAusgabe>
	</xsl:template>

	<xsl:template match="z:repeatableGroup[@name='ObjTextOnlineGrp']">
		<onlineBeschreibung>
			<xsl:for-each select="z:repeatableGroupItem">
				<!-- sort doesn't seem to exist here
				xsl:sort select="z:dataField[@name='SortLnu']/z:value"/-->
				<xsl:value-of select="z:dataField[@name='TextClb']"/>
                <xsl:if test="position()!=last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
			</xsl:for-each>		
		</onlineBeschreibung>
	</xsl:template>

	<!--veräußerer-->
	<xsl:template match="z:moduleReference[@name='ObjPerAssociationRef']">
		<veräußerer>
			<xsl:for-each select="z:moduleReferenceItem[z:vocabularyReference/z:vocabularyReferenceItem/@name='Veräußerer']">
				<xsl:value-of select="substring-before(z:formattedValue,', Veräußerer')"/>
                <xsl:if test="position()!=last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
			</xsl:for-each>		
		</veräußerer>
	</xsl:template>


	<!-- named Templates -->

	<xsl:template name="sortQ">
		<xsl:text>[s:</xsl:text>
		<xsl:value-of select="z:dataField[@name='SortLnu']/z:value"/>
		<xsl:text>] </xsl:text>
	</xsl:template>
</xsl:stylesheet>
