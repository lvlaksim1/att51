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
	    <title>Результат хронометражных наблюдений</title>
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
      font-size:10.0pt;
      }

      table.rm_data tr td {
      font-size:10.0pt;
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
    <table width="100%" class="rm_data">
      <tr>
        <td class="center" width="5%">№ РМ</td>
        <td class="center" width="30%">Наименование рабочего места</td>
        <td class="center" width="25%">Показатель</td>
        <td class="center" width="40%">Результат хронометражных наблюдений</td>
      </tr>
      <xsl:apply-templates select="ORG/RM"/>
    </table>
    
    <p>&#160;</p>
    <!-- Комиссия с подписями -->
    <xsl:apply-templates select="ORG/comission" mode="mode2"/>
    <!-- Служебный блок, чтобы не сбивалось форматирование последнего абзаца -->
    <p>&#160;</p>
    
  </xsl:template>

  <xsl:template match ="RM">
    <xsl:variable name="co_items" select="count(params/param)"/>
    <xsl:if test="$co_items>0">
      <tr>
        <td align="center">
          <xsl:attribute name="rowspan">
            <xsl:value-of select ="$co_items"/>
          </xsl:attribute>
          <xsl:value-of select="@num"/>
        </td>
        <td>
          <xsl:attribute name="rowspan">
            <xsl:value-of select ="$co_items"/>
          </xsl:attribute>
          <xsl:value-of select="@name"/>
          <xsl:if test="@sex='1'"> (мужской пол)</xsl:if>
          <xsl:if test="@sex='2'"> (женский пол)</xsl:if>
        </td>
        <xsl:apply-templates select="params/param" mode="first_row"/>
      </tr>
      <xsl:apply-templates select="params/param" mode="second_row"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="param" mode="first_row">
    <xsl:variable name="item_num" select="count(preceding-sibling::*)+1"/>
    <xsl:if test="$item_num=1">
      <td>
        <xsl:if test="@id='stat_bm_4_3'">Статическая с участием мышц корпуса и ног</xsl:if>
        <xsl:if test="@id='fdn_bm_1_1'">Физическая динамическая нагрузка до 1 м</xsl:if>
        <xsl:if test="@id='fdn_bm_1_2'">Физическая динамическая нагрузка от 1 м до 5 м</xsl:if>
        <xsl:if test="@id='fdn_bm_1_3'">Физическая динамическая нагрузка более 5 м</xsl:if>
        <xsl:if test="@id='massa_bm_2_1'">Подъем и перемещение тяжести (до 2-х раз в час)</xsl:if>
        <xsl:if test="@id='massa_bm_2_2'">Подъем и перемещение тяжести (более 2 раз в час)</xsl:if>
        <xsl:if test="@id='move_bm_2_3_1'">Перемещение груза с рабочей поверхности</xsl:if>
        <xsl:if test="@id='move_bm_2_3_2'">Перемещение груза с пола</xsl:if>
        <xsl:if test="@id='stereo_bm_3_1'">Стереотипные рабочие движения при локальной нагрузке </xsl:if>
        <xsl:if test="@id='stereo_bm_3_2'">Стереотипные рабочие движения при региональной нагрузке </xsl:if>
        <xsl:if test="@id='stat_bm_4_1'">Статическая нагрузка одной рукой</xsl:if>
        <xsl:if test="@id='stat_bm_4_2'">Статическая нагрузка двумя руками</xsl:if>
        <xsl:if test="@id='pose'">Рабочая поза</xsl:if>
        <xsl:if test="@id='nakl_bm_6'">Наклоны корпуса</xsl:if>
        <xsl:if test="@id='dist_hor_bm_7_1'">Перемещение по горизонтали</xsl:if>
        <xsl:if test="@id='dist_ver_bm_7_2'">Перемещение по вертикали</xsl:if>
      </td>
      <td align="center">
        <xsl:apply-templates select="item"/>
      </td>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="param" mode="second_row">
    <xsl:variable name="item_num" select="count(preceding-sibling::*)+1"/>
    <xsl:if test="$item_num>1">
      <tr>
        <td>
          <xsl:if test="@id='stat_bm_4_3'">Статическая нагрузка с участием мышц корпуса и ног</xsl:if>
          <xsl:if test="@id='fdn_bm_1_1'">Физическая динамическая нагрузка до 1 м</xsl:if>
          <xsl:if test="@id='fdn_bm_1_2'">Физическая динамическая нагрузка от 1 м до 5 м</xsl:if>
          <xsl:if test="@id='fdn_bm_1_3'">Физическая динамическая нагрузка более 5 м</xsl:if>
          <xsl:if test="@id='massa_bm_2_1'">Подъем и перемещение тяжести (до 2-х раз в час)</xsl:if>
          <xsl:if test="@id='massa_bm_2_2'">Подъем и перемещение тяжести (более 2 раз в час)</xsl:if>
          <xsl:if test="@id='move_bm_2_3_1'">Перемещение груза с рабочей поверхности</xsl:if>
          <xsl:if test="@id='move_bm_2_3_2'">Перемещение груза с пола</xsl:if>
          <xsl:if test="@id='stereo_bm_3_1'">Стереотипные рабочие движения при локальной нагрузке </xsl:if>
          <xsl:if test="@id='stereo_bm_3_2'">Стереотипные рабочие движения при региональной нагрузке </xsl:if>
          <xsl:if test="@id='stat_bm_4_1'">Статическая нагрузка одной рукой</xsl:if>
          <xsl:if test="@id='stat_bm_4_2'">Статическая нагрузка двумя руками</xsl:if>
          <xsl:if test="@id='pose'">Рабочая поза</xsl:if>
          <xsl:if test="@id='nakl_bm_6'">Наклоны корпуса</xsl:if>
          <xsl:if test="@id='dist_hor_bm_7_1'">Перемещение по горизонтали</xsl:if>
          <xsl:if test="@id='dist_ver_bm_7_2'">Перемещение по вертикали</xsl:if>
        </td>
        <td align="center">
          <xsl:apply-templates select="item"/>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="item">
    <xsl:variable name="id" select="../@id"/>
    <!-- Рабочая поза -->
    <xsl:if test="$id='pose'">
      <xsl:if test="@bm='bm_5_1'">
        Свободная - 
      </xsl:if>
      <xsl:if test="@bm='bm_5_2'">
        Стоя - 
      </xsl:if>
      <xsl:if test="@bm='bm_5_3'">
        Неудобная -
      </xsl:if>
      <xsl:if test="@bm='bm_5_4'">
        Фиксированная -
      </xsl:if>
      <xsl:if test="@bm='bm_5_5'">
        Вынужденная - 
      </xsl:if>
      <xsl:if test="@bm='bm_5_6'">
        Поза «сидя» без перерывов
      </xsl:if>
      <xsl:value-of select="@fact"/>%<xsl:if test="not (position() = last())" >; </xsl:if>
  </xsl:if>
    <!-- статическая нагрузка -->
    <xsl:if test="contains($id,'stat_bm_4')">
      <xsl:value-of select="@massa"/> кг - <xsl:value-of select="@time"/> сек - <xsl:value-of select="@count"/>
      раз(а)<xsl:if test="not (position() = last())" >; </xsl:if>
    </xsl:if>
    <!-- ФДН -->
    <xsl:if test="contains($id,'fdn_bm_1')">
      <xsl:value-of select="@massa"/> кг - <xsl:value-of select="@dist"/> м - <xsl:value-of select="@count"/>
      раз(а)<xsl:if test="not (position() = last())" >; </xsl:if>
    </xsl:if>
    <!-- масса -->
    <xsl:if test="contains($id,'massa_bm_2')">
      <xsl:value-of select="@massa"/> кг
    </xsl:if>
    <!-- перемещение за 1 час -->
    <xsl:if test="contains($id,'move_bm_2_3')">
      <xsl:value-of select="@massa"/> кг - <xsl:value-of select="@count"/>
      раз(а)<xsl:if test="not (position() = last())" >; </xsl:if>
    </xsl:if>
    <!-- стереотипные движения -->
    <xsl:if test="contains($id,'stereo_bm_3')">
      <xsl:value-of select="@moves"/> дв. - <xsl:value-of select="@count"/> раз(а)<xsl:if test="not (position() = last())" >; </xsl:if>
    </xsl:if>
    <!-- Наклоны -->
    <xsl:if test="contains($id,'nakl_bm_6')">
      <xsl:variable name="co_nakl">
        <xsl:value-of select="@count"/>
      </xsl:variable>
      <xsl:if test="$co_nakl=''">
        <xsl:value-of select="@nakl"/>
      </xsl:if>
      <xsl:if test="$co_nakl!=''">
        <xsl:value-of select="@nakl"/> накл. - <xsl:value-of select="@count"/> раз(а)<xsl:if test="not (position() = last())" >; </xsl:if> 
      </xsl:if>
    </xsl:if>
    <!-- Перемещение по горизонтали -->
    <xsl:if test="contains($id,'dist_hor_bm_7_1')">
      <xsl:variable name="ed_izm">
        <xsl:value-of select="@ed_izm"/>
      </xsl:variable>
      <xsl:if test="$ed_izm='km'">
        <xsl:value-of select="@dist"/> км
      </xsl:if>
      <xsl:if test="$ed_izm='metr'">
        <xsl:value-of select="@dist"/> м - <xsl:value-of select="@count"/> раз(а)<xsl:if test="not (position() = last())" >; </xsl:if>
      </xsl:if>
      <xsl:if test="$ed_izm='step'">
        <xsl:value-of select="@dist"/> шаг. - <xsl:value-of select="@count"/> раз(а)<xsl:if test="not (position() = last())" >; </xsl:if>
      </xsl:if>
    </xsl:if>
    <!-- Перемещение по вертикали -->
    <xsl:if test="contains($id,'dist_ver_bm_7_2')">
      <xsl:variable name="ed_izm">
        <xsl:value-of select="@ed_izm"/>
      </xsl:variable>
      <xsl:if test="$ed_izm='km'">
        <xsl:value-of select="@dist"/> км
      </xsl:if>
      <xsl:if test="$ed_izm='metr'">
        <xsl:value-of select="@dist"/> м - <xsl:value-of select="@count"/> раз(а)<xsl:if test="not (position() = last())" >; </xsl:if>
      </xsl:if>
      <xsl:if test="$ed_izm='step'">
        <xsl:value-of select="@dist"/> шаг. - <xsl:value-of select="@count"/> раз(а)<xsl:if test="not (position() = last())" >; </xsl:if>
      </xsl:if>
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