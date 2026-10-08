<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип предписания -->
  
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения о вредных и (или) опасных производственных факторах</title>
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
        <td width="11%">Индивидуальный номер рабочего места</td>
        <td width="30%">Наименование рабочего места, рабочей зоны, фактора</td>
        <td width="11%">Дата оценки (измерения)</td>
        <td width="13%">Факт. уровень</td>
        <td width="13%">ПДУ</td>
        <td width="11%">Класс условий труда</td>
        <td width="11%">Время воздействия</td>
      </tr>
        <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="row">
    <tr>
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      <td>
        <xsl:value-of select="@cell1"/>
      </td>
      <td>
        <p>
          <xsl:value-of select="@cell2"/>
        </p>
      </td>
      <td>
        <xsl:value-of select="@cell3"/>
      </td>
      <td>
        <xsl:value-of select="@cell4"/>
      </td>
      <td>
        <xsl:value-of select="@cell5"/>
      </td>
      <td>
        <xsl:value-of select="@cell6"/>
      </td>
      <td>
        <xsl:value-of select="@cell7"/>
      </td>
    </tr>
  </xsl:template>
  
  

</xsl:stylesheet>