<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем переменные -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:variable name="org_name">
    <xsl:value-of select="Document/@org_name"/>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Бланк-задание на проведение измерений</title>
    <style>
      /* Style Definitions */
      body
      {
      font-size:10.0pt;
      font-family: Times new roman, serif;
      text-align:left;
      }
      p.h1 {
      font-weight:bold;
      font-size:14.0pt;
      text-align:center;
      }
      p.h2 {
      font-weight:bold;
      font-size:12.0pt;
      text-align:left;
      margin-top:6pt;
      margin-bottom:6pt;
      }
      p.h3 {
      font-weight:bold;
      font-size:11.0pt;
      text-align:left;
      margin-top:0pt;
      margin-bottom:3pt;
      }
      p.space {
      font-size:8.0pt;
      margin-top:0pt;
      margin-bottom:0pt;
      }
      p.zone {
      margin-top:0pt;
      margin-bottom:0pt;
      }
      p.factor {
      font-weight:bold;
      font-size:11.0pt;
      text-align:left;
      margin-top:0pt;
      margin-bottom:0pt;
      }

      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
      td.center {
      text-align:center;
      }
      table.empty,table.empty th,table.empty td
      {
      border:none;
      background:none;
      padding:0 5px 0 5px;
      font-weight:bold;
      font-size:11.0pt;
      }
      td.h30 {
      height:30pt;
      }
      table.empty td.sign {
      border-bottom: 1px solid black;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <p class="h1" >Бланк-задание на проведение измерений</p>
    <xsl:apply-templates select="rm"/>
  </xsl:template>

 

  <xsl:template match ="rm">
    <table class="empty">
      <tr>
        <td width="20%">Наименование заказчика:</td>
        <td width="80%" class="sign">
          <xsl:value-of select="$org_name"/>
        </td>
      </tr>
      <tr>
        <td>Рабочее место:</td>
        <td class="sign">
          <xsl:value-of select="@rm_code"/>. <xsl:value-of select="@rm_name"/>
        </td>
      </tr>
      <tr>
        <td>Факторы:</td>
        <td class="sign">
          <xsl:apply-templates select="factor" mode="m2"/>
        </td>
      </tr>
    </table>
    <p class="space">
      &#160;
    </p>
    <!-- Сведения о рабочей зоне -->
    <xsl:apply-templates select="per_rzona"/>
    <!-- Сведения о сан-гиг. факторах -->
    <xsl:apply-templates select="factor" mode="m1"/>
    <!-- Тяжесть -->
    <xsl:apply-templates select="factor13"/>
    <!-- Напряженность -->
    <xsl:apply-templates select="factor14"/>
  </xsl:template>

  <xsl:template match ="factor14">
    <table width="100%">
      <tr>
        <td colspan="7">
          <b>Наименование фактора: Напряженность трудового процесса</b>
        </td>
      </tr>
      <tr>
        <td align="center" rowspan="2" width="30%">Параметр</td>
        <td align="center" rowspan="2" width="20%">Характеристика</td>
        <td align="center" colspan="5" width="50%">
          <b>Результаты измерений</b>
        </td>
      </tr>
      <tr>
        <td align="center" width="10%">
          <b>1</b>
        </td>
        <td align="center" width="10%">
          <b>2</b>
        </td>
        <td align="center" width="10%">
          <b>3</b>
        </td>
        <td align="center" width="10%">
          <b>4</b>
        </td>
        <td align="center" width="10%">
          <b>5</b>
        </td>
      </tr>
      <xsl:apply-templates select="param"  mode="m2"/>
      <!-- Пустые строки под Примечание-->
      <tr>
        <td colspan="7">Примечание:</td>
      </tr>
      <tr>
        <td colspan="7">
          &#160;
        </td>
      </tr>
      <tr>
        <td colspan="7">
          &#160;
        </td>
      </tr>
    </table>
    <p class="space">
      &#160;
    </p>
  </xsl:template>

  <xsl:template match ="factor13">
    <table width="100%">
      <tr>
        <td colspan="7">
          <b>Наименование фактора: Тяжесть трудового процесса</b>
        </td>
      </tr>
      <tr>
        <td align="center" rowspan="2" width="30%">Параметр</td>
        <td align="center" rowspan="2" width="20%">Характеристика</td>
        <td align="center" colspan="5" width="50%">
          <b>Результаты измерений</b>
        </td>
      </tr>
      <tr>
        <td align="center" width="10%">
          <b>1</b>
        </td>
        <td align="center" width="10%">
          <b>2</b>
        </td>
        <td align="center" width="10%">
          <b>3</b>
        </td>
        <td align="center" width="10%">
          <b>4</b>
        </td>
        <td align="center" width="10%">
          <b>5</b>
        </td>
      </tr>
      <xsl:apply-templates select="param"  mode="m2"/>
      <!-- Пустые строки под Примечание-->
      <tr>
        <td colspan="7">Примечание:</td>
      </tr>
      <tr>
        <td colspan="7">
          &#160;
        </td>
      </tr>
      <tr>
        <td colspan="7">
          &#160;
        </td>
      </tr>
    </table>
    <p class="space">
      &#160;
    </p>
  </xsl:template>

  <xsl:template match ="param" mode="m2">
    <tr>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td align="center">
        <xsl:value-of select="@char"/>
      </td>
      <td align="center">
        <xsl:value-of select="@fact1"/>
      </td>
      <td align="center">
        <xsl:value-of select="@fact2"/>
      </td>
      <td align="center">
        <xsl:value-of select="@fact3"/>
      </td>
      <td align="center">
        <xsl:value-of select="@fact4"/>
      </td>
      <td align="center">
        <xsl:value-of select="@fact5"/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="factor" mode="m2">
    <xsl:variable name="co_facs">
      <xsl:value-of select="count(preceding-sibling::factor)+1"/>
    </xsl:variable>
    <xsl:if test="$co_facs>1">, </xsl:if><xsl:value-of select="@name"/>
  </xsl:template>


  <xsl:template match="per_rzona">
    <table width="100%">
      <tr>
        <td align="center" rowspan="2" width="15%">Дата измерения</td>
        <td align="center" rowspan="2" width="45%">Рабочая зона (РЗ)</td>
        <td align="center" rowspan="2" width="8%">№ РЗ</td>
        <td align="center" colspan="4" width="32%">Условия измерений</td>
      </tr>
      <tr>
        <td align="center" width="8%">t, °С</td>
        <td align="center" width="8%">φ, %</td>
        <td align="center" width="8%">υ, м/с</td>
        <td align="center" width="8%">p, кПа</td>
      </tr>
      <xsl:apply-templates select="per_zone"/>
      <!-- пустые строки -->
      <tr>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
      </tr>
      <tr>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
      </tr>
      <tr>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
      </tr>
    </table>
    <p class="space">
      &#160;
    </p>
  </xsl:template>

  <xsl:template match ="per_zone">
    <tr>
      <td align="center">
        <xsl:value-of select="../../factor/@izm_date"/>
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td align="center">
        <xsl:value-of select="@num"/>
      </td>
      <td align="center">
        <xsl:value-of select="@os_temp"/>
      </td>
      <td align="center">
        <xsl:value-of select="@os_vlag"/>
      </td>
      <td align="center">
        <xsl:value-of select="@os_skor"/>
      </td>
      <td align="center">
        <xsl:value-of select="@os_patm"/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="factor" mode="m1">
    <table width="100%">
      <tr>
        <td colspan="8">
          <b>Наименование фактора: <xsl:value-of select="@name"/></b>
        </td>
      </tr>
      <tr>
        <td width="5%" rowspan="2" align="center">№ РЗ</td>
        <td width="25%" rowspan="2" align="center">Наименование операции/продолжительность</td>
        <td width="30%" rowspan="2" align="center">Источник, параметр</td>
        <td colspan="5" width="40%" align="center">
          Результаты измерений
        </td>
      </tr>
      <tr>
        <td align="center" width="8%">
          1
        </td>
        <td align="center" width="8%">
          2
        </td>
        <td align="center" width="8%">
          3
        </td>
        <td align="center" width="8%">
          4
        </td>
        <td align="center" width="8%">
          5
        </td>
      </tr>
      <xsl:apply-templates select="zone/param" mode="m1"/>
      <!-- Пустые строки-->
      <tr>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
      </tr>
      <tr>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
      </tr>
      <tr>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
        <td>&#160;</td>
      </tr>
      <!-- Пустые строки под Примечание-->
      <tr>
        <td colspan="8">Примечание:</td>
      </tr>
      <tr>
        <td colspan="8">
          &#160;
        </td>
      </tr>
      <tr>
        <td colspan="8">
          &#160;
        </td>
      </tr>
    </table>
    <p class="space">
      &#160;
    </p>
  </xsl:template>

  <xsl:template match ="param" mode="m1">
    <!--  Переменная z_time -->
    <xsl:variable name="z_time">
      <xsl:choose>
        <xsl:when test="@time!='' and @time!='-'">
          <xsl:value-of select="@time"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="../@time"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--  Переменная param_name -->
    <tr>
      <td align="center">
        <xsl:value-of select="../@num"/>
      </td>
      <td>
        <xsl:value-of select="../@name"/>, <xsl:value-of select="$z_time"/>%
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td align="center">
        <xsl:value-of select="@fact1"/>
      </td>
      <td align="center">
        <xsl:value-of select="@fact2"/>
      </td>
      <td align="center">
        <xsl:value-of select="@fact3"/>
      </td>
      <td align="center">
        <xsl:value-of select="@fact4"/>
      </td>
      <td align="center">
        <xsl:value-of select="@fact5"/>
      </td>
    </tr>
  </xsl:template>
  
</xsl:stylesheet>