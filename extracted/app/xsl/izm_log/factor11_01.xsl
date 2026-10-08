<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Журнал регистрации измерений</title>
    <style>
      /* Style Definitions */
      table
      {
      font-size:9.0pt;
      font-family:arial, verdana, sans-serif;
      text-align:center;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
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
    <xsl:if test="not(@all_facs)">
      <h1>Журнал регистрации измерений</h1>
    </xsl:if>
    <xsl:if test="@all_facs">
      <h1>Микроклимат</h1>
    </xsl:if>
    <table>
      <tr>
        <td width="4%">№ п/п</td>
        <td width="15%">Наименование организации</td>
        <td width="4%">№ РМ</td>
        <td width="30%">Наименование рабочего места, рабочей зоны, фактора</td>
        <td width="8%">Дата проведения измерения</td>
        <td width="10%">Факт.уровень</td>
        <td width="6%">Время воздействия, %</td>
        <td width="9%">Подпись работника, проводившего измерения</td>
        <td width="14%">Ф.И.О., должность присутствовавшего представителя заказчика</td>
      </tr>
      <tr>
        <td>1</td>
        <td>2</td>
        <td>3</td>
        <td>4</td>
        <td>5</td>
        <td>6</td>
        <td>7</td>
        <td>8</td>
        <td>9</td>
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
      <xsl:if test="@class='rm'">
        <td>
          <xsl:attribute name="rowspan">
            <xsl:value-of select="@rowspan_rm"/>
          </xsl:attribute>
          <xsl:value-of select="@cell2"/>
        </td>
      </xsl:if>
      <td>
        <xsl:attribute name="class"><xsl:value-of select="@cell3_class"/></xsl:attribute>
        <xsl:value-of select="@cell3"/>
      </td>
      <td>
        <xsl:attribute name="class"><xsl:value-of select="@cell4_class"/></xsl:attribute>
        <xsl:value-of select="@cell4"/>
      </td>
      <td>
        <xsl:attribute name="class"><xsl:value-of select="@cell5_class"/></xsl:attribute>
        <xsl:value-of select="@cell5"/>
      </td>
      <td>
        <xsl:value-of select="@cell6"/><xsl:if test="@U095">±<xsl:value-of select="@U095"/></xsl:if>
      </td>
      <td>
        <xsl:value-of select="@cell7"/>
      </td>
      <xsl:if test="@class!='param'">
        <td>
          <xsl:attribute name="rowspan"><xsl:value-of select="@rowspan"/></xsl:attribute>
          <xsl:value-of select="@cell8"/>
        </td>
      </xsl:if>
      <xsl:if test="@class!='param'">
        <td>
          <xsl:attribute name="class"><xsl:value-of select="@cell9_class"/></xsl:attribute>
          <xsl:attribute name="rowspan"><xsl:value-of select="@rowspan"/></xsl:attribute>
          <xsl:value-of select="@cell9"/>
        </td>
      </xsl:if>
    </tr>
  </xsl:template>
  
  

</xsl:stylesheet>