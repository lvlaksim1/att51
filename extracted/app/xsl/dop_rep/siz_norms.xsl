<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Отчет по оформленным документам</title>
    <style>
      /* Style Definitions */
      body
      {
      font-size:12.0pt;
      font-family: Times new roman, serif;
      text-align:left;
      }
      .h1 {
      font-weight:bold;
      font-size:16.0pt;
      text-align:center;
      }
      .h2 {
      font-weight:bold;
      font-size:14.0pt;
      text-align:center;
      }
      p.razdel
      {
      font-size:11.0pt;
      font-weight: bold;
      margin-top:0.1cm;
      margin-bottom:0.1cm;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
      td.center {
      text-align:center;
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

      .red {
      color: red;
      }

      table.empty
      {
      margin-bottom:0cm;
      margin-top:0cm;
      }

      table.empty,table.empty th,table.empty td
      {
      font-size:10.0pt;
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
    <p class="h1">НОРМЫ ВЫДАЧИ СИЗ</p>
    <p style='margin-left:540.0pt; margin-top:10.0pt'>
      УТВЕРЖДАЮ<br/>
      Руководитель организации<br/>
      ____________ <xsl:value-of select="@boss_fio"/><br/>
      "___" ____________ <xsl:value-of select="@year"/>
    </p>
    <table>
      <tr>
        <td class="center" width="5%">№ РМ</td>
        <td class="center" width="12%">Наименование РМ</td>
        <td class="center" width="12%">Тип СИЗ</td>
        <td class="center" width="12%">Наименование СИЗ</td>
        <td class="center" width="24%">Дополнительные сведения о СИЗ (данные о конструкции, классе защиты, категориях эффективности и/или эксплуатационных уровнях)</td>
        <td class="center" width="10%">Нормы выдачи СИЗ</td>
        <td class="center" width="25%">Основание выдачи СИЗ (по приказу N 767Н от 29.10.2021)</td>
      </tr>
      <xsl:apply-templates select="RM"/>
    </table>
    <p class="razdel">
      Ответственное лицо:
    </p>
    <table align="center" width="60%" class="empty">
      <tr>
        <td class="sign" width="37%">
          <xsl:value-of select="@org_member_state" />
        </td>
        <td width="3%">
          <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
        </td>
        <td class="sign" width="20%">
          <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
        </td>
        <td width="3%">
          <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
        </td>
        <td class="sign" width="37%">
          <xsl:value-of select="@org_member_fio" />
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
    </table>
  </xsl:template>

  
  <xsl:template match ="RM">
    <xsl:variable name="RowSpan" select="count(siz)"/>
    <tr>
      <td align="center">
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="@num"/>
      </td>
      <td>
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="@prof"/>
      </td>
      <td>
        <xsl:value-of select="siz[1]/@type"/>
      </td>
      <td>
        <xsl:value-of select="siz[1]/@siz"/>
      </td>
      <td>
        <xsl:value-of select="siz[1]/@descr"/>
      </td>
      <td>
        <xsl:value-of select="siz[1]/@norm"/>
      </td>
      <td>
        <xsl:if test="siz[1]/@osn_type='p1'">
          Прил.1, п."<xsl:value-of select="siz[1]/@osn"/>"
        </xsl:if>
        <xsl:if test="siz[1]/@osn_type='p2'">
          Прил.2, п."<xsl:value-of select="siz[1]/@osn"/>"
        </xsl:if>
        <xsl:if test="siz[1]/@osn_type='p3'">
          Прил.3, п."<xsl:value-of select="siz[1]/@osn"/>"
        </xsl:if>
      </td>
    </tr>
    <xsl:apply-templates select="siz"/>
  </xsl:template>

  <xsl:template match ="siz">
    <xsl:variable name="co_siz" select="count(preceding-sibling::*)"/>
    <xsl:if test="$co_siz>0">
      <tr>
        <td>
          <xsl:value-of select="@type"/>
        </td>
        <td>
          <xsl:value-of select="@siz"/>
        </td>
        <td>
          <xsl:value-of select="@descr"/>
        </td>
        <td>
          <xsl:value-of select="@norm"/>
        </td>
        <td>
          <xsl:if test="@osn_type='p1'">
            Прил.1, п."<xsl:value-of select="@osn"/>"
          </xsl:if>
          <xsl:if test="@osn_type='p2'">
            Прил.2, п."<xsl:value-of select="@osn"/>"
          </xsl:if>
          <xsl:if test="@osn_type='p3'">
            Прил.3, п."<xsl:value-of select="@osn"/>"
          </xsl:if>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>