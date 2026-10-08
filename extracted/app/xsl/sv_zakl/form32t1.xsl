<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сводное заключение по результатам идентификации</title>
    <style>
      /* Style Definitions */
      table
      {
      font-size:9.0pt;
      font-family:Times new roman, arial, verdana, sans-serif;
      text-align:center;
      width:100%;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
      th {
      background-color: #EAEAEA;
      }
      td.bold {
      font-weight: bold;
      font-size:9.0pt;
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
      td.sign {
      height:30pt;
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
        <th width="10%">№ РМ</th>
        <th width="70%">Наименование РМ (по штатному расписанию)</th>
        <th width="20%">Наличие аналогичного РМ</th>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>
  
  <xsl:template match ="podr">
    <tr>
      <td colspan="3">
        <xsl:value-of select="@name"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="rm">
    <tr>
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      <td>
        <xsl:value-of select="@rm_num"/>
      </td>
      <td>
        <xsl:value-of select="@rm_name"/>
      </td>
      <td>
        <xsl:value-of select="@anal_rms"/>
      </td>
    </tr>
  </xsl:template>
  
  

</xsl:stylesheet>