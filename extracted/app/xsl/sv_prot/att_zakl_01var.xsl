<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип предписания -->
  
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сводное заключения о вредных условия труда</title>
    <style>
      /* Style Definitions */
      table
      {
      font-size:10.0pt;
      font-family:"Times New Roman";
      text-align:center;
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
      font-style:italic;
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
      font-size:12.0pt;
      text-align:left;
      border:none;
      background:none;
      padding:0 5px 0 5px;
      vertical-align: top;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <p>
      <br/>По результатам измерений установлено:<br/>
      <!-- КОД ДЛЯ ВЫВОДА ЗАКЛЮЧЕНИЯ -->
      <!-- Код получился через чур замсыловатым по причине необходимости замены последней ";" на "." и необходимости вывода разрывов строки -->
      <!-- Пока в голову ничего не приходит. Если кто-то найдет более элегантное рещение подскажите, поправлю. -->
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
    <p>&#160;</p>
  </xsl:template>

</xsl:stylesheet>