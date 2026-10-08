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
        <td width="50%" align="center">Рабочее место</td>
        <td width="50%" align="center">Соответствие фактического уровня вредного фактора гигиеническим нормативам</td>
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
        <td>
          <xsl:if test="$kut>2">
            Фактический уровень вредного фактора не соответствует гигиеническим нормативам по вредным веществам:
            <!--xsl:apply-templates select="zone/param[@kut>2]" /-->
            <xsl:for-each select=".//param[@kut>2 and not(@name=../preceding-sibling::zone/param/@name)]">
              <xsl:value-of select="@name"/><xsl:if test="position()!=last()">; </xsl:if><xsl:if test="position()=last()">.</xsl:if>
            </xsl:for-each>
          </xsl:if>
          <xsl:if test="$kut&lt;=2">
            Фактический уровень вредного фактора соответствует гигиеническим нормативам
          </xsl:if>
        </td>
      </tr>
  </xsl:template>

  <xsl:template match ="param">
      <xsl:value-of select="@name"/>; 
  </xsl:template>
  
</xsl:stylesheet>