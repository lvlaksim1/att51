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
    <h1>Форма "Сведения для протокола измерений параметров ультразвука"</h1>
    <p class="prim">
      <b>Рекомендации по заполнению:</b><br/>
      1. Ввод сведений производится в ячейки с белым фоном<br/>
      2. Формат даты - "дд.мм.гггг" (пример, 21.09.2021).<br/>
      3. Допускается не вводить дату в ведомость<br/>
      4. Код временной характеристики: 1 - постоянный ультразвук; 2 - импульсный ультразвук<br/>
      5. Результаты измерений требуется заполнять только для той частоты, которая соответствует источнику ультразвука на рабочем месте. Остальные частоты заполнять не требуется.
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

    <!-- Дата измерений параметров ультразвука  -->
    <p class="t_name">
      Дата измерения параметров ультразвука (РМ № <xsl:value-of select="@rm_code"/>)
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

    <!-- Интервалы проведения измерений параметров ультразвука  -->
    <p class="t_name">
      Интервалы проведения измерений параметров ультразвука (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="12">
          <xsl:value-of select="@rm_guid"/>:0602
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray" rowspan="2">№<br/>m</td>
        <td width="25%" class="gray" rowspan="2">Место проведения измерения (рабочая операция)</td>
        <td width="10%" class="gray" rowspan="2">
          Время воздействия, % смены
        </td>
        <td width="10%" class="gray" rowspan="2">Код временной характеристики (1 или 2)</td>
        <td width="50%" class="gray" colspan="10">
          Уровень звукового давления, дБ (в среднегеометрических частотах f, кГц)
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray">12.5</td>
        <td width="5%" class="gray">16</td>
        <td width="5%" class="gray">20</td>
        <td width="5%" class="gray">25</td>
        <td width="5%" class="gray">31.5</td>
        <td width="5%" class="gray">40</td>
        <td width="5%" class="gray">50</td>
        <td width="5%" class="gray">63</td>
        <td width="5%" class="gray">80</td>
        <td width="5%" class="gray">100</td>
      </tr>
      <xsl:apply-templates select="t0602"/>
    </table>

  </xsl:template>
 

  <xsl:template match ="t0602">
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
        <xsl:value-of select="@z_char"/>
      </td>
      <td>
        <xsl:value-of select="@res12_5"/>
      </td>
      <td>
        <xsl:value-of select="@res16"/>
      </td>
      <td>
        <xsl:value-of select="@res20"/>
      </td>
      <td>
        <xsl:value-of select="@res25"/>
      </td>
      <td>
        <xsl:value-of select="@res31_5"/>
      </td>
      <td>
        <xsl:value-of select="@res40"/>
      </td>
      <td>
        <xsl:value-of select="@res50"/>
      </td>
      <td>
        <xsl:value-of select="@res63"/>
      </td>
      <td>
        <xsl:value-of select="@res80"/>
      </td>
      <td>
        <xsl:value-of select="@res100"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
