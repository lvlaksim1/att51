<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения по организациям в базе РМ</title>
    <style>
      /* Style Definitions */
      body
      {
      font-size:12.0pt;
      font-family: Times new roman, serif;
      text-align:left;
      }
      table
      {
      font-size:9.0pt;
      text-align:center;
      }
      table.org
      {
      font-size:10.0pt;
      text-align:left;
      }

      .prim {
      font-size:10.0pt;
      }
      .h1 {
      font-weight:bold;
      font-size:14.0pt;
      text-align:center;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
      table.comission,table.comission th,table.comission td
      {
      font-size:12.0pt;
      text-align:center;
      border:none;
      background:none;
      padding:0 5px 0 5px;
      }
      td.center {
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
    <p align="right">Форма № 2</p>
    <p class="h1">Сведения о проведении специальной оценки условий труда в организациях</p>
    <p align="center">по состоянию на ____________ 20 _____ года</p>
    <table>
      <tr>
        <td rowspan="4" width="3%">№<br/>п/п</td>
        <td rowspan="4" width="20%">Наименование организации, в которой проведена специальная оценка условий труда за отчетный период</td>
        <td rowspan="4" width="20%">ОКВЭД,  юридический и фактический адрес</td>
        <td colspan="4" width="25%">Количество рабочих мест и численность работников, занятых на этих рабочих местах</td>
        <td colspan="14" width="20%">
          Количество рабочих мест и численность занятых на них работников по классам (подклассам) условий труда из числа рабочих мест&lt;*&gt;
        </td>
      </tr>
      <tr>
        <td rowspan="2" colspan="2">Всего</td>
        <td rowspan="2" colspan="2">в том числе на которых проведена СОУТ</td>
        <td rowspan="2" colspan="2">Класс 1</td>
        <td rowspan="2" colspan="2">Класс 2</td>
        <td colspan="8">Класс 3</td>
        <td rowspan="2" colspan="2">Класс 4</td>
      </tr>
      <tr>
        <td colspan="2">3.1</td>
        <td colspan="2">3.2</td>
        <td colspan="2">3.3</td>
        <td colspan="2">3.4</td>
      </tr>
      <tr>
        <td>РМ</td>
        <td>чел.</td>
        <td>РМ</td>
        <td>чел.</td>
        <td>РМ</td>
        <td>чел.</td>
        <td>РМ</td>
        <td>чел.</td>
        <td>РМ</td>
        <td>чел.</td>
        <td>РМ</td>
        <td>чел.</td>
        <td>РМ</td>
        <td>чел.</td>
        <td>РМ</td>
        <td>чел.</td>
        <td>РМ</td>
        <td>чел.</td>
      </tr>
      <xsl:apply-templates/>
      </table>
    <p>
    <span class="prim">
      &lt;*&gt; - В том числе рабочие места, в отношении которых оформлена декларация соответствия условий труда государственным нормативным требованиям охраны труда.
    </span>
    </p>
  </xsl:template>

  <xsl:template match ="ORG">
    <tr>
      <td>
        <xsl:value-of select="count(preceding-sibling::ORG)+1"/>
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@okved"/><br/><xsl:value-of select="@adr"/>
      </td>
      <td>
        <xsl:value-of select="@colrm"/>
      </td>
      <td>
        <xsl:value-of select="@colrab"/>
      </td>
      <td>
        <xsl:value-of select="@att_colrm"/>
      </td>
      <td>
        <xsl:value-of select="@att_colrab"/>
      </td>
      <td>
        <xsl:value-of select="@colrm1"/>
      </td>
      <td>
        <xsl:value-of select="@colrab1"/>
      </td>
      <td>
        <xsl:value-of select="@colrm2"/>
      </td>
      <td>
        <xsl:value-of select="@colrab2"/>
      </td>
      <td>
        <xsl:value-of select="@colrm31"/>
      </td>
      <td>
        <xsl:value-of select="@colrab31"/>
      </td>
      <td>
        <xsl:value-of select="@colrm32"/>
      </td>
      <td>
        <xsl:value-of select="@colrab32"/>
      </td>
      <td>
        <xsl:value-of select="@colrm33"/>
      </td>
      <td>
        <xsl:value-of select="@colrab33"/>
      </td>
      <td>
        <xsl:value-of select="@colrm34"/>
      </td>
      <td>
        <xsl:value-of select="@colrab34"/>
      </td>
      <td>
        <xsl:value-of select="@colrm4"/>
      </td>
      <td>
        <xsl:value-of select="@colrab4"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>