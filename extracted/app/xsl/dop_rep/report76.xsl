<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Опись документов по СОУТ</title>
    <style>
      /* Style Definitions */
      body
      {
      font-size:10.0pt;
      font-family: Times new roman, serif;
      text-align:left;
      }
      .h1 {
      font-weight:bold;
      font-size:14.0pt;
      text-align:center;
      }
      .h2 {
      font-weight:bold;
      font-size:12.0pt;
      text-align:left;
      }
      .normal
      {
      font-size:10.0pt;
      font-family:"Times New Roman";
      text-align:left;
      font-weight: normal;
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

      table.empty
      {
      margin-bottom:0cm;
      margin-top:0cm;
      }

      table.empty,table.empty th,table.empty td
      {
      font-size:9.0pt;
      text-align:center;
      border:none;
      background:none;
      padding:0 5px 0 5px;
      }
      table.empty td.sign {
      border-bottom: 1px solid black;
      }
      table.empty td.align_left {
      text-align:left;
      }

      td.gray {
      background-color: #DDDDDD;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <p class="h1">Отчет по параметрам окружающей среды</p>
    <p class="h2">
      Организация: <xsl:value-of select="ORG/@name"/>
    </p>
    <xsl:apply-templates select="OS_params"/>
    <p>
      <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
    </p>
  </xsl:template>

  <xsl:template match ="OS_params">
    <table width="100%">
      <tr>
        <td width="40%" align="center" class="gray">Рабочая зона</td>
        <td width="20%" align="center" class="gray">Температура воздуха, °C</td>
        <td width="20%" align="center" class="gray">Относительная влажность, %</td>
        <td width="20%" align="center" class="gray">Атмосферное давление, ед.изм.</td>
      </tr>
      <xsl:apply-templates select="param"/>
    </table>
  </xsl:template>

  <xsl:template match ="param">
    <tr>
      <td class="gray">
        <xsl:value-of select="@name"/>
      </td>
      <td align="center">
        <xsl:value-of select="@os_temp"/>
      </td>
      <td align="center">
        <xsl:value-of select="@os_vlag"/>
      </td>
      <td align="center">
        <xsl:value-of select="@os_patm"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>