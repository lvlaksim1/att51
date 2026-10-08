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
        <td class="center" width="35%">Наименование рабочего места</td>
        <td colspan="2" class="center" width="60%">Результат хронометражных наблюдений<br/>(Наименование рабочей позы - время пребывания)
      </td>
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
    <xsl:variable name="co_items" select="count(pose/item)"/>
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
        <xsl:apply-templates select="pose/item" mode="item_first"/>
      </tr>
      <xsl:apply-templates select="pose/item" mode="item_second"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="item" mode="item_first">
    <xsl:variable name="item_num" select="count(preceding-sibling::*)+1"/>
    <xsl:if test="$item_num=1">
      <td width="50%">
        <xsl:if test="@bm='bm_5_1'">
          Свободная
        </xsl:if>
        <xsl:if test="@bm='bm_5_2'">
          Стоя
        </xsl:if>
        <xsl:if test="@bm='bm_5_3'">
          Неудобная
        </xsl:if>
        <xsl:if test="@bm='bm_5_4'">
          Фиксированная
        </xsl:if>
        <xsl:if test="@bm='bm_5_5'">
          Вынужденная
        </xsl:if>
        <xsl:if test="@bm='bm_5_6'">
          Поза «сидя» без перерывов
        </xsl:if>
      </td>
      <td width="10%" align="center">
        <xsl:value-of select="@fact"/> %
      </td>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="item" mode="item_second">
    <xsl:variable name="item_num" select="count(preceding-sibling::*)+1"/>
    <xsl:if test="$item_num>1">
      <tr>
        <td>
          <xsl:if test="@bm='bm_5_1'">
            Свободная
          </xsl:if>
          <xsl:if test="@bm='bm_5_2'">
            Стоя
          </xsl:if>
          <xsl:if test="@bm='bm_5_3'">
            Неудобная
          </xsl:if>
          <xsl:if test="@bm='bm_5_4'">
            Фиксированная
          </xsl:if>
          <xsl:if test="@bm='bm_5_5'">
            Вынужденная
          </xsl:if>
          <xsl:if test="@bm='bm_5_6'">
            Поза «сидя» без перерывов
          </xsl:if>
        </td>
        <td align="center">
          <xsl:value-of select="@fact"/> %
        </td>
      </tr>
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