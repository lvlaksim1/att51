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
    <h1>Форма "Сведения для протокола измерений параметров инфразвука"</h1>
    <p class="prim">
      <b>Рекомендации по заполнению:</b><br/>
      1. Формат даты - "дд.мм.гггг" (пример, 21.09.2021).<br/>
      2. В таблице "Дополнительные сведения об условиях измерения" допускается установка прочерка с заполнением одной строки. Прочерк обозначает, что сведения применимы для всех интервалов измерения.
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
    


    <!-- Таблица 0501. А. Сведения об условиях ОС  -->
    <p class="t_name">
      А. Сведения об условиях ОС (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="4">
          <xsl:value-of select="@rm_guid"/>:0501
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
      <xsl:apply-templates select="t0501"/>
    </table>


    <!-- Таблица 0502. Б1. Интервалы проведения измерений параметров инфразвука  -->
    <p class="t_name">
      Б1. Интервалы проведения измерений параметров инфразвука (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="3">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="4">
          <xsl:value-of select="@rm_guid"/>:0502
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray">№<br/>m</td>
        <td width="20%" class="gray">Место проведения измерения (рабочая операция)</td>
        <td width="10%" class="gray">Дата<br/>измерения</td>
        <td width="20%" class="gray">Краткое описание источников инфразвука</td>
        <td width="15%" class="gray">
          Общий уровень звукового давления, дБ<br/>
          (L<sub>1</sub>; L<sub>2</sub>; L<sub>3</sub>;..)
        </td>
        <td width="15%" class="gray">Длительность i-го измерения, мин</td>
        <td width="15%" class="gray">
          Время операции<br/>Tm,i, мин</td>
      </tr>
      <xsl:apply-templates select="t0502" mode="m1"/>
    </table>

    <!-- Таблица 0502-2. Б2. УЗД инфразвука в октавных полосах частот (Гц), дБ  -->
    <p class="t_name">
      Б2. УЗД инфразвука в октавных полосах частот (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="3">
          <xsl:value-of select="@rm_guid"/>:0502_2
        </td>
      </tr>
      <tr>
        <td width="8%" class="gray" rowspan="2">№<br/>m</td>
        <td width="92%" class="gray" colspan="4">УЗД инфразвука в октавных полосах частот (Гц), дБ</td>
      </tr>
      <tr>
        <td class="gray" width="23%">2</td>
        <td class="gray" width="23%">4</td>
        <td class="gray" width="23%">8</td>
        <td class="gray" width="23%">16</td>
      </tr>
      <xsl:apply-templates select="t0502" mode="m2"/>
    </table>


    <!-- Таблица 0503. В. Результаты измерений уровня звука  -->
    <p class="t_name">
      В. Дополнительные сведения об условиях измерения (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2">
          <xsl:value-of select="@rm_guid"/>:0503
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray">
          №<br/>m
        </td>
        <td width="35%" class="gray">Положение микрофона</td>
        <td width="60%" class="gray">
          Дополнительные сведения об условиях измерения<br/>(при необходимости)
        </td>
      </tr>
      <xsl:apply-templates select="t0503"/>
    </table>
  </xsl:template>
 
  
  <xsl:template match ="t0501">
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

  <xsl:template match ="t0502" mode="m1">
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
        <xsl:value-of select="@results"/>
      </td>
      <td>
        <xsl:value-of select="@z_izm_time"/>
      </td>
      <td>
        <xsl:value-of select="@z_time"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t0502" mode="m2">
    <tr>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td>
        <xsl:value-of select="@okt2"/>
      </td>
      <td>
        <xsl:value-of select="@okt4"/>
      </td>
      <td>
        <xsl:value-of select="@okt8"/>
      </td>
      <td>
        <xsl:value-of select="@okt16"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t0503">
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
