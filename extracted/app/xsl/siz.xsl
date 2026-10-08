<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип предписания -->
  
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения об обеспеченности СИЗ</title>
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
        font-size:12.0pt;
        }
        tr.factor {
        font-weight: bold;
        }
        tr.param p {
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
    <table>
      <tr>
        <td width="6%">Номер рабочего места</td>
        <td width="15%">Наименование рабочего места</td>
        <td width="25%">Основание для выдачи работнику СИЗ</td>
        <td width="25%">Наименование СИЗ</td>
        <td width="10%">Наличие СИЗ</td>
        <td width="15%">Наличие сертификата</td>
      </tr>
        <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="siz">
    <tr>
      <xsl:if test="@isiz=0">
        <td>
          <xsl:attribute name="rowspan"><xsl:value-of select="@rowspan"/></xsl:attribute>
          <xsl:value-of select="@cell1"/>
        </td>
        <td>
          <xsl:attribute name="rowspan"><xsl:value-of select="@rowspan"/></xsl:attribute>
          <xsl:value-of select="@cell2"/>
        </td>
        <td>
          <xsl:attribute name="rowspan"><xsl:value-of select="@rowspan"/></xsl:attribute>
          <xsl:value-of select="@cell6"/>
        </td>
      </xsl:if>
      <td>
        <xsl:value-of select="@cell3"/>
      </td>
      <td>
        <xsl:value-of select="@cell4"/>
      </td>
      <td>
        <xsl:value-of select="@cell5"/>
      </td>
    </tr>
  </xsl:template>
  
  

</xsl:stylesheet>