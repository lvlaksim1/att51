<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения об оформленных картах СОУТ</title>
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

      p.org_name {
      font-size:12.0pt;
      font-weight:bold;
      text-align:center;
      margin-bottom:0pt;
      }

      p.org_sign {
      border-top: 1px solid black;
      text-align:center;
      margin-top:0pt;
      }

      .header {
      font-size:12.0pt;
      text-align:center;
      margin-left:200pt;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      font-size:9.0pt;
      }
      td.center {
      text-align:center;
      }
      .factor {
      font-size:9.0pt;
      }
      tr.param p {
      text-align:left;
      }
      tr.zone {
      font-style:italic;
      }
      td.sign {
      height:30pt;
      text-align:center;
      }

      span.err1 {
      background-color: #FFAAAA;
      }

      span.err2 {
      background-color: #FF6666;
      }

      table.comission,table.comission th,table.comission td
      {
      font-size:10.0pt;
      text-align:center;
      border:none;
      background:none;
      padding:0 5px 0 5px;
      }
      table.comission td.sign {
      border-bottom: 1px solid black;
      }
      table.comission td.sign2 {
      border-bottom: 1px solid black;
      text-align:right;
      margin-top:7pt;
      }
      table.comission td.sign3 {
      border-bottom: 1px solid black;
      text-align:center;
      margin-top:5pt;
      }
      table.comission td.left {
      text-align:left;
      }
      table.comission td.italic {
      font-size:8.0pt;
      font-style:italic;
      text-align:center;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
     <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="ORG">

  <p class="h1">
    Сведения об оформленных картах СОУТ
  </p>
    <p class="org_name"><xsl:value-of select="@name"/></p>
    <p class="org_sign">(наименование организации)</p>
    

    <table>
      <tr>
        <td class="center" width="5%">№ п/п</td>
        <td class="center" width="15%">Наименование РМ</td>
        <td class="center" width="10%">Номер карты</td>
        <td class="center" width="10%">Дата оформления</td>
        <td class="center" width="30%">Факторы, подлежащие исследованиям (испытаниям)</td>
        <td class="center" width="10%">Итоговый класс УТ</td>
        <td class="center" width="30%">Сведения об экспертах</td>
      </tr>
      <xsl:apply-templates select="RM"/>
    </table>
  </xsl:template>

  <xsl:template match ="RM">
    <tr>
      <td align="center">
        <xsl:value-of select="@num_pp"/>
      </td>
      <td align="center">
        <xsl:value-of select="@num"/>. <xsl:value-of select="@name"/>
      </td>
      <td align="center">
        <xsl:value-of select="@num_doc"/>
      </td>
      <td align="center">
        <xsl:value-of select="@fill_date"/>
      </td>
      <td align="center">
        <xsl:value-of select="@all_kuts"/>
      </td>
      <td align="center">
        <xsl:value-of select="@itog_kut"/>
      </td>
      <td align="center">
        <xsl:value-of select="@fios"/>
      </td>
    </tr>
  </xsl:template> 
  

  <xsl:template match ="izm_pers">
      <xsl:apply-templates select="fio"/>
  </xsl:template>

  <xsl:template match ="fio">
    <xsl:value-of select="@name"/>
    <br/>
  </xsl:template>


</xsl:stylesheet>