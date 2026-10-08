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
    <h1>Форма "Сведения для протокола измерений параметров шума"</h1>
    <p class="prim">
      <b>Рекомендации по заполнению:</b><br/>
      1. Формат даты - "дд.мм.гггг" (пример, 21.09.2021).<br/>
      2. В графе "Характер шума" указывается один из следующих вариантов: "1", "2", "3" (1 - Широкополосный, 2 - Тональный, 3 - Импульсный).<br/>
      3. В таблице "Дополнительные сведения об условиях измерения" допускается установка прочерка с заполнением одной строки. Прочерк обозначает, что сведения применимы для всех интервалов измерения.
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
    


    <!-- Таблица 0401. А. Сведения об условиях ОС  -->
    <p class="t_name">
      А. Сведения об условиях ОС (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="4">
          <xsl:value-of select="@rm_guid"/>:0401
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
      <xsl:apply-templates select="t0401"/>
    </table>


    <!-- Таблица 0402. Б. Интервалы проведения измерений параметров шума  -->
    <p class="t_name">
      Б. Интервалы проведения измерений параметров шума (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="3">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="5">
          <xsl:value-of select="@rm_guid"/>:0402
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray">№<br/>m</td>
        <td width="20%" class="gray">Место проведения измерения (рабочая операция)</td>
        <td width="10%" class="gray">Дата<br/>измерения</td>
        <td width="20%" class="gray">Краткое описание источников шума</td>
        <td width="15%" class="gray">
          Эквивалентный уровень звука, дБА<br/>
          (L<sub>1</sub>; L<sub>2</sub>; L<sub>3</sub>;..)
        </td>
        <td width="10%" class="gray">Длительность i-го измерения, мин</td>
        <td width="10%" class="gray">Характер шума</td>
        <td width="10%" class="gray">
          Время операции<br/>Tm,i, мин</td>
      </tr>
      <xsl:apply-templates select="t0402"/>
    </table>


    <!-- Таблица 0403. В. Результаты измерений уровня звука  -->
    <p class="t_name">
      В. Дополнительные сведения об условиях измерения (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>:0403
        </td>
      </tr>
      <tr>
        <td width="10%" class="gray">
          №<br/>m
        </td>
        <td width="30%" class="gray">Конфигурация измерительной системы</td>
        <td width="30%" class="gray">Информация об особых метеорологических условиях</td>
        <td width="30%" class="gray">Положение микрофона</td>
      </tr>
      <xsl:apply-templates select="t0403"/>
    </table>
  </xsl:template>
 
  
  <xsl:template match ="t0401">
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

  <xsl:template match ="t0402">
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
        <xsl:value-of select="@z_char"/>
      </td>
      <td>
        <xsl:value-of select="@z_time"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t0403">
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
      <td>
        <xsl:value-of select="@descr3"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
