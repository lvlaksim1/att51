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
	    <title>Сводный протокол измерений массовых концентраций вредных химических веществ</title>
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
      font-style:italic;
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
      1. Заключение:
    </p>
    <p>
      по результатам измерений установлено:<br/>
      <!-- КОД ДЛЯ ВЫВОДА ЗАКЛЮЧЕНИЯ -->
      <!-- Код получился через чур замсыловатым по причине необходимости замены последней ";" на "." и необходимости вывода разрывов строки -->
      <!-- Пока в голову нисего не приходит. Если кто-то найдет более элегантное рещение подскажите, поправлю. -->
      <xsl:if test="@co_cl1!='0'">
        - для <xsl:value-of select="@co_cl1"/>  рабочих(его) мест(а) № <xsl:value-of select="@co_cl1_str"/> установлен класс (подкласс) условий труда
        <xsl:if test="(@co_cl2='0') and (@co_cl31='0') and (@co_cl32='0') and (@co_cl33='0')  and (@co_cl34='0') and (@co_cl4='0')">1.</xsl:if>
        <xsl:if test="(@co_cl2!='0') or (@co_cl31!='0') or (@co_cl32!='0') or (@co_cl33!='0') or (@co_cl34!='0') or (@co_cl4!='0')">1;</xsl:if>
        <br/>
      </xsl:if>
      <xsl:if test="@co_cl2!='0'">
        - для <xsl:value-of select="@co_cl2"/> рабочих(его) мест(а) № <xsl:value-of select="@co_cl2_str"/> установлен класс (подкласс) условий труда
        <xsl:if test="(@co_cl31='0') and (@co_cl32='0') and (@co_cl33='0')  and (@co_cl34='0') and (@co_cl4='0')">2.</xsl:if>
        <xsl:if test="(@co_cl31!='0') or (@co_cl32!='0') or (@co_cl33!='0') or (@co_cl34!='0') or (@co_cl4!='0')">2;</xsl:if>
        <br/>
      </xsl:if>
      <xsl:if test="@co_cl31!='0'">
        - для <xsl:value-of select="@co_cl31"/> рабочих(его) мест(а) № <xsl:value-of select="@co_cl31_str"/> установлен класс (подкласс) условий труда
        <xsl:if test="(@co_cl32='0') and (@co_cl33='0')  and (@co_cl34='0') and (@co_cl4='0')">3.1.</xsl:if>
        <xsl:if test="(@co_cl32!='0') or (@co_cl33!='0') or (@co_cl34!='0') or (@co_cl4!='0')">3.1;</xsl:if>
        <br/>
      </xsl:if>
      <xsl:if test="@co_cl32!='0'">
        - для <xsl:value-of select="@co_cl32"/> рабочих(его) мест(а) № <xsl:value-of select="@co_cl32_str"/> установлен класс (подкласс) условий труда
        <xsl:if test="(@co_cl33='0')  and (@co_cl34='0') and (@co_cl4='0')">3.2.</xsl:if>
        <xsl:if test="(@co_cl33!='0') or (@co_cl34!='0') or (@co_cl4!='0')">3.2;</xsl:if>
        <br/>
      </xsl:if>
      <xsl:if test="@co_cl33!='0'">
        - для <xsl:value-of select="@co_cl33"/> рабочих(его) мест(а) № <xsl:value-of select="@co_cl33_str"/> установлен класс (подкласс) условий труда
        <xsl:if test="(@co_cl34='0') and (@co_cl4='0')">3.3.</xsl:if>
        <xsl:if test="(@co_cl34!='0') or (@co_cl4!='0')">3.3;</xsl:if>
        <br/>
      </xsl:if>
      <xsl:if test="@co_cl34!='0'">
        - для <xsl:value-of select="@co_cl34"/> рабочих(его) мест(а) № <xsl:value-of select="@co_cl34_str"/> установлен класс (подкласс) условий труда
        <xsl:if test="(@co_cl4='0')">3.4.</xsl:if>
        <xsl:if test="(@co_cl4!='0')">3.4;</xsl:if>
        <br/>
      </xsl:if>
      <xsl:if test="@co_cl4!='0'">
        - для <xsl:value-of select="@co_cl4"/> рабочих(его) мест(а) № <xsl:value-of select="@co_cl4_str"/> установлен класс (подкласс) условий труда 4.
      </xsl:if>
      <!-- КОНЕЦ КОДА ДЛЯ ВЫВОДА ЗАКЛЮЧЕНИЯ -->
    </p>
    <p class="razdel">
      2. Сотрудники (эксперты) по проведению специальной оценки условий труда:
    </p>
    <xsl:apply-templates select="pers_exp"/>
  </xsl:template>


  <xsl:template match ="org_data">
    <!--  Шапка протокола -->
    <table width="100%" class="header">
      <tr>
        <td>
          <xsl:value-of select="@org_info" />
        </td>
      </tr>
      <tr>
        <td>
          <sup>
            (полное наименование организации, проводящей специальную оценку условий труда,
            регистрационный номер записи в реестре организаций, проводящих специальную оценку условий труда)
          </sup>
        </td>
      </tr>
    </table>

    <!--  Наименование протокола -->
    <p class="prot">
      Заключение сформировано на основании протокола<br/>
      проведения исследований (испытаний) и измерений

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
  </xsl:template>


  <xsl:template match ="pers_exp">
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

</xsl:stylesheet>