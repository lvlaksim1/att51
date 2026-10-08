<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сокращенный перечень РМ</title>
    <style>
      /* Style Definitions */
      body
      {
      font-size:11.0pt;
      font-family: Times new roman, serif;
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

      table.comission,table.comission th,table.comission td
      {
      font-size:12.0pt;
      text-align:center;
      border:none;
      background:none;
      padding:0 5px 0 5px;
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
    <p class="h1">Перечень вредных и (или) опасных производственных факторов, подлежащих исследованиям (испытаниям) и измерениям</p>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="ORG">
    <p>
      Организация: <xsl:value-of select="@name"/>
    </p>
    <table>
      <tr>
        <td class="center" width="10%">№ п/п</td>
        <td class="center" width="15%">Код РМ</td>
        <td class="center" width="35%">Наименование подразделения, рабочего места (профессии или должности)</td>
        <td class="center" width="30%">Фактор</td>
        <td class="center" width="10%">Время, %</td>
      </tr>
      <xsl:apply-templates select="RM"/>
    </table>
    <p/>
    <xsl:apply-templates select="comission"/>
    </xsl:template>
  <xsl:template match ="RM">
    <xsl:variable name="RowSpan" select="count(factor)"/>
    <tr>
      <td class="center">
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="count(preceding-sibling::RM)+1"/>
      </td>
      <td class="center">
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="@num"/>
      </td>
      <td class="center">
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="@name"/>
      </td>
      <xsl:apply-templates select="factor[1]"  />
    </tr>
    <xsl:apply-templates select="factor[position()>1]"  />
  </xsl:template>

  <xsl:template match ="PODR">
    <tr>
      <td align="center" colspan="5">
        <b>
          <xsl:value-of select="@name"/>
        </b>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="factor[1]">
    <td class="factor">
        <xsl:value-of select="@name"/>
      </td>
    <td class="factor" align="center">
        <xsl:value-of select="@time"/>
      </td>
  </xsl:template>

  <xsl:template match ="factor">
    <tr class="factor">
      <td>
          <xsl:value-of select="@name"/>
      </td>
      <td align="center">
          <xsl:value-of select="@time"/>
      </td>
    </tr>
  </xsl:template>


  <xsl:template match ="comission">
    <table class="comission">
      <xsl:apply-templates select="member"/>
    </table>
  </xsl:template>

  <xsl:template match ="member">
    <xsl:variable name="iRow" select="count(preceding-sibling::member)+1"/>
    <xsl:if test="$iRow='1'">
      <tr>
        <td class="left"  colspan="7">Председатель комиссии по проведению специальной оценки условий труда:</td>
      </tr>
    </xsl:if>
    <xsl:if test="$iRow='2'">
      <tr>
        <td class="left" colspan="7">Члены комиссии по проведению специальной оценки условий труда:</td>
      </tr>
    </xsl:if>
    <tr>
      <td class="sign" width="20%">
        <xsl:value-of select="@proff"/>
      </td>
      <td width="3%"></td>
      <td class="sign" width="20%"></td>
      <td width="3%"></td>
      <td class="sign" width="20%">
        <xsl:value-of select="@fio"/>
      </td>
      <td width="3%"></td>
      <td class="sign" width="20%"></td>
    </tr>
    <tr>
      <td width="20%">
        <sup>(должность)</sup>
      </td>
      <td width="3%"></td>
      <td width="20%">
        <sup>(подпись)</sup>
      </td>
      <td width="3%"></td>
      <td width="20%">
        <sup>Ф.И.О.</sup>
      </td>
      <td width="3%"></td>
      <td width="20%">
        <sup>(дата)</sup>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>