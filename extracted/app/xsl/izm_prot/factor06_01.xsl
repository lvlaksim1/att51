<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <xsl:variable name="org_info">
    <xsl:value-of select="Document/org_data/@org_info"/>
  </xsl:variable>
  <xsl:variable name="rbtd_name">
    <xsl:value-of select="Document/org_data/@rbtd_name"/>
  </xsl:variable>
  <xsl:variable name="rbtd_adr">
    <xsl:value-of select="Document/org_data/@rbtd_adr"/>
  </xsl:variable>

  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения о вредных и (или) опасных производственных факторах</title>
    <style>
      /* Style Definitions */
      p
      {
      font-family:"Times New Roman";
      font-size:12.0pt;
      }

      .normal_inline
      {
      font-weight: normal;
      }

      .data
      {
      text-decoration: underline;
      }

      .normal
      {
      margin-top:0cm;
      margin-bottom:0cm;
      }
      .prot
      {
      font-weight: bold;
      text-align: center;
      margin-bottom:0.2cm;
      margin-top:0.2cm;
      }
      .razdel
      {
      font-weight: bold;
      text-align: left;
      margin-bottom:0cm;
      margin-top:0.1cm;
      }
      .razdel2
      {
      margin-top:0cm;
      margin-bottom:0cm;
      }

      table
      {
      font-size:10.0pt;
      font-family:"Times New Roman";
      text-align:center;
      }
      table.header
      {
      font-size:9.0pt;
      border:1px solid black;border-collapse:collapse;padding:0 0px 0 5px;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
      tr.rm {
      font-weight: bold;
      }
      tr.src {
      font-weight: bold;
      text-align: left;
      }
      tr.zone {
      font-weight: bold;
      }
      tr.param {
      font-size:9.0pt;
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

    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <!--p style="font-size:1.0pt;">
      <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
    </p-->
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="prot">
    <!--  Шапка протокола -->
    <table width="100%" class="header">
      <tr>
        <td colspan="3">
          <xsl:value-of select="$org_info" />
        </td>
      </tr>
      <tr>
        <td colspan="3">
          <sup>(полное наименование организации, проводящей специальную оценку условий труда, 
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
    <p class="prot">
        ПРОТОКОЛ<br/>проведения исследований (испытаний) и измерений ультазвука
    </p>
    <!--  Таблица для номера протокола -->
    <table align="center" class="empty">
      <tr>
        <td class="sign">
          <xsl:value-of select="@num_doc"/>
        </td>
      </tr>
      <tr>
        <td>
          <sup> (идентификационный номер протокола) </sup>
          <!-- Спец.маркер для определения номера протокола -->
          <span style='display:none'>~$~$~</span>
        </td>
      </tr>
    </table>
    <p class="razdel">Дата проведения измерений: <span class="normal_inline"><xsl:value-of select="@izm_date"/>
      </span>
    </p>
    <p class="razdel">Сведения о работодателе:</p>
    <p class="razdel2">Наименование работодателя: <span class="data"><xsl:value-of select="$rbtd_name" /></span></p>
    <p class="razdel2">Место нахождения и место осуществления деятельности работодателя: <span class="data"><xsl:value-of select="$rbtd_adr" />
      </span>
    </p>
    <p class="razdel2">Наименование структурного подразделения: </p>
    <p class="razdel">Сведения о рабочем месте:</p>
    <p class="razdel2">Номер рабочего места: <span class="data">
      <xsl:value-of select="@num" /></span>
    </p>
    <p class="razdel2">Наименование рабочего места: <span class="data">
      <xsl:value-of select="@name" /></span>
    </p>
    <p class="razdel2">
      Код по ОК 016-94: <span class="data"><xsl:value-of select="@ok016" /></span>
    </p>
    <p class="razdel">
      Цель проведения исследований (испытаний) и измерений: <span class="normal_inline">проведение специальной оценки условий труда</span>
    </p>
    <p class="razdel">Сведения о средствах измерения:</p>
    <xsl:apply-templates select="si_data"/>
    <!-- Доплнительные разделы для СИ -->
    <xsl:if test="si_data_os">
      <p class="razdel">Средства измерений параметров окружающей среды:</p>
      <xsl:apply-templates select="si_data_os"/>
    </xsl:if>
    <xsl:if test="si_data_dop">
      <p class="razdel">Сведения о вспомогательном оборудовании:</p>
      <xsl:apply-templates select="si_data_dop"/>
    </xsl:if>

    <p class="razdel">НД, устанавливающие метод проведения измерений:</p>
    <xsl:apply-templates select="nd_data"/>
    <p class="razdel">
      Сведения об источнике ультразвука: <span class="normal_inline">
        <xsl:value-of select="@src"/>
      </span>
    </p>
    <xsl:if test="os_data">
      <p class="razdel">Условия проведения исследований (испытаний) и измерений:</p>
      <xsl:apply-templates select="os_data"/>
    </xsl:if>
    <p class="razdel">Результаты измерений:</p>
    <xsl:if test="@form=1">
      <xsl:apply-templates select="izm_data" mode="f1"/>
    </xsl:if>
    <xsl:if test="@form=2">
      <xsl:apply-templates select="izm_data" mode="f2"/>
    </xsl:if>
    <p class="razdel">Лица, проводившие измерения:</p>
    <xsl:apply-templates select="pers_data"/>
    <!-- Служебная информация - маркер для установки разрыва раздела-->
    <p>~@~@~</p>
  </xsl:template>

  <xsl:template match ="os_data">
    <xsl:if test="@is_skor='false'">
      <table>
        <tr>
          <td width="55%">Наименование места измерения</td>
          <td width="15%">Температура воздуха, ºC</td>
          <td width="15%">Атмосферное давление, мм рт.ст.</td>
          <td width="15%">Относительная влажность, %</td>
        </tr>
        <xsl:apply-templates select="os_param" mode="m1"/>
      </table>
    </xsl:if>
    <xsl:if test="@is_skor='true'">
      <table>
        <tr>
          <td width="40%">Наименование места измерения</td>
          <td width="15%">Температура воздуха, ºC</td>
          <td width="15%">Атмосферное давление, мм рт.ст.</td>
          <td width="15%">Относительная влажность, %</td>
          <td width="15%">Скорость воздуха, м/с</td>
        </tr>
        <xsl:apply-templates select="os_param" mode="m2"/>
      </table>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="os_param" mode="m1">
    <tr>
      <td>
        <xsl:value-of select="@name" />
      </td>
      <td>
        <xsl:value-of select="@os_temp" />
      </td>
      <td>
        <xsl:value-of select="@os_patm" />
      </td>
      <td>
        <xsl:value-of select="@os_vlag" />
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="os_param" mode="m2">
    <tr>
      <td>
        <xsl:value-of select="@name" />
      </td>
      <td>
        <xsl:value-of select="@os_temp" />
      </td>
      <td>
        <xsl:value-of select="@os_patm" />
      </td>
      <td>
        <xsl:value-of select="@os_vlag" />
      </td>
      <td>
        <xsl:value-of select="@os_skor" />
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="si_data|si_data_os|si_data_dop">
    <table>
      <tr>
        <td width="40%">Наименование средства измерения</td>
        <td width="15%">Заводской номер</td>
        <td width="15%">№ свидетельства о поверке</td>
        <td width="15%">Действие поверки</td>
        <td width="15%">Погрешность измерения</td>
      </tr>
      <xsl:apply-templates select="si"/>
    </table>
  </xsl:template>
  
  <xsl:template match ="si">
    <tr>
      <td>
        <xsl:value-of select="@name" />
      </td>
      <td>
        <xsl:value-of select="@factory_num" />
      </td>
      <td>
        <xsl:value-of select="@num_doc" />
      </td>
      <td>
        <xsl:if test="@end_date!='-'">
          <xsl:value-of select="@begin_date" /> - <xsl:value-of select="@end_date" />
        </xsl:if>
        <xsl:if test="@end_date='-'">
          -
        </xsl:if>
      </td>
      <td>
        <xsl:value-of select="@err" />
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="nd_data">
    <xsl:apply-templates select="nd"/>
  </xsl:template>
  
  <xsl:template match ="nd">
    <p class="normal"><xsl:value-of select="@name2" /></p>
  </xsl:template>
  
  <xsl:template match ="pers_data">
    <table width="100%" class="empty">
      <xsl:apply-templates select="pers"/>
    </table>
  </xsl:template>
  
  <xsl:template match ="pers">
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
        <xsl:value-of select="@name" />
      </td>
    </tr>
    <tr>
      <td width="30%">
        <sup>Должность</sup></td>
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

  <xsl:template match ="izm_data" mode="f1">
    <table width="100%">
      <tr>
        <td width="50%">
          Место измерения, источник ультразвука (среднегеометрическая частота, кГц)
        </td>
        <td width="25%">Уровень звукового давления, дБ</td>
        <td width="25%">Время воздействия, %</td>
      </tr>
      <xsl:apply-templates select="izm" mode="f1"/>
    </table>
  </xsl:template>

  <xsl:template match ="izm" mode="f1">
    <tr>
      <td>
        <xsl:value-of select="@name" />
      </td>
      <td>
        <xsl:value-of select="@level" />
      </td>
      <td>
        <xsl:value-of select="@time" />
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="izm_data" mode="f2">
    <table width="100%">
      <tr>
        <td width="25%">Место измерения, источник ультразвука</td>
        <td width="15%">Средне-<br/>геометрическая частота, кГц</td>
        <td width="15%">Результат измерения</td>
        <td width="15%">Среднее значение</td>
        <td width="15%">U<sub>0.95</sub>
      </td>
        <td width="15%">Время воздействия, %</td>
      </tr>
      <xsl:apply-templates select="izm" mode="f2"/>
    </table>
  </xsl:template>

  <xsl:template match ="izm" mode="f2">
    <tr>
      <td>
        <xsl:value-of select="@name" />
      </td>
      <td>
        <xsl:value-of select="@freq" />
      </td>
      <td>
        <xsl:value-of select="@result" />
      </td>
       <td>
        <xsl:value-of select="@fact" />
      </td>
       <td>
        <xsl:value-of select="@unc" />
      </td>
       <td>
        <xsl:value-of select="@time" />
      </td>
   </tr>
  </xsl:template>

  <xsl:template match ="itog_level" mode="f1">
    <table width="100%">
      <tr>
        <td width="50%">Фактор</td>
        <td width="50%">Фактическое значение</td>
      </tr>
     <tr>
      <td>
        <xsl:value-of select="@name" />
      </td>
      <td>
        <xsl:value-of select="@fact" />
      </td>
    </tr>
   </table>
  </xsl:template>

  <xsl:template match ="itog_level" mode="f2">
    <table width="100%">
      <tr>
        <td width="33%">Фактор</td>
        <td width="33%">Фактическое значение</td>
        <td width="33%">Неопределенность измерения</td>
      </tr>
      <tr>
        <td>
          <xsl:value-of select="@name" />
        </td>
        <td>
          <xsl:value-of select="@fact" />
        </td>
        <td>
          <xsl:value-of select="@U8h" />
        </td>
      </tr>
    </table>
  </xsl:template>

</xsl:stylesheet>