<xsl:stylesheet version="2.0"
    xmlns="http://www.mpx.org/npx"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:npx="http://www.mpx.org/npx"
	xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="npx z">
	
	<!-- TOP -->
	<xsl:template match="/z:application/z:modules/z:module[@name='Object']/z:moduleItem">
		<xsl:variable name="id" select="@id"/>
		<xsl:message>
			<xsl:value-of select="$id"/>
		</xsl:message>
		<sammlungsobjekt>
			<!-- anzahlTeile-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjNumberObjectsGrp']"/>

			<!-- ausstellung !!Funktioniert bei altem Export nicht!! -->
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
			<!--beteiligte-->
			<xsl:apply-templates select="z:moduleReference[@name='ObjPerAssociationRef' and @targetModule ='Person']"/> 
			<!-- credits-->
			<xsl:apply-templates select="z:vocabularyReference[@name='ObjCreditLineVoc']"/> 
			<!--datierung-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjDateGrp']"/> 
			<!--erwerbDatum-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjAcquisitionDateGrp']"/> 
			<!--erwerbungsart-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjAcquisitionMethodGrp']"/>
			<!--erwerbVon
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjAcquisitionMethodGrp']"/>
			-->
			<!--erwerbNotizAusgabe TODO: Ausgabe noch nicht implementiert -->
			<xsl:apply-templates select="z:repeatableGroup[
				@name='ObjAcquisitionNotesGrp' and 
				./z:repeatableGroupItem/z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = 'Notiz'
				]"/>
			<!-- geogrBezug-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjGeograficGrp']"/>
			<!-- identNr-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjObjectNumberGrp']"/>
			<!-- ikonografie -->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjIconographyGrp']"/>

			<ikonografieKurz>
				<xsl:value-of select="z:dataField[@name='ObjIconographyContentBriefClb']/z:value"/>
			</ikonografieKurz>
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
			<!-- oov -->
			<xsl:apply-templates select="z:composite[@name='ObjObjectCre']"/>
			<!--rauteElement-->
			<xsl:apply-templates select="z:moduleReference[@name='ObjObjectGroupsRef']"/>

			<!-- todo multiple sachbegriffe-->
			<sachbegriff>
				<xsl:value-of select="z:dataField[@name='ObjTechnicalTermClb']/z:value"/>
			</sachbegriff>

			<!-- 
				Aus Sicherheitsgründen sollen nur Standorte aus HF Ausstellungen an SHF übergeben werden. 
				Cornelia möchte lieber alle Standorte auf einmal und so lange leere Felder.
				Hier werden nur definitive aktuelle Standorte ausgegeben, keine historischen.
			-->
			<standortAktuellHf>
				<xsl:if test="starts-with(z:vocabularyReference[@name='ObjNormalLocationVoc']/z:vocabularyReferenceItem/@name, 'HUF##')">
					<xsl:value-of select="z:vocabularyReference[@name='ObjNormalLocationVoc']/z:vocabularyReferenceItem/@name"/>
				</xsl:if>
			</standortAktuellHf>
			<!--titel-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjObjectTitleGrp']"/>

			<!--veräußerer-->
			<xsl:apply-templates select="z:moduleReference[@name='ObjPerAssociationRef' and 
			./z:moduleReferenceItem/z:vocabularyReference/z:vocabularyReferenceItem/@name='Veräußerer']"/>
			<verwaltendeInstitution>
				<xsl:value-of select="z:moduleReference[@name='ObjOwnerRef']/z:moduleReferenceItem/z:formattedValue"/>
			</verwaltendeInstitution>
		</sammlungsobjekt>
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

	<!--beteiligte-->
	<xsl:template match="z:moduleReference[@name='ObjPerAssociationRef' and @targetModule ='Person']">
		<beteiligte>
			<xsl:for-each select="z:moduleReferenceItem">
				<xsl:variable name="role" select="z:vocabularyReference[@name='RoleVoc']/z:vocabularyReferenceItem/@name"/>
				<xsl:value-of select="substring-before(z:formattedValue, concat(', ', $role))"/>
				<xsl:text> [</xsl:text>
				<xsl:value-of select="$role"/>
				<xsl:text>]</xsl:text>
                <xsl:if test="position()!=last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
			</xsl:for-each>		
		</beteiligte>
	</xsl:template>

	<!-- credits-->
	<xsl:template match="z:vocabularyReference[@name='ObjCreditLineVoc']">
		<credits>
			<xsl:value-of select="z:vocabularyReferenceItem/@name"/>
		</credits>
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

	<!--datierung-->
	<xsl:template match="z:repeatableGroup[@name='ObjDateGrp']">
		<datierung>
			<xsl:for-each select="z:repeatableGroupItem">
				<xsl:value-of select="z:dataField[@name = 'DateTxt']/z:value"/>
				<xsl:text> [</xsl:text>
				<xsl:value-of select="z:dataField[@name = 'DateFromTxt']/z:value"/>
				<xsl:text>]</xsl:text>

				<xsl:text> [</xsl:text>
				<xsl:value-of select="z:dataField[@name = 'DateToTxt']/z:value"/>
				<xsl:text>]</xsl:text>

				<xsl:text> [</xsl:text>
				<xsl:value-of select="z:vocabularyReference[@instanceName = 'ObjDateTypeVgr']/z:vocabularyReferenceItem/@name"/>
				<xsl:text>]</xsl:text>

                <xsl:if test="position()!=last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
			</xsl:for-each>
		</datierung>
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
				<xsl:value-of select="z:dataField[@name='InventarNrSTxt']"/>
                <xsl:if test="position()!=last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
			</xsl:for-each>		
		</identNr>
	</xsl:template>

	<!-- ikonografie -->
	<xsl:template match="z:repeatableGroup[@name='ObjIconographyGrp']">
		<ikonografieEM>
			<xsl:value-of select="z:repeatableGroupItem/@id"/>
		</ikonografieEM>
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

	<xsl:template match="z:composite[@name='ObjObjectCre']">
		<oov>
			<xsl:for-each select="z:compositeItem/z:moduleReference/z:moduleReferenceItem">
				<xsl:text>[</xsl:text>
				<xsl:value-of select="@moduleItemId"/>
				<xsl:text>] </xsl:text>
				<xsl:value-of select="z:formattedValue"/>
				<xsl:text> [</xsl:text>
				<xsl:value-of select="z:vocabularyReference[name='TypeAVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
				<xsl:text>] </xsl:text>
				<xsl:text>[</xsl:text>
				<xsl:value-of select="z:vocabularyReference[name='TypeBVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
				<xsl:text>]</xsl:text>
                <xsl:if test="position()!=last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
			</xsl:for-each>
		</oov>
	</xsl:template>
	<!-- 
		rauteElement, e.g.
		EM-ME HUF-E39040# 
	-->
	<xsl:template match="z:moduleReference[@name='ObjObjectGroupsRef']">
		<rauteElement>
			<xsl:choose>
				<xsl:when test="z:moduleReference[@name='ObjOwnerRef']/z:moduleReferenceItem">
					<xsl:for-each select="z:moduleReferenceItem[contains (z:formattedValue, '#')]">
						<xsl:analyze-string select="z:formattedValue" regex="HUF-(E\d+)(.*)#">
							<xsl:matching-substring>
								<xsl:value-of select="regex-group(1)"/>
								<xsl:value-of select="regex-group(2)"/>
							</xsl:matching-substring>
						</xsl:analyze-string>
						<xsl:if test="position()!=last()">
							<xsl:text>; </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="z:moduleReferenceItem[starts-with (z:formattedValue, 'HUFO - ')]">
						<xsl:analyze-string select="z:formattedValue" regex="- (E\d+) - ">
							<xsl:matching-substring>
								<xsl:value-of select="regex-group(1)"/>
							</xsl:matching-substring>
						</xsl:analyze-string>
						<xsl:if test="position()!=last()">
							<xsl:text>; </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</rauteElement>
	</xsl:template>

	<!-- titel -->
	<xsl:template match="z:repeatableGroup[@name='ObjObjectTitleGrp']">
		<xsl:if test="z:repeatableGroupItem/z:dataField[@name='TitleTxt'] != ''">
			<titel>
				<xsl:for-each select="z:repeatableGroupItem">
					<xsl:value-of select="z:dataField[@name='TitleTxt']"/>
					<xsl:text> [</xsl:text>
						<xsl:value-of select="z:vocabularyReference[@name='TypeVoc']/z:vocabularyReferenceItem/@name"/>
					<xsl:text>]</xsl:text>
					<xsl:if test="position()!=last()">
						<xsl:text>; </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</titel>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>