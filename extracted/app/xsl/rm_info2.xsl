<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип предписания -->
  
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения о рабочих местах</title>
    <style>
      /* Style Definitions */
      table
      {
      font-size:10.0pt;
      font-family:"Times New Roman";
      text-align:center;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <table>
      <tr>
        <td width="8%">Индивидуальный номер рабочего места</td>
        <td width="20%">Профессия/должность/специальность работника</td>
        <td width="8%">Код по<br/>ОК 016-94</td>
        <td width="8%">Численность<br/>работников</td>
        <td width="8%">СНИЛС работников</td>
        <td width="20%">Основание для формирования прав на досрочную трудовую пенсию по старости (при наличии)</td>
        <td width="10%">Наличие<br/>профзаболеваний (за 5 лет)</td>
        <td width="10%">Наличие случаев травматизма (за 5 лет)</td>
        <td width="8%">Примечание</td>
      </tr>
        <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="row">
    <tr>
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      <td>
        <xsl:value-of select="@cell1"/>
      </td>
      <td>
        <xsl:value-of select="@cell2"/>
      </td>
      <td>
        <xsl:value-of select="@cell3"/>
      </td>
      <td>
        <xsl:value-of select="@cell4"/>
      </td>
      <td>
        <xsl:value-of select="@cell5"/>
      </td>
      <td>
        <xsl:value-of select="@cell6"/>
      </td>
      <td>
        <xsl:value-of select="@cell7"/>
      </td>
      <td>
        <xsl:value-of select="@cell8"/>
      </td>
      <td>
        <xsl:value-of select="@cell9"/>
      </td>
    </tr>
  </xsl:template>
  
  

</xsl:stylesheet>