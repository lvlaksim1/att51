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
      font-size:10.0pt;
      font-family: Times new roman, serif;
      text-align:left;
      }
      .h1 {
      font-weight:bold;
      font-size:14.0pt;
      text-align:center;
      }
      .header {
      font-size:12.0pt;
      text-align:center;
      margin-left:200pt;
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
    
  <table width="100%" class="comission" align="right">
    <tr>
      <td width="65%"></td>
      <td width="35%" class="center">
        УТВЕРЖДАЮ<br/>Руководитель организации
      </td>
    </tr>
    <tr>
      <td></td>
      <td class="sign2">
        <xsl:value-of select="@boss_fio"/>
      </td>
    </tr>
    <tr>
      <td></td>
      <td class="italic">(подпись, ФИО)</td>
    </tr>
    <tr>
      <td></td>
      <td class="sign2"></td>
    </tr>
    <tr>
      <td></td>
      <td class="italic">(дата)</td>
    </tr>
    </table>

  <table width="100%" class="comission">
    <tr>
      <td align="center" class="sign3">
        <xsl:value-of select="@name"/>
      </td>
    </tr>
    <tr>
      <td class="italic">(полное наименование организации)</td>
    </tr>
    <tr>
      <td align="center" class="sign3">
        <xsl:value-of select="@adr"/>
        <xsl:choose>
          <xsl:when test="@adr2 !=''">; <xsl:value-of select="@adr2"/></xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@phone !=''">; <xsl:value-of select="@phone"/></xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@fax !=''">; <xsl:value-of select="@fax"/></xsl:when>
        </xsl:choose>; <xsl:value-of select="@email"/>
      </td>
    </tr>
    <tr>
      <td class="italic">(адрес организации, тел., факс, адрес электронной почты)</td>
    </tr>
    </table>

  <table width="100%">
    <tr>
      <td class="center" width="20%">ИНН организации</td>
      <td class="center" width="20%">Код организации по ОКПО</td>
      <td class="center" width="20%">Код органа государственной власти по ОКОГУ</td>
      <td class="center" width="20%">Код вида экономической деятельности по ОКВЭД</td>
      <td class="center" width="20%">Код территории по ОКАТО</td>
    </tr>
    <tr>
      <td class="center">
        <xsl:value-of select="@inn"/>
      </td>
      <td class="center">
        <xsl:value-of select="@okpo"/>
      </td>
      <td class="center">
        <xsl:value-of select="@okogu"/>
      </td>
      <td class="center">
        <xsl:value-of select="@okved"/>
      </td>
      <td class="center">
        <xsl:value-of select="@okato"/>
      </td>
    </tr>
    </table>

  <p class="h1">Протокол утверждения результатов идентификации</p>


    <table>
      <tr>
        <td class="center" width="10%">№ п/п</td>
        <td class="center" width="15%">Код РМ</td>
        <td class="center" width="30%">Наименование подразделения, рабочего места (профессии или должности)</td>
        <td class="center" width="45%">Факторы, подлежащие оценке</td>
      </tr>
      <xsl:apply-templates select="PODR|RM"/>
    </table>
    
    <p>
      <xsl:text>&#160;</xsl:text>
    </p>
    <xsl:apply-templates select="comission"/>
    </xsl:template>
  
  
  <xsl:template match ="RM">
    <xsl:variable name="RowSpan" select="count(factor)"/>
    <tr>
      <td class="center">
        <xsl:value-of select="count(preceding-sibling::RM)+1"/>
      </td>
      <td class="center">
        <xsl:value-of select="@num"/>
      </td>
      <td class="center">
        <xsl:value-of select="@name"/>
      </td>
      <td class="center">
          <xsl:apply-templates select="factor"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="PODR">
    <tr>
      <td align="center" colspan="4">
        <b>
          <xsl:value-of select="@name"/>
        </b>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="factor[1]"><xsl:value-of select="@name"/></xsl:template>

  <xsl:template match ="factor">; <xsl:value-of select="@name"/></xsl:template>


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
      <td class="sign3" width="20%">
        <xsl:value-of select="@proff"/>
      </td>
      <td width="3%"></td>
      <td class="sign3" width="20%"></td>
      <td width="3%"></td>
      <td class="sign3" width="20%">
        <xsl:value-of select="@fio"/>
      </td>
      <td width="3%"></td>
      <td class="sign3" width="20%"></td>
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