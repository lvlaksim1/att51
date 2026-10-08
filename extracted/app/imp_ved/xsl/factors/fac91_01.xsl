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
    <h1>Форма для сбора сведений по показателям ЭМП-50</h1>
    <p class="prim">
      <b>Рекомендации по заполнению:</b><br/>
      1. Формат даты - "дд.мм.гггг" (пример, 21.09.2021).<br/>
      2. Особенности ЭМП - указывается один из следующих вариантов: "1", "2", "3", "4", "5" (1 - Общее воздействие; 2 - Локальное воздействие; 3 - Импульсный режим I; 4 - Импульсный режим II; 5 - Импульсный режим III).
      <br/>
      3. Графа "Локальное облучение" заполняется только при наличии локального облучения.
      <br/>
      4. Место измерения (для локального облучения) - указывается один из следующих вариантов: "1", "2" (1 - кисти рук, 2 - предплечье).
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
    


    <!-- Таблица 9101. А. Сведения об интевлах и условиях проведения измерений  -->
    <p class="t_name">
      А. Сведения об интервалах и условиях проведения измерений (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="8">
          <xsl:value-of select="@rm_guid"/>:9101
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray" rowspan="2">№ зоны</td>
        <td width="20%" class="gray" rowspan="2">Рабочая зона</td>
        <td width="10%" class="gray" rowspan="2">Время пребывания, мин</td>
        <td width="10%" class="gray" rowspan="2">Дата измерения</td>
        <td width="10%" class="gray" rowspan="2">Особенности ЭМП</td>
        <td width="25%" class="gray" rowspan="2">Краткое описание источников ЭМП</td>
        <td width="20%" class="gray" colspan="4">Условия ОС</td>
      </tr>
      <tr>
        <td width="5%" class="gray">t, ºC</td>
        <td width="5%" class="gray">p</td>
        <td width="5%" class="gray">υ, м/с</td>
        <td width="5%" class="gray">φ, %</td>
      </tr>
      <xsl:apply-templates select="t9101"/>
    </table>


    <!-- Таблица 9102. Б. Сведения об измерениях параметров ЭМП  -->
    <p class="t_name">
      Б. Сведения об измерениях электрической составляющей параметров ЭМП  (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="3">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>:9102
        </td>
      </tr>
      <tr>
        <td width="8%" class="gray" rowspan="2">№ зоны</td>
        <td width="92%" class="gray" colspan="4">Напряженность электрического поля, кВ/м</td>
      </tr>
      <tr>
        <td width="23%" class="gray">H - 0.0 м</td>
        <td width="23%" class="gray">H - 0.5 м</td>
        <td width="23%" class="gray">H - 1.0 м</td>
        <td width="23%" class="gray">H - 1.7 м</td>
      </tr>
      <xsl:apply-templates select="t9102"/>
    </table>

    <!-- Таблица 9103. Б. Сведения об измерениях параметров ЭМП  -->
    <p class="t_name">
      Б. Сведения об измерениях магнитной составляющей параметров ЭМП  (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="3">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="5">
          <xsl:value-of select="@rm_guid"/>:9103
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray" rowspan="3">№ зоны</td>
        <td width="10%" class="gray" rowspan="3">Единица измерения</td>
        <td width="85%" class="gray" colspan="6">Напряженность магнитного поля (А/м) или Индукция магнитного поля, (мкТл) по уровням измерения</td>
      </tr>
      <tr>
        <td width="15%" class="gray" rowspan="2">H - 0.0 м</td>
        <td width="15%" class="gray" rowspan="2">H - 0.5 м</td>
        <td width="15%" class="gray" rowspan="2">H - 1.0 м</td>
        <td width="15%" class="gray" rowspan="2">H - 1.7 м</td>
        <td width="25%" class="gray" colspan="2">Локальное облучение</td>
      </tr>
      <tr>
        <td width="10%" class="gray">Место (1, 2)</td>
        <td width="15%" class="gray">Результат измерения</td>
      </tr>
      <xsl:apply-templates select="t9103"/>
    </table>


  </xsl:template>


  <xsl:template match ="t9101">
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
        <xsl:value-of select="@vid_emp"/>
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


  <xsl:template match ="t9102">
    <tr>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td>
        <xsl:value-of select="@ep_res00"/>
      </td>
      <td>
        <xsl:value-of select="@ep_res05"/>
      </td>
      <td>
        <xsl:value-of select="@ep_res10"/>
      </td>
      <td>
        <xsl:value-of select="@ep_res17"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t9103">
    <tr>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td>
        <xsl:value-of select="@ed_izm"/>
      </td>
      <td>
        <xsl:value-of select="@mp_res00"/>
      </td>
      <td>
        <xsl:value-of select="@mp_res05"/>
      </td>
      <td>
        <xsl:value-of select="@mp_res10"/>
      </td>
      <td>
        <xsl:value-of select="@mp_res17"/>
      </td>
      <td>
        <xsl:value-of select="@mp_loc"/>
      </td>
      <td>
        <xsl:value-of select="@mp_res_loc"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
