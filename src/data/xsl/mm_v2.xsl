<xsl:stylesheet version="2.0"
    xmlns="http://www.mpx.org/npx"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:npx="http://www.mpx.org/npx"
	xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="npx z">

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
			<xsl:if test="not(z:repeatableGroup[@name = 'MulApprovalGrp'])">
				<freigabe/>
			</xsl:if>

			<!--funktion-->
			<xsl:apply-templates select="z:vocabularyReference[@name = 'MulCategoryVoc']"/>

			<!--inhaltAnsicht-->
			<xsl:apply-templates select="z:dataField[@name = 'MulSubjectTxt']"/>
			<mulId>
				<xsl:value-of select="@id"/>
			</mulId>

			<!-- 
				If image is standardbild set sort = 1
				Elsif sort has a numeric value add 1 to it
				If sort is empty, leave it empty
			-->
			<sort>
				<xsl:variable name="sort_orig" select="z:composite[
					@name='MulReferencesCre'
				]/z:compositeItem/z:moduleReference/z:moduleReferenceItem/z:dataField[
					@name='SortLnu'
				]/z:value"/>
				<!--xsl:message>
					<xsl:text>SORT_ORIG: </xsl:text>
					<xsl:value-of select="$sort_orig"></xsl:value-of>
				</xsl:message-->
				<xsl:choose>
					<xsl:when test="z:composite[
						@name='MulReferencesCre'
					]/z:compositeItem/z:moduleReference/z:moduleReferenceItem[
						z:dataField[
							@name = 'ThumbnailBoo'
						]/z:value = 'true']">
						<xsl:text>1</xsl:text>
					</xsl:when>
					<xsl:when test="$sort_orig ne ''">
						<xsl:value-of select="number($sort_orig)+1"/>
					</xsl:when>
				</xsl:choose>
			</sort>
			<!-- 
				in the past it was possible that the standardbild element did not exist
				hence an csv was possible that didnt have this column
			-->
			<standardbild>
				<xsl:if test="z:composite[
					@name='MulReferencesCre'
				][
					z:compositeItem/z:moduleReference[@targetModule = 'Object']/z:moduleReferenceItem/z:dataField[
						@name = 'ThumbnailBoo'
					]/z:value = 'true'
				]">
					<xsl:value-of select="z:composite[
						@name='MulReferencesCre'
					]/z:compositeItem/z:moduleReference[@targetModule = 'Object']/z:moduleReferenceItem[
						z:dataField[
							@name = 'ThumbnailBoo'
						]/z:value = 'true'
					]/@moduleItemId"/>
				</xsl:if>
			</standardbild>
			
			<!-- Typ -->
			<xsl:apply-templates select="z:vocabularyReference[@name = 'MulTypeVoc']"/>
			<!-- urhebFotograf -->
			<xsl:apply-templates select="z:moduleReference[@name = 'MulPhotographerPerRef']"/>
			<!-- verknüpftesObjekt-->
			<xsl:apply-templates select="z:composite[@name = 'MulReferencesCre']"/>
		</multimediaobjekt>
	</xsl:template>


	<!-- MEDIA:ALL OTHERS ALPHABETICALLY -->
	<xsl:template match="z:dataField[@name = 'MulDateTxt']">
		<datum>
			<xsl:value-of select="z:value"/>
		</datum>
	</xsl:template>

	<!-- 2022.02.18: newly lower-cased -->
	<xsl:template match="z:dataField[@name = 'MulOriginalFileTxt']">
		<dateinameNeu>
			<xsl:value-of select="../@id"/>
			<xsl:variable name="suffix">
				<xsl:analyze-string select="z:value" regex="(\.\w+)">
					<xsl:matching-substring>
						<xsl:value-of select="regex-group(1)"/>
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="starts-with(lower-case($suffix),'.tif')">
					<xsl:text>.jpg</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$suffix"/>
				</xsl:otherwise>
			</xsl:choose>
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
		<funktion>
			<xsl:value-of select="z:vocabularyReferenceItem/@name"/>
		</funktion>
	</xsl:template>

	<xsl:template match="z:dataField[@name = 'MulSubjectTxt']">
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
		<xsl:variable name="objId" select="z:compositeItem/z:moduleReference[
			@targetModule = 'Object'
		]/z:moduleReferenceItem/@moduleItemId"/>
		<verknüpftesObjekt>
			<xsl:for-each select="$objId">
				<xsl:value-of select="." />
				<xsl:if test="position() != last()">; </xsl:if>
			</xsl:for-each> 
		</verknüpftesObjekt>
		<verknüpftesObjektIdentNr>
			<xsl:for-each select="/z:application/z:modules/z:module[
				@name = 'Object'
			]/z:moduleItem[
				@id = $objId
			]/z:virtualField[
				@name = 'ObjObjectNumberVrt'
			]/z:value">
				<xsl:value-of select="." />
				<xsl:if test="position() != last()">; </xsl:if>
			</xsl:for-each> 
		</verknüpftesObjektIdentNr>
	</xsl:template>
</xsl:stylesheet>
