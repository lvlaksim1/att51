<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="co_members">
    <xsl:value-of select="count(//comission/member)" />
  </xsl:variable>
  <xsl:variable name="reasons">
    <xsl:value-of select="Document/ORG/@ident2_reason" />
  </xsl:variable>
  <xsl:variable name="predsed">
    <xsl:value-of select="//comission/member[1]/@fio" />
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


      p.space
      {
      margin-top:10pt;
      margin-bottom:10pt;
      }

      p.ident
      {
      text-indent: 50px;
      margin-top:0pt;
      margin-bottom:0pt;
      }

      .h1 {
      font-weight:bold;
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
      font-size:12.0pt;
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
      border:none;
      background:none;
      padding:0 5px 0 5px;
      }

      table.empty td.sign4 {
      border-bottom: 1px solid black;
      margin-top:5pt;
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
    <p class="ident">
      Комиссия по специальной оценке условий труда в <xsl:value-of select="ORG/@name"/>, созданная приказом № <xsl:value-of select="ORG/@N_prikaz"/> от <xsl:value-of select="ORG/@D_prikaz"/>, в составе:
    </p>
    <!-- Перечисляем комиссию -->
    <xsl:apply-templates select="ORG/comission" mode="mode1"/>
    <!-- Основной текст протокола -->
    <p class="ident">
      рассмотрела нижеуказанные вопросы:
    </p>
    <p class="ident">
      1. об утверждении  Перечня вредных и (или) опасных производственных факторов, подлежащих исследованиям (испытаниям) и измерениям,  содержащего результаты идентификации потенциально вредных и (или) опасных производственных факторов (согласно п. 5,  ст. 9 Федерального закона № 426-ФЗ от 28.12.2013 «О специальной оценке условий труда»), составленного на основании Заключения эксперта о проведении идентификации потенциально вредных и (или) опасных  производственных факторов № <xsl:value-of select="ORG/@zakl_ident"/> (согласно п. 3, р. 2 Методики проведения специальной оценки условий труда (утв. приказом Минтруда РФ № 817н от 21 ноября 2023 г.));
    </p>
    <p class="ident">
      2. о предоставлении  утвержденного Председателем комиссии по специальной оценке условий труда <xsl:value-of select="ORG/@name"/>, подписанного членами комиссии по специальной оценке условий труда Перечня рабочих мест с наличием биологического фактора для использования экспертом по специальной оценке условий труда;
    </p>
    <p class="ident">
      3. о внесении данных по СНИЛС в карты специальной оценки условий труда.
    </p>
    <p class="ident">&#160;</p>
    <p class="ident">
      Председатель комиссии <xsl:value-of select="$predsed"/> предложил:
    </p>
    <p class="ident">
      - утвердить Перечень вредных и (или) опасных производственных факторов, подлежащих исследованиям (испытаниям) и измерениям, содержащий результаты идентификации потенциально вредных и (или) опасных производственных факторов;
    </p>
    <p class="ident">
      - предоставить  утвержденный Председателем комиссии по специальной оценке условий труда <xsl:value-of select="ORG/@name"/>, подписанный членами комиссии по специальной оценке условий труда Перечень рабочих мест с наличием биологического фактора;
    </p>
    <p class="ident">
      - не  вносить данные по СНИЛС в карты специальной оценки условий труда,  кроме тех рабочих мест,  на которых профессии, должности и показатели дают право на льготное пенсионное обеспечение, в соответствии  Списков N 1 и 2, утвержденных Постановлением Кабинета министров СССР от 26 января 1991 года N 10.
    </p>
    <p class="ident">&#160;</p>
    <p class="ident">
      Комиссия приняла следующие решения:
    </p>
    <p class="ident">
      1. утвердить Перечень вредных и (или) опасных производственных факторов, подлежащих исследованиям (испытаниям) и измерениям, содержащий результаты идентификации потенциально вредных и (или) опасных производственных факторов;
    </p>
    <p class="ident">
      2. предоставить  утвержденный Председателем комиссии по специальной оценке условий труда <xsl:value-of select="ORG/@name"/>, подписанный членами комиссии по специальной оценке условий труда Перечень рабочих мест с наличием биологического фактора;
    </p>
    <p class="ident">
      3. не  вносить данные по СНИЛС в карты специальной оценки условий труда,  кроме тех рабочих мест,  на которых профессии, должности и показатели дают право на льготное пенсионное обеспечение, в соответствии  Списков N 1 и 2, утвержденных Постановлением Кабинета министров СССР от 26 января 1991 года N 10.
    </p>
    <p class="ident">&#160;</p>
    <p class="ident">
      Приложения:
    </p>
    <p class="ident">
      - Заключение эксперта № <xsl:value-of select="ORG/@zakl_ident"/> по результатам проведения идентификации потенциально вредных и (или) опасных  производственных факторов;
    </p>
    <p class="ident">
      - Перечень вредных и (или) опасных производственных факторов на рабочих местах, подлежащих исследованиям (испытаниям) и измерениям, в том числе содержащий результаты идентификации потенциально вредных и (или) опасных производственных факторов.
    </p>

    <p>&#160;</p>
    <!-- Комиссия с подписями -->
    <xsl:apply-templates select="ORG/comission" mode="mode2"/>
    <!-- Служебный блок, чтобы не сбивалось форматирование последнего абзаца -->
    <p>&#160;</p>
  </xsl:template>

  <xsl:template match ="RM">
    <xsl:if test="@is_ident='2'">
      <br/><b><xsl:value-of select="@rm_name"/><xsl:if test="position() != last()">;</xsl:if></b>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="comission" mode="mode1">
    <table class="empty" width="100%">
      <xsl:apply-templates select="member" mode="mode1"/>
    </table>
  </xsl:template>

  <xsl:template match ="member" mode="mode1">
    <xsl:variable name="num_member">
      <xsl:value-of select="count(preceding-sibling::member[@state='Член комиссии'])+1"/>
    </xsl:variable>
    <tr>
      <td width="30%">
         <xsl:if test="@state='Председатель'">
           <b>Председатель комиссии:</b>
           <xsl:attribute name="width">10%</xsl:attribute>
         </xsl:if>
         <xsl:if test="(@state='Член комиссии') and ($num_member=1)">
           <b>Члены комиссии:</b>
         </xsl:if>
       </td>
      <td width="3%"></td>
      <td  width="67%" class="sign4" align="center">
        <xsl:value-of select="@proff"/>, <xsl:value-of select="@fio"/>
      </td>
    </tr>
  </xsl:template>


  <xsl:template match ="comission" mode="mode2">
    <table class="comission" width="100%">
      <xsl:apply-templates select="member" mode="mode2"/>
    </table>
  </xsl:template>

  <xsl:template match ="member" mode="mode2">
    <xsl:variable name="iRow" select="count(preceding-sibling::member)+1"/>
    <xsl:if test="$iRow='1'">
      <tr>
        <td class="left"  colspan="7">
          <b>Председатель комиссии:</b>
        </td>
      </tr>
    </xsl:if>
    <xsl:if test="$iRow='2'">
      <tr>
        <td class="left" colspan="7">
          <b>Члены комиссии:</b>
        </td>
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
      <td width="20%">
        <sup>(должность)</sup>
      </td>
      <td width="3%"></td>
      <td width="15%">
        <sup>(подпись)</sup>
      </td>
      <td width="3%"></td>
      <td width="30%">
        <sup>(фамилия, имя, отчество (при наличии))</sup>
      </td>
      <td width="3%"></td>
      <td width="15%">
        <sup>(дата)</sup>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>