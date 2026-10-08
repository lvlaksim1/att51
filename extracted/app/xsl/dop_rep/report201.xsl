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
    ПЕРЕЧЕНЬ РАБОЧИХ ЗОН<br/>
    подлежащих специальной оценке условий труда по договору №<xsl:text>&#160;&#160;&#160;&#160;&#160;&#160;</xsl:text>от
    <xsl:text>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;</xsl:text>202__ г.
  </p>
    <p class="org_name"><xsl:value-of select="@name"/></p>
    <p class="org_sign">(наименование организации)</p>
    

    <table>
      <tr>
        <td rowspan="3" class="center" width="5%">№ п/п</td>
        <td rowspan="3" class="center" width="10%">Наименование РМ</td>
        <td rowspan="3" class="center" width="15%">Обрудование</td>
        <td rowspan="3" class="center" width="15%">Рабочая зона</td>
        <td rowspan="3" class="center" width="5%">Время, %</td>
        <td colspan="14" class="center" width="50%">Значения</td>
      </tr>
      <tr>
        <td colspan="2"></td>
        <td colspan="2"></td>
        <td colspan="2"></td>
        <td colspan="2"></td>
        <td colspan="2"></td>
        <td colspan="2"></td>
        <td colspan="2"></td>
      </tr>
      <tr>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
      <xsl:apply-templates select="RM"/>
    </table>
  </xsl:template>

  <xsl:template match ="RM">
    <xsl:variable name="RowSpan" select="count(zones/zone)"/>
    <tr>
      <td align="center">
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="count(preceding-sibling::RM)+1"/>
      </td>
      <td align="center">
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="@num"/>. <xsl:value-of select="@name"/>
      </td>
      <td align="center">
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="@oborud"/>
      </td>
      <td align="center">
        <xsl:value-of select="zones/zone[@num='1']/@name"/>
      </td>
      <td align="center">
        <xsl:value-of select="zones/zone[@num='1']/@time"/>
      </td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <xsl:apply-templates select="zones/zone"/>
  </xsl:template>


  <xsl:template match ="zone[@num!='1']">
    <tr>
      <td align="center">
        <xsl:value-of select="@name"/>
      </td>
      <td align="center">
        <xsl:value-of select="@time"/>
      </td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  </xsl:template>



</xsl:stylesheet>