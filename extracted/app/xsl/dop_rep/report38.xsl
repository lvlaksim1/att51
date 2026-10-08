<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения об организации, в которой проводится СОУТ</title>
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
      font-size:10.0pt;
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
      td.rotate {
      mso-rotate:90;
      font-size:7.0pt;
      height:80pt;
      }
      table.comission td.sign {
      border-bottom: 1px solid black;
      }
      table.comission td.left {
      text-align:left;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <p class="h1">Отчет по оформленным документам (форма 2)</p>
    <table>
      <tr>
        <td width="20%">Индиви­дуальный номер рабочего места</td>
        <td width="20%">Профессия/должность/специальность работника</td>
        <td width="20%">Карта, фактор</td>
        <td width="20%">Количество протоколов</td>
        <td width="20%">Количество рабочих зон (на основе протоколов)</td>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="PODR_">
    <tr>
      <td colspan="5">
        <xsl:value-of select="@name"/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="RM">
    <tr>
      <td>
        <xsl:attribute name="rowspan">
          <xsl:value-of select="count(doc)+1"/>
        </xsl:attribute>
        <xsl:value-of select="@num"/>
      </td>
      <td>
        <xsl:attribute name="rowspan">
          <xsl:value-of select="count(doc)+1"/>
        </xsl:attribute>
        <xsl:value-of select="@name"/>
      </td>
      <td>Карта СОУТ</td>
      <td>
        <xsl:value-of select="@co_cards"/>
      </td>
      <td>-</td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="doc">
    <tr>
      <td>
        <xsl:value-of select="@factor_name"/>
      </td>
      <td>1</td>
      <td>
        <xsl:value-of select="@co_zones"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>