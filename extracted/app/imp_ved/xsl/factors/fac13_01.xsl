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
    <h1>Форма для сбора сведений по показателям тяжести трудового процесса (для протоколов по МИ ТТП.ИНТ-16.01-2018)</h1>
    <xsl:apply-templates/>
    <p class="prim">
      <b>Примечание:</b><br/>
      * - графа «№ смены» заполняется только в том случае, если для протокола настроен учет сведений за несколько смен (доп.опции в настройках протокола);<br/>
      ** - длина шага заполняется в случае указания единиц измерения в шагах («ш»)<br/>
      Порядок заполнения: ввод сведений производится только в ячейки с белым фоном. Для большинства таблиц предусмотрено несколько строк заполнения сведений.
      Дополнительные строки добавляются (в конец таблицы) пользователем самостоятельно  за счет средств MS Word (клавиша «Tab» или другие способы).<br/>
      Примечание к пункту Д:<br/>1. Нельзя для оценки одного показателя использовать два разных способа учета.<br/>
      2. Время выборочного интервала (2 способ) обычно составляет 10-15 мин.
    </p>
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
    
    <!-- Таблица 1301. А. Общие сведения  -->
    <p class="t_name">А. Общие сведения (РМ № <xsl:value-of select="@rm_code"/>)</p>
    <table width="100%">
      <tr>
        <td class="gray">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="3">
          <xsl:value-of select="@rm_guid"/>:1301
        </td>
      </tr>
      <tr>
        <td width="30%" class="gray">Дата измерения:</td>
        <td width="40%">
          <xsl:value-of select="@izm_date"/>
        </td>
        <td width="20%" class="gray">Пол (м/ж)</td>
        <td width="10%">
          <xsl:value-of select="@sex"/>
        </td>
      </tr>
      <tr>
        <td colspan="4" align="left" class="gray">Краткое описание выполняемой работы:</td>
      </tr>
      <tr>
        <td colspan="4" align="left">
          <xsl:value-of select="@descr"/>
        </td>
      </tr>
      <tr>
        <td colspan="4" align="left" class="gray">Сведения об оцениваемых показателях (масса груза), полученных из эксплуатационной и технологической документации:</td>
      </tr>
      <tr>
        <td colspan="4" align="left">
          <xsl:value-of select="@rbtd_docs"/>
        </td>
      </tr>
    </table>

    <!-- Таблица 1302. Б. Сведения об условиях проведения измерений  -->
    <p class="t_name">
      Б. Сведения об условиях проведения измерений (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="4">
          <xsl:value-of select="@rm_guid"/>:1302
        </td>
      </tr>
      <tr>
        <td width="40%" class="gray">Место измерения</td>
        <td width="15%" class="gray">t, ºC</td>
        <td width="15%" class="gray">p</td>
        <td width="15%" class="gray">υ, м/с</td>
        <td width="15%" class="gray">φ, %</td>
      </tr>
      <xsl:apply-templates select="t1302"/>
    </table>

    <!-- Таблица 1303. В. Физическая динамическая нагрузка  -->
    <p class="t_name">
      В. Физическая динамическая нагрузка (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>:1303
        </td>
      </tr>
      <tr>
        <td width="25%" class="gray">Масса груза, кг</td>
        <td width="25%" class="gray">Расстояние, м</td>
        <td width="35%" class="gray">Кол-во перемещений</td>
        <td width="15%" class="gray">№ смены*</td>
      </tr>
      <xsl:apply-templates select="t1303"/>
    </table>

    <!-- Таблица 1304. Г. Масса поднимаемого и перемещаемого груза вручную  -->
    <p class="t_name">
      Г. Масса поднимаемого и перемещаемого груза вручную (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>:1304
        </td>
      </tr>
      <tr>
        <td class="gray" colspan="4">
          Подъем и перемещение тяжести (в зависимости от частоты повторения)
        </td>
      </tr>
      <tr>
        <td width="35%" class="gray">до 2-х раз в час, кг:</td>
        <td width="20%">
          <xsl:value-of select="@massa1"/>
        </td>
        <td width="30%" class="gray">более 2 раз в час, кг:</td>
        <td width="15%">
          <xsl:value-of select="@massa2"/>
        </td>
      </tr>
      <tr>
        <td width="35%" class="gray">
          Код перемещения («1» или «2»)
          «1» - с раб. поверхности, «2» - с пола
        </td>
        <td width="20%" class="gray">Масса груза, кг</td>
        <td width="30%" class="gray">Кол-во перемещений</td>
        <td width="15%" class="gray">№ смены*</td>
      </tr>
      <xsl:apply-templates select="t1304"/>
    </table>

    <!-- Таблица 1305. Д.1. Стереотипные рабочие движения (способ 1)  -->
    <p class="t_name">
      Д.1. Стереотипные рабочие движения, способ 1 (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>:1305
        </td>
      </tr>
      <tr>
        <td width="35%" class="gray">
          Код нагрузки («1» или «2»)
          «1» - локальная, «2» - региональная
        </td>
        <td width="30%" class="gray">Кол-во движений за операцию</td>
        <td width="20%" class="gray">Кол-во операций</td>
        <td width="15%" class="gray">№ смены*</td>
      </tr>
      <xsl:apply-templates select="t1305"/>
    </table>

    <!-- Таблица 1306. Д.2. Стереотипные рабочие движения (способ 2)  -->
    <p class="t_name">
      Д.2. Стереотипные рабочие движения, способ 2 (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="3">
          <xsl:value-of select="@rm_guid"/>:1306
        </td>
      </tr>
      <tr>
        <td width="25%" class="gray">
          Код нагрузки («1» или «2»)
          «1» - локальная, «2» - региональная
        </td>
        <td width="20%" class="gray">Время операции, мин</td>
        <td width="20%" class="gray">Кол-во движений за выборочный интервал </td>
        <td width="20%" class="gray">Время интервала, мин</td>
        <td width="15%" class="gray">№ смены*</td>
      </tr>
      <xsl:apply-templates select="t1306"/>
    </table>

    <!-- Таблица 1307. Е. Статическая нагрузка  -->
    <p class="t_name">
      Е. Статическая нагрузка (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="3">
          <xsl:value-of select="@rm_guid"/>:1307
        </td>
      </tr>
      <tr>
        <td class="gray" colspan="2">Единицы измерения усилий/нагрузки, «кг» или «Н» («Н» - усилие в ньютонах ) по видам нагрузки (1,2,3):</td>
        <td>
          <xsl:value-of select="@t1307_ed1"/>
        </td>
        <td>
          <xsl:value-of select="@t1307_ed2"/>
        </td>
        <td>
          <xsl:value-of select="@t1307_ed3"/>
        </td>
      </tr>
      <tr>
        <td width="30%" class="gray">
          Код нагрузки («1», «2» или «3»)
          «1» - одной рукой, «2» - двумя руками, «3» -региональная
        </td>
        <td width="30%" class="gray">Масса, кг (усилие, Н)</td>
        <td width="20%" class="gray">Время, с</td>
        <td width="20%" class="gray">Кол-во операций</td>
        <td width="20%" class="gray">№ смены*</td>
      </tr>
      <xsl:apply-templates select="t1307"/>
    </table>


    <!-- Таблица 1308. Ж. Рабочая поза -->
    <p class="t_name">
      Ж. Рабочая поза (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="2">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="4">
          <xsl:value-of select="@rm_guid"/>:1308
        </td>
      </tr>
      <tr>
        <td class="gray" colspan="2">
          Единица измерения («%» или «мин»)
        </td>
        <td>
          <xsl:value-of select="@t1308_ed"/>
        </td>
        <td class="gray" colspan="2">Приведенное время смены, мин:</td>
        <td class="gray">480</td>
      </tr>
      <tr>
        <td colspan="6" class="gray">Время нахождения в рабочей позе за смену:</td>
      </tr>
      <tr>
        <td width="16%" class="gray">Свободная</td>
        <td width="16%" class="gray">Стоя</td>
        <td width="16%" class="gray">Неудобная</td>
        <td width="16%" class="gray">Фиксированная</td>
        <td width="16%" class="gray">Вынужденная</td>
        <td width="20%" class="gray">Сидя без перерывов</td>
      </tr>
      <xsl:apply-templates select="t1308"/>
    </table>

    <!-- Таблица 1309. З. Наклоны корпуса -->
    <p class="t_name">
      З. Наклоны корпуса (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>:1309
        </td>
      </tr>
      <tr>
        <td width="40%" class="gray">Кол-во наклонов за операцию</td>
        <td width="45%" class="gray">Кол-во операций</td>
        <td width="15%" class="gray">№ смены*</td>
     </tr>
      <xsl:apply-templates select="t1309"/>
    </table>

    <!-- Таблица 1310. И. Перемещения работника -->
    <p class="t_name">
      И. Перемещения работника (РМ № <xsl:value-of select="@rm_code"/>)
    </p>
    <table width="100%">
      <tr>
        <td class="gray">
          Идентификатор РМ/таблицы:
        </td>
        <td class="gray2" colspan="3">
          <xsl:value-of select="@rm_guid"/>:1310
        </td>
      </tr>
      <tr>
        <td  class="gray" colspan="4">Единицы измерения расстояния («м» или «ш»). По умолчанию расстояние указывается в метрах</td>
      </tr>
      <tr>
        <td class="gray">- по горизонтали:</td>
        <td>
          <xsl:value-of select="@t1310_ed_v"/>
        </td>
        <td class="gray">Длина шага, м**:</td>
        <td>
          <xsl:value-of select="@t1310_step_h"/>
        </td>
      </tr>
      <tr>
        <td class="gray">- по вертикали:</td>
        <td>
          <xsl:value-of select="@t1310_ed_v"/>
        </td>
        <td class="gray">Длина шага, м**:</td>
        <td>
          <xsl:value-of select="@t1310_step_v"/>
        </td>
      </tr>
      <tr>
        <td width="40%" class="gray">
          Код перемещения («1» или «2»)
          «1» - по горизонтали, «2» - по вертикали
        </td>
        <td width="20%" class="gray">Расстояние перемещения</td>
        <td width="25%" class="gray">Кол-во перемещений</td>
        <td width="15%" class="gray">№ смены*</td>
      </tr>
      <xsl:apply-templates select="t1310"/>
    </table>



  </xsl:template>

  <xsl:template match ="t1302">
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

  <xsl:template match ="t1303">
    <tr>
      <td>
        <xsl:value-of select="@massa"/>
      </td>
      <td>
        <xsl:value-of select="@rast"/>
      </td>
      <td>
        <xsl:value-of select="@col"/>
      </td>
      <td>
        <xsl:value-of select="@smena"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1304">
    <tr>
      <td>
        <xsl:value-of select="@code"/>
      </td>
      <td>
        <xsl:value-of select="@massa"/>
      </td>
      <td>
        <xsl:value-of select="@col"/>
      </td>
      <td>
        <xsl:value-of select="@smena"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1305">
    <tr>
      <td>
        <xsl:value-of select="@code"/>
      </td>
      <td>
        <xsl:value-of select="@col1"/>
      </td>
      <td>
        <xsl:value-of select="@col2"/>
      </td>
      <td>
        <xsl:value-of select="@smena"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1306">
    <tr>
      <td>
        <xsl:value-of select="@code"/>
      </td>
      <td>
        <xsl:value-of select="@time1"/>
      </td>
      <td>
        <xsl:value-of select="@col"/>
      </td>
      <td>
        <xsl:value-of select="@time2"/>
      </td>
      <td>
        <xsl:value-of select="@smena"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1307">
    <tr>
      <td>
        <xsl:value-of select="@code"/>
      </td>
      <td>
        <xsl:value-of select="@massa"/>
      </td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
      <td>
        <xsl:value-of select="@col"/>
      </td>
      <td>
        <xsl:value-of select="@smena"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1308">
    <tr>
      <td>
        <xsl:value-of select="@pose1"/>
      </td>
      <td>
        <xsl:value-of select="@pose2"/>
      </td>
      <td>
        <xsl:value-of select="@pose3"/>
      </td>
      <td>
        <xsl:value-of select="@pose4"/>
      </td>
      <td>
        <xsl:value-of select="@pose5"/>
      </td>
      <td>
        <xsl:value-of select="@pose6"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1309">
    <tr>
      <td>
        <xsl:value-of select="@col1"/>
      </td>
      <td>
        <xsl:value-of select="@col2"/>
      </td>
      <td>
        <xsl:value-of select="@smena"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="t1310">
    <tr>
      <td>
        <xsl:value-of select="@code"/>
      </td>
      <td>
        <xsl:value-of select="@rast"/>
      </td>
      <td>
        <xsl:value-of select="@col"/>
      </td>
      <td>
        <xsl:value-of select="@smena"/>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>
