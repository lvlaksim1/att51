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
    <h1>Форма для сбора сведений по показателям световой среды</h1>
    <p class="prim">
      <b>Рекомендации по заполнению:</b><br/>
      1. Формат даты - "дд.мм.гггг" (пример, 21.09.2021).<br/>
      2. Если предусмторена общая система освещения, графу "Комбинированная освещенность" оставить не заполненной.<br/>
      3. В графе ПДУ <b>E</b> - освещенность для системы общего освещения, <b>Eo</b> и <b>Ek</b> - освещенности (общая и комб.) для системы комбинированного освещения.<br/>
      4. Если ПДУ не были определены в ведомости, при импорте протоколов будет установлено значение по умолчанию ("СанПиН 1.2.3685-21, табл.5.25, п.1" E=300; Eo=200; Ek=400).
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
    


    <!-- Таблица 1101. А. Сведения об условиях проведения измерений  -->
    <p class="t_name">
      А. Сведения об условиях проведения измерений (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="6">
          <xsl:value-of select="@rm_guid"/>:1201
        </td>
      </tr>
      <tr>
        <td class="gray" colspan="2">
          Время работы на открытой территории днем, мин<br/>
          (заполняется только при наличии таких работ)
        </td>
        <td>
          <xsl:value-of select="@day_min"/>
        </td>
        <td class="gray">
          Наименование рабочих зон:
        </td>
        <td colspan="4" align="left">
          <xsl:value-of select="@day_zones"/>
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray" rowspan="2">№ зоны</td>
        <td width="35%" class="gray" rowspan="2">Рабочая зона</td>
        <td width="15%" class="gray" rowspan="2">Время пребывания, мин</td>
        <td width="15%" class="gray" rowspan="2">Дата измерения</td>
        <td width="10%" class="gray" rowspan="2">Напряжение сети, В (U1/U2)</td>
        <td width="20%" class="gray" colspan="3">Условия ОС</td>
      </tr>
      <tr>
        <td width="7%" class="gray">t, ºC</td>
        <td width="7%" class="gray">p</td>
        <td width="6%" class="gray">φ, %</td>
      </tr>
      <xsl:apply-templates select="t1201"/>
    </table>

    <!-- Таблица 1202. Б. Характеристика осветительного оборудования  (осветительных приборов)  -->
    <p class="t_name">
      Б. Характеристика осветительного оборудования  (осветительных приборов) (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="3">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="4">
          <xsl:value-of select="@rm_guid"/>:1202
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray">№ зоны</td>
        <td width="15%" class="gray">Тип светильников</td>
        <td width="15%" class="gray">Тип ламп</td>
        <td width="10%" class="gray">Мощность ламп, Вт</td>
        <td width="10%" class="gray">Высота подвеса, м</td>
        <td width="10%" class="gray">Негорящие лампы, %</td>
        <td width="35%" class="gray">Дополнительные сведения</td>
      </tr>
      <xsl:apply-templates select="t1202"/>
    </table>

    <!-- Таблица 1203. В. Сведения об измерениях параметров микроклимата  -->
    <p class="t_name">
      В. Сведения об измерениях параметров световой среды (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="3">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="6">
          <xsl:value-of select="@rm_guid"/>:1203
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray" rowspan="2">№ зоны</td>
        <td width="35%" class="gray" colspan="2">Результат измерения освещенности, Лк</td>
        <td width="20%" class="gray" colspan="2">Результат оценки блескости, наличие (да/нет)</td>
        <td width="40%" class="gray" colspan="4">ПДУ</td>
      </tr>
      <tr>
        <td width="20%" class="gray">Общая</td>
        <td width="15%" class="gray">Комбинированная</td>
        <td width="10%" class="gray">Прямая блескость</td>
        <td width="10%" class="gray">Отраженная блескость</td>
        <td width="25%" class="gray">Сокращенное наименование НД</td>
        <td width="5%" class="gray">E</td>
        <td width="5%" class="gray">Eo</td>
        <td width="5%" class="gray">Ek</td>
      </tr>
      <xsl:apply-templates select="t1203"/>
    </table>


  </xsl:template>

  
  
  <xsl:template match ="t1201">
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
        <xsl:value-of select="@cond_u"/>
      </td>
      <td>
        <xsl:value-of select="@cond_t"/>
      </td>
      <td>
        <xsl:value-of select="@cond_p"/>
      </td>
      <td>
        <xsl:value-of select="@cond_v"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1202">
    <tr>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td>
        <xsl:value-of select="@dop_svet"/>
      </td>
      <td>
        <xsl:value-of select="@dop_lamp"/>
      </td>
      <td>
        <xsl:value-of select="@dop_p"/>
      </td>
      <td>
        <xsl:value-of select="@dop_h"/>
      </td>
      <td>
        <xsl:value-of select="@dop_bad"/>
      </td>
      <td>
        <xsl:value-of select="@descr"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1203">
    <tr>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td>
        <xsl:value-of select="@res_E"/>
      </td>
      <td>
        <xsl:value-of select="@res_Ek"/>
      </td>
      <td>
        <xsl:value-of select="@res_blesk"/>
      </td>
      <td>
        <xsl:value-of select="@res_blesk_otr"/>
      </td>
      <td>
        <xsl:value-of select="@pdu_nd"/>
      </td>
      <td>
        <xsl:value-of select="@pdu_E"/>
      </td>
      <td>
        <xsl:value-of select="@pdu_Eo"/>
      </td>
      <td>
        <xsl:value-of select="@pdu_Ek"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
