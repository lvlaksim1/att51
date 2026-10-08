<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <!-- 11/01/2024 - co_prots -->
  <xsl:variable name="co_him">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='1']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_bio">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='2']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_apfd">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='3']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_shum">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='4']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_infr">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='5']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_ultr">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='6']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_vibr_o">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='7']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_vibr_l">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='8']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_emp50">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='9' and @factor_name='ЭМП50']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_esp">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='9' and @factor_name='ЭСП']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_pmp">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='9' and @factor_name='ПМП']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_emp_rd">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='9' and @factor_name='ЭМП РЧ']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_rad">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='10']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_micro">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='11']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_osv">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='12']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_tyag">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='13']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_napr">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='14']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_ufi">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='26']/@co_docs"/>
  </xsl:variable>
  <xsl:variable name="co_lazer">
    <xsl:value-of select="//Document/ORG/doc[@factor_id='41']/@co_docs"/>
  </xsl:variable>
  
  
  <xsl:template match ="/">    
	<html>
	<head>
	    <title>Сведения об оформленных картах СОУТ</title>
    <style>
      /* Style Definitions */
      body
      {
      font-size:12.0pt;
      font-family: Times new roman, serif;
      text-align:left;
      }
      .h1 {
      font-size:14.0pt;
      text-align:center;
      }
      .h2 {
      font-weight:bold;
      font-size:12.0pt;
      text-align:center;
      }

      p.org_name {
      font-size:12.0pt;
      font-weight:bold;
      text-align:center;
      margin-bottom:0pt;
      }

      p.label {
      margin-bottom:0pt;
      }

      table.table2 tr td {
      font-size:11.0pt;
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
      font-size:12.0pt;
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

      table.empty
      {
      margin-bottom:0cm;
      margin-top:0cm;
      }

      table.empty,table.empty th,table.empty td
      {
      font-size:12.0pt;
      text-align:center;
      border:none;
      background:none;
      padding:0 5px 0 5px;
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
    <table class="empty">
      <tr>
        <td align="left" width="40%">
          <xsl:value-of select="@name"/>
        </td>
        <td width="20%"></td>
        <td align="left" width="40%">
          Начальнику испытательной лаборатории
        </td>
      </tr>
    </table>
  <p class="h1">
    <b>ЗАЯВКА № __</b><br/> на проведение лабораторных исследований (испытаний, измерений)
  </p>
  <p class="label">
    Заказчик:
  </p>
  <table width="100%">
    <tr>
      <td width="5%" class="center">1.</td>
      <td width="35%">Наименование организации</td>
      <td width="60%">
        <xsl:value-of select="@name"/>
      </td>
    </tr>
    <tr>
      <td class="center">2.</td>
      <td>Юридический адрес организации</td>
      <td>
        <xsl:value-of select="@adr"/>
      </td>
    </tr>
    <tr>
      <td class="center">3.</td>
      <td>Фактическое место проведения исследований (испытаний, измерений)</td>
      <td>
        <xsl:value-of select="@adr2"/>
      </td>
    </tr>
    <tr>
      <td class="center">4.</td>
      <td>Основание проведения исследований (испытаний, измерений)</td>
      <td></td>
    </tr>
    <tr>
      <td class="center">5.</td>
      <td>Номер и дата договора на проведение исследований (испытаний, измерений)</td>
      <td>
        <xsl:value-of select="@N_dog"/> от <xsl:value-of select="@D_dog"/>
      </td>
    </tr>
    <tr>
      <td class="center">6.</td>
      <td>Контактные данные заказчика (телефон, электронная почта)</td>
      <td>
        <xsl:value-of select="@phone"/>; <xsl:value-of select="@email"/>
      </td>
    </tr>
  </table>

    <p>
      <b>Прошу</b> (нужное указать)<br/>
      ❑ Провести исследования, испытания, измерения (перечень на 2-й стр. заявки)<br/>
      ❑ Оформить сводные протоколы по результатам проведения исследования, испытания, измерения<br/>
      ❑ Оформить индивидуальные протоколы по результатам проведения исследования, испытания, измерения<br/>
    </p>

    <p>
      <b>Заказчик обязуется:</b><br/>
      - обеспечить доступ на объект, создать условия для проведения исследований (измерений);<br/>
      - предоставить необходимые документы;<br/>
      - оплатить расходы на проведение исследований (измерений).<br/>
      <b>Заказчик ознакомлен с:</b><br/>
      - применяемыми методами и методиками проведения исследований, испытаний, измерений;<br/>
      - порядком, условиями и сроками проведения испытаний (измерений).<br/>
      <b>Заказчик согласен, что:</b><br/>
      - выбор оптимальных методов и методик исследований, испытаний, измерений остается за Испытательной лабораторией;<br/>
      - информация о заказчике, об объекте исследования, результатах исследований и т.д. в соответствии с действующим законодательством Российской Федерации передается в Федеральную службу по аккредитации;<br/>
      - к выполнению работ может быть привлечена субподрядная организация.
    </p>
    <p class="h2">Перечень исследований, испытаний, измерений</p>
    <table>
      <tr>
        <td width="5%" align="center">№</td>
        <td width="75%" align="center">Наименование</td>
        <td width="20%" align="center">Количество р.м. (т.и)</td>
      </tr>
      <tr>
        <td>1.</td>
        <td>Физические факторы</td>
        <td></td>
      </tr>
      <tr>
        <td>1.1</td>
        <td>Микроклимат</td>
        <td align="center">
          <xsl:value-of select="$co_micro"/>
        </td>
      </tr>
      <tr>
        <td>1.2</td>
        <td>Аэрозоли преимущественно фиброгенного действия (АПФД)</td>
        <td align="center">
          <xsl:value-of select="$co_apfd"/>
        </td>
      </tr>
      <tr>
        <td>1.3</td>
        <td>Шум</td>
        <td align="center">
          <xsl:value-of select="$co_shum"/>
        </td>
      </tr>
      <tr>
        <td>1.4</td>
        <td>Инфразвук</td>
        <td align="center">
          <xsl:value-of select="$co_infr"/>
        </td>
      </tr>
      <tr>
        <td>1.5</td>
        <td>Ультразвук воздушный</td>
        <td align="center">
          <xsl:value-of select="$co_ultr"/>
        </td>
      </tr>
      <tr>
        <td>1.6</td>
        <td>Общая вибрация</td>
        <td align="center">
          <xsl:value-of select="$co_vibr_o"/>
        </td>
      </tr>
      <tr>
        <td>1.7</td>
        <td>Локальная вибрация</td>
        <td align="center">
          <xsl:value-of select="$co_vibr_l"/>
        </td>
      </tr>
      <tr>
        <td>1.8</td>
        <td>Световая среда</td>
        <td align="center">
          <xsl:value-of select="$co_osv"/>
        </td>
      </tr>
      <tr>
        <td>1.9</td>
        <td>Переменное электромагнитное поле (промышленная частота 50 Гц)</td>
        <td align="center">
          <xsl:value-of select="$co_emp50"/>
        </td>
      </tr>
      <tr>
        <td>1.10</td>
        <td>Переменное электромагнитное поле радиочастотного диапазона</td>
        <td align="center">
          <xsl:value-of select="$co_emp_rd"/>
        </td>
      </tr>
      <tr>
        <td>1.11</td>
        <td>Электростатическое поле</td>
        <td align="center">
          <xsl:value-of select="$co_esp"/>
        </td>
      </tr>
      <tr>
        <td>1.12</td>
        <td>Постоянное магнитное поле</td>
        <td align="center">
          <xsl:value-of select="$co_pmp"/>
        </td>
      </tr>
      <tr>
        <td>1.13</td>
        <td>Ультрафиолетовое излучение</td>
        <td align="center">
          <xsl:value-of select="$co_ufi"/>
        </td>
      </tr>
      <tr>
        <td>1.14</td>
        <td>Лазерное излучение</td>
        <td align="center">
          <xsl:value-of select="$co_lazer"/>
        </td>
      </tr>
      <tr>
        <td>1.15</td>
        <td>Ионизирующие излучения</td>
        <td align="center">
          <xsl:value-of select="$co_rad"/>
        </td>
      </tr>
      <tr>
        <td>1.16</td>
        <td>Тяжесть трудового процесса</td>
        <td align="center">
          <xsl:value-of select="$co_tyag"/>
        </td>
      </tr>
      <tr>
        <td>1.17</td>
        <td>Напряженность трудового процесса</td>
        <td align="center">
          <xsl:value-of select="$co_napr"/>
        </td>
      </tr>
      <tr>
        <td>2.</td>
        <td>Химический фактор</td>
        <td align="center">
          <xsl:value-of select="$co_him"/>
        </td>
      </tr>
      <tr>
        <td>2.1</td>
        <td></td>
        <td></td>
      </tr>
      <tr>
        <td>2.2</td>
        <td></td>
        <td></td>
      </tr>
    </table>
    <p class="label">Менеджер ________________________________</p>
    <p class="label">Дата составления:</p>

    <p class="h2">Анализ заявки</p>
    <table class="table2">
      <tr>
        <td align="center" width="65%">Анализируемые требования</td>
        <td align="center" width="35%">
          Оценка соответствия требованиям<br/>
          <sup>(нужное подчеркнуть)</sup>
        </td>
      </tr>
      <tr>
        <td>Соответствие материально-технической базы ИЛ требованиям методик для проведения исследований (измерений)</td>
        <td align="center">Соответствие/несоответствие</td>
      </tr>
      <tr>
        <td>Соответствие материально-технической базы ИЛ требованиям методик для проведения исследований (измерений)</td>
        <td align="center">Соответствие/несоответствие</td>
      </tr>
    </table>

    <table width="100%">
      <tr>
        <td align="center">
          <br/>
          Заявка принята / не принята в работу Испытательной лаборатории ООО»<br/>
          <sup>(нужное подчеркнуть)</sup>
          <br/>
          <br/>
        </td>
      </tr>
    </table>

    <p align="center">
      Анализ заявки проведен, ИЛ имеет необходимые ресурсы для выполнения требований заказчика.<br/>
      Показатели, методы исследований, сроки выполнения, стоимость работ согласованы:
    </p>
    <p align="center">
      Начальник испытательной лаборатории ________________________________
    </p>
    
  </xsl:template>


</xsl:stylesheet>