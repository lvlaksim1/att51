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
    <table width="100%">
      <tr>
        <td width="40%" align="center">Рабочее место</td>
        <td width="40%" align="center">Заключение</td>
        <td width="20%" align="center">Класс условий труда</td>
      </tr>
      <xsl:apply-templates select="rm" />
    </table>
  </xsl:template>

  <xsl:template match ="rm">
      <tr>
        <xsl:variable name="kut">
          <xsl:value-of select="@kut"/>
        </xsl:variable>
        <td align="left">
          <xsl:value-of select="@num"/>. <xsl:value-of select="@name"/>
        </td>
        <td align="left">
          <xsl:apply-templates select="att_zakl" />
        </td>
        <td>
          <xsl:value-of select="$kut"/>
        </td>
      </tr>
  </xsl:template>

  <xsl:template match ="att_zakl">
    <xsl:value-of select="@text"/>
  </xsl:template>
  
</xsl:stylesheet>