<xsl:stylesheet version="2.0"
    xmlns="http://www.mpx.org/npx"
    xmlns:n="http://www.mpx.org/npx"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="n">	

	<xsl:output method="html" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />
	
	<!-- 
	Erstellt eine HTML Liste zum Ausdrucken als Teil des seit 21.7.21 vorgeschriebenen
	Medienvertrages zwischen SPK&SHF.

	Das Dokument besteht im Wesentlichen aus einer Tabelle mit drei Spalten
	Sammlung
	Objekt / ID
	Datei
	-->

	<xsl:template match="/">
		<html>
			<head>
				<meta charset="utf-8"/>
				<title>Liste der Freigegebenen Multimediadateien und Digitalisate</title>
				<style>
				table, th, td{
					border-collapse: collapse;
				}
				td {
					padding-left:12px;
					padding-right:12px;
				}
				</style>
			</head>
			<body>
				<h1>Liste der freigegebenen audiovisuellen Mediendateien bzw. Digitalisate</h1>
				<table border="1">
					<tr>
						<th>Lfd.Nr.</th>
						<th>Sammlung</th>
						<th>Objekt / ID</th>
						<th>Datei</th>
					</tr>
					<xsl:apply-templates select="/n:npx/n:multimediaobjekt"/>
				</table>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="/n:npx/n:multimediaobjekt">
		<xsl:variable name="objId" select="n:verknüpftesObjekt"/>
		<!--xsl:message>
			<xsl:value-of select="n:mulId"/>
			<xsl:text> : </xsl:text>
			<xsl:value-of select="$objId"/>
		</xsl:message-->
		<tr>
			<td>
				<xsl:number value="position()" format="1" />
			</td>
			<td>
				<xsl:value-of select="/n:npx/n:sammlungsobjekt[n:objId eq $objId]/n:verwaltendeInstitution"/>
			</td>
			<td>
				<xsl:value-of select="/n:npx/n:sammlungsobjekt[n:objId eq $objId]/n:identNr"/>
				<xsl:text> / </xsl:text>
				<xsl:value-of select="$objId"/>
			</td>
			<td>
				<xsl:value-of select="n:dateinameNeu"/>
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>	
