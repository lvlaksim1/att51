<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- глобальные переменные -->
  <xsl:variable name="co_pers">
    <xsl:value-of select="count(Document/pers_exp/pers)"/>
  </xsl:variable>
  <xsl:variable name="show_podrs">
    <xsl:value-of select="Document/@show_podrs"/>
  </xsl:variable>

  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сводный протокол измерений параметров лазерного излучения</title>
      <style>
        /* Style Definitions */
        body
        {
        font-size:10.0pt;
        font-family:"Times New Roman";
        text-align:left;
        }
        p
        {
        margin-bottom:0cm;
        margin-top:0cm;
        }
        p.razdel
        {
        font-size:11.0pt;
        font-weight: bold;
        margin-top:0.1cm;
        margin-bottom:0.1cm;
        }
        .razdel2
        {
        font-size:11.0pt;
        font-weight: bold;
        }

        .underline
        {
        text-decoration: underline;
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
        tr.prot {
        font-weight: bold;
        }
        tr.zone {
        font-weight: bold;
        }
        tr.param {
        font-size:9.0pt;
        }
        tr.param_header {
        font-size:9.0pt;
        font-weight: bold;
        }

        .prim
        {
        font-size:9.0pt;
        margin-bottom:0cm;
        margin-top:0cm;
        }

        .prim2
        {
        font-size:8.0pt;
        margin-top:0.2cm;
        margin-bottom:0cm;
        }

        .prot
        {
        font-size:12.0pt;
        font-weight: bold;
        text-align: center;
        margin-bottom:0.2cm;
        margin-top:0.2cm;
        }
        table.header
        {
        font-size:9.0pt;
        border:1px solid black;border-collapse:collapse;padding:0 0px 0 5px;
        }

        table.empty
        {
        margin-bottom:0cm;
        margin-top:0cm;
        }

        table.empty,table.empty th,table.empty td
        {
        font-size:9.0pt;
        text-align:center;
        border:none;
        background:none;
        padding:0 5px 0 5px;
        }
        table.empty td.sign {
        border-bottom: 1px solid black;
        }
        .medium
        {
        font-size:9.0pt;
        }
        .small
        {
        font-size:8.0pt;
        }
      </style>	
  </head>
	<body>
      <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <!--  Шапка протокола и сведения о работадателе -->
    <xsl:apply-templates select="org_data"/>
    <!--  Сведения о СИ -->
    <p class="razdel">
      2. Сведения о применяемых средствах измерения (СИ):
    </p>
    <xsl:apply-templates select="si_data"/>
    <p class="razdel">
      3. Сведения о средствах измерений параметров окружающей среды и вспомогательном оборудовании:
    </p>
    <xsl:apply-templates select="si_os_data"/>
    <p class="razdel">
      4. Нормативные документы, устанавливающие метод и требования к проведению измерений:
    </p>
    <xsl:apply-templates select="nd_data_izm"/>
    <p class="razdel">
      5. Нормативные документы, регламентирующие предельно допустимые уровни вредного фактора:
    </p>
    <xsl:apply-templates select="nd_data_ctl"/>
    <p class="razdel">
      6. Фактические и нормативные значения измеряемых параметров по рабочим местам:
    </p>
    <xsl:apply-templates select="prot"/>
    <p class="prim2">
      <b>Условные обозначения: </b>t - температура воздуха; p - атмосферное давление; φ - относительная влажность; υ – скорость движения воздуха;
      Tm – время интервала m;
      λ – длина волны; p – мощность излучения ЛУ; dизл - диаметр выходного луча;
      τ<sub>и</sub> – длительность импульса, с; F<sub>N</sub> – частота импульсов; t<sub>СИ,НП</sub> - длительность серии импульсов или непрерывного излучения; 
      t<sub>В</sub> - общая длительность воздействия;
      Ai -точка контроля (А1 или А2); А1 – точка измерения на границе рабочей зоны (для оценки облучения кожи); А2 - точка измерения на границе зоны возможного повреждения глаз (для оценки облучения глаз); ЛД – дозиметр лазерного излучения. Выбор точки контроля осуществляется в соответствии с ГОСТ Р 12.1.031-2010;
      Xmax – максимальное значение на интервале измерения; ПДУ1– ПДУ для хронического облучения в соответствии с СанПиН 1.2.3685-21; ПДУ2– ПДУ для однократного облучения в соответствии с СанПиН 1.2.3685-21; ОТКЛ = Xmax/ПДУ; КУТ – класс условий труда. Для дробных значений в графах ОТКЛ и КУТ в числителе указано значение для ПДУ1, а в знаменателе - для ПДУ2;
      Sa – площадь апертуры; H – Энергетическая экспозиция; E – облученность; ФАКТ = H(E) * Sa.
    </p>
    <p class="razdel">
      7. Сведения о лицах проводивших измерения:
    </p>
    <xsl:apply-templates select="pers_izm"/>
    <xsl:if test="$co_pers>0">
      <p class="razdel">
        8. Эксперт(ы) по проведению специальной оценки условий труда:
      </p>
    </xsl:if>
    <xsl:apply-templates select="pers_exp"/>
    <!-- Ответсвенное лицо - заполняется опционально (если имеется в протоколах на РМ) -->
    <xsl:if test="pers_boss">
      <p class="razdel">
        9. Ответственное лицо организации, проводящей специальную оценку условий труда:
      </p>
      <xsl:apply-templates select="pers_boss"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="org_data">
    <!--  Шапка протокола -->
    <table width="100%" class="header">
      <tr>
        <td colspan="3">
          <xsl:value-of select="@org_info" />
        </td>
      </tr>
      <tr>
        <td colspan="3">
          <sup>
            (полное наименование организации, проводящей специальную оценку условий труда,
            регистрационный номер записи в реестре организаций, проводящих специальную оценку условий труда)
          </sup>
        </td>
      </tr>
      <tr>
        <td width="60%">
          Уникальный номер записи об аккредитации в реестре аккредитованных лиц
        </td>
        <td width="20%">Дата получения</td>
        <td width="20%">Дата окончания </td>
      </tr>
      <xsl:for-each select="//Document/org_data/lab">
        <tr>
          <td>
            <xsl:value-of select="@license"/>
          </td>
          <td>
            <xsl:value-of select="@beg_date"/>
          </td>
          <td>
            <xsl:value-of select="@end_date"/>
          </td>
        </tr>
      </xsl:for-each>
    </table>

    <!--  Наименование протокола -->
    <p class="prot">
      СВОДНЫЙ ПРОТОКОЛ<br/>измерений параметров лазерного излучения
    </p>

    <!--  Таблица для номера протокола -->
    <table align="center" class="empty">
      <tr>
        <td>№</td>
        <td class="sign">
          <xsl:value-of select="../@num_prot"/>
        </td>
        <td width="5%">
          <span style='display:none'>~$~$~</span>
        </td>
        <td class="sign">
          <xsl:value-of select="../@fill_date"/>
        </td>
      </tr>
      <tr>
        <td></td>
        <td>
          <sup>(идентификационный номер протокола)</sup>
        </td>
        <td></td>
        <td>
          <sup>(дата)</sup>
        </td>
      </tr>
    </table>
    <!--  Сведения о работдателе -->
    <p class="razdel">
      1. Сведения о работодателе:
    </p>
    <p>
      1.1. Наименование работодателя: <span class="underline"><xsl:value-of select="@rbtd_name"/></span>
      <br/>
      1.2. Место нахождения и место осуществления деятельности работодателя: <span class="underline"><xsl:value-of select="@rbtd_adr"/>
      </span>
    </p>
  </xsl:template>

  <xsl:template match ="nd_data_izm|nd_data_ctl">
    <table width="100%">
      <tr>
        <td width="5%">№</td>
        <td width="95%">Наименование нормативного документа (НД)</td>
      </tr>
      <xsl:apply-templates select="nd"/>
    </table>
  </xsl:template>

  <xsl:template match ="nd">
    <tr>
      <td>
        <xsl:value-of select="@num"/>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
      </td>
    </tr>
  </xsl:template>


  <xsl:template match ="si_data|si_os_data">
    <table>
      <tr>
        <td width="5%">№</td>
        <td width="30%">Наименование средства измерения</td>
        <td width="10%">Заводской номер</td>
        <td width="10%">Сведения о поверке</td>
        <td width="10%">Действие поверки</td>
        <td width="15%">Погрешность измерения</td>
        <td width="20%">Условия эксплуатации</td>
      </tr>
      <xsl:apply-templates select="si"/>
    </table>
  </xsl:template>

  <xsl:template match ="si">
    <tr>
      <td>
        <xsl:value-of select="@num"/>
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@factory_num"/>
      </td>
      <td>
        <xsl:value-of select="@num_doc2"/>
      </td>
      <td>
        <xsl:value-of select="@begin_date"/>-<xsl:value-of select="@end_date"/>
      </td>
      <td>
        <xsl:value-of select="@si_err"/>
      </td>
      <td>
        <xsl:value-of select="@si_cond"/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="podr">
    <tr>
      <td colspan="6">
        <xsl:value-of select="@name"/>
      </td>
    </tr>
  </xsl:template>

  <!-- В данном блоке находится специфика по каждому фактору -->
  <xsl:template match ="prot">
    <p>
      <span class="razdel2"><xsl:value-of select="count(preceding-sibling::prot)+1"/>) Рабочее место № <xsl:value-of select="@code"/>:</span>
      <br/>
      <b>Наименование</b>: <xsl:value-of select="@name"/>; <b>Код по ОК 016-94</b>: <xsl:value-of select="@ok016"/>
      <xsl:if test="$show_podrs='true'">
        <br/>
        <b>Наименование структурного подразделения</b>: <xsl:value-of select="@podr"/>
      </xsl:if>
      <br/>
      <b>Дата измерения</b>: <xsl:value-of select="@izm_date"/>
    </p>
    <p>
      <b>Сведения об условиях проведения измерений:</b>
    </p>
    <xsl:apply-templates select="os_data"/>
    <p>
      <b>Интервалы проведения измерений параметров лазерного излучения:</b>
    </p>
    <xsl:apply-templates select="tables/intervals"/>
    <p>
      <b>Сведения о лазерной установке (ЛУ):</b>
    </p>
    <xsl:apply-templates select="tables/lu_info"/>
    <p>
      <b>Режим генерации ЛУ на интервале измерения:</b>
    </p>
    <xsl:apply-templates select="tables/regim_info"/>
    <p>
      <b>Вид облучения по времени воздействия: </b>
      <xsl:value-of select="@ExposureType"/>
    </p>
    <p>
      <b>Результаты измерения:</b>
    </p>
    <xsl:apply-templates select="tables/results"/>
    <p>
      <b>Результат оценки лазерного излучения:</b>
    </p>
    <xsl:apply-templates select="tables/results_kut"/>
    <p>
      <b>Результат расчета энергетических параметров ЛИ, выраженных в единицах энергии (Дж) и/или мощности (Вт):</b>
    </p>
    <xsl:apply-templates select="tables/results_energy"/>
    <p>
      <b>Заключение</b>:
      <br/>
      <xsl:value-of select="@zakl"/>
      <br/>
      - класс (подкласс) условий труда - <xsl:value-of select="@kut"/>
    </p>
  </xsl:template>


  <xsl:template match ="results_energy">
    <table>
      <tr>
        <td width="5%">№ п/п</td>
        <td width="30%">Наименование измеряемого параметра</td>
        <td width="5%">
          A<sub>i</sub>
        </td>
        <td width="7%">№ m</td>
        <td width="25%">Измеренное значение параметра ЛИ</td>
        <td width="7%">Sa, см²</td>
        <td width="7%">ФАКТ</td>
        <td width="7%">ПДУ<sub>1</sub></td>
        <td width="7%">ПДУ<sub>2</sub></td>
      </tr>
      <xsl:apply-templates select="param" mode="results_energy"/>
    </table>
  </xsl:template>

  <xsl:template match ="param" mode="results_energy">
    <tr>
      <!-- СТРОКИ!!! -->
      <td>
        <xsl:number/>
      </td>
      <td align="left">
        <xsl:value-of select="@param_name"/>
      </td>
      <td>
        <xsl:value-of select="@A_name"/>
      </td>
      <td>
        <xsl:value-of select="@m"/>
      </td>
      <td>
        <xsl:value-of select="@fact_max"/>
      </td>
      <td>
        <xsl:value-of select="@S"/>
      </td>
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:value-of select="@pdu1"/>
      </td>
      <td>
        <xsl:value-of select="@pdu2"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="results_kut">
    <table>
      <tr>
        <td width="5%">№ п/п</td>
        <td width="25%">Наименование измеряемого параметра</td>
        <td width="5%">
          A<sub>i</sub>
        </td>
        <td width="5%">№ m</td>
        <td width="5%">Xmax</td>
        <td width="5%">U095</td>
        <td width="5%">
          ПДУ<sub>1</sub>
        </td>
        <td width="5%">
          ПДУ<sub>2</sub>
        </td>
        <td width="5%">ОТКЛ</td>
        <td width="5%">КУТ</td>
      </tr>
      <xsl:apply-templates select="param" mode="results_kut"/>
    </table>
  </xsl:template>

  <xsl:template match ="param" mode="results_kut">
    <tr>
      <!-- СТРОКИ!!! -->
      <td>
        <xsl:number/>
      </td>
      <td align="left">
        <xsl:value-of select="@param_name"/>
      </td>
      <td>
        <xsl:value-of select="@A_name"/>
      </td>
      <td>
        <xsl:value-of select="@m"/>
      </td>
      <td>
        <xsl:value-of select="@fact_max"/>
      </td>
      <td>
        <xsl:value-of select="@fact_unc"/>
      </td>
      <td>
        <xsl:value-of select="@pdu1"/>
      </td>
      <td>
        <xsl:value-of select="@pdu2"/>
      </td>
      <td>
        <xsl:value-of select="@otkl"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
  </xsl:template>
  

  <xsl:template match ="results">
    <table>
      <tr>
        <td rowspan="2" width="5%">№ п/п</td>
        <td rowspan="2" width="25%">Наименование измеряемого параметра</td>
        <td rowspan="2" width="5%">A<sub>i</sub></td>
        <td rowspan="2" width="5%">№ m</td>
        <td width="60%" colspan="5" class="medium">
          Результаты измерения с учетом отклонения оси визирования ЛД на 3±0.5º<br/>
          (1- без отклонения, 2 – вверх, 3 – вниз, 4 – влево, 5 - вправо)
        </td>
      </tr>
      <tr>
        <td width="12%">1</td>
        <td width="12%">2</td>
        <td width="12%">3</td>
        <td width="12%">4</td>
        <td width="12%">5</td>
      </tr>
      <xsl:apply-templates select="param" mode="results"/>
    </table>
  </xsl:template>

  <xsl:template match ="param" mode="results">
    <tr>
      <!-- СТРОКИ!!! -->
      <td>
        <xsl:number/>
      </td>
      <td align="left">
        <xsl:value-of select="@param_name"/>
      </td>
      <td>
        <xsl:value-of select="@A_name"/>
      </td>
      <td>
        <xsl:value-of select="@m"/>
      </td>
      <td>
        <xsl:value-of select="@fact1"/>
      </td>
      <td>
        <xsl:value-of select="@fact2"/>
      </td>
      <td>
        <xsl:value-of select="@fact3"/>
      </td>
      <td>
        <xsl:value-of select="@fact4"/>
      </td>
      <td>
        <xsl:value-of select="@fact5"/>
      </td>
    </tr>
  </xsl:template> 
  
  <xsl:template match ="regim_info">
    <table>
      <tr>
        <td width="5%">№ п/п</td>
        <td width="35%">Наименование ЛУ</td>
        <td width="20%">Вид излучения</td>
        <td width="10%">τ<sub>и</sub>, с</td>
        <td width="10%">F<sub>N</sub>, Гц</td>
        <td width="10%">t<sub>СИ,НП</sub>, с</td>
        <td width="10%">t<sub>В</sub>, с</td>
      </tr>
      <xsl:apply-templates select="param" mode="regim_info"/>
    </table>
  </xsl:template>

  <xsl:template match ="param" mode="regim_info">
    <tr>
      <!-- СТРОКИ!!! -->
      <td>
        <xsl:number/>
      </td>
      <td align="left">
        <xsl:value-of select="@lu_name"/>
      </td>
      <td>
        <xsl:value-of select="@regim_name"/>
      </td>
      <td>
        <xsl:value-of select="@Timp"/>
      </td>
      <td>
        <xsl:value-of select="@Fimp"/>
      </td>
      <td>
        <xsl:value-of select="@Tsi"/>
      </td>
      <td>
        <xsl:value-of select="@Tsum"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="lu_info">
    <table>
      <tr>
        <td width="5%">№ п/п</td>
        <td width="25%">Наименование ЛУ</td>
        <td width="10%">λ, нм</td>
        <td width="10%">Класс опасности</td>
        <td width="10%">P, Вт</td>
        <td width="10%">dизл, мм</td>
        <td width="30%">Дополнительные сведения о лазерной установке</td>
      </tr>
      <xsl:apply-templates select="param" mode="lu_info"/>
    </table>
  </xsl:template>

  <xsl:template match ="param" mode="lu_info">
    <tr>
      <!-- СТРОКИ!!! -->
      <td>
        <xsl:number/>
      </td>
      <td align="left">
        <xsl:value-of select="@lu_name"/>
      </td>
      <td>
        <xsl:value-of select="@wave"/>
      </td>
      <td>
        <xsl:value-of select="@lu_class"/>
      </td>
      <td>
        <xsl:value-of select="@power"/>
      </td>
      <td>
        <xsl:value-of select="@d_mm"/>
      </td>
      <td align="left">
        <xsl:value-of select="@descr"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="intervals">
    <table>
      <tr>
        <td width="5%">№ m</td>
        <td width="25%">Место проведения измерения (наименование интервала)</td>
        <td width="5%">Tm, мин</td>
        <td width="5%">Tm, час</td>
        <td width="10%">Дата измерения</td>
        <td width="35%">Источник лазерного излучения<br/>(лазерная установка)</td>
      </tr>
      <xsl:apply-templates select="param" mode="intervals"/>
    </table>
  </xsl:template>
  
  <xsl:template match ="param" mode="intervals">
    <tr>
      <!-- СТРОКИ!!! -->
      <td>
        <xsl:number/>
      </td>
      <td align="left">
        <xsl:value-of select="@zone_name"/>
      </td>
      <td>
        <xsl:value-of select="@zone_time"/>
      </td>
      <td>
        <xsl:value-of select="@zone_time_h"/>
      </td>
      <td>
        <xsl:value-of select="@izm_date"/>
      </td>
      <td align="left">
        <xsl:value-of select="@descr_lu"/>
      </td>
    </tr>
  </xsl:template>
  

  <xsl:template match ="pers_izm|pers_exp">
    <table width="100%" class="empty">
      <xsl:apply-templates select="pers"/>
    </table>
  </xsl:template>
  
  <xsl:template match ="pers">
    <tr>
      <td class="sign" width="15%">
        <xsl:value-of select="@reg_num" />
      </td>
      <td width="5%">
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </td>
      <td class="sign" width="25%">
        <xsl:value-of select="@dolg" />
      </td>
      <td width="5%">
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </td>
      <td class="sign" width="15%">
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </td>
      <td width="5%">
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </td>
      <td class="sign" width="30%">
        <xsl:value-of select="@fio" />
      </td>
    </tr>
    <tr>
      <td>
        <sup>№ в реестре</sup>
      </td>
      <td>
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </td>
      <td>
        <sup>Должность</sup>
      </td>
      <td>
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </td>
      <td>
        <sup>Подпись</sup>
      </td>
      <td>
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </td>
      <td>
        <sup>Ф.И.О.</sup>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="pers_boss">
    <table width="100%" class="empty">
      <xsl:apply-templates select="pers" mode="m2"/>
    </table>
  </xsl:template>


  <xsl:template  match ="pers" mode="m2">
    <tr>
      <td class="sign" width="25%">
        <xsl:value-of select="@dolg" />
      </td>
      <td width="5%">
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </td>
      <td class="sign" width="15%">
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </td>
      <td width="5%">
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </td>
      <td class="sign" width="30%">
        <xsl:value-of select="@fio" />
      </td>
    </tr>
    <tr>
      <td>
        <sup>Должность</sup>
      </td>
      <td>
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </td>
      <td>
        <sup>Подпись</sup>
      </td>
      <td>
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </td>
      <td>
        <sup>Ф.И.О.</sup>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match ="os_data">
    <table width="100%">
      <tr>
        <td width="8%">№</td>
        <td width="44%">Место измерения</td>
        <td width="12%">t, ºC</td>
        <td width="12%">p, мм.рт.ст.</td>
        <td width="12%">υ, м/с</td>
        <td width="12%">φ, %</td>
      </tr>
      <xsl:apply-templates select="os_item"/>
    </table>
  </xsl:template>

  <xsl:template match ="os_item">
    <tr>
      <td>
        <xsl:value-of select="@num" />
      </td>
      <td>
        <xsl:value-of select="@name" />
      </td>
      <td>
        <xsl:value-of select="@os_t" />
      </td>
      <td>
        <xsl:value-of select="@os_p" />
      </td>
      <td>
        <xsl:value-of select="@os_sk" />
      </td>
      <td>
        <xsl:value-of select="@os_v" />
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>