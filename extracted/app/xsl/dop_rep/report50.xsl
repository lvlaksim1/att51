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
      tr.bold {
      font-weight:bold;
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
        <td rowspan="3" width="3%">№<br/>п/п</td>
        <td rowspan="3" width="20%">Наименование организации, в которой проведена специальная оценка условий труда за отчетный период</td>
        <td rowspan="3" width="27%">ОКВЭД,  юридический и фактический адрес</td>
        <td colspan="4" width="15%">Количество рабочих мест и численность работников, занятых на этих рабочих местах</td>
        <td rowspan="2" colspan="2" width="15%">Декларирование соответствия условий труда</td>
        <td colspan="7" width="30%">
          Количество рабочих мест и численность занятых на них работников по классам (подклассам) условий труда из числа рабочих мест;
        </td>
      </tr>
      <tr>
        <td colspan="2" >Всего</td>
        <td colspan="2" >в том числе на которых проведена СОУТ</td>
        <td rowspan="2" width="5%">Класс 1</td>
        <td rowspan="2" width="5%">Класс 2</td>
        <td colspan="4" width="15%">Класс 3</td>
        <td rowspan="2" width="5%">Класс 4</td>
      </tr>
      <tr>
        <td>РМ</td>
        <td>чел</td>
        <td>РМ</td>
        <td>чел</td>
        <td>РМ</td>
        <td>чел</td>
        <td>3.1</td>
        <td>3.2</td>
        <td>3.3</td>
        <td>3.4</td>
      </tr>
      <tr class="bold">
        <td>1</td>
        <td>2</td>
        <td>3</td>
        <td colspan="2">4</td>
        <td colspan="2">5</td>
        <td colspan="2">6</td>
        <td>7</td>
        <td>8</td>
        <td>9</td>
        <td>10</td>
        <td>11</td>
        <td>12</td>
        <td>13</td>
      </tr>
      <xsl:apply-templates/>
      </table>
    <p>
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
      <!--Декларирование-->
      <td><xsl:value-of select="@colrm_decl"/></td>
      <td>
        <xsl:value-of select="@colrab_decl"/>
      </td>
      <td>
        <xsl:value-of select="@colrm1"/>/<xsl:value-of select="@colrab1"/>
      </td>
      <td>
        <xsl:value-of select="@colrm2"/>/<xsl:value-of select="@colrab2"/>
      </td>
      <td>
        <xsl:value-of select="@colrm31"/>/<xsl:value-of select="@colrab31"/>
      </td>
      <td>
        <xsl:value-of select="@colrm32"/>/<xsl:value-of select="@colrab32"/>
      </td>
      <td>
        <xsl:value-of select="@colrm33"/>/<xsl:value-of select="@colrab33"/>
      </td>
      <td>
        <xsl:value-of select="@colrm34"/>/<xsl:value-of select="@colrab34"/>
      </td>
      <td>
        <xsl:value-of select="@colrm4"/>/<xsl:value-of select="@colrab4"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>