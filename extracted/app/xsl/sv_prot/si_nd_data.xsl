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
    <table width="100%">
      <tr>
        <td width="8%">№</td>
        <td width="62%">Наименование вредного вещества</td>
        <td width="15%">№ СИ из п.2</td>
        <td width="15%">№ НД из п.6</td>
      </tr>
      <xsl:apply-templates select="//si_nd_data/si_nd_param"/>
    </table>
  </body>
	</html>
  </xsl:template>


  <xsl:template match ="si_nd_param">
    <tr>
      <td>
        <xsl:value-of select="count(preceding-sibling::si_nd_param)+1"/>
      </td>
      <td>
        <xsl:value-of select="@name" />
      </td>
      <td>
        <xsl:value-of select="@si_nums" />
      </td>
      <td>
        <xsl:value-of select="@nd_nums" />
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>