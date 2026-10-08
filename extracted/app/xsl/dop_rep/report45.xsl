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
    <p class="h1">Сводный отчет о средствах измерения, используемых в СОУТ</p>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="si_data">
    <p>
      Организация: <xsl:value-of select="@name"/>
    </p>
    <table>
      <tr>
        <td class="center" width="5%">№ п/п</td>
        <td class="center" width="27%">Наименование средства измерения</td>
        <td class="center" width="12%">Заводской номер</td>
        <td class="center" width="12%">№ свидетельства о поверке</td>
        <td class="center" width="12%">Действие поверки</td>
        <td class="center" width="12%">Погрешность СИ</td>
        <td class="center" width="20%">Условия эксплуатации СИ</td>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>
  <xsl:template match ="si">
    <tr>
      <td class="center">
        <xsl:value-of select="count(preceding-sibling::*)+1"/>
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td class="center">
        <xsl:value-of select="@fac_num"/>
      </td>
      <td class="center">
        <xsl:value-of select="@sertif"/>
      </td>
      <td class="center">
        <xsl:value-of select="@test"/>
      </td>
      <td>
        <xsl:value-of select="@si_err"/>
      </td>
      <td>
        <xsl:value-of select="@si_cond"/>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>