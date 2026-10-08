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
    <h1>Форма для сбора сведений по показателям переменного электромагнитного поля радиочастотного диапазона</h1>
    <p class="prim">
      <b>Рекомендации по заполнению:</b><br/>
      1. Формат даты - "дд.мм.гггг" (пример, 21.09.2021).
      <br/>
      2. Рабочая поза - указывается один из следующих вариантов: "стоя", "сидя".
      <br/>
      3. Диапазон ЭМП - указывается один из следующих вариантов: "1", "2", "3", "4", "5", "6", "7":<br/>
      1 - 10 кГц - 30 кГц<br/>2 - 30 кГц - 3 МГц<br/>3 - 3 МГц - 30 МГц<br/>4 - 30 МГц - 50 МГц<br/>5 - 50 МГц - 300 МГц<br/>6 - 300 МГц - 300 ГГц<br/>7 - 300 МГц - 300 ГГц (локальное облучение рук)).
      <br/>
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
    


    <!-- Таблица 9401. А. Сведения об интевлах и условиях проведения измерений  -->
    <p class="t_name">
      А. Сведения об интервалах и условиях проведения измерений (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="3">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="7">
          <xsl:value-of select="@rm_guid"/>:9401
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray" rowspan="2">№ зоны</td>
        <td width="26%" class="gray" rowspan="2">Рабочая зона</td>
        <td width="8%" class="gray" rowspan="2">Время пребывания, мин</td>
        <td width="8%" class="gray" rowspan="2">Дата измерения</td>
        <td width="8%" class="gray" rowspan="2">Рабочая поза</td>
        <td width="25%" class="gray" rowspan="2">Краткое описание источников ЭМП</td>
        <td width="20%" class="gray" colspan="4">Условия ОС</td>
      </tr>
      <tr>
        <td width="5%" class="gray">t, ºC</td>
        <td width="5%" class="gray">p</td>
        <td width="5%" class="gray">υ, м/с</td>
        <td width="5%" class="gray">φ, %</td>
      </tr>
      <xsl:apply-templates select="t9401"/>
    </table>


    <!-- Таблица 9402. Сведения об измерениях параметров ПМП  -->
    <p class="t_name">
      Б. Сведения об измерениях параметров ЭМП  (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="4">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="7">
          <xsl:value-of select="@rm_guid"/>:9402
        </td>
      </tr>
      <tr>
        <td width="3%" class="gray" rowspan="2">№ зоны</td>
        <td width="7%" class="gray" rowspan="2">Диапазон ЭМП</td>
        <td width="30%" class="gray" colspan="3">Напряженность электрического поля, В/м</td>
        <td width="30%" class="gray" colspan="3">Напряженность магнитного поля, А/м</td>
        <td width="30%" class="gray" colspan="3">Плотность потока энергии, мкВт/см²</td>
      </tr>
      <tr>
        <td width="10%" class="gray">H - 0.5/0.8 м</td>
        <td width="10%" class="gray">H - 1.0 м</td>
        <td width="10%" class="gray">H - 1.4/1.7 м</td>
        <td width="10%" class="gray">H - 0.5/0.8 м</td>
        <td width="10%" class="gray">H - 1.0 м</td>
        <td width="10%" class="gray">H - 1.4/1.7 м</td>
        <td width="10%" class="gray">H - 0.5/0.8 м*</td>
        <td width="10%" class="gray">H - 1.0 м*</td>
        <td width="10%" class="gray">H - 1.4/1.7 м</td>
      </tr>
      <xsl:apply-templates select="t9402"/>
    </table>
    <p class="prim">
      * - для локального облучения рук графа "H - 0.5/0.8 м" используется для измерения на уровне кистей, графа "H - 1.0 м" - уровень середины предплечья.
    </p>
    

  </xsl:template>


  <xsl:template match ="t9401">
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
        <xsl:value-of select="@pose"/>
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


  <xsl:template match ="t9402">
    <tr>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td>
        <xsl:value-of select="@diap"/>
      </td>
      <td>
        <xsl:value-of select="@res_e1"/>
      </td>
      <td>
        <xsl:value-of select="@res_e2"/>
      </td>
      <td>
        <xsl:value-of select="@res_e3"/>
      </td>
      <td>
        <xsl:value-of select="@res_m1"/>
      </td>
      <td>
        <xsl:value-of select="@res_m2"/>
      </td>
      <td>
        <xsl:value-of select="@res_m3"/>
      </td>
      <td>
        <xsl:value-of select="@res_ppe1"/>
      </td>
      <td>
        <xsl:value-of select="@res_ppe2"/>
      </td>
      <td>
        <xsl:value-of select="@res_ppe3"/>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>
