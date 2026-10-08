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
    <h1>Форма "Сведения для протокола измерений химического фактора"</h1>
    <p class="prim">
      <b>Рекомендации по заполнению:</b><br/>
      1. Ввод сведений производится в ячейки с белым фоном<br/>
      2. Формат даты - "дд.мм.гггг" (пример, 21.09.2021).<br/>
      3. Допускается не вводить дату в ведомость<br/>
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
  
  <xsl:template match ="rm">
    <p class="rm_name">
      <b><xsl:value-of select="@rm_code"/>. <xsl:value-of select="@rm_name"/></b>
    </p>

    <!-- Дата измерения  -->
    <p class="t_name">
      Дата измерения (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" width="30%">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" width="70%">
          <xsl:value-of select="@rm_guid"/>:izm_date
        </td>
      </tr>
      <tr>
        <td class="gray">
          Дата измерения:
        </td>
        <td>
          <xsl:value-of select="@izm_date"/>
        </td>
      </tr>
    </table>


    <!-- Таблица 0101. А. Сведения об интевлах и условиях проведения измерений  -->
    <p class="t_name">
      А. Сведения о рабочей зоне и условиях проведения измерений (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="3">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="3">
          <xsl:value-of select="@rm_guid"/>:0101
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray" rowspan="2">№ зоны</td>
        <td width="55%" class="gray" rowspan="2">Рабочая зона</td>
        <td width="10%" class="gray" rowspan="2">Время пребывания, % смены</td>
        <td width="30%" class="gray" colspan="3">Условия ОС</td>
      </tr>
      <tr>
        <td width="10%" class="gray">t, ºC</td>
        <td width="10%" class="gray">p</td>
        <td width="10%" class="gray">φ, %</td>
      </tr>
      <xsl:apply-templates select="t0101"/>
    </table>


    <!-- Таблица 0102. Сведения об измерениях ХИМ -->
    <p class="t_name">
      Б. Сведения об измерениях (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="4">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2">
          <xsl:value-of select="@rm_guid"/>:0102
        </td>
      </tr>
      <tr>
        <td width="10%" class="gray">DIC_ID<br/>вещества
      </td>
        <td width="5%" class="gray">№ зоны</td>
        <td width="15%" class="gray">Время воздействия, % смены</td>
        <td width="20%" class="gray">Результат измерения, мг/м3 (несколько значений заполняется через ";")</td>
        <td width="50%" class="gray">Название вещества (данная колонка не обязательна для заполнения; обновляется автоматически при использовании кнопки "Проверка")</td>
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
        <xsl:value-of select="@vozd_time"/>
      </td>
      <td>
        <xsl:value-of select="@result"/>
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
    </tr>
  </xsl:template>


  <xsl:template match ="him_table">
    <p class="t_name">
      <b>Таблица 1.</b> Перечень вредных веществ доступных для импорта в рамках текущей ведомости (список создан на основе вредных веществ, введенных в базу РМ).
    </p>
    <table width="100%">
      <tr>
        <td class="gray2" colspan="2">ID table:</td>
        <td class="gray2">dic_ids</td>
      </tr>
      <tr>
        <td class="gray">№<br/>п/п</td>
        <td class="gray">DIC_ID</td>
        <td class="gray">Наименование вещества</td>
      </tr>
      <xsl:apply-templates select="him"/>
    </table>
  </xsl:template>


  <xsl:template match ="him">
    <tr>
      <td class="gray2">
        <b>
          <xsl:value-of select="@num"/>
        </b>
      </td>
      <td class="gray">
        <xsl:value-of select="@dic_id"/>
      </td>
      <td class="gray" align="left">
        <xsl:value-of select="@name"/>
      </td>
    </tr>

  </xsl:template>


</xsl:stylesheet>
