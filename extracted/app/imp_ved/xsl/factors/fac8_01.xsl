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
    <h1>Форма "Сведения для протокола измерений параметров локальной вибрации"</h1>
    <p class="prim">
      <b>Рекомендации по заполнению:</b><br/>
      Формат даты - "дд.мм.гггг" (пример, 21.09.2021).<br/>
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
    


    <!-- Таблица 0801. А. Сведения об условиях ОС  -->
    <p class="t_name">
      А. Сведения об условиях ОС (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="4">
          <xsl:value-of select="@rm_guid"/>:0801
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
      <xsl:apply-templates select="t0801"/>
    </table>


    <!-- Таблица 0802. Б. Интервалы проведения измерений параметров инфразвука  -->
    <p class="t_name">
      Б. Интервалы проведения измерений параметров вибрации (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="3">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="6">
          <xsl:value-of select="@rm_guid"/>:0802
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray" rowspan="2">№<br/>m</td>
        <td width="15%" class="gray" rowspan="2">Рабочая операция</td>
        <td width="10%" class="gray" rowspan="2">Дата<br/>измерения</td>
        <td width="20%" class="gray" rowspan="2">Краткое описание операции (источников вибрации)</td>
        <td width="10%" class="gray" rowspan="2">Время операции</td>
        <td width="30%" class="gray" colspan="3">Результаты измерения по осям (L1;L2;L3;..)</td>
        <td width="10%" class="gray" rowspan="2">Длительность измерения, мин</td>
      </tr>
      <tr>
        <td width="10%" class="gray">X</td>
        <td width="10%" class="gray">Y</td>
        <td width="10%" class="gray">Z</td>
      </tr>
      <xsl:apply-templates select="t0802"/>
    </table>


    <!-- Таблица 0803. В. Результаты измерений уровня звука  -->
    <p class="t_name">
      В. Дополнительные сведения об условиях измерения (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2">
          <xsl:value-of select="@rm_guid"/>:0803
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray">
          №<br/>m
        </td>
        <td width="35%" class="gray">Место установки и ориентация акселерометров, методы крепления акселерометров</td>
        <td width="60%" class="gray">Дополнительные сведения о месте проведения измерения (при необходимости)</td>
      </tr>
      <xsl:apply-templates select="t0803"/>
    </table>
  </xsl:template>
 
  
  <xsl:template match ="t0801">
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

  <xsl:template match ="t0802">
    <tr>
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
        <xsl:value-of select="@descr"/>
      </td>
      <td>
        <xsl:value-of select="@z_time"/>
      </td>
      <td>
        <xsl:value-of select="@resX"/>
      </td>
      <td>
        <xsl:value-of select="@resY"/>
      </td>
      <td>
        <xsl:value-of select="@resZ"/>
      </td>
      <td>
        <xsl:value-of select="@z_izm_time"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t0803">
    <tr>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td>
        <xsl:value-of select="@descr1"/>
      </td>
      <td>
        <xsl:value-of select="@descr2"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
