<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <xsl:variable name="no_org">
    <xsl:value-of select="Document/table/@no_org"/>
  </xsl:variable>
  <xsl:variable name="no_signs">
    <xsl:value-of select="Document/table/@no_signs"/>
  </xsl:variable>
  <xsl:variable name="no_os_sk">
    <xsl:value-of select="Document/@no_os_sk"/>
  </xsl:variable>

  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Журнал регистрации измерений</title>
      <style>
        /* Style Definitions */
        body
        {
        font-family:arial, verdana, sans-serif;
        text-align:left;
        }
        h2
        {
        font-size:12.0pt;
        font-weight: bold;
        margin-bottom:0px;
        }
        table
        {
        font-size:9.0pt;
        font-family:arial, verdana, sans-serif;
        text-align:center;
        }
        table,th,td {
        border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
        }
        td.bold {
        font-weight: bold;
        font-size:9.0pt;
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
        height:20pt;
        vertical-align:bottom;
        }

        table.comission,table.comission th,table.comission td
        {
        font-size:10.0pt;
        text-align:center;
        border:none;
        background:none;
        padding:0 5px 0 5px;
        }
        table.comission td.sign {
        border-bottom: 1px solid black;
        }
        p.nd {
        margin-top:0px;
        margin-bottom:0px;
        }
        td.empty {
        border:none;
        }
        td.rm_num {
        vertical-align:top;
        }
      </style>
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <xsl:if test="not(@all_facs)">
      <h1>Журнал регистрации измерений</h1>
    </xsl:if>
    <xsl:if test="@all_facs">
      <h1>Световая среда</h1>
    </xsl:if>
    <xsl:apply-templates/>
    </xsl:template>

  <xsl:template match ="si_data">
    <h2>
      <xsl:if test="@num_razd">
        <xsl:value-of select="@num_razd"/>
      </xsl:if>. Сведения о средствах измерения:
    </h2>
    <table>
      <tr>
        <td width="30%">Наименование средства измерения</td>
        <td width="15%">Заводской номер</td>
        <td width="15%">№ свидетельства о поверке</td>
        <td width="20%">Действие поверки</td>
        <td width="20%">Погрешность измерения</td>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="si_os_data">
    <h2>
      <xsl:if test="@num_razd">
        <xsl:value-of select="@num_razd"/>
      </xsl:if>. Сведения о средствах измерений параметров окружающей среды и вспомогательном оборудовании:
    </h2>
    <table>
      <tr>
        <td width="30%">Наименование средства измерения</td>
        <td width="15%">Заводской номер</td>
        <td width="15%">№ свидетельства о поверке</td>
        <td width="20%">Действие поверки</td>
        <td width="20%">Погрешность измерения</td>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="si_dop_data">
    <h2>
      <xsl:if test="@num_razd">
        <xsl:value-of select="@num_razd"/>
      </xsl:if>. Сведения о вспомогательном оборудовании:
    </h2>
    <table>
      <tr>
        <td width="30%">Наименование средства измерения</td>
        <td width="15%">Заводской номер</td>
        <td width="15%">№ свидетельства о поверке</td>
        <td width="20%">Действие поверки</td>
        <td width="20%">Погрешность измерения</td>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="si">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@factory_num"/>
      </td>
      <td>
        <xsl:value-of select="@num_doc"/>
      </td>
      <td>
        <xsl:value-of select="@begin_date"/>-<xsl:value-of select="@end_date"/>
      </td>
      <td>
        <xsl:value-of select="@si_err"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="pers_data">
    <h2>
      <xsl:if test="@num_razd">
        <xsl:value-of select="@num_razd"/>
      </xsl:if>. Сотрудники организации (лаборатории), проводившие измерения:
    </h2>
    <table>
      <tr>
        <td width="30%">№ в реестре экспертов</td>
        <td width="30%">Должность</td>
        <td width="40%">Ф.И.О.</td>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="pers">
    <tr>
      <td>
        <xsl:value-of select="@reg_num"/>
      </td>
      <td>
        <xsl:value-of select="@dolg"/>
      </td>
      <td>
        <xsl:value-of select="@fio"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="org_sout_data">
    <h2>
      <xsl:if test="@num_razd">
        <xsl:value-of select="@num_razd"/>
      </xsl:if>. Сведения об организации, проводящей специальную оценку условий труда:
    </h2>
    <p class="nd">
      Наименование организации: <xsl:value-of select="@org_info"/>
    </p>
    <p class="nd">
      Адрес: <xsl:value-of select="@org_adr"/>
    </p>
    <p class="nd">
      Регистрационный номер записи в реестре организаций: <xsl:value-of select="@reg_num"/> от <xsl:value-of select="@reg_date"/>
    </p>
  </xsl:template>


  <xsl:template match ="org_data">
    <h2>
      <xsl:if test="@num_razd">
        <xsl:value-of select="@num_razd"/>
      </xsl:if>. Сведения об организации, в которой проводились измерения:
    </h2>
    <p class="nd">
      Наименование организации: <xsl:value-of select="@rbtd_name"/>
    </p>
    <p class="nd">
      Место нахождения и место осуществления деятельности работодателя: <xsl:value-of select="@rbtd_adr"/>
      <xsl:if test="@rbtd_adr2">
        ; <xsl:value-of select="@rbtd_adr2"/>
      </xsl:if>
    </p>
  </xsl:template>

  <xsl:template match ="nd_data">
    <h2>
      <xsl:if test="@num_razd">
        <xsl:value-of select="@num_razd"/>.
      </xsl:if>
      <xsl:if test="@pdu_nd=1">
        НД, устанавливающие метод проведения измерений и оценок и регламентирующие ПДК, ПДУ, нормативные значения измеряемого и оцениваемого фактора:
      </xsl:if>
      <xsl:if test="@pdu_nd=0">
        НД, устанавливающие метод и требования к проведению измерений:
      </xsl:if>
    </h2>
    <p class="nd">
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match ="nd">
    <xsl:value-of select="@name"/>;<br/>
  </xsl:template>

  <xsl:template match ="osv_data">
    <h2>
      <xsl:if test="@num_razd">
        <xsl:value-of select="@num_razd"/>
      </xsl:if>. Характеристика осветительного оборудования  (осветительных приборов):
    </h2>
    <table>
      <tr>
        <td width="20%">Наименование рабочего места</td>
        <td width="20%">Наименование рабочей зоны</td>
        <td width="10%">Тип светильников</td>
        <td width="10%">Тип ламп</td>
        <td width="10%">Мощность ламп, Вт</td>
        <td width="10%">Высота подвеса, м</td>
        <td width="10%">Доля негорящих ламп, %</td>
        <td width="10%">Напряжение сети, В (U1/U2)</td>
      </tr>
      <xsl:apply-templates select="row_osv"/>
    </table>
  </xsl:template>

  <xsl:template match ="row_osv">
    <tr>
      <xsl:if test="@rm_name">
        <td align="left">
          <xsl:attribute name="rowspan">
            <xsl:value-of select="@rowspan"/>
          </xsl:attribute>
          <xsl:value-of select="@rm_name"/>
        </td>
      </xsl:if>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@sv_type"/>
      </td>
      <td>
        <xsl:value-of select="@l_type"/>
      </td>
      <td>
        <xsl:value-of select="@Plamp"/>
      </td>
      <td>
        <xsl:value-of select="@Hlamp"/>
      </td>
      <td>
        <xsl:value-of select="@Badlamp"/>
      </td>
      <td>
        <xsl:value-of select="@Uizm"/>
      </td>
    </tr>
  </xsl:template>
  
  
  <xsl:template match ="os_data">
    <h2>
      <xsl:if test="@num_razd">
        <xsl:value-of select="@num_razd"/>
      </xsl:if>. Сведения об условиях проведения измерений:
    </h2>
    <table>
      <tr>
        <td width="30%">Наименование рабочего места</td>
        <td width="30%">Наименование рабочей зоны</td>
        <td width="15%">Температура воздуха, ºC</td>
        <td width="15%">Атмосферное давление, мм рт.ст.</td>
        <td width="15%">Относительная влажность, %</td>
        <td width="15%">Скорость движения воздуха, м/с</td>
      </tr>
      <xsl:apply-templates select="row_os"/>
    </table>
  </xsl:template>

  <xsl:template match ="row_os">
    <tr>
      <xsl:if test="@rm_name">
        <td align="left">
          <xsl:attribute name="rowspan">
            <xsl:value-of select="@rowspan"/>
          </xsl:attribute>
          <xsl:value-of select="@rm_name"/>
        </td>
      </xsl:if>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@os_t"/>
      </td>
      <td>
        <xsl:value-of select="@os_p"/>
      </td>
      <td>
        <xsl:value-of select="@os_v"/>
      </td>
      <td>
        <xsl:value-of select="@os_sk"/>
      </td>
    </tr>
  </xsl:template>


  <xsl:template match ="os_data">
    <h2>
      <xsl:if test="@num_razd">
        <xsl:value-of select="@num_razd"/>
      </xsl:if>. Сведения об условиях проведения измерений:
    </h2>
    <xsl:if test="$no_os_sk='0'">
      <table>
        <tr>
          <td width="20%">Наименование рабочего места</td>
          <td width="20%">Наименование рабочей зоны</td>
          <td width="15%">Температура воздуха, ºC</td>
          <td width="15%">Атмосферное давление, мм рт.ст.</td>
          <td width="15%">Относительная влажность, %</td>
          <td width="15%">Скорость движения воздуха, м/с</td>
        </tr>
        <xsl:apply-templates select="row_os"/>
      </table>
    </xsl:if>
    <xsl:if test="$no_os_sk='1'">
      <table>
        <tr>
          <td width="25%">Наименование рабочего места</td>
          <td width="30%">Наименование рабочей зоны</td>
          <td width="15%">Температура воздуха, ºC</td>
          <td width="15%">Атмосферное давление, мм рт.ст.</td>
          <td width="15%">Относительная влажность, %</td>
        </tr>
        <xsl:apply-templates select="row_os"/>
      </table>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="row_os">
    <tr>
      <xsl:if test="@rm_name">
        <td align="left">
          <xsl:attribute name="rowspan">
            <xsl:value-of select="@rowspan"/>
          </xsl:attribute>
          <xsl:value-of select="@rm_name"/>
        </td>
      </xsl:if>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@os_t"/>
      </td>
      <td>
        <xsl:value-of select="@os_p"/>
      </td>
      <td>
        <xsl:value-of select="@os_v"/>
      </td>
      <xsl:if test="$no_os_sk='0'">
        <td>
          <xsl:value-of select="@os_sk"/>
        </td>
      </xsl:if>
    </tr>
  </xsl:template>



  <xsl:template match ="table">
    <h2>
      <xsl:if test="@num_razd">
        <xsl:value-of select="@num_razd"/>
      </xsl:if>. Результаты измерений:
    </h2>
    <xsl:if test="$no_org='no'">
      <table>
        <tr>
          <td width="4%">№ п/п</td>
          <td width="15%">Наименование организации</td>
          <td width="4%">№ РМ</td>
          <td width="32%">Наименование рабочего места, рабочей зоны, фактора</td>
          <td width="10%">
            Дата проведения измерения
            <xsl:if test="@col5_header='yes'">
              /<br/>№ протокола
            </xsl:if>
          </td>
          <td width="10%">Факт.уровень</td>
          <td width="6%">Время воздействия, %</td>
          <xsl:if test="$no_signs='no'">
            <td width="9%">Подпись работника, проводившего измерения</td>
            <td width="14%">Ф.И.О., должность присутствовавшего представителя заказчика</td>
          </xsl:if>
        </tr>
        <tr>
          <td>1</td>
          <td>2</td>
          <td>3</td>
          <td>4</td>
          <td>5</td>
          <td>6</td>
          <td>7</td>
          <xsl:if test="$no_signs='no'">
            <td>8</td>
            <td>9</td>
          </xsl:if>
        </tr>
        <xsl:apply-templates/>
      </table>
    </xsl:if>
    <xsl:if test="$no_org='yes'">
      <table>
        <tr>
          <td width="4%">№ п/п</td>
          <td width="6%">№ РМ</td>
          <td width="33%">Наименование рабочего места, рабочей зоны, фактора</td>
          <td width="10%">
            Дата проведения измерения
            <xsl:if test="@col5_header='yes'">
              /<br/>№ протокола
            </xsl:if>
          </td>
          <td width="14%">Факт.уровень</td>
          <td width="10%">Время воздействия, %</td>
          <xsl:if test="$no_signs='no'">
            <td width="9%">Подпись работника, проводившего измерения</td>
            <td width="14%">Ф.И.О., должность присутствовавшего представителя заказчика</td>
          </xsl:if>
        </tr>
        <tr>
          <td>1</td>
          <td>2</td>
          <td>3</td>
          <td>4</td>
          <td>5</td>
          <td>6</td>
          <xsl:if test="$no_signs='no'">
            <td>7</td>
            <td>8</td>
          </xsl:if>
        </tr>
        <xsl:apply-templates/>
      </table>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="row">
    <tr>
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      <td>
        <xsl:value-of select="@cell1"/>
      </td>
      <!-- Сведения об организации (выводятся не всегда) -->
      <xsl:if test="(@class='rm') and ($no_org='no')">
        <td>
          <xsl:attribute name="rowspan">
            <xsl:value-of select="@rowspan_rm"/>
          </xsl:attribute>
          <xsl:value-of select="@cell2"/>
        </td>
      </xsl:if>
      <!-- Номер РМ-->
      <td>
        <xsl:attribute name="class"><xsl:value-of select="@cell3_class"/></xsl:attribute>
        <xsl:value-of select="@cell3"/>
      </td>
      <td>
        <xsl:attribute name="class"><xsl:value-of select="@cell4_class"/></xsl:attribute>
        <xsl:value-of select="@cell4"/>
      </td>
      <!-- Заполнение даты -->
      <xsl:if test="@class='rm'">
        <td>
          <xsl:attribute name="class">
            <xsl:value-of select="@cell5_class"/>
          </xsl:attribute>
          <xsl:attribute name="rowspan">
            <xsl:value-of select="@rowspan_rm"/>
          </xsl:attribute>
          <xsl:value-of select="@cell5"/>
          <xsl:if test="@num_doc">
            <br/>/<br/>№ <xsl:value-of select="@num_doc"/>
          </xsl:if>
        </td>
        <xsl:if test="$no_signs='no'">
          <td colspan="4">
            <xsl:value-of select="@cell6"/>
          </td>
        </xsl:if>
        <xsl:if test="$no_signs!='no'">
          <td colspan="2">
            <xsl:value-of select="@cell6"/>
          </td>
        </xsl:if>
      </xsl:if>
      <xsl:if test="@class!='rm'">
        <td>
          <xsl:value-of select="@cell6"/><xsl:if test="@U095">±<xsl:value-of select="@U095"/></xsl:if>
        </td>
        <td>
          <xsl:value-of select="@cell7"/>
        </td>
        <xsl:if test="@class!='param'">
          <xsl:if test="$no_signs='no'">
            <td>
              <xsl:attribute name="rowspan">
                <xsl:value-of select="@rowspan"/>
              </xsl:attribute>
              <xsl:value-of select="@cell8"/>
            </td>
            <td>
              <xsl:attribute name="class">
                <xsl:value-of select="@cell9_class"/>
              </xsl:attribute>
              <xsl:attribute name="rowspan">
                <xsl:value-of select="@rowspan"/>
              </xsl:attribute>
              <xsl:value-of select="@cell9"/>
            </td>
          </xsl:if>
        </xsl:if>
      </xsl:if>
    </tr>
  </xsl:template>

  <xsl:template match ="org_member">
    <h2>
      <xsl:if test="@num_razd">
        <xsl:value-of select="@num_razd"/>
      </xsl:if>. Ф.И.О., должность присутствовавшего представителя заказчика:
    </h2>
    <p class="nd">
      <xsl:value-of select="@fio"/>
    </p>
  </xsl:template>


  <xsl:template match ="pers_signs">
    <h2>
      <xsl:if test="@num_razd">
        <xsl:value-of select="@num_razd"/>
      </xsl:if>. Лица, проводившие измерения:
    </h2>
    <table class="comission" width="70%">
      <xsl:apply-templates select="pers_sign"/>
    </table>
  </xsl:template>

  <xsl:template match ="pers_sign">
    <tr>
      <td class="sign" width="30%">
        <xsl:value-of select="@dolg" />
      </td>
      <td width="5%">
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </td>
      <td class="sign" width="30%">
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
      <td width="30%">
        <sup>Должность</sup>
      </td>
      <td width="5%">
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </td>
      <td width="30%">
        <sup>Подпись</sup>
      </td>
      <td width="5%">
        <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
      </td>
      <td width="30%">
        <sup>Ф.И.О.</sup>
      </td>
    </tr>
  </xsl:template>



</xsl:stylesheet>