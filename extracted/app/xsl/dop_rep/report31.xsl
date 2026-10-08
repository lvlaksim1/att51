<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Отчет по оформленным документам</title>
    <style>
      /* Style Definitions */
      body
      {
      font-size:12.0pt;
      font-family: Times new roman, serif;
      text-align:left;
      }
      .h1 {
      font-weight:bold;
      font-size:14.0pt;
      text-align:center;
      }
      table,th,td {
      border:none;
      background:none;
      border-collapse:collapse;
      padding:0 5px 0 5px;
      }
      td.center {
      text-align:center;
      }
      tr.factor {
      font-weight: bold;
      }
      tr.param p {
      text-align:left;
      }
      tr.zone {
      font-style:italic;
      }
      td.sign {
      height:30pt;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <p class="h1">Отчет по оформленным протоколам</p>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="ORG">
    <p>
      Организация: <xsl:value-of select="@name"/>
    </p>
    <table>
      <tr>
        <td class="center" width="10%">№ п/п</td>
        <td class="center" width="75%">Наименование протокола (документа)</td>
        <td class="center" width="15%">Кол-во документов</td>
      </tr>
      <xsl:apply-templates select="doc"/>
    </table>
    </xsl:template>
  <xsl:template match ="doc">
    <tr>
      <td class="center">
        3.<xsl:value-of select="count(preceding-sibling::*)+1"/>
      </td>
      <td>
        <xsl:value-of select="@factor_name"/>
      </td>
      <td class="center">
        <xsl:value-of select="@co_docs"/>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>