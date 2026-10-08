<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Отчет по оформленным документам</title>
    <style>
      /* Style Definitions */
      body
      {
      font-size:12.0pt;
      font-family: Times new roman, serif;
      text-align:left;
      }
      .h1 {
      font-weight:bold;
      font-size:16.0pt;
      text-align:center;
      }
      .h2 {
      font-weight:bold;
      font-size:14.0pt;
      text-align:center;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
      td.center {
      text-align:center;
      }
      tr.factor {
      font-weight: bold;
      }
      tr.param p {
      text-align:left;
      }
      tr.zone {
      font-style:italic;
      }
      td.sign {
      height:30pt;
      }
      .red {
      color: red;
      }

    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <p class="h1">Отчет о поверке средств измерения</p>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="si_data">
    <p>
      Организация: <xsl:value-of select="@name"/>
    </p>
    <table>
      <tr>
        <td class="center" width="5%">№ п/п</td>
        <td class="center" width="20%">Фактор</td>
        <td class="center" width="15%">Наименование СИ</td>
        <td class="center" width="15%">Действие поверки</td>
        <td class="center" width="15%">Номера протоколов</td>
        <td class="center" width="15%">Даты измерения</td>
        <td class="center" width="15%">Нарушение срока поверки</td>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>
  <xsl:template match ="si">
    <tr>
      <td class="center">
        <xsl:value-of select="count(preceding-sibling::*)+1"/>
      </td>
      <td>
        <xsl:value-of select="@factor"/>
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td class="center">
        <xsl:value-of select="@test"/>
        <xsl:if test="@test_descr">
          <p class="red">Имеется более новая поверка: <xsl:value-of select="@test_descr"/>
        </p>
        </xsl:if>
      </td>
      <td>
        <xsl:value-of select="@num_prots"/>
      </td>
      <td>
        <xsl:value-of select="@izm_dates"/>
      </td>
      <td class="red">
        <xsl:value-of select="@errors"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="si_err_data">
    <p class="h2">
      Проблемные СИ, которые не идентифицированы в справочнике ресурсов
    </p>
    <table>
      <tr>
        <td class="center" width="5%">№ п/п</td>
        <td class="center" width="20%">Фактор</td>
        <td class="center" width="15%">Наименоваение СИ</td>
        <td class="center" width="15%">Заводской номер</td>
        <td class="center" width="15%">Действие поверки</td>
        <td class="center" width="15%">Номера протоколов</td>
        <td class="center" width="15%">Даты измерения</td>
      </tr>
      <xsl:apply-templates/>
    </table>
    <p>
      Для проблемных СИ рекомендуется обновить раздел "Средства измерений" в протоколах
    </p>
  </xsl:template>
  <xsl:template match ="si_err">
    <tr>
      <td class="center">
        <xsl:value-of select="count(preceding-sibling::*)+1"/>
      </td>
      <td>
        <xsl:value-of select="@factor"/>
      </td>
      <td class="red">
        Отсутствует в справочнике ресурсов
      </td>
      <td class="center">
        <xsl:value-of select="@num"/>
      </td>
      <td>
        <xsl:value-of select="@test"/>
      </td>
      <td>
        <xsl:value-of select="@num_prots"/>
      </td>
      <td>
        <xsl:value-of select="@izm_dates"/>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>