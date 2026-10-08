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
      .prim
      {
      font-size:10.0pt;
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
    <h1>Импорт сведений для строки 040 в уже оформленные карты</h1>
    <p>
    <b>Порядок заполнения ведомости:</b><br/>
    <span class="prim">
      Для каждого рабочего места определена отдельная таблица со сведениями для строки 040. Допускается редактирование только сведений в ячейках с белым фоном.
    В первой ячейке каждой таблицы находится уникальный идентификатор рабочего места, редактировать его категорически запрещено. 
    Данная ведомость предназначена для импорта в уже оформленные карты СОУТ.
    </span>
  </p>    
    <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="podr">
    <p>
      <b><xsl:value-of select="@name"/></b>
    </p>
  </xsl:template>
  
  <xsl:template match ="rm">
    <p>
      <b><xsl:value-of select="@rm_code"/>. <xsl:value-of select="@rm_name"/></b>
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="3">
          Уникальный идентификатор РМ:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>
        </td>
      </tr>
      <tr>
        <td width="5%" rowspan="2" class="gray">№<br/>п/п</td>
        <td width="25%" rowspan="2" class="gray">Виды гарантий и компенсаций</td>
        <td width="15%" rowspan="2" class="gray">Фактическое наличие</td>
        <td colspan="2" class="gray">
          По результатам оценки условий труда (класс <xsl:value-of select="@kut"/>)
      </td>
      </tr>
      <tr>
        <td width="15%" class="gray">необходимость  в установлении (да, нет)</td>
        <td width="40%" class="gray">основание</td>
      </tr>
      <tr>
        <td class="gray">1.</td>
        <td class="gray">Повышенная оплата труда работника (работников)</td>
        <td><xsl:value-of select="@dopl"/></td>
        <td>
          <xsl:value-of select="@dopl2"/>
        </td>
        <td align="left"><xsl:value-of select="@dopl_osn"/></td>
      </tr>
      <tr>
        <td class="gray">2.</td>
        <td class="gray">Ежегодный дополнительный оплачиваемый отпуск</td>
        <td>
          <xsl:value-of select="@dop_otpusk"/>
        </td>
        <td>
          <xsl:value-of select="@dop_otpusk2"/>
        </td>
        <td align="left"><xsl:value-of select="@dopotpusk_osn"/></td>
      </tr>
      <tr>
        <td class="gray">3.</td>
        <td class="gray">Сокращенная продолжительность рабочего времени</td>
        <td>
          <xsl:value-of select="@week"/>
        </td>
        <td>
          <xsl:value-of select="@week2"/>
        </td>
        <td align="left"><xsl:value-of select="@week_osn"/></td>
      </tr>
      <tr>
        <td class="gray">4.</td>
        <td class="gray">Молоко или другие равноценные пищевые продукты</td>
        <td>
          <xsl:value-of select="@milk"/>
        </td>
        <td>
          <xsl:value-of select="@milk2"/>
        </td>
        <td align="left"><xsl:value-of select="@milk_osn"/></td>
      </tr>
      <tr>
        <td class="gray">5.</td>
        <td class="gray">Лечебно - профилактическое питание</td>
        <td>
          <xsl:value-of select="@profpit"/>
        </td>
        <td>
          <xsl:value-of select="@profpit2"/>
        </td>
        <td align="left"><xsl:value-of select="@profpit_osn"/></td>
      </tr>
      <tr>
        <td class="gray">6.</td>
        <td class="gray">Право на досрочное назначение страховой пенсии</td>
        <td>
          <xsl:value-of select="@lpo"/>
        </td>
        <td>
          <xsl:value-of select="@lpo2"/>
        </td>
        <td align="left"><xsl:value-of select="@lpo_osn"/></td>
      </tr>
      <tr>
        <td class="gray">7.</td>
        <td class="gray">Проведение медицинских осмотров</td>
        <td>
          <xsl:value-of select="@medosm"/>
        </td>
        <td>
          <xsl:value-of select="@medosm2"/>
        </td>
        <td align="left"><xsl:value-of select="@medosm_osn"/></td>
      </tr>
    </table>
  </xsl:template>

</xsl:stylesheet>