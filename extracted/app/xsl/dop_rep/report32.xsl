<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения об организации, в которой проводится СОУТ</title>
    <style>
      /* Style Definitions */
      body
      {
      font-size:12.0pt;
      font-family: Times new roman, serif;
      text-align:left;
      }
      .prim {
      font-size:10.0pt;
      }
      table
      {
      font-size:8.0pt;
      text-align:center;
      }
      table.org
      {
      font-size:10.0pt;
      text-align:left;
      }

      .h1 {
      font-weight:bold;
      font-size:14.0pt;
      text-align:center;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
      table.comission,table.comission th,table.comission td
      {
      font-size:12.0pt;
      text-align:center;
      border:none;
      background:none;
      padding:0 5px 0 5px;
      }
      td.center {
      text-align:center;
      }
      td.rotate {
      mso-rotate:90;
      font-size:7.0pt;
      height:80pt;
      }
      table.comission td.sign {
      border-bottom: 1px solid black;
      }
      table.comission td.left {
      text-align:left;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <p class="h1">Сведения об организации, в которой проводится СОУТ</p>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="ORG">
    <p>
      <b>1. Общие сведения об организации</b>
    </p>
    <table class="org">
      <tr>
        <td width="30%">Название организации:</td>
        <td width="70%">
          <xsl:value-of select="@name"/>
        </td>
      </tr>
      <tr>
        <td width="30%">Место нахождения (адрес):</td>
        <td width="70%">
          <xsl:value-of select="@adr"/>
        </td>
      </tr>
      <tr>
        <td width="30%">Место осуществления деятельности (если не свпадает с местом нахождения):</td>
        <td width="70%">
          <xsl:value-of select="@adr2"/>
        </td>
      </tr>
      <tr>
        <td width="30%">Ф.И.О руководителя:</td>
        <td width="70%">
          <xsl:value-of select="@boss_fio"/>
        </td>
      </tr>
      <tr>
        <td width="30%">E-mail:</td>
        <td width="70%">
          <xsl:value-of select="@email"/>
        </td>
      </tr>
      <tr>
        <td width="30%">Телефон:</td>
        <td width="70%">
          <xsl:value-of select="@phone"/>
        </td>
      </tr>
      <tr>
        <td width="30%">Факс:</td>
        <td width="70%">
          <xsl:value-of select="@fax"/>
        </td>
      </tr>
      <tr>
        <td width="30%">ИНН:</td>
        <td width="70%">
          <xsl:value-of select="@inn"/>
        </td>
      </tr>
      <tr>
        <td width="30%">ОКПО:</td>
        <td width="70%">
          <xsl:value-of select="@okpo"/>
        </td>
      </tr>
      <tr>
        <td width="30%">ОКОГУ:</td>
        <td width="70%">
          <xsl:value-of select="@okogu"/>
        </td>
      </tr>
      <tr>
        <td width="30%">ОКВЭД:</td>
        <td width="70%">
          <xsl:value-of select="@okved"/>
        </td>
      </tr>
      <tr>
        <td width="30%">ОКАТО:</td>
        <td width="70%">
          <xsl:value-of select="@okato"/>
        </td>
      </tr>
      <tr>
        <td width="30%">ОГРН:</td>
        <td width="70%">
          <xsl:value-of select="@ogrn"/>
        </td>
      </tr>
      <tr>
        <td width="30%">Кол-во рабочих мест:</td>
        <td width="70%">
          <xsl:value-of select="@col_rms"/>
        </td>
      </tr>
      <tr>
        <td width="30%">Кол-во женщин:</td>
        <td width="70%">
          <xsl:value-of select="@col_wom"/>
        </td>
      </tr>
      <tr>
        <td width="30%">Кол-во лиц до 18:</td>
        <td width="70%">
          <xsl:value-of select="@col18"/>
        </td>
      </tr>
      <tr>
        <td width="30%">Кол-во инвалидов:</td>
        <td width="70%">
          <xsl:value-of select="@invalid"/>
        </td>
      </tr>
    </table>
    <p>
      <b>2. Сведения о рабочих местах</b>
    </p>
    <table>
      <tr>
        <td class="center" width="4%">№ п/п</td>
        <td width="10%">Наименование рабочего места (основное/аналогичное)</td>
        <td width="12%">Сведения о работниках (ФИО/СНИЛС)</td>
        <td class="rotate" width="2.5%">Кол-во работников</td>
        <td class="rotate" width="2.5%">Кол-во женщин</td>
        <td class="rotate" width="2.5%">Кол-во лиц до 18</td>
        <td class="rotate" width="2.5%">Кол-во инвалидов</td>
        <td class="rotate" width="3%">Продолжительность рабочей смены, мин</td>
        <td class="rotate" width="2.5%">Доплаты*</td>
        <td class="rotate" width="2.5%">Дополнительный отпуск*</td>
        <td class="rotate" width="2.5%">Сокращённая рабочая неделя*</td>
        <td class="rotate" width="2.5%">Выдача молока*</td>
        <td class="rotate" width="3%">Лечебно-проф.питание*</td>
        <td class="rotate" width="3%">Право на досрочное назначение пенсии*</td>
        <td class="rotate" width="3%">Проведение медицинских осмотров*</td>
        <td class="rotate" width="3%">Класс условий труда предыдущей АРМ/СОУТ</td>
        <td class="rotate" width="2.5%">Предложения работников*</td>
        <td class="rotate" width="3%">Несчастные случаи  за последние 5 лет*</td>
        <td class="rotate" width="3%">Проф.заболевания за последние 5 лет*</td>
        <td width="10%">Используемое оборудование</td>
        <td width="10%">Используемые материалы и сырье</td>
        <td width="10%">Краткое описание выполняемой работы (для Т и Н)</td>
      </tr>
      <xsl:apply-templates select="PODR|RM"/>
      <!--ИТОГО-->
      <tr>
        <td colspan="3" align="right">ИТОГО</td>
        <td>
          <xsl:value-of select="sum(RM/@colrab_rm)"/>
        </td>
        <td>
          <xsl:value-of select="sum(RM/@colwom)"/>
        </td>
        <td>
          <xsl:value-of select="sum(RM/@col18)"/>
        </td>
        <td>
          <xsl:value-of select="sum(RM/@colinv)"/>
        </td>
        <td>-</td>
        <td>-</td>
        <td>-</td>
        <td>-</td>
        <td>-</td>
        <td>-</td>
        <td>-</td>
        <td>-</td>
        <td>-</td>
        <td>-</td>
        <td>-</td>
        <td>-</td>
        <td>-</td>
        <td>-</td>
        <td>-</td>
      </tr>
    </table>
    <span class="prim">*- указывается наличие ("да" или "нет")</span>
    <p>Данная информация является достоверной и  предоставлена в целях проведения специальной оценки условий труда на основании п.п. 2 п.2 статьи 4 Федерального закона № 426-ФЗ от 28 декабря 2013 г. «О специальной оценке условий труда».</p>
    <xsl:apply-templates select="comission"/>
  </xsl:template>
  
  <xsl:template match ="PODR">
    <tr>
      <td colspan="22">
        <xsl:value-of select="@name"/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="RM">
    <xsl:variable name="tab" select="count(rab)"/>
    <tr>
      <td>
        <xsl:value-of select="count(preceding-sibling::RM)+1"/>
      </td>
      <td>
        <xsl:value-of select="@num"/>. <xsl:value-of select="@name"/>
        <br/><b>(<xsl:value-of select="@anal_type"/>)</b>
      </td>
      <td>
        <xsl:apply-templates select="rab"/>
      </td>
      <td>
        <xsl:value-of select="@colrab_rm"/>
      </td>
      <td>
        <xsl:value-of select="@colwom"/>
      </td>
      <td>
        <xsl:value-of select="@col18"/>
      </td>
      <td>
        <xsl:value-of select="@colinv"/>
      </td>
      <td>
        <xsl:value-of select="@timesmena"/>
      </td>
      <td>
        <xsl:value-of select="@dopl"/>
      </td>
      <td>
        <xsl:value-of select="@dop_otpusk"/>
      </td>
      <td>
        <xsl:value-of select="@week"/>
      </td>
      <td>
        <xsl:value-of select="@milk"/>
      </td>
      <td>
        <xsl:value-of select="@profpit"/>
      </td>
      <td>
        <xsl:value-of select="@lpo"/>
      </td>
      <td>
        <xsl:value-of select="@medosm"/>
      </td>
      <td>
        <xsl:value-of select="@arm_kut"/>
      </td>
      <td>
        <xsl:value-of select="@rab_descr"/>
      </td>
      <td>
        <xsl:value-of select="@is_travma"/>
      </td>
      <td>
        <xsl:value-of select="@is_profzab"/>
      </td>
      <td>
        <xsl:value-of select="oborud"/>
      </td>
      <td>
        <xsl:value-of select="material"/>
      </td>
      <td>
        <xsl:value-of select="operac"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="rab">
    <xsl:value-of select="@fio"/>/<xsl:value-of select="@snils"/>;<br/>
  </xsl:template>
  
  <xsl:template match ="comission">
    <table class="comission">
        <xsl:apply-templates select="member"/>
    </table>
  </xsl:template>
  
  <xsl:template match ="member">
    <xsl:variable name="iRow" select="count(preceding-sibling::member)+1"/>
    <xsl:if test="$iRow='1'">
      <tr>
        <td class="left"  colspan="7">Председатель комиссии по проведению специальной оценки условий труда:</td>
      </tr>
    </xsl:if>
    <xsl:if test="$iRow='2'">
      <tr>
        <td class="left" colspan="7">Члены комиссии по проведению специальной оценки условий труда:</td>
      </tr>
    </xsl:if>
    <tr>
      <td class="sign" width="20%">
        <xsl:value-of select="@proff"/>
      </td>
      <td width="3%"></td>
      <td class="sign" width="20%"></td>
      <td width="3%"></td>
      <td class="sign" width="20%">
        <xsl:value-of select="@fio"/>
      </td>
      <td width="3%"></td>
      <td class="sign" width="20%"></td>
    </tr>
    <tr>
      <td width="20%"><sup>(должность)</sup></td>
      <td width="3%"></td>
      <td width="20%"><sup>(подпись)</sup></td>
      <td width="3%"></td>
      <td width="20%"><sup>Ф.И.О.</sup></td>
      <td width="3%"></td>
      <td width="20%"><sup>(дата)</sup></td>
    </tr>
  </xsl:template>

</xsl:stylesheet>