<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип предписания -->
  
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения о средствах измерения</title>
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
    <table>
      <tr>
        <td width="5%">№</td>
        <td width="30%">Наименование средства измерения</td>
        <td width="10%">Заводской номер</td>
        <td width="10%">Сведения о поверке</td>
        <td width="10%">Действие поверки</td>
        <td width="15%">Погрешность измерения</td>
        <td width="20%">Условия эксплуатации</td>
      </tr>
      <xsl:apply-templates select="//si_data/si"/>
    </table>
	</body>
	</html>
  </xsl:template>


  <xsl:template match ="si">
    <tr>
      <td>
        <xsl:value-of select="@num"/>
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@factory_num"/>
      </td>
      <td>
        <xsl:value-of select="@num_doc2"/>
      </td>
      <td>
        <xsl:value-of select="@begin_date"/>-<xsl:value-of select="@end_date"/>
      </td>
      <td>
        <xsl:value-of select="@si_err"/>
      </td>
      <td>
        <xsl:value-of select="@si_cond"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>