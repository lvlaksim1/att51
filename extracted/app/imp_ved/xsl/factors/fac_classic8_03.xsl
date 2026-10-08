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
    <h1>Форма "Сведения для протокола измерений параметров вибрации локальной"</h1>
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

    <!-- Дата измерений параметров вибрации локальной  -->
    <p class="t_name">
      Дата измерения параметров вибрации локальной (РМ № <xsl:value-of select="@rm_code"/>)
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

    <!-- Интервалы проведения измерений параметров вибрации локальной  -->
    <p class="t_name">
      Интервалы проведения измерений параметров вибрации локальной (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="4">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="3">
          <xsl:value-of select="@rm_guid"/>:0702
        </td>
      </tr>
      <tr>
        <td class="gray" colspan="2">Код единицы измерения (<b>1</b> - м/с2, <b>2</b> - дБ)</td>
        <td>
          <xsl:value-of select="@izm_code"/>
        </td>
        <td class="gray" colspan="4"></td>
      </tr>
      <tr>
        <td width="5%" class="gray" rowspan="2">№<br/>m</td>
        <td width="25%" class="gray" rowspan="2">Место проведения измерения (рабочая операция)</td>
        <td width="45%" class="gray" colspan="3">
          Результат измерения, м/с2 или дБ (см. выше код единицы измерения)
        </td>
        <td width="15%" class="gray" rowspan="2">Длительность i-го измерения, мин (форма 5)</td>
        <td width="15%" class="gray" rowspan="2">
          Время операции<br/>Tm,i, мин</td>
      </tr>
      <tr>
        <td width="15%" class="gray">ось X</td>
        <td width="15%" class="gray">ось Y</td>
        <td width="15%" class="gray">ось Z</td>
      </tr>
      <xsl:apply-templates select="t0702"/>
    </table>

  </xsl:template>
 

  <xsl:template match ="t0702">
    <tr>
      <td>
        <xsl:value-of select="@z_num"/>
      </td>
      <td align="left">
        <xsl:value-of select="@zona"/>
      </td>
      <td>
        <xsl:value-of select="@resX"/>
      </td>
      <td>
        <xsl:value-of select="@resY"/>
      </td>
      <td>
        <xsl:value-of select="@resZ"/>
      </td>
      <td>
        <xsl:value-of select="@z_izm_time"/>
      </td>
      <td>
        <xsl:value-of select="@z_time"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
