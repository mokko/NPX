<xsl:stylesheet version="2.0"
    xmlns="http://www.mpx.org/npx"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:npx="http://www.mpx.org/npx"
	xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="npx z">
	<xsl:import href="konsAuflagen_v2.xsl"/>

	<!-- version 2 of the npx exchange format, has been remodelled together with Cornelia
		from SHF in 2024 pretty much from the ground up. 
	-->
	
	<!-- TOP -->
	<xsl:template match="/z:application/z:modules/z:module[@name='Object']/z:moduleItem">
		<xsl:variable name="id" select="@id"/>
		<!--xsl:message>
			<xsl:value-of select="$id"/>
		</xsl:message-->
		<sammlungsobjekt>
			<!-- anzahlTeile-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjNumberObjectsGrp']"/>

			<bearbDatum>
				<xsl:value-of select="z:systemField[@name='__lastModified']/z:value"/>
			</bearbDatum>

			<!-- Beleuchtung -->
			<beleuchtung>
				<xsl:apply-templates select="z:repeatableGroup[
					@name = 'ObjIlluminationGrp'
					and z:repeatableGroupItem/z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = 'Aktuell'
				]"/>
			</beleuchtung>
			
			<bereich>
				<xsl:value-of select="z:vocabularyReference[@name = 'ObjOrgGroupVoc']/z:vocabularyReferenceItem/@name"/>
			</bereich>
			<!--beteiligte-->
			<xsl:apply-templates select="z:moduleReference[@name='ObjPerAssociationRef' and @targetModule ='Person']"/> 
			<credits>
				<xsl:apply-templates select="z:vocabularyReference[@name='ObjCreditLineVoc']"/> 
			</credits>
			<!--datierung-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjDateGrp']"/> 

			<!--xsl:apply-templates select="z:repeatableGroup[@name='ObjAcquisitionDateGrp']"/> 
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjAcquisitionMethodGrp']"/>
			erwerbVon
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjAcquisitionMethodGrp']"/>
			z:repeatableGroupItem/z:vocabularyReference/z:vocabularyReferenceItem[z:formattedValue = 'Ausgabe']
			-->

			<!--erwerbNotizAusgabe -->
			<xsl:if test="z:repeatableGroup[@name='ObjAcquisitionNotesGrp']/z:repeatableGroupItem[
						z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = 'Ausgabe']">
				<erwerbNotizAusgabe>
					<xsl:for-each select="z:repeatableGroup[@name='ObjAcquisitionNotesGrp']/z:repeatableGroupItem[
						z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = 'Ausgabe']">
						<xsl:value-of select="z:dataField[@name='MemoClb']/z:value"/>
						<xsl:if test="position()!=last()">
							<xsl:text>; </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</erwerbNotizAusgabe>
			</xsl:if>
			
			
			<!-- geogrBezug-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjGeograficGrp']"/>
			<!-- identNr-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjObjectNumberGrp']"/>

			<!--
			ikonografieKurz (7.6.24) und ikonografieEM (16.9.2024) auf Wunsch von Cornelia entfernt
			-->

			<!--konserv. Auflagen-->
			<xsl:apply-templates select="z:repeatableGroup[
				@name='ObjConservationTermsGrp']"/>		
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
			<!--rauteElement und rauteModul-->
			<!-- 
			rauteElement und rauteModul 
			in v1 these two fields were based on RIA:Objektgruppe(ObjObjectGroupsRef), in v2 these are supposed 
			to be based on Standort.
			-->
			<xsl:variable name="ständiger" select="z:vocabularyReference[@name='ObjNormalLocationVoc']/z:vocabularyReferenceItem"/>
			<xsl:variable name="aktueller" select="z:vocabularyReference[@name='ObjCurrentLocationVoc']/z:vocabularyReferenceItem"/>
			<xsl:choose>
				<xsl:when test="contains ($ständiger/@name, 'HUF##')">
					<!--xsl:message>
						<xsl:text>STÄNDIGER: </xsl:text>
						<xsl:value-of select="$ständiger/z:formattedValue[@language = 'de']"/>
					</xsl:message-->
					<rauteElement>
						<xsl:value-of select="$ständiger/z:formattedValue[@language = 'de']"/>
					</rauteElement>
					<rauteModul>
						<xsl:analyze-string select="$ständiger/z:formattedValue" regex="E(\d\d)\d\d\d">
							<xsl:matching-substring>
								<xsl:value-of select="regex-group(1)"/>
							</xsl:matching-substring>
						</xsl:analyze-string>
					</rauteModul>
				</xsl:when>
				<xsl:when test="contains ($aktueller/@name, 'HUF##')">
					<!--xsl:message>
						<xsl:text>AKTUELLER: </xsl:text>
						<xsl:value-of select="$aktueller/z:formattedValue[@language = 'de']"/>
					</xsl:message-->
					<rauteElement>
						<xsl:value-of select="$aktueller/z:formattedValue[@language = 'de']"/>
					</rauteElement>
					<rauteModul>
						<xsl:analyze-string select="$aktueller/z:formattedValue" regex="E(\d\d)\d\d\d">
							<xsl:matching-substring>
								<xsl:value-of select="regex-group(1)"/>
							</xsl:matching-substring>
						</xsl:analyze-string>
					</rauteModul>
				</xsl:when>
				<xsl:otherwise>
					<xsl:comment>rauteElement/rauteModul otherwise</xsl:comment>
				</xsl:otherwise>
			</xsl:choose>


			<!-- todo multiple sachbegriffe-->
			<sachbegriff>
				<xsl:value-of select="z:dataField[@name='ObjTechnicalTermClb']/z:value"/>
			</sachbegriff>

			<SMBfreigabe>
				<xsl:choose>
					<xsl:when test="z:repeatableGroup[
						@name = 'ObjPublicationGrp'
					]/z:repeatableGroupItem[
						z:vocabularyReference[
							@name = 'PublicationVoc'
						]/z:vocabularyReferenceItem[
							z:formattedValue = 'Ja'
						]
					][
						z:vocabularyReference[
							@name = 'TypeVoc'
						]/z:vocabularyReferenceItem[
							z:formattedValue = 'Daten freigegeben für SMB-digital'
						]
					]">
						<xsl:text>ja</xsl:text>					
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>nein</xsl:text>
					</xsl:otherwise>
				</xsl:choose> 	
			</SMBfreigabe>

			<!-- 
			contains standardbild's mulID if there is a standardbild and is empty if there is no 
			standardbild
			-->
			<standardbild>
				<xsl:value-of select="z:moduleReference[
					@name ='ObjMultimediaRef'
				]/z:moduleReferenceItem[
					z:dataField[
						@name = 'ThumbnailBoo'
					]/z:value eq 'true'
				]/@moduleItemId"/>
			</standardbild>


			<!-- 
				Aus Sicherheitsgründen sollen nur Standorte aus HF Ausstellungen an SHF übergeben werden. 
				Cornelia möchte lieber alle Standorte auf einmal und so lange leere Felder.
				Hier werden nur definitive aktuelle Standorte ausgegeben, keine historischen.
				
				TODO: Die SHF wünscht nur die Übergabe von Objekten in Ausstellungen. Dazu brauchen wir eine
				Positivliste mit allen Ausstellungsräumen (ohne WAF).
				HUF##O1.189.01.K1 Modul 13
				HUF##O1.196.01.K2 Modul 11
				HUF##O2.017.B2 Modul 37 Treffpunkt Afrika
				HUF##O2.019.P3 Modul 39 Klänge der Welt
				HUF##O2.020.P1 Modul 30 Benin
				HUF##O2.029.B3 Modul 15 
				HUF##O2.037.B3 Modul 16
				HUF##O2.047.B5 Modul 21 Am Humboldtstrom
				HUF##O2.061.B5 Modul 23 Azteken
				HUF##O2.073.B5 Modul 29 Benin
				HUF##O2.124.K1 Modul 14 Ozeanien Schiffe
				HUF##O2.133.K2 Modul 12 Kubus Nord Galerie
				HUF##O2.160.01.B2 Modul 35 Intro Afrika
				HUF##O2.160.02.B2 Modul 36 Schaumagazin Afrika
				HUF##O2.161.B4 Modul 19 Ein Sammler
				HUF##O2.163.01.B5 Modul 24 Kommunikationssysteme
				HUF##O2.163.02.B5 Schaumagazin Amerika
				HUF##O2.163.03.B5 Cotzmalhualpa-Stelen
				HUF##O2.163.04.B5 Modul 26 Goldkammer
				HUF##O2.164.P4 Modul 18 Treffpunkt Nordamerika
				HUF##O3.001.P1 Modul 56 Asiatisches Theater
				HUF##O3.014.B2 Modul 61 Südasien Skulpturen
				HUF##O3.090.K1 Modul 43 Studiensammlung Zentralasien
				HUF##O3.124.B1 Modul 57 Südostasien
				HUF##O3.125.01.B2 Introraum Südostasien
				HUF##O3.127.02.B3 Modul 46
				HUF##O3.128.B4 Modul 48 China Religion
				HUF##O3.130.B5 Modul 55 Selbstbestimmung
				HUF##O3.131.01.B5 Modul 53 Islam
				
				Ausstellung fraglich?
				HUF##O3.125.02.B2 314
				HUF##O3.126.P3    317
				HUF##O3.127.01.B3 319
				HUF##O3.131.02 B5 306
				HUF##O3.131.03.B5
				HUF##RA242				
			-->
			<xsl:variable name="Ausstellungen" select="
				'HUF##O1.189.01.K1',
				'HUF##O1.196.01.K2',
				'HUF##O2.017.B2',
				'HUF##O2.019.P3',
				'HUF##O2.020.P1',
				'HUF##O2.029.B3',
				'HUF##O2.037.B3',
				'HUF##O2.047.B5',
				'HUF##O2.061.B5',
				'HUF##O2.073.B5',
				'HUF##O2.124.K1',
				'HUF##O2.133.K2',
				'HUF##O2.160.01.B2',
				'HUF##O2.160.02.B2',
				'HUF##O2.161.B4',
				'HUF##O2.163.01.B5',
				'HUF##O2.163.02.B5',
				'HUF##O2.163.03.B5',
				'HUF##O2.163.04.B5',
				'HUF##O2.164.P4',
				'HUF##O3.001.P1',
				'HUF##O3.014.B2',
				'HUF##O3.090.K1',
				'HUF##O3.124.B1',
				'HUF##O3.125.01.B2',
				'HUF##O3.127.02.B3',
				'HUF##O3.128.B4',
				'HUF##O3.130.B5',
				'HUF##O3.131.01.B5'
			"/>
			
			
			<!-- 
			we want locations from either Ständiger STO oder aktueller STO, in the recent 
			past we only got aktueller Standort; if both ständiger and aktueller have a 
			whitelisted HUF location, we prefer ständiger.
			-->
			<xsl:variable name="ständiger" select="z:vocabularyReference[@name='ObjNormalLocationVoc']/z:vocabularyReferenceItem/@name"/>
			<xsl:variable name="aktueller" select="z:vocabularyReference[@name='ObjCurrentLocationVoc']/z:vocabularyReferenceItem/@name"/>

			<standortAusstellungHF>
				<xsl:choose>
					<xsl:when test="some $Ausstellung in $Ausstellungen satisfies starts-with($ständiger, $Ausstellung)">
						<xsl:value-of select="$ständiger"/>
						<!--xsl:text> [ständiger Standort]</xsl:text-->
					</xsl:when>
					<xsl:when test="some $Ausstellung in $Ausstellungen satisfies starts-with($aktueller, $Ausstellung)">
						<xsl:value-of select="$aktueller"/>
						<!--xsl:text> [aktueller Standort]</xsl:text-->
					</xsl:when>
					<xsl:otherwise>
						<!-- no whitelised HUF standort, leave field empty-->
					</xsl:otherwise>
				</xsl:choose>
			</standortAusstellungHF>
			<!--titel-->
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjObjectTitleGrp']"/>

			<!--neu veräußerung-->
			<xsl:apply-templates select="z:moduleReference[
				@name='ObjPerAssociationRef' and 
			./z:moduleReferenceItem/z:vocabularyReference/z:vocabularyReferenceItem/@name='Veräußerung']"/>
			<verwaltendeInstitution>
				<xsl:value-of select="z:moduleReference[@name='ObjOwnerRef']/z:moduleReferenceItem/z:formattedValue"/>
			</verwaltendeInstitution>
			
			<!-- zustandKurz-->
			<zustandKurz>
				<xsl:apply-templates select="z:repeatableGroup[
					@name = 'ObjConditionGrp'
				]/z:repeatableGroupItem[
					z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = 'aktuell'
				]"/>
			</zustandKurz>
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
				<!-- 20220524 explicit order -->
				<xsl:sort select="z:dataField[@name='SortLnu']/z:value" data-type="number" order="ascending"/>
				<!-- xsl:message>
					<xsl:text>Beteiligte Sort: </xsl:text>
					<xsl:value-of select="z:dataField[@name='SortLnu']/z:value"/>
				</xsl:message-->
				<xsl:variable name="role" select="z:vocabularyReference[@name='RoleVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
				<xsl:variable name="name" select="substring-before(z:formattedValue, concat(', ', $role))"/>
				<!--xsl:message>
					<xsl:text>Beteiligte '</xsl:text>
					<xsl:value-of select="$name"/>
					<xsl:text>' '</xsl:text>
					<xsl:value-of select="$role"/>
					<xsl:text>'</xsl:text>
				</xsl:message-->
				<xsl:value-of select="$name"/>
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
			<xsl:value-of select="z:vocabularyReferenceItem/z:formattedValue[@language = 'de']"/>
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

	<xsl:template match="z:repeatableGroup[@name='ObjGeograficGrp']">
		<xsl:variable name="order">
			<xsl:choose>
				<!-- 165950 = AKu -->
				<xsl:when test="../z:moduleReference[@name='ObjOwnerRef']/z:moduleReferenceItem/@moduleItemId = '165950'">
					<xsl:text>descending</xsl:text>
				</xsl:when>
				<xsl:otherwise>ascending</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<geogrBezug>
			<xsl:for-each select="z:repeatableGroupItem">
				<xsl:sort select="z:dataField[@name='SortLnu']/z:value" data-type="number" order="{$order}"/>
				<!--xsl:call-template name="sortQ"/--> 
				<!-- 
					if ortDetails but no geoName, put ortDetails first 
					not sure if I should pick @name oder z:formattedValue
				-->
				<xsl:variable name="geoName" select="z:vocabularyReference[@name='PlaceVoc']/z:vocabularyReferenceItem/@name"/>
				<xsl:variable name="details" select="z:dataField[@name='DetailsTxt']"/>
				<xsl:variable name="ortstyp" select="z:vocabularyReference[@name='TypeVoc']/z:vocabularyReferenceItem/@name"/>
				<xsl:variable name="bezeichnung" select="z:vocabularyReference[@name='GeopolVoc']/z:vocabularyReferenceItem/@name"/>

				<!--xsl:message>
					<xsl:text>N: </xsl:text>
					<xsl:value-of select="$geoName"/>
					<xsl:text> D: </xsl:text>
					<xsl:value-of select="$details"/>
				</xsl:message-->

				<xsl:if test="$ortstyp ne ''">
					<xsl:text>[</xsl:text>
					<xsl:value-of select="$ortstyp"/>
					<xsl:text>] </xsl:text>
				</xsl:if>
				
				<xsl:choose>
					<xsl:when test="not($geoName)">
							<xsl:value-of select="$details"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$geoName"/>
					</xsl:otherwise>
				</xsl:choose>
				
				<xsl:if test="$bezeichnung ne ''">
					<xsl:text> [</xsl:text>
						<xsl:value-of select="$bezeichnung"/>
					<xsl:text>]</xsl:text>
				</xsl:if>

				<xsl:if test="$geoName and normalize-space($details) ne ''">
					<xsl:text> [</xsl:text>
						<xsl:value-of select="z:dataField[@name='DetailsTxt']"/>
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


	<!--
	Verpackungs- und Transportmaße sollen nicht ausgespielt werden
	7.12.2021
	Transportmaß im falschen Qualifikator lasse ich stehen.
	-->
	
	<xsl:template match="z:repeatableGroup[@name='ObjDimAllGrp']">
		<xsl:variable name="excluded" select="'Verpackungsmaß', 'Transportmaß'"/>
		<maße>
			<xsl:for-each select="z:repeatableGroupItem[z:moduleReference[
				@name='TypeDimRef']/z:moduleReferenceItem[not (z:formattedValue = $excluded)]]">
				<xsl:sort select="z:dataField[@name='SortLnu']/z:value"/>
				<xsl:call-template name="sortQ"/>
				<xsl:if test="z:vocabularyReference[@name='UnitDdiVoc']">
					<xsl:value-of select="z:moduleReference[@name='TypeDimRef']"/>
					<xsl:text>: </xsl:text>
				</xsl:if>
				<xsl:value-of select="z:virtualField[@name='PreviewVrt']/z:value"/>
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
				<!-- 
					sort doesn't seem to exist here
					xsl:sort select="z:dataField[@name='SortLnu']/z:value"/
				-->
				<xsl:variable name="txt" select="z:dataField[@name='TextClb']/z:value"/>
				<xsl:choose>
					<xsl:when test="contains($txt, '[SM8HF]')">
						<xsl:variable name="before" select="normalize-space(substring-before($txt,'[SM8HF]'))"/>
						<xsl:variable name="after" select="normalize-space(substring-after($txt,'[SM8HF]'))"/>
						<xsl:variable name="new">
							<xsl:if test="$before ne ''">
								<xsl:value-of select="$before"/>
							</xsl:if>
							<xsl:if test="$before ne '' and $after ne ''">
								<xsl:text> </xsl:text>
							</xsl:if>
							<xsl:if test="$after ne ''">
								<xsl:value-of select="$after"/>
							</xsl:if>
						</xsl:variable>
						<xsl:value-of select="$new"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$txt"/>
					</xsl:otherwise>
				</xsl:choose>
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