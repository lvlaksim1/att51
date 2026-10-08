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
    <h1>Форма для сбора сведений по измерениям УФИ</h1>
    <p class="prim">
      <b>Рекомендации по заполнению:</b><br/>
      1. Формат даты - "дд.мм.гггг" (пример, 21.09.2021).
      <br/>
      2. Ячейка "Характер облучения" - указывается один из следующих вариантов: "1", "2", "3":
      <br/>
      "1" - Облучение при наличии незащищенных участков поверхности кожи: период - до 5 мин; паузы - до 30 мин; общая продолжительность - до 60 мин.
      <br/>
      "2" - Облучение при наличии незащищенных участков поверхности кожи: период - до 5 мин; общая продолжительность - до 50 % времени смены.
      <br/>
      "3" - Облучение при использовании спецодежды и средств защиты, не пропускающих излучение.
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
    


    <!-- Таблица 2601. А. Сведения об интевлах и условиях проведения измерений  -->
    <p class="t_name">
      А. Сведения об интервалах и условиях проведения измерений (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="3">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>:2601
        </td>
        <td class="gray" colspan="3" align="right">Характер облучения: </td>
        <td>
          <xsl:value-of select="@char"/>
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray" rowspan="2">№ зоны</td>
        <td width="25%" class="gray" rowspan="2">Рабочая зона</td>
        <td width="10%" class="gray" rowspan="2">Время пребывания, мин</td>
        <td width="10%" class="gray" rowspan="2">Дата измерения</td>
        <td width="30%" class="gray" rowspan="2">Краткое описание источников УФИ</td>
        <td width="20%" class="gray" colspan="4">Условия ОС</td>
      </tr>
      <tr>
        <td width="5%" class="gray">t, ºC</td>
        <td width="5%" class="gray">p</td>
        <td width="5%" class="gray">υ, м/с</td>
        <td width="5%" class="gray">φ, %</td>
      </tr>
      <xsl:apply-templates select="t2601"/>
    </table>


    <!-- Таблица 2602. Сведения об измерениях параметров ПМП  -->
    <p class="t_name">
      Б. Сведения об измерениях параметров УФИ  (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="4">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="3">
          <xsl:value-of select="@rm_guid"/>:2602
        </td>
      </tr>
      <tr>
        <td width="4%" class="gray" rowspan="2">№ зоны</td>
        <td width="32%" class="gray" colspan="2">Энергетическая освещенность (УФ-A), Вт/м²</td>
        <td width="32%" class="gray" colspan="2">Энергетическая освещенность (УФ-B), Вт/м²</td>
        <td width="32%" class="gray" colspan="2">Энергетическая освещенность (УФ-C), Вт/м²</td>
      </tr>
      <tr>
        <td width="16%" class="gray">H - 0.5-1.0 м</td>
        <td width="16%" class="gray">H - 1.5 м</td>
        <td width="16%" class="gray">H - 0.5-1.0 м</td>
        <td width="16%" class="gray">H - 1.5 м</td>
        <td width="16%" class="gray">H - 0.5-1.0 м</td>
        <td width="16%" class="gray">H - 1.5 м</td>
      </tr>
      <xsl:apply-templates select="t2602"/>
    </table>

  </xsl:template>


  <xsl:template match ="t2601">
    <tr>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td align="left">
        <xsl:value-of select="@zona"/>
      </td>
      <td>
        <xsl:value-of select="@z_time"/>
      </td>
      <td>
        <xsl:value-of select="@izm_date"/>
      </td>
      <td>
        <xsl:value-of select="@descr"/>
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


  <xsl:template match ="t2602">
    <tr>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td>
        <xsl:value-of select="@res_ufa1"/>
      </td>
      <td>
        <xsl:value-of select="@res_ufa2"/>
      </td>
      <td>
        <xsl:value-of select="@res_ufb1"/>
      </td>
      <td>
        <xsl:value-of select="@res_ufb2"/>
      </td>
      <td>
        <xsl:value-of select="@res_ufc1"/>
      </td>
      <td>
        <xsl:value-of select="@res_ufc2"/>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>
