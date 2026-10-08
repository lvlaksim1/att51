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
    <h1>Импорт сведений для строки 050 в уже оформленные карты</h1>
    <p>
    <b>Порядок заполнения ведомости:</b><br/>
    <span class="prim">
      Для каждого рабочего места определена отдельная таблица со сведениями для строки 050. Допускается редактирование только сведений в ячейках с белым фоном.
      В первой ячейке каждой таблицы находится уникальный идентификатор рабочего места, редактировать его категорически запрещено.
      Данная ведомость предназначена для импорта в уже оформленные карты СОУТ. Графа "Код фактора" не обязательна для заполнения
    </span>
  </p>    
    <xsl:apply-templates/>
    <p>* - графа "Код фактора" не обязательна для заполнения.</p>
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
        <td class="gray">
          Уникальный идентификатор РМ:
        </td>
        <td class="gray2" colspan="4">
          <xsl:value-of select="@rm_guid"/>
        </td>
      </tr>
      <tr>
        <td class="gray">
          Рекомендации по режимам труда и отдыха:
        </td>
        <td align="left" colspan="4">
          <xsl:value-of select="@regim"/>
        </td>
      </tr>
      <tr>
        <td class="gray">
          Рекомендации по подбору работников:
        </td>
        <td align="left" colspan="4">
          <xsl:value-of select="@trud"/>
        </td>
      </tr>
      <tr>
        <td class="gray" colspan="5">
          Рекомендации по улучшению условий труда
        </td>
      </tr>
      <tr>
        <td class="gray" width="35">Наименование мероприятия</td>
        <td class="gray" width="25">Назначение мероприятия</td>
        <td class="gray" width="10">Срок выполнения</td>
        <td class="gray" width="20">Подразделения, привлекаемые для выполнения</td>
        <td class="gray" width="10">Код фактора*</td>
      </tr>
      <xsl:apply-templates select="measures/measure"/>
    </table>
  </xsl:template>

  <xsl:template match ="measure">
    <tr>
      <td align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td align="left">
        <xsl:value-of select="@name2"/>
      </td>
      <td>
        <xsl:value-of select="@srok_date"/>
      </td>
      <td>
        <xsl:value-of select="@service"/>
      </td>
      <td>
        <xsl:value-of select="@fac_id"/>
      </td>
    </tr>
  </xsl:template>
  
</xsl:stylesheet>