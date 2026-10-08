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
    <h1>Форма для сбора сведений по показателям микроклимата</h1>
    <p class="prim">
      <b>Рекомендации по заполнению:</b><br/>
      1. Формат даты - "дд.мм.гггг" (пример, 21.09.2021).<br/>
      2. Категория работ - указывается один из следующих вариантов: "Iа", "Iб", "IIа", "IIб", "III".<br/>
      3. Рабочая поза - указывается один из следующих вариантов: "стоя", "сидя".<br/>
      4. Расположение (для ФГИС СОУТ) - указывается один из следующих вариантов: "1", "2", "3" (1 - Отапливаемое помещение, 2 -Неотапливаемое помещение, 3 - Открытая территория).
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
        <td class="gray2" colspan="9">
          <xsl:value-of select="@rm_guid"/>:1101
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray" rowspan="2">№ зоны</td>
        <td width="20%" class="gray" rowspan="2">Рабочая зона</td>
        <td width="8%" class="gray" rowspan="2">Время пребывания, мин</td>
        <td width="8%" class="gray" rowspan="2">Дата измерения</td>
        <td width="8%" class="gray" rowspan="2">Категория работ</td>
        <td width="8%" class="gray" rowspan="2">Поза<br/>(сидя/стоя)</td>
        <td width="10%" class="gray" rowspan="2">Расположение (для ФГИС СОУТ)</td>
        <td width="15%" class="gray" colspan="3">Условия ОС</td>
        <td width="20%" class="gray" rowspan="2">Дополнительные сведения</td>
      </tr>
      <tr>
        <td width="5%" class="gray">t, ºC</td>
        <td width="5%" class="gray">p</td>
        <td width="5%" class="gray">φ, %</td>
      </tr>
      <xsl:apply-templates select="t1101"/>
    </table>


    <!-- Таблица 1102. Б. Сведения об измерениях параметров микроклимата  -->
    <p class="t_name">
      Б. Сведения об измерениях параметров микроклимата (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="3">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="8">
          <xsl:value-of select="@rm_guid"/>:1102
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray" rowspan="2">№ зоны</td>
        <td class="gray" colspan="2">Температура воздуха ºC</td>
        <td class="gray" colspan="2">Скорость движения воздуха, м/с</td>
        <td width="14%" class="gray" rowspan="2">Относительная влажность, %</td>
        <td class="gray" colspan="2">ТНС-индекс, ºC</td>
        <td class="gray" colspan="3">Интенсивность теплового излучения, Вт/м2</td>
      </tr>
      <tr>
        <td width="9%" class="gray">0.1 м</td>
        <td width="9%" class="gray">1.0/1.5 м</td>
        <td width="9%" class="gray">0.1 м</td>
        <td width="9%" class="gray">1.0/1.5 м</td>
        <td width="9%" class="gray">0.1 м</td>
        <td width="9%" class="gray">1.0/1.5 м</td>
        <td width="9%" class="gray">0.5 м</td>
        <td width="9%" class="gray">1.0 м</td>
        <td width="9%" class="gray">1.5 м</td>
      </tr>
      <xsl:apply-templates select="t1102"/>
    </table>


  </xsl:template>

  
  
  <xsl:template match ="t1101">
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
        <xsl:value-of select="@cat"/>
      </td>
      <td>
        <xsl:value-of select="@pose"/>
      </td>
      <td>
        <xsl:value-of select="@fgis_flag"/>
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
      <td>
        <xsl:value-of select="@descr"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1102">
    <tr>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td>
        <xsl:value-of select="@temp1"/>
      </td>
      <td>
        <xsl:value-of select="@temp2"/>
      </td>
      <td>
        <xsl:value-of select="@skor1"/>
      </td>
      <td>
        <xsl:value-of select="@skor2"/>
      </td>
      <td>
        <xsl:value-of select="@vlag"/>
      </td>
      <td>
        <xsl:value-of select="@tns1"/>
      </td>
      <td>
        <xsl:value-of select="@tns2"/>
      </td>
      <td>
        <xsl:value-of select="@tepl1"/>
      </td>
      <td>
        <xsl:value-of select="@tepl2"/>
      </td>
      <td>
        <xsl:value-of select="@tepl3"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
