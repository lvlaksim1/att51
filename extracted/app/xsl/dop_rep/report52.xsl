<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сводная таблица по компенсациям за вредные условия труда</title>
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
    Отчет "Проверка корректности СНИЛС"
  </p>
    <p class="org_name"><xsl:value-of select="@name"/></p>
    <p class="org_sign">(наименование организации)</p>
    

    <table>
      <tr>
        <td class="center" width="5%">№ п/п</td>
        <td class="center" width="10%">Номер РМ</td>
        <td class="center" width="25%">Наименование рабочего места</td>
        <td class="center" width="60%">СНИЛС</td>
      </tr>
      <xsl:apply-templates select="RM"/>
    </table>
    
    <p>
      Примечание: цветом выделены СНИЛС, в которых имеется нарушение шаблона СНИЛС (светло красный цвет) и не пройдена проверка по контрольной сумме (темно красный цвет).
      Значение "Отсутствует" удовлетворяет шаблону ФГИС СОУТ и не проходит проверку по контрольной сумме.
    </p>
    <!-->xsl:apply-templates select="comission"/-->
    </xsl:template>
  
  
  <xsl:template match ="RM">
    <xsl:variable name="RowSpan" select="count(factor)"/>
    <tr>
      <td align="center">
        <xsl:value-of select="count(preceding-sibling::RM)+1"/>
      </td>
      <td align="center">
        <xsl:value-of select="@num"/>
      </td>
      <td align="center">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:apply-templates select="snils"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="snils">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <xsl:value-of select="@value"/>
    </span>; 
  </xsl:template>
  
  <xsl:template match ="PODR">
    <tr>
      <td align="center" colspan="15">
        <b>
          <xsl:value-of select="@value"/>
        </b>
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