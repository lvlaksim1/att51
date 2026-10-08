<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>ПРОТОКОЛ заседания комиссии по проверке знаний</title>
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
      .h2 {
      font-weight:bold;
      font-size:12.0pt;
      text-align:center;
      }
      p.razdel
      {
      font-size:11.0pt;
      font-weight: bold;
      margin-top:0.1cm;
      margin-bottom:0.1cm;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      font-size:10.0pt;
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

      .red {
      color: red;
      }

      table.empty
      {
      margin-bottom:0cm;
      margin-top:0cm;
      }

      table.empty,table.empty th,table.empty td
      {
      font-size:10.0pt;
      border:none;
      background:none;
      padding:0 5px 0 5px;
      }
      table.empty td.sign {
      border-bottom: 1px solid black;
      }

      table.empty td.sign2 {
      border-bottom: 1px solid black;
      font-size:12.0pt;
      }
      table.empty td.big_font {
      font-size:12.0pt;
      }

    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <p class="h1">
      ПРОТОКОЛ № <xsl:value-of select="@prot_num"/><br/>
      заседания комиссии по проверке знания требований охраны труда
    </p>
    <table class="empty" width="100%">
      <tr>
        <td class="sign2" align="center">
          <xsl:value-of select="@org_name"/>
        </td>
      </tr>
      <tr>
        <td align="center">
          <sup>(полное наименование организации)</sup>
        </td>
      </tr>
    </table>
    <p align="right">
      <xsl:value-of select="@prot_date2"/> г.
    </p>
    <p>В соответствии с приказом <xsl:value-of select="@boss_state2"/> (<xsl:value-of select="@boss_fio"/>) от <xsl:value-of select="@date_prikaz"/> г. № <xsl:value-of select="@num_prikaz"/> комиссия в составе:</p>
    <table class="empty" width="80%">
      <xsl:apply-templates select="comission/pers" mode="pred"/>
      <xsl:apply-templates select="comission/pers" mode="chlen"/>
    </table>
    <p>
      провела проверку знаний требований охраны труда работников по программе:
    </p>
    <table class="empty" width="100%">
      <tr>
        <td colspan="3" class="sign2" align="center">
          <xsl:value-of select="@lp_title"/>
        </td>
      </tr>
      <tr>
        <td colspan="3" align="center">
          <sup>(полное наименование организации)</sup>
        </td>
      </tr>
      <tr>
        <td width="20%" align="left" class="big_font">в объеме:</td>
        <td width="20%" class="sign2" align="center">
          <xsl:value-of select="@lp_hours"/>
        </td>
        <td width="60%"></td>
      </tr>
      <tr>
        <td></td>
        <td align="center">
          <sup>(количество часов)</sup>
        </td>
        <td></td>
      </tr>
    </table>
    <table width="100%">
      <tr>
        <td class="center" width="5%">№ п/п</td>
        <td class="center" width="15%">Ф.И.О.</td>
        <td class="center" width="10%">Профессия (должность)</td>
        <td class="center" width="20%">Место работы</td>
        <td class="center" width="15%">Результат проверки знания</td>
        <td class="center" width="10%">Дата проверки</td>
        <td class="center" width="15%">Регистрационный номер в реестре обученных</td>
        <td class="center" width="10%">Подпись проверяемого</td>
      </tr>
      <xsl:apply-templates select="Workers/Worker"/>
    </table>
    <!-- ПОДПИСИ -->
    <p>
      <xsl:text>&#160;</xsl:text>
    </p>
    <p>
      <xsl:text>&#160;</xsl:text>
    </p>
    <table class="empty" width="80%">
      <xsl:apply-templates select="comission/pers" mode="pred_sign"/>
      <xsl:apply-templates select="comission/pers" mode="chlen_sign"/>
      
    </table>

  </xsl:template>

  
  <xsl:template match ="Worker">
    <xsl:variable name="num" select="count(preceding-sibling::Worker)+1"/>
    <tr>
      <td align="center">
        <xsl:value-of select="$num"/>
      </td>
      <td align="center">
        <xsl:value-of select="@name_f"/><xsl:text> </xsl:text><xsl:value-of select="@name_i"/><xsl:text> </xsl:text><xsl:value-of select="@name_o"/>
      </td>
      <td align="center">
        <xsl:value-of select="@state"/>
      </td>
      <td align="center">
        <xsl:value-of select="@rbtd_name"/>
      </td>
      <td align="center">
        <xsl:value-of select="@result"/>
      </td>
      <td align="center">
        <xsl:value-of select="@check_date"/>
      </td>
      <td align="center">
        <xsl:value-of select="@reg_num"/>
      </td>
      <td></td>
    </tr>
  </xsl:template>
  
  
  <xsl:template match ="pers" mode="pred">
    <xsl:if test="@status=0">
      <tr>
        <td width="20%" align="left">Председателя:</td>
        <td class="sign" width="40%" align="center">
          <xsl:value-of select="@fio"/>
        </td>
        <td class="sign" width="40%" align="center">
          <xsl:value-of select="@state"/>
        </td>
      </tr>
      <tr>
        <td></td>
        <td align="center">
          <sup>(Ф.И.О.)</sup>
        </td>
        <td align="center">
          <sup>(должность)</sup>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  
  <xsl:template match ="pers" mode="chlen">
    <xsl:if test="@status=1">
      <xsl:variable name="co_pers" select="count(preceding-sibling::pers[@status=1])+1"/>
      <tr>
        <td width="20%" align="left">
          <xsl:if test="$co_pers=1">
            Членов:
          </xsl:if>
        </td>
        <td class="sign" width="40%" align="center">
          <xsl:value-of select="@fio"/>
        </td>
        <td class="sign" width="40%" align="center">
          <xsl:value-of select="@state"/>
        </td>
      </tr>
      <tr>
        <td></td>
        <td align="center">
          <sup>(Ф.И.О.)</sup>
        </td>
        <td align="center">
          <sup>(должность)</sup>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>


  <xsl:template match ="pers" mode="pred_sign">
    <xsl:if test="@status=0">
      <tr>
        <td width="35%" align="left" class="big_font">Председатель комиссии:</td>
        <td width="30%" class="sign"></td>
        <td width="35%" align="left" class="big_font">
          <xsl:value-of select="@fio"/>
        </td>
      </tr>
      <tr>
        <td></td>
        <td align="center">
          <sup>(подпись)</sup>
        </td>
        <td></td>
      </tr>
    </xsl:if>
  </xsl:template>


  <xsl:template match ="pers" mode="chlen_sign">
    <xsl:if test="@status=1">
      <xsl:variable name="co_pers" select="count(preceding-sibling::pers[@status=1])+1"/>
      <tr>
        <td width="35%" align="left" class="big_font">
          <xsl:if test="$co_pers=1">
            Члены комиссии:
          </xsl:if>
        </td>
        <td width="30%" class="sign"></td>
        <td width="35%" align="left" class="big_font">
          <xsl:value-of select="@fio"/>
        </td>
      </tr>
      <tr>
        <td></td>
        <td align="center">
          <sup>(подпись)</sup>
        </td>
        <td></td>
      </tr>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>