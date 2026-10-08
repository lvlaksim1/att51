<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Заготовка по факторам, подлежащим оценке (сгруппированная по рабочим зонам)</title>
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

      td {
      height: 30pt;
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
     <xsl:apply-templates select="ORG"/>
    <table>
      <tr>
        <td class="center" width="5%">№ п/п</td>
        <td class="center" width="15%">Рабочая зона</td>
        <td class="center" width="10%">
          Рабочие места (время пребывания)
        </td>
        <td class="center" width="10%">Условия ОС и доп.сведения</td>
        <td class="center" width="15%">Фактор</td>
        <td class="center" width="45%">Результат измерения</td>
      </tr>
      <xsl:apply-templates select="zone"/>
    </table>
  </xsl:template>

  <xsl:template match ="ORG">

  <p class="h1">
    Заготовка по факторам, подлежащим оценке (сгруппированная по рабочим зонам)
  </p>
    <p class="org_name"><xsl:value-of select="@name"/></p>
    <p class="org_sign">(наименование организации)</p>
  </xsl:template>


  <xsl:template match ="zone">
    <xsl:variable name="RowSpan" select="count(factors/fac)"/>
    <tr>
      <td align="center">
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="count(preceding-sibling::zone)+1"/>
      </td>
      <td>
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:apply-templates select="rms/rm"/>
      </td>
      <td>
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
      </td>
      <td>
        <xsl:value-of select="factors/fac[@num='1']/@name"/>
      </td>
      <td></td>
    </tr>
    <xsl:apply-templates select="factors/fac"/>
  </xsl:template>

  <xsl:template match ="rm">
    <xsl:value-of select="@name2"/> (<xsl:value-of select="@time"/> %);<br/>
  </xsl:template>

  <xsl:template match ="fac[@num!='1']">
    <tr>
      <td>
        <xsl:value-of select="@name"/>
      </td>
    <td></td>
    </tr>
  </xsl:template>


</xsl:stylesheet>