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
    <h1>Форма для сбора сведений по показателям напряженности трудового процесса (для протоколов по МИ НТП.ИНТ-17.01-2018)</h1>
    <p class="prim">
      <b>Рекомендации по заполнению:</b><br/>
      1. Формат даты - "дд.мм.гггг" (пример, 21.09.2021).
    </p>
    <xsl:apply-templates/>
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
    
    <!-- Таблица 1401. А. Общие сведения  -->
    <p class="t_name">А. Общие сведения (РМ № <xsl:value-of select="@rm_code"/>)</p>
    <table width="100%">
      <tr>
        <td class="gray">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2">
          <xsl:value-of select="@rm_guid"/>:1401
        </td>
      </tr>
      <tr>
        <td width="30%" class="gray">Дата измерения:</td>
        <td width="40%">
          <xsl:value-of select="@izm_date"/>
        </td>
      </tr>
      <tr>
        <td colspan="2" align="left" class="gray">Краткое описание выполняемой работы:</td>
      </tr>
      <tr>
        <td colspan="2" align="left">
          <xsl:value-of select="@descr"/>
        </td>
      </tr>
    </table>

    <!-- Таблица 1402. Б. Сведения об условиях проведения измерений  -->
    <p class="t_name">
      Б. Сведения об условиях проведения измерений. РМ № <xsl:value-of select="@rm_code"/>
    </p>
    <table width="100%">
      <tr>
        <td class="gray">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="4">
          <xsl:value-of select="@rm_guid"/>:1402
        </td>
      </tr>
      <tr>
        <td width="40%" class="gray">Место измерения</td>
        <td width="15%" class="gray">t, ºC</td>
        <td width="15%" class="gray">p</td>
        <td width="15%" class="gray">υ, м/с</td>
        <td width="15%" class="gray">φ, %</td>
      </tr>
      <xsl:apply-templates select="t1402"/>
    </table>

    <!-- Таблица 1403. В. Плотность сигналов  -->
    <p class="t_name">
      В. Плотность сигналов (световых, звуковых) и сообщений в среднем за 1 час работы. РМ № <xsl:value-of select="@rm_code"/>
    </p>
    <table width="100%">
      <tr>
        <td class="gray">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>:1403
        </td>
      </tr>
      <tr>
        <td width="33%" class="gray">№ интервала</td>
        <td width="33%" class="gray">Количество сигналов</td>
        <td width="33%" class="gray">Время интервала, час</td>
      </tr>
      <xsl:apply-templates select="t1403"/>
    </table>

    <!-- Таблица 1404. Г. Число производственных объектов одновремен-ного наблюдения -->
    <p class="t_name">
      Г. Число производственных объектов одновременного наблюдения. РМ № <xsl:value-of select="@rm_code"/>
    </p>
    <table width="100%">
      <tr>
        <td class="gray">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2">
          <xsl:value-of select="@rm_guid"/>:1404
        </td>
      </tr>
      <tr>
        <td width="34%" class="gray">№ единичного измерения</td>
        <td width="66%" class="gray">Количество объектов наблюдения</td>
      </tr>
      <xsl:apply-templates select="t1404"/>
    </table>

    <!-- Таблица 1405. Д. Работа с оптическими приборами (% времени смены) -->
    <p class="t_name">
      Д. Работа с оптическими приборами (% времени смены). РМ № <xsl:value-of select="@rm_code"/>
    </p>
    <table width="100%">
      <tr>
        <td class="gray">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>:1405
        </td>
      </tr>
      <tr>
        <td width="33%" class="gray">№ интервала</td>
        <td width="33%" class="gray">Время работы, мин</td>
        <td width="33%" class="gray">Время интервала, мин</td>
      </tr>
      <xsl:apply-templates select="t1405"/>
    </table>

    <!-- Таблица 1406. Е. Нагрузка на голосовой аппарат (суммарное количество часов, наговариваемое в неделю) -->
    <p class="t_name">
      Е. Нагрузка на голосовой аппарат (суммарное количество часов, наговариваемое в неделю). РМ № <xsl:value-of select="@rm_code"/>
    </p>
    <table width="100%">
      <tr>
        <td class="gray">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2">
          <xsl:value-of select="@rm_guid"/>:1406
        </td>
      </tr>
      <tr>
        <td width="33%" class="gray">№ смены</td>
        <td width="67%" class="gray">Кол-во часов (ввод нескольких значений через ";")</td>
      </tr>
      <xsl:apply-templates select="t1406"/>
    </table>

    <!-- Таблица 1407. Ж. Нагрузка на слуховой анализатор (при производственной необходимости восприятия речи или дифференцированных сигналов) -->
    <p class="t_name">
      Ж. Нагрузка на слуховой анализатор (при производственной необходимости восприятия речи или дифференцированных сигналов). РМ № <xsl:value-of select="@rm_code"/>
    </p>
    <table width="100%">
      <tr>
        <td class="gray">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2">
          <xsl:value-of select="@rm_guid"/>:1407
        </td>
      </tr>
      <tr>
        <td width="67%" class="gray">Результат экспертной оценки (числовое значение):</td>
        <td width="33%">
          <xsl:value-of select="@t1407_col"/>
        </td>
      </tr>
    </table>

    <!-- Таблица 1408. З.Длительность сосредоточенного наблюдения (% времени смены) -->
    <p class="t_name">
      З. Длительность сосредоточенного наблюдения (% времени смены). РМ № <xsl:value-of select="@rm_code"/>
    </p>
    <table width="100%">
      <tr>
        <td class="gray">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>:1408
        </td>
      </tr>
      <tr>
        <td width="33%" class="gray">№ интервала</td>
        <td width="33%" class="gray">Сосредоточенное наблюдение, мин</td>
        <td width="33%" class="gray">Время интервала, мин</td>
      </tr>
      <xsl:apply-templates select="t1408"/>
    </table>

    <!-- Таблица 1409. И. Число элементов (приемов), необходимых для реализации простого задания или многократно повторяющихся операций -->
    <p class="t_name">
      И. Число элементов (приемов), необходимых для реализации простого задания или многократно повторяющихся операций. РМ № <xsl:value-of select="@rm_code"/>
    </p>
    <table width="100%">
      <tr>
        <td class="gray">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2">
          <xsl:value-of select="@rm_guid"/>:1409
        </td>
      </tr>
      <tr>
        <td width="33%" class="gray">№ интервала</td>
        <td width="67%" class="gray">Число элементов</td>
      </tr>
      <xsl:apply-templates select="t1409"/>
    </table>

    <!-- Таблица 1410. К. Монотонность производственной обстановки (время пассивного наблюдения за ходом технологического процесса в % от времени смены) -->
    <p class="t_name">
      К. Монотонность производственной обстановки (время пассивного наблюдения за ходом технологического процесса в % от времени смены). РМ № <xsl:value-of select="@rm_code"/>
    </p>
    <table width="100%">
      <tr>
        <td class="gray">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>:1410
        </td>
      </tr>
      <tr>
        <td width="33%" class="gray">№ интервала</td>
        <td width="34%" class="gray">Пассивное наблюдение, мин</td>
        <td width="33%" class="gray">Время интервала, мин</td>
      </tr>
      <xsl:apply-templates select="t1410"/>
    </table>

    <!-- Таблица 1411. Л. Время активного наблюдения за ходом производственного процесса (% времени смены) -->
    <p class="t_name">
      Л. Время активного наблюдения за ходом производственного процесса (% времени смены). РМ № <xsl:value-of select="@rm_code"/>
    </p>
    <table width="100%">
      <tr>
        <td class="gray">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>:1411
        </td>
      </tr>
      <tr>
        <td width="33%" class="gray">№ интервала</td>
        <td width="34%" class="gray">Активное наблюдение, мин</td>
        <td width="33%" class="gray">Время интервала, мин</td>
      </tr>
      <xsl:apply-templates select="t1411"/>
    </table>


  </xsl:template>

  <xsl:template match ="t1402">
    <tr>
      <td align="left">
        <xsl:value-of select="@place"/>
      </td>
      <td>
        <xsl:value-of select="@temp"/>
      </td>
      <td>
        <xsl:value-of select="@press"/>
      </td>
      <td>
        <xsl:value-of select="@skor"/>
      </td>
      <td>
        <xsl:value-of select="@vlag"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1403">
    <tr>
      <td>
        <xsl:value-of select="position()" />
      </td>
      <td>
        <xsl:value-of select="@col"/>
      </td>
      <td>
        <xsl:value-of select="@time_ivl"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1404">
    <tr>
      <td>
        <xsl:value-of select="position()" />
      </td>
      <td>
        <xsl:value-of select="@col"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1405">
    <tr>
      <td>
        <xsl:value-of select="position()" />
      </td>
      <td>
        <xsl:value-of select="@time_work"/>
      </td>
      <td>
        <xsl:value-of select="@time_ivl"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1406">
    <tr>
      <td>
        <xsl:value-of select="position()" />
      </td>
      <td>
        <xsl:value-of select="@col"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1408">
    <tr>
      <td>
        <xsl:value-of select="position()" />
      </td>
      <td>
        <xsl:value-of select="@time_work"/>
      </td>
      <td>
        <xsl:value-of select="@time_ivl"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1409">
    <tr>
      <td>
        <xsl:value-of select="position()" />
      </td>
      <td>
        <xsl:value-of select="@col"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1410">
    <tr>
      <td>
        <xsl:value-of select="position()" />
      </td>
      <td>
        <xsl:value-of select="@time_work"/>
      </td>
      <td>
        <xsl:value-of select="@time_ivl"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1411">
    <tr>
      <td>
        <xsl:value-of select="position()" />
      </td>
      <td>
        <xsl:value-of select="@time_work"/>
      </td>
      <td>
        <xsl:value-of select="@time_ivl"/>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>
