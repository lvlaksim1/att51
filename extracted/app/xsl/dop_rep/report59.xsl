<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения об оформленных картах СОУТ</title>
    <style>
      /* Style Definitions */
      body
      {
      font-size:10.0pt;
      font-family: Times new roman, serif;
      text-align:left;
      }
      .h1 {
      font-weight:bold;
      font-size:14.0pt;
      text-align:center;
      }
      .h2 {
      font-weight:bold;
      font-size:12.0pt;
      }

      p.org_name {
      font-size:12.0pt;
      font-weight:bold;
      text-align:center;
      margin-bottom:0pt;
      }

      p.org_sign {
      border-top: 1px solid black;
      text-align:center;
      margin-top:0pt;
      }

      .header {
      font-size:12.0pt;
      text-align:center;
      margin-left:200pt;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      font-size:10.0pt;
      }

      table.rm_data tr td {
      font-size:9.0pt;
      }

      tr.t_header td{ height: 100pt; }

      td.center {
      text-align:center;
      }
      .factor {
      font-size:9.0pt;
      }
      tr.param p {
      text-align:left;
      }
      tr.zone {
      font-style:italic;
      }
      td.sign {
      height:30pt;
      text-align:center;
      }

      span.err1 {
      background-color: #FFAAAA;
      }

      span.err2 {
      background-color: #FF6666;
      }


      table.transparent,table.transparent th,table.transparent td
      {
      font-size:12.0pt;
      border:none;
      background:none;
      padding:0 5px 0 5px;
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
      table.comission td.sign2 {
      border-bottom: 1px solid black;
      text-align:right;
      margin-top:7pt;
      }
      table.comission td.sign3 {
      border-bottom: 1px solid black;
      text-align:center;
      margin-top:5pt;
      }
      table.comission td.left {
      text-align:left;
      }
      table.comission td.italic {
      font-size:8.0pt;
      font-style:italic;
      text-align:center;
      }

      td.rotate {
      mso-rotate:90;
      font-size:8.0pt;
      height:120pt;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
     <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="ORG">
    <p align="right">
      <b>Приложение № ###</b><br/>
      к Договору на выполнение комплекса работ<br/>
      по специальной оценке условий труда<br/>
      № <xsl:value-of select="@N_dog"/> от <xsl:value-of select="@D_dog"/>
    </p>
  <p class="h1">
    Сведения об организации <xsl:value-of select="@name"/> для выполнения комплекса работ по специальной оценке условий труда
  </p>
  <p class="h2">
    1. Общие сведения
  </p>
    <table width="100%">
      <tr>
        <td class="center" width="5%">
          <b>№ п/п</b></td>
        <td class="center" width="25%">
          <b>Наименование позиции</b>
        </td>
        <td colspan="2" class="center" width="70%">
          <b>Сведения для заполнения</b>
      </td>
      </tr>
      <tr>
        <td class="center">1</td>
        <td>Полное наименование</td>
        <td colspan="2">
          <xsl:value-of select="@name"/>
        </td>
      </tr>
      <tr>
        <td class="center">2</td>
        <td>Сокращенное наименование</td>
        <td colspan="2">
          <xsl:value-of select="@name2"/>
        </td>
      </tr>
      <tr>
        <td class="center">3</td>
        <td>Юридический адрес</td>
        <td colspan="2">
          <xsl:value-of select="@adr"/>
        </td>
      </tr>
      <tr>
        <td class="center">4</td>
        <td>Фактический адрес</td>
        <td colspan="2">
          <xsl:value-of select="@adr2"/>
        </td>
      </tr>
      <tr>
        <td class="center">5</td>
        <td>Почтовый адрес</td>
        <td colspan="2"></td>
      </tr>
      <tr>
        <td class="center">6</td>
        <td>ФИО руководителя</td>
        <td colspan="2"><xsl:value-of select="@boss_fio"/></td>
      </tr>
      <tr>
        <td class="center">7</td>
        <td>Общедоступный телефон организации</td>
        <td colspan="2"><xsl:value-of select="@phone"/></td>
      </tr>
      <tr>
        <td class="center">8</td>
        <td>ФИО, должность, телефон  и электронный адрес уполномоченного (контактного) лица, ответственного за организацию проведения СОУТ</td>
        <td colspan="2"></td>
      </tr>
      <tr>
        <td class="center">9</td>
        <td>Электронный адрес Заказчика для осуществления официальной переписки с Исполнителем согласно п. ### Договора (Лист согласования, скан титульного листа отчета и пр., уведомления и сообщения от Исполнителя, предусмотренные Федеральным законом от 28.12.2013 г. № 426-ФЗ «О специальной оценке условий труда»)</td>
        <td colspan="2">
          <xsl:value-of select="@email"/>
        </td>
      </tr>
      <tr>
        <td class="center" colspan="4">
          <b>Коды организации</b>
        </td>
      </tr>
      <tr>
        <td class="center">10</td>
        <td>КПП</td>
        <td colspan="2">
          <xsl:value-of select="@kpp"/>
        </td>
      </tr>
      <tr>
        <td class="center">11</td>
        <td>ИНН</td>
        <td colspan="2">
          <xsl:value-of select="@inn"/>
        </td>
      </tr>
      <tr>
        <td class="center">12</td>
        <td>ОКПО</td>
        <td colspan="2">
          <xsl:value-of select="@okpo"/>
        </td>
      </tr>
      <tr>
        <td class="center">13</td>
        <td>ОКОГУ</td>
        <td colspan="2">
          <xsl:value-of select="@okogu"/>
        </td>
      </tr>
      <tr>
        <td class="center">14</td>
        <td>Основной ОКВЭД</td>
        <td colspan="2">
          <xsl:value-of select="@okved"/>
        </td>
      </tr>
      <tr>
        <td class="center">15</td>
        <td>ОКТМО (ОКАТО)</td>
        <td colspan="2">
          <xsl:value-of select="@okato"/>
        </td>
      </tr>
      <tr>
        <td class="center">16</td>
        <td>ОГРН</td>
        <td colspan="2">
          <xsl:value-of select="@ogrn"/>
        </td>
      </tr>
      <tr>
        <td class="center" colspan="4">
          <b>Реквизиты приказа «Об организации и проведении специальной оценки условий труда»</b>
        </td>
      </tr>
      <tr>
        <td class="center">17</td>
        <td>№  и дата приказа</td>
        <td colspan="2">
          <xsl:value-of select="@N_prikaz"/> от <xsl:value-of select="@D_prikaz"/>
        </td>
      </tr>
      <tr>
        <td class="center" colspan="4">
          <b>Статистические данные по несчастным случаям за последние 5 лет (для ФГИС СОУТ)</b>
        </td>
      </tr>
      <tr>
        <td class="center">18</td>
        <td>Количество легких несчастных случаев</td>
        <td colspan="2">
          <xsl:value-of select="@VictimsNumber1"/>
        </td>
      </tr>
      <tr>
        <td class="center">19</td>
        <td>Количество тяжелых несчастных случаев</td>
        <td colspan="2">
          <xsl:value-of select="@VictimsNumber2"/>
        </td>
      </tr>
      <tr>
        <td class="center">20</td>
        <td>Количество несчастных случаев со смертельным исходом</td>
        <td colspan="2">
          <xsl:value-of select="@VictimsNumber3"/>
        </td>
      </tr>
      <tr>
        <td class="center" colspan="4">
          <b>Сведения о количестве работников в организации (ВСЕГО)</b>
          <br/>
          <i>заполняется только в случае применения Заказчиком поэтапного проведения СОУТ, т.е. в разное время, отдельными Договорами</i>
        </td>
      </tr>
      <tr>
        <td class="center">21</td>
        <td>Общее количество рабочих мест</td>
        <td colspan="2" class="center">
          <xsl:value-of select="@col_rms"/>
        </td>
      </tr>
      <tr>
        <td class="center">22</td>
        <td>Общее количество работников</td>
        <td colspan="2" class="center">
          <xsl:value-of select="@col_rab"/>
        </td>
      </tr>
      <tr>
        <td class="center">23</td>
        <td>Общее количество женщин</td>
        <td colspan="2" class="center">
          <xsl:value-of select="@col_wom"/>
        </td>
      </tr>
      <tr>
        <td class="center">24</td>
        <td>Общее количество лиц до 18 лет</td>
        <td colspan="2" class="center">
          <xsl:value-of select="@col18"/>
        </td>
      </tr>
      <tr>
        <td class="center">25</td>
        <td>Общее количество инвалидов, допущенных к работе</td>
        <td colspan="2" class="center">
          <xsl:value-of select="@invalid"/>
        </td>
      </tr>
      <tr>
        <td class="center" colspan="4">
          <b>Состав комиссии по специальной оценке условий труда</b> <i>(нечетное количество)</i>
        </td>
      </tr>
      <tr>
        <td></td>
        <td>Статус члена комиссии</td>
        <td class="center" width="35%">
          Должность
        </td>
        <td class="center" width="35%">
          ФИО
        </td>
      </tr>
      <xsl:apply-templates select="comission/member"/>
    </table>
    
    <!-- Подписи-->
    <table class="comission" align="center" width="90%">
      <tr>
        <td width="45%">
          <b>Заказчик ___________ <xsl:value-of select="@boss_fio"/>
        </b>
        </td>
        <td width="10%"></td>
        <td width="45%">
          <b>Исполнитель ___________ Ф.И.О - исправить в шаблоне</b>
        </td>
      </tr>
    </table>

    <br clear="all" style="page-break-before:always"/>
    
    <p align="right">
      <b>Приложение № ###</b><br/>
      к Договору на выполнение комплекса работ<br/>
      по специальной оценке условий труда<br/>
      № <xsl:value-of select="@N_dog"/> от <xsl:value-of select="@D_dog"/>
    </p>
    <p class="h2">
      2.	Перечень рабочих мест, подлежащих специальной оценке условий труда
    </p>

    <table class="rm_data">
      <tr>
        <td>№<br></br>п/п</td>
        <td width="4%" class="rotate">Индивидуальный номер РМ</td>
        <td width="13%" align="center">
          Наименование рабочего места
        </td>
        <td width="13%" align="center">
          Наименование структурного подразделения
        </td>
        <td width="13%" align="center">
          Фактический адрес местонахождения рабочего места<br/>
          <i>(адрес проведения измерений)</i>
        </td>
        <td width="4%" class="rotate">Наличие аналогичных РМ (да/нет)</td>
        <td width="4%" class="rotate">Кол-во работников на РМ (чел.)</td>
        <td width="4%" class="rotate">Из них женщин (чел.)</td>
        <td width="4%" class="rotate">Из них работников до 18 лет (чел.)</td>
        <td width="4%" class="rotate">Наличие случав травматизма за 5 лет (да/нет)</td>
        <td width="4%" class="rotate">Наличие профзаболеваний за 5<xsl:text>&#160;</xsl:text>лет (да/нет)</td>
        <td width="4%" class="rotate">Класс условий труда предыдущей оценки</td>
        <td width="13%" align="center">
          Гарантии и компенсации, предоставляемые работникам за работу во вредных условиях
        </td>
        <td width="16%" align="center">
          Сведения о работниках, занятых на оцениваемых рабочих местах (ФИО/СНИЛС)
        </td>
      </tr>
      <xsl:apply-templates select="RM"/>
    </table>

    <!-- Подписи-->
    <table class="transparent" align="center" width="90%">
      <tr>
        <td align="left" width="45%">
          <b>Заказчик:</b>
          <br/>
          <xsl:value-of select="@name2"/>
          <br/>
          <br/>
          <br/>
        </td>
        <td width="10%"></td>
        <td align="left" width="45%">
          <b>Исполнитель:</b>
          <br/>
          ООО "Организация проводящая СОУТ" - исправить в шаблоне
          <br/><br/><br/>
        </td>
      </tr>
      <tr>
        <td align="left">
          ________________<b><xsl:value-of select="@boss_fio"/></b>
        </td>
        <td align="left"></td>
        <td align="left">________________<b>Ф.И.О - исправить в шаблоне</b></td>
      </tr>
    </table>

  </xsl:template>
  
  <xsl:template match ="RM">
    <xsl:if test="@anal_rm='0'">
      <tr>
        <td align="center">
          <xsl:value-of select="count(preceding-sibling::RM)+1"/>
        </td>
        <td align="center">
          <xsl:value-of select="@num"/>
        </td>
        <td>
          <xsl:value-of select="@name"/>
        </td>
        <td>
          <xsl:value-of select="@podrs"/>
        </td>
        <td>
          <xsl:value-of select="@fact_adr"/>
        </td>
        <!-- наличие аналогичного РМ-->
        <td align="center">
          <xsl:if test="@main_anal='0'">нет</xsl:if>
          <xsl:if test="@main_anal='1'">да</xsl:if>
        </td>
        <!-- Кол-венные показатели -->
        <td align="center">
          <xsl:value-of select="@colrab_rm"/>
        </td>
        <td align="center">
          <xsl:value-of select="@colwom"/>
        </td>
        <td align="center">
          <xsl:value-of select="@col18"/>
        </td>
        <td align="center">
          <xsl:value-of select="@is_travma"/>
        </td>
        <td align="center">
          <xsl:value-of select="@is_profzab"/>
        </td>
        <td align="center">
          <xsl:value-of select="@arm_kut"/>
        </td>
        <td>
          <!-- Гарантии и компенсации -->
          <xsl:if test="@dopl='да'">
            - доплата;<br/>
          </xsl:if>
          <xsl:if test="@dop_otpusk='да'">
            - допотпуск;<br/>
          </xsl:if>
          <xsl:if test="@week ='да'">
            - сокращенное рабочее время;<br/>
          </xsl:if>
          <xsl:if test="@lpo ='да'">
            - льготная пенсия;<br/>
          </xsl:if>
          <xsl:if test="@milk ='да'">
            - выдача молока;<br/>
          </xsl:if>
          <xsl:if test="@profpit ='да'">
            - профпитание;<br/>
          </xsl:if>
          <xsl:if test="@medosm ='да'">
            - медосмотр.<br/>
          </xsl:if>
        </td>
        <td>
          <xsl:apply-templates select="rab"/>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="rab">
    <xsl:value-of select="@fio"/>/<xsl:value-of select="@snils"/><br/>
  </xsl:template>
  
  <xsl:template match ="member">
    <tr>
      <td class="center">
        <xsl:value-of select="count(preceding-sibling::member)+26"/>
      </td>
      <td>
        <xsl:value-of select="@state"/>
      </td>
      <td class="center">
        <xsl:value-of select="@proff"/>
      </td>
      <td class="center">
        <xsl:value-of select="@fio"/>
      </td>
    </tr>
  </xsl:template>  
  

  <xsl:template match ="izm_pers">
      <xsl:apply-templates select="fio"/>
  </xsl:template>

  <xsl:template match ="fio">
    <xsl:value-of select="@name"/>
    <br/>
  </xsl:template>


</xsl:stylesheet>