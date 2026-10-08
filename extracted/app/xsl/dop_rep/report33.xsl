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
      .prim {
      font-size:10.0pt;
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
    <p class="h1">Сведения по организациям в базе РМ</p>
    <table>
      <tr>
        <td rowspan="2" width="5%">№<br/>п/п</td>
        <td rowspan="2" width="20%">Название организации</td>
        <td rowspan="2" width="25%">Адрес организации</td>
        <td rowspan="2" width="15%">Ф.И.О руководителя</td>
        <td rowspan="2" width="15%">Контактная информация</td>
        <td colspan="2" width="20%">Количество рабочих мест</td>
      </tr>
      <tr>
        <td width="5%">Всего</td>
        <td width="15%">в том числе на которых проведена СОУТ</td>
      </tr>
      <xsl:apply-templates/>
      </table>
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
        <xsl:value-of select="@adr"/>
      </td>
      <td>
        <xsl:value-of select="@fio"/>
      </td>
      <td>
        <xsl:value-of select="@contacts"/>
      </td>
      <td>
        <xsl:value-of select="@colrm"/>
      </td>
      <td>
        <xsl:value-of select="@att_colrm"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>