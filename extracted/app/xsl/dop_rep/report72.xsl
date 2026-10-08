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
      font-size:12.0pt;
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

    <p class="h1">
      ЛИСТ ОЗНАКОМЛЕНИЯ<br/>
      с результатами специальной оценки условий труда в<br/>
      <xsl:value-of select="@name"/>
    </p>
    <p>
      Идентификационный номер отчета о проведении СОУТ:<u>&#160;&#160;<xsl:value-of select="@sout_id"/>&#160;&#160;</u><br/>
      Дата утверждения отчета:<u>&#160;&#160;<xsl:value-of select="//Document/@cur_date"/>&#160;&#160;</u>
    </p>

    <table>
      <tr>
        <td class="center" width="5%">№ п/п</td>
        <td class="center" width="30%">ФИО работника</td>
        <td class="center" width="20%">Должность/профессия</td>
        <td class="center" width="15%">№ раб.места</td>
        <td class="center" width="15%">Дата ознакомления</td>
        <td class="center" width="15%">Подпись работника</td>
      </tr>
      <xsl:apply-templates select="row"/>
    </table>
    
    <p>
      <xsl:text>&#160;</xsl:text>
    </p>
    </xsl:template>
  
  
  <xsl:template match ="row">
    <xsl:variable name="num_p_p" select="count(preceding-sibling::row)+1"/>
    <tr>
      <td align="center">
        <xsl:value-of select="$num_p_p"/>
      </td>
      <td class="sign"></td>
      <td class="sign"></td>
      <td class="sign"></td>
      <td class="sign"></td>
      <td class="sign"></td>
    </tr>
  </xsl:template>




</xsl:stylesheet>