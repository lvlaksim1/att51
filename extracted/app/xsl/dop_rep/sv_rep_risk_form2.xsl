<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>План мероприятий по снижению уровней профессиональных рисков</title>
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

      td.red {
      background-color: #FFAAAA;
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

  <xsl:template match ="Document/risk_data">

  <p class="h1">
    ПЛАН<br/>мероприятий по снижению уровней профессиональных рисков<br/>на _______ год
  </p>
    <p class="org_name"><xsl:value-of select="@org_name"/></p>
    <p class="org_sign">(наименование организации)</p>
    

    <table>
      <tr>
        <td class="center" width="3%">№ п/п</td>
        <td class="center" width="7%">Номер РМ</td>
        <td class="center" width="15%">Наименование РМ</td>
        <td class="center" width="30%">Мероприятие</td>
        <td class="center" width="15%">Срочность проведения</td>
        <td class="center" width="15%">Ответственные</td>
        <td class="center" width="15%">Требуемый объем финансовых средств</td>
      </tr>
      <xsl:apply-templates select="PODR|row"/>
    </table>

    <xsl:apply-templates select="comission"/>
    </xsl:template>
  
  
  <xsl:template match ="row">
    <tr>
      <td align="center">
        <xsl:value-of select="count(preceding-sibling::row)+1"/>
      </td>
      <xsl:if test="@rowspan">
        <td align="center">
          <xsl:attribute name="rowspan">
            <xsl:value-of select="@rowspan"/>
          </xsl:attribute>
          <xsl:value-of select="@rm_num"/>
        </td>
        <td align="center">
          <xsl:attribute name="rowspan">
            <xsl:value-of select="@rowspan"/>
          </xsl:attribute>
          <xsl:value-of select="@rm_name"/>
        </td>
      </xsl:if>
      <td align="left">
        <xsl:value-of select="@measure"/>
      </td>
      <td align="center">
        <xsl:value-of select="@meas_srok"/>
      </td>
      <td align="center">
        <xsl:value-of select="@meas_otv"/>
      </td>
      <td align="center">
        <xsl:value-of select="@meas_money"/>
      </td>
   </tr>
  </xsl:template>

  <xsl:template match ="PODR">
    <tr>
      <td align="center" colspan="7">
        <b>
          <xsl:value-of select="@name"/>
        </b>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="comission">
    <table class="comission">
      <tr>
        <td class="left" colspan="7"><b>Комиссия по оценке уровней профессиональных рисков:</b></td>
      </tr>
      <xsl:apply-templates select="member"/>
    </table>
  </xsl:template>

  <xsl:template match ="member">
    <xsl:variable name="iRow" select="count(preceding-sibling::member)+1"/>
    <xsl:if test="$iRow='1'">
      <tr>
        <td class="left"  colspan="7">Председатель комиссии:</td>
      </tr>
    </xsl:if>
    <xsl:if test="$iRow='2'">
      <tr>
        <td class="left" colspan="7">Члены комиссии:</td>
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