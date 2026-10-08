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
        <xsl:apply-templates select="Document"/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <table width="100%">
      <tr>
        <td colspan="5" align="center">
          <xsl:value-of select="@org_name"/>
        </td>
      </tr>
      <tr>
        <td colspan="5" align="center">
          <sup>(полное наименование организации)</sup>
        </td>
      </tr>
      <tr>
        <td colspan="5" align="center">
          <xsl:value-of select="@adr"/>, <xsl:value-of select="@boss_fio"/>, <xsl:value-of select="@email"/>
        </td>
      </tr>
      <tr>
        <td colspan="5" align="center">
          <sup>(адрес места нахождения работодателя, фамилия, имя, отчество руководителя, адрес электронной почты)</sup>
        </td>
      </tr>
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
    <xsl:apply-templates select="risk_data"/>
  </xsl:template>
  
  <xsl:template match ="risk_data">

    <p class="h1">
    Перечень рабочих мест, на которых  будет проводиться идентификация и оценка профессиональных рисков
  </p>
   

    <table width="100%">
      <tr>
        <td class="center" width="10%">№<br/>п/п</td>
        <td class="center" width="15%">№ РМ</td>
        <td class="center" width="75%">Наименование РМ</td>
      </tr>
      <xsl:apply-templates select="PODR|row"/>
    </table>
    
    <p>&#xA0;</p>
    
    <xsl:apply-templates select="comission"/>
    </xsl:template>
  
  
  <xsl:template match ="row">
    <tr>
      <td align="center">
        <xsl:value-of select="count(preceding-sibling::row)+1"/>
      </td>
      <td align="center">
        <xsl:value-of select="@rm_num"/>
      </td>
      <td>
        <xsl:value-of select="@rm_name"/>
      </td>
   </tr>
  </xsl:template>

  <xsl:template match ="PODR">
    <tr>
      <td align="center" colspan="3">
        <b>
          <xsl:value-of select="@name"/>
        </b>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="comission">
    <table class="comission" width="100%">
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