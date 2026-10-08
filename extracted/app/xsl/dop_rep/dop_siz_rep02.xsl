<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем tab-символ -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Лист выдачи оборудования</title>
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
      font-size:16.0pt;
      text-align:center;
      }
      .h2 {
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
      tr.factor {
      font-weight: bold;
      }
      tr.param p {
      text-align:left;
      }
      tr.zone {
      font-style:italic;
      }
      td.sign {
      height:30pt;
      }
      td.red {
      color: red;
      }
      table.empty
      {
      margin-bottom:0cm;
      margin-top:0cm;
      }

      table.empty,table.empty th,table.empty td
      {
      font-size:12.0pt;
      border:none;
      background:none;
      padding:0 5px 0 5px;
      }
      td.fix {
      height:50px;
      }

    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <p class="h1">КАРТОЧКА ДВИЖЕНИЯ СРЕДСТВ ИЗМЕРЕНИЙ, ВСПОМОГАТЕЛЬНОГО ОБОРУДОВАНИЯ</p>
    <xsl:apply-templates select="si_data"/>
  </xsl:template>

  <xsl:template match ="si_data">
    <table>
      <tr>
        <td class="center" width="5%">№ п/п</td>
        <td class="center" width="75%">Наименование оборудования</td>
        <td class="center" width="20%">Заводской номер</td>
      </tr>
      <xsl:apply-templates select="si"/>
    </table>
    <!-- пустая строка -->
    <p>&#160;</p>
    <!-- подписи -->
    <table width="100%">
      <tr>
        <td width="25%">Дата выдачи</td>
        <td width="75%" colspan="3">
          <xsl:value-of select="@min_date"/>
        </td>
      </tr>
      <tr>
        <td class="fix">Выдал</td>
        <td width="25%">
          <xsl:value-of select="@boss_state"/>
        </td>
        <td width="25%">
          <xsl:value-of select="@boss_fio"/>
        </td>
        <td width="25%"></td>
      </tr>
      <tr>
        <td class="fix">Получил</td>
        <td>
          <xsl:apply-templates select="//Document/persons/pers" mode="state"/>
        </td>
        <td>
          <xsl:apply-templates select="//Document/persons/pers" mode="fio"/>
        </td>
        <td></td>
      </tr>
      <tr>
        <td>Дата возврата</td>
        <td colspan="3">
          <xsl:value-of select="@max_date"/>
        </td>
      </tr>
      <tr>
        <td class="fix">Сдал</td>
        <td>
          <xsl:apply-templates select="//Document/persons/pers" mode="state"/>
        </td>
        <td>
          <xsl:apply-templates select="//Document/persons/pers" mode="fio"/>
        </td>
        <td></td>
      </tr>
      <tr>
        <td class="fix">Получил</td>
        <td>
          <xsl:value-of select="@boss_state"/>
        </td>
        <td>
          <xsl:value-of select="@boss_fio"/>
        </td>
        <td></td>
      </tr>
   </table>
  </xsl:template>
  
  <xsl:template match ="pers" mode="fio">
    <xsl:variable name="pers_num">
      <xsl:value-of select="count(preceding-sibling::*)+1"/>
    </xsl:variable>
    <xsl:if test="$pers_num=1"><xsl:value-of select="@fio"/></xsl:if>
    <xsl:if test="$pers_num>1">
      <br/>
      <xsl:value-of select="@fio"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match ="pers" mode="state">
    <xsl:variable name="pers_num">
      <xsl:value-of select="count(preceding-sibling::*)+1"/>
    </xsl:variable>
    <xsl:if test="$pers_num=1"><xsl:value-of select="@state"/></xsl:if>
    <xsl:if test="$pers_num>1">
      <br/>
      <xsl:value-of select="@state"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match ="si">
    <tr>
      <td class="center">
        <xsl:value-of select="count(preceding-sibling::*)+1"/>
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td align="center">
        <xsl:value-of select="@fac_num"/>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>