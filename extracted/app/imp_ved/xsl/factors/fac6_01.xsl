<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения о рабочих местах</title>
    <style>
      /* Style Definitions */
      body {
      font-family:"Arial";
      }
      .rm_name
      {
      font-weight:bold;
      font-size:12.0pt;
      margin-top:6px;
      margin-bottom:3px;
      }

      .t_name
      {
      font-weight:bold;
      font-size:11.0pt;
      color: #777777;
      margin-top:3px;
      margin-bottom:0px;
      }
      .prim
      {
      font-size:9.0pt;
      font-family:"Times New Roman";
      }
      table
      {
      font-size:10.0pt;
      font-family:"Times New Roman";
      text-align:center;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
      }
      td.gray {
      background-color: #DDDDDD;
      }
      td.gray2 {
      background-color: #DDDDDD;
      color: #777777;
      }

    </style>	
  </head>
	<body>
    <h1>Форма "Сведения для протокола измерений параметров ультразвука"</h1>
    <p class="prim">
      <b>Рекомендации по заполнению:</b><br/>
      1. Формат даты - "дд.мм.гггг" (пример, 21.09.2021).<br/>
      2. Допустимые значения для среднегеометрическая частоты f, кГц: 12.5, 16, 20, 25, 31.5, 40, 50, 63, 80, 100.<br/>
      3. Допустимые значения для графы "Временная характеристика": 1 или 2 (1 - постоянный, 2 - импульсный).
    </p>
    <xsl:apply-templates/>
    <p/>
  </body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <xsl:apply-templates select="rm"/>
  </xsl:template>

  <xsl:template match ="podr">
    <p>
      <b><xsl:value-of select="@name"/></b>
    </p>
  </xsl:template>
  
  <xsl:template match ="rm">
    <p class="rm_name">
      <b><xsl:value-of select="@rm_code"/>. <xsl:value-of select="@rm_name"/></b>
    </p>
    


    <!-- Таблица 0601. А. Сведения об условиях ОС  -->
    <p class="t_name">
      А. Сведения об условиях ОС (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="4">
          <xsl:value-of select="@rm_guid"/>:0601
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray">№ зоны</td>
        <td width="55%" class="gray">Место измерения параметров ОС</td>
        <td width="10%" class="gray">t, ºC</td>
        <td width="10%" class="gray">p</td>
        <td width="10%" class="gray">υ, м/с</td>
        <td width="10%" class="gray">φ, %</td>
      </tr>
      <xsl:apply-templates select="t0601"/>
    </table>


    <!-- Таблица 0602. Б. Интервалы проведения измерений параметров ультразвука  -->
    <p class="t_name">
      Б. Интервалы и условия проведения измерений параметров ультразвука (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="5">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>:0602
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray">№<br/>п/п</td>
        <td width="5%" class="gray">f,<br/>кГц</td>
        <td width="5%" class="gray">№<br/>m</td>
        <td width="25%" class="gray">Место проведения измерения (рабочая операция)</td>
        <td width="10%" class="gray">Дата<br/>измерения</td>
        <td width="30%" class="gray">Краткое описание источников ультразвука</td>
        <td width="20%" class="gray">Положение микрофона</td>
      </tr>
      <xsl:apply-templates select="t0602"/>
    </table>


    <!-- Таблица 0603. В. Результаты прямых измерений и время воздействия на интервале измерения  -->
    <p class="t_name">
      В. Результаты прямых измерений и время воздействия на интервале измерения (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="4">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="3">
          <xsl:value-of select="@rm_guid"/>:0603
        </td>
      </tr>
      <tr>
        <td width="6%" class="gray">
          №<br/>п/п
        </td>
        <td width="8%" class="gray">
          f,<br/>кГц
        </td>
        <td width="6%" class="gray">
          №<br/>m
        </td>
        <td width="20%" class="gray">УЗД, дБ (L1; L2; L3;..)</td>
        <td width="20%" class="gray">Длительность i-го измерения, мин</td>
        <td width="20%" class="gray">Временная характеристика</td>
        <td width="20%" class="gray">Tm,i, мин</td>
      </tr>
      <xsl:apply-templates select="t0603"/>
    </table>
  </xsl:template>
 
  
  <xsl:template match ="t0601">
    <tr>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td align="left">
        <xsl:value-of select="@zona"/>
      </td>
      <td>
        <xsl:value-of select="@cond_t"/>
      </td>
      <td>
        <xsl:value-of select="@cond_p"/>
      </td>
      <td>
        <xsl:value-of select="@cond_sk"/>
      </td>
      <td>
        <xsl:value-of select="@cond_v"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t0602">
    <tr>
      <td>
        <xsl:value-of select="@num"/>
      </td>
      <td>
        <xsl:value-of select="@f_khz"/>
      </td>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td align="left">
        <xsl:value-of select="@zona"/>
      </td>
      <td>
        <xsl:value-of select="@izm_date"/>
      </td>
      <td>
        <xsl:value-of select="@descr1"/>
      </td>
      <td>
        <xsl:value-of select="@descr2"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t0603">
    <tr>
      <td>
        <xsl:value-of select="@num"/>
      </td>
      <td>
        <xsl:value-of select="@f_khz"/>
      </td>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td>
        <xsl:value-of select="@results"/>
      </td>
      <td>
        <xsl:value-of select="@z_izm_time"/>
      </td>
      <td>
        <xsl:value-of select="@z_char"/>
      </td>
      <td>
        <xsl:value-of select="@z_time"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
