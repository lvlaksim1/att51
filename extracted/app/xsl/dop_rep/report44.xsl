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
      font-size:16.0pt;
      text-align:center;
      }
      .h2 {
      margin-top:10px;
      font-weight:bold;
      font-size:14.0pt;
      text-align:center;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
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
      td.red {
      color: red;
      }

    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <p class="h1">Отчет о нормативных документах (на основе протоколов)</p>
    <xsl:apply-templates select="dist_nd_data"/>
    <xsl:apply-templates select="nd_data"/>
  </xsl:template>
  
  <xsl:template match ="nd_data">
    <p class="h2">Распределение НД по протоколам</p>
    <table>
      <tr>
        <td class="center" width="15%">№ протокола</td>
        <td class="center" width="15%">Фактор</td>
        <td class="center" width="70%">Нормативный документ</td>
      </tr>
      <xsl:apply-templates select="prot"/>
    </table>
  </xsl:template>
  
  <xsl:template match ="prot">
    <xsl:variable name="RowSpan" select="count(persons/pers)+1"/>
    <tr>
      <td align="center">
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="@num_prot"/>
      </td>
      <td align="center">
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="@factor"/>
      </td>
      <td align="left">
        <xsl:apply-templates select="nd_data/nd" />
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="nd">
      <p align="left">
        <xsl:value-of select="@name"/>
      </p>
  </xsl:template>


  <xsl:template match ="dist_nd_data">
    <p>Перечень используемых НД в организации "<b><xsl:value-of select="@name"/>"</b>:</p>
    <xsl:apply-templates select="dist_nd" />
  </xsl:template>


  <xsl:template match ="dist_nd">
      <xsl:value-of select="@name"/><br/>
  </xsl:template>


</xsl:stylesheet>