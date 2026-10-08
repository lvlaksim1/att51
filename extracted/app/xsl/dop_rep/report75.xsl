<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Опись документов по СОУТ</title>
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
      text-align:left;
      }
      .normal
      {
      font-size:10.0pt;
      font-family:"Times New Roman";
      text-align:left;
      font-weight: normal;
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
      table.empty td.align_left {
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
    <p class="h1">Сводное заключение по условиям труда</p>
    <p class="h2">
      Организация: <xsl:value-of select="ORG/@name"/>
    </p>
    <xsl:apply-templates select="factor"/>
    <p>
      <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
    </p>
  </xsl:template>

  <xsl:template match ="factor">
    <xsl:variable name="fac_name">
      <xsl:if test="@fac_id='1'">
        Химический:
      </xsl:if>
      <xsl:if test="@fac_id='2'">
        Биологический:
      </xsl:if>
      <xsl:if test="@fac_id='3'">
        Аэрозоли ПФД:
      </xsl:if>
      <xsl:if test="@fac_id='4'">
        Шум:
      </xsl:if>
      <xsl:if test="@fac_id='5'">
        Инфразвук:
      </xsl:if>
      <xsl:if test="@fac_id='6'">
        Ультразвук:
      </xsl:if>
      <xsl:if test="@fac_id='7'">
        Вибрация общаяv
      </xsl:if>
      <xsl:if test="@fac_id='8'">
        Вибрация локальная:
      </xsl:if>
      <xsl:if test="@fac_id='9_1'">
        ЭМП-50:
      </xsl:if>
      <xsl:if test="@fac_id='9_2'">
        ЭСП:
      </xsl:if>
      <xsl:if test="@fac_id='9_3'">
        ПМП:
      </xsl:if>
      <xsl:if test="@fac_id='9_4'">
        ЭМП РЧ:
      </xsl:if>
      <xsl:if test="@fac_id='26'">
        УФИ:
      </xsl:if>
      <xsl:if test="@fac_id='41'">
        ЛИ:
      </xsl:if>
      <xsl:if test="@fac_id='10'">
        ИИ:
      </xsl:if>
      <xsl:if test="@fac_id='11'">
        Микроклимат:
      </xsl:if>
      <xsl:if test="@fac_id='12'">
        Световая среда:
      </xsl:if>
      <xsl:if test="@fac_id='13'">
        Тяжесть труда:
      </xsl:if>
      <xsl:if test="@fac_id='14'">
        Напряженность труда:
      </xsl:if>
    </xsl:variable>
    <p class="normal">
      <b><xsl:value-of select="$fac_name"/></b>
      <br/>
      <span>
          <!-- КОД ДЛЯ ВЫВОДА ЗАКЛЮЧЕНИЯ -->
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
      </span>
    </p>
  </xsl:template>  

</xsl:stylesheet>