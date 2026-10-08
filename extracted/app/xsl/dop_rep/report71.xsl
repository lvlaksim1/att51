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

  <p class="h1">Перечень рабочих мест, на которых  будет проводиться специальная оценка условий труда</p>


    <table>
      <tr>
        <td class="center" width="5%">№ п/п</td>
        <td class="center" width="7%">Код (№) РМ</td>
        <td class="center" width="20%">Наименование РМ</td>
        <td class="center" width="10%">Количество  работников, занятых на данном РМ (чел.)</td>
        <td class="center" width="8%">Код по ОК 016-94</td>
        <td class="center" width="10%">Досрочное назначение  трудовой  пенсии по старости</td>
        <td class="center" width="10%">Сокращенная продолжительность рабочего времени</td>
        <td class="center" width="10%">Дополнительный отпуск</td>
        <td class="center" width="10%">Повышенная оплата труда</td>
      </tr>
      <xsl:apply-templates select="PODR|RM"/>
    </table>
    
    <p>
      <xsl:text>&#160;</xsl:text>
    </p>
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
        <xsl:value-of select="@colrab_rm"/>
      </td>
      <td class="center">
        <xsl:value-of select="@codeok"/>
      </td>
      <td class="center">
        <xsl:value-of select="@lpo"/>
      </td>
      <td class="center">
        <xsl:value-of select="@week"/>
      </td>
      <td class="center">
        <xsl:value-of select="@dop_otpusk"/>
      </td>
      <td class="center">
        <xsl:value-of select="@dopl"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="PODR">
    <tr>
      <td align="center" colspan="9">
        <b>
          <xsl:value-of select="@name"/>
        </b>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="factor[1]"><xsl:value-of select="@name"/></xsl:template>

  <xsl:template match ="factor">; <xsl:value-of select="@name"/></xsl:template>



</xsl:stylesheet>