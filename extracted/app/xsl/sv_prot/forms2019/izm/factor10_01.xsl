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
	    <title>Сводный протокол измерений параметров ионизирующего излучения</title>
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
      4. Нормативные документы, устанавливающие метод и требования проведения к проведению измерений:
    </p>
    <xsl:apply-templates select="nd_data_izm"/>
    <p class="razdel">
      5. Измеряемые показатели и методы контроля (СИ, НД):
    </p>
    <xsl:apply-templates select="si_nd_data"/>
    <p class="razdel">
      6. Нормативные документы, регламентирующие предельно допустимые уровни вредного фактора:
    </p>
    <xsl:apply-templates select="nd_data_ctl"/>
    <p class="razdel">
      7. Фактические и нормативные значения измеряемых параметров по рабочим местам:
    </p>
    <p class="prim">
      Условные обозначения: ИИ – ионизирующее излучение; ПДУ – предельно-допустимый уровень; U095 – значение расширенной неопределенности; ОТКЛ - отклонение;
      t - температура воздуха; p - атмосферное давление; φ - относительная влажность; υ – скорость движения воздуха;
      m – интервал измерения в соответствии с МИ ИИ.ИНТ-14.01-2018; Tm,i – приведенное к 480 мин время интервала m по наблюдениям; Тm – среднее приведенное время интервала m;
      МПД – максимальная потенциальная доза за год; ПД – предельная доза, установленная для спе-циальной оценки условий труда; ОТКЛ = МПД / ПД.
    </p>
    <xsl:apply-templates select="prot"/>
    <p class="razdel">
      8. Сведения о лицах проводивших измерения:
    </p>
    <xsl:apply-templates select="pers_izm"/>
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
      ПРОТОКОЛ<br/>измерений параметров ионизирующего излучения
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

  <xsl:template match ="pers_izm">
    
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
      <br/>
      <b>Категория облучаемых лиц по НРБ-99/2009:</b>: <xsl:value-of select="@personal"/>
    </p>
    <p>
      <b>Сведения об условиях проведения измерений:</b>
    </p>
    <xsl:apply-templates select="os_data"/>
    <p>
      <b>Интервалы проведения измерений параметров ИИ:</b>
    </p>
    <xsl:apply-templates select="table"/>

    <p>
      <b>Сведения об измерениях параметров ИИ (мощность дозы внешнего облучения):</b>
    </p>
    <xsl:apply-templates select="table2"/>

    <!--Сведения о наличии радионуклидов на рабочем месте в виде аэрозолей или газов (внут-реннее облучение)-->
    <xsl:apply-templates select="table4"/>
    
    <p>
      <b>Результат оценки максимальной потенциальной дозы ИИ:</b>
    </p>
    <xsl:apply-templates select="table3"/>
    <p>
      <b>Заключение</b>:
      <br/>
      <xsl:value-of select="@zakl"/>
    </p>
  </xsl:template>

  <xsl:template match ="table">
    <table>
      <tr>
        <td width="5%">№ m</td>
        <td width="30%">Место проведения измерения (наименование интервала)</td>
        <td width="5%">Tm, мин</td>
        <td width="10%">Дата измерения</td>
        <td width="35%">Краткое описание источников ИИ</td>
      </tr>
      <xsl:apply-templates select="param"/>
    </table>
  </xsl:template>
  
  <xsl:template match ="param">
    <tr>
      <!-- СТРОКИ!!! -->
      <td>
        <xsl:value-of select="@num"/>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@time_min"/>
      </td>
      <td align="left">
        <xsl:value-of select="@izm_date"/>
      </td>
      <td>
        <xsl:value-of select="@descr"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="table2">
    <table>
      <tr>
        <td width="5%">№ m</td>
        <td width="40%">Место проведения измерения, наименование параметра измеряемого показателя</td>
        <td width="10%">Вид дозы (нормируемая величина)</td>
        <td width="15%">Результат измерения (i=1;2;3)</td>
        <td width="10%">Тизм, сек</td>
        <td width="10%">ФАКТ</td>
        <td width="10%">U095</td>
      </tr>
      <xsl:apply-templates select="param2"/>
    </table>
  </xsl:template>

  <xsl:template match ="param2">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <td>
        <xsl:value-of select="@num"/>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@dose_type"/>
      </td>
      <td>
        <xsl:value-of select="@results"/>
      </td>
      <td>
        <xsl:value-of select="@izm_time"/>
      </td>
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:value-of select="@U095"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="table3">
    <table width="100%">
      <tr>
        <td width="5%">№ п/п</td>
        <td width="40%">Место проведения измерения (наименование интервала)</td>
        <td width="25%">Вид дозы (нормируемая величина)</td>
        <td width="10%">МПД, мЗв/год</td>
        <td width="10%">ПД, мЗв/год</td>
        <td width="10%">ОТКЛ</td>
      </tr>
      <xsl:apply-templates select="param3"/>
    </table>
  </xsl:template>

  <xsl:template match ="param3">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <td>
        <xsl:value-of select="@num"/>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@diap"/>
      </td>
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:value-of select="@pdu"/>
      </td>
      <td>
        <xsl:value-of select="@otkl"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="table4">
    <p>
      <b>Сведения о наличии радионуклидов на рабочем месте в виде аэрозолей или газов (внутреннее облучение):</b>
    </p>
    <table width="100%">
      <tr>
        <td width="5%">№ п/п</td>
        <td width="30%">Наименование соединения радионуклида</td>
        <td width="25%">Место измерения</td>
        <td width="10%">Объемная активность, Бк/м3</td>
        <td width="10%">Дозовый коэффициент, Зв/Бк</td>
      </tr>
      <xsl:apply-templates select="param4"/>
    </table>
  </xsl:template>

  <xsl:template match ="param4">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <td>
        <xsl:value-of select="@num"/>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@zone_name"/>
      </td>
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:value-of select="@epsilon"/>
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

  <xsl:template match ="si_nd_data">
    <table width="100%">
      <tr>
        <td width="8%">№</td>
        <td width="62%">Наименование вредного вещества</td>
        <td width="15%">№ СИ из п.2</td>
        <td width="15%">№ НД из п.4</td>
      </tr>
      <xsl:apply-templates select="si_nd_param"/>
    </table>
  </xsl:template>


  <xsl:template match ="si_nd_param">
    <tr>
      <td>
        <xsl:value-of select="count(preceding-sibling::si_nd_param)+1"/>
      </td>
      <td>
        <xsl:value-of select="@name" />
      </td>
      <td>
        <xsl:value-of select="@si_nums" />
      </td>
      <td>
        <xsl:value-of select="@nd_nums" />
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>