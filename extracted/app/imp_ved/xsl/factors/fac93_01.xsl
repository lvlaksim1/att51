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
    <h1>Форма для сбора сведений по показателям электростатического поля</h1>
    <p class="prim">
      <b>Рекомендации по заполнению:</b><br/>
      1. Формат даты - "дд.мм.гггг" (пример, 21.09.2021).
      <br/>
      2. Особенности ЭСП - указывается один из следующих вариантов: "1", "2" (1 - Общее воздействие , 2 - Локальное воздействие ).
      <br/>
      3. Рабочая поза - указывается один из следующих вариантов: "стоя", "сидя".
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
    


    <!-- Таблица 9301. А. Сведения об интевлах и условиях проведения измерений  -->
    <p class="t_name">
      А. Сведения об интервалах и условиях проведения измерений (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="3">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="7">
          <xsl:value-of select="@rm_guid"/>:9301
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray" rowspan="2">№ зоны</td>
        <td width="26%" class="gray" rowspan="2">Рабочая зона</td>
        <td width="8%" class="gray" rowspan="2">Время пребывания, мин</td>
        <td width="8%" class="gray" rowspan="2">Дата измерения</td>
        <td width="8%" class="gray" rowspan="2">Рабочая поза</td>
        <td width="25%" class="gray" rowspan="2">Краткое описание источников ЭСП</td>
        <td width="20%" class="gray" colspan="4">Условия ОС</td>
      </tr>
      <tr>
        <td width="5%" class="gray">t, ºC</td>
        <td width="5%" class="gray">p</td>
        <td width="5%" class="gray">υ, м/с</td>
        <td width="5%" class="gray">φ, %</td>
      </tr>
      <xsl:apply-templates select="t9301"/>
    </table>


    <!-- Таблица 9302. Сведения об измерениях параметров ПМП  -->
    <p class="t_name">
      Б. Сведения об измерениях параметров ЭМП  (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>:9302
        </td>
      </tr>
      <tr>
        <td width="7%" class="gray" rowspan="2">№ зоны</td>
        <td width="92%" class="gray" colspan="3">Напряженность электростатического поля, кВ/м</td>
      </tr>
      <tr>
        <td width="31%" class="gray">H - 0.5/0.8 м</td>
        <td width="31%" class="gray">H - 1.0 м</td>
        <td width="31%" class="gray">H - 1.4/1.7 м</td>
      </tr>
      <xsl:apply-templates select="t9302"/>
    </table>

    

  </xsl:template>


  <xsl:template match ="t9301">
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


  <xsl:template match ="t9302">
    <tr>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td>
        <xsl:value-of select="@res1"/>
      </td>
      <td>
        <xsl:value-of select="@res2"/>
      </td>
      <td>
        <xsl:value-of select="@res3"/>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>
