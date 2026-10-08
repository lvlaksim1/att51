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
      td.gray, th.gray {
      background-color: #DDDDDD;
      }
      td.gray2 {
      background-color: #DDDDDD;
      color: #777777;
      }

    </style>	
  </head>
	<body>
    <h1>
      <a name="bm_him_form6"></a>
      Форма для сбора сведений по измерениям вредных веществ в составе Хим.фактора
    </h1>
    <p class="prim">
      <b>Рекомендации по заполнению:</b><br/>
      1. Формат даты - "дд.мм.гггг" (пример, 21.09.2021).
      <br/>
      2. Графа "ID вещества" - заполняется на основе таблицы 1, графы "ID"
      <br/>
      3. Графа "Время воздействия" - заполняется только в том случае, если время воздействия меньше времени пребывания в рабочей зоне.
    </p>
    <xsl:apply-templates/>
    <p/>
  </body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <xsl:apply-templates select="him_table"/>
    <xsl:apply-templates select="rm"/>
  </xsl:template>

  <xsl:template match ="podr">
    <p>
      <b><xsl:value-of select="@name"/></b>
    </p>
  </xsl:template>

  <xsl:template match ="him_table">
    <p class="t_name">
      <b>Таблица 1.</b> Перечень вредных веществ доступных для импорта в рамках текущей ведомости (список создан на основе справочника ресурсов).
    </p>
    <table width="100%">
      <tr>
        <td class="gray2" colspan="2">ID table:</td>
        <td class="gray2" colspan="2">dic_himia01</td>
      </tr>
      <tr>
        <th class="gray">ID</th>
        <th class="gray">DIC_ID</th>
        <th class="gray">Наименование вещества</th>
        <th class="gray">Доп.признак</th>
      </tr>
      <xsl:apply-templates select="him"/>
    </table>
  </xsl:template>


  <xsl:template match ="him">
    <tr>
      <td class="gray">
        <b>
          <xsl:value-of select="@id"/>
        </b>
      </td>
      <td class="gray2">
        <xsl:value-of select="@dic_id"/>
      </td>
      <td class="gray" align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td class="gray" align="center">
        <xsl:value-of select="@dop_id"/>
      </td>
    </tr>

  </xsl:template>


  <xsl:template match ="rm">
    <p class="rm_name">
      <b><xsl:value-of select="@rm_code"/>. <xsl:value-of select="@rm_name"/></b>
    </p>
    


    <!-- Таблица 0101. А. Сведения об интевлах и условиях проведения измерений  -->
    <p class="t_name">
      А. Сведения о рабочей зоне и условиях проведения измерений (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="3">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="4">
          <xsl:value-of select="@rm_guid"/>:0101
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray" rowspan="2">№ зоны</td>
        <td width="25%" class="gray" rowspan="2">Рабочая зона</td>
        <td width="10%" class="gray" rowspan="2">Время пребывания, мин</td>
        <td width="30%" class="gray" rowspan="2">Сведения об источнике</td>
        <td width="30%" class="gray" colspan="3">Условия ОС</td>
      </tr>
      <tr>
        <td width="10%" class="gray">t, ºC</td>
        <td width="10%" class="gray">p</td>
        <td width="10%" class="gray">φ, %</td>
      </tr>
      <xsl:apply-templates select="t0101"/>
    </table>


    <!-- Таблица 0102. Сведения об измерениях параметров ПМП  -->
    <p class="t_name">
      Б. Сведения об измерениях (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="7">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2">
          <xsl:value-of select="@rm_guid"/>:0102
        </td>
      </tr>
      <tr>
        <td rowspan="2" width="10%" class="gray">ID вещества</td>
        <td rowspan="2" width="5%" class="gray">№ зоны</td>
        <td rowspan="2" width="15%" class="gray">Дата измерения</td>
        <td rowspan="2" width="15%" class="gray">Время воздействия, мин</td>
        <td colspan="3" width="30%" class="gray">Результат измерения, мг/м3 (несколько значений заполняется через ";")</td>
        <td rowspan="2" width="25%" class="gray">Название вещества (заполняется автоматически с использованием кнопки "Проверка")</td>
     </tr>
      <tr>
        <td width="10%" class="gray">Смена 1</td>
        <td width="10%" class="gray">Смена 2</td>
        <td width="10%" class="gray">Смена 3</td>
      </tr>
      <xsl:apply-templates select="t0102"/>
    </table>

  </xsl:template>


  <xsl:template match ="t0101">
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
        <xsl:value-of select="@descr"/>
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


  <xsl:template match ="t0102">
    <tr>
      <td>
        <xsl:value-of select="@him_id"/>
      </td>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td>
        <xsl:value-of select="@izm_date"/>
      </td>
      <td>
        <xsl:value-of select="@vozd_time"/>
      </td>
      <td>
        <xsl:value-of select="@res_smena1"/>
      </td>
      <td>
        <xsl:value-of select="@res_smena2"/>
      </td>
      <td>
        <xsl:value-of select="@res_smena3"/>
      </td>
      <td>-</td>
    </tr>
  </xsl:template>


</xsl:stylesheet>
