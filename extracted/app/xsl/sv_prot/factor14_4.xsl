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
      }
      tr.zone {
      font-style:italic;
      }
      tr.param {
      font-size:9.0pt;
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
        <td width="6%">№ (код) РМ</td>
        <td width="20%">Наименование рабочего места, рабочей зоны, фактора</td>
        <td width="11%">Дата оценки (измерения)</td>
        <td width="13%">Факт. уровень</td>
        <td width="9%">U095</td>
        <td width="10%">ПДУ</td>
        <td width="9%">ОТКЛ</td>
        <td width="11%">Класс условий труда</td>
        <td width="11%">Время воздействия, %</td>
      </tr>
        <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="podr">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <td colspan="9">
        <xsl:value-of select="@name"/>
        <xsl:if test="@adr!=''">
          (<xsl:value-of select="@adr"/>)
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="rm">
    <tr>
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      <td>
        <xsl:value-of select="@num"/>
      </td>
      <td>
        <p>
          <xsl:value-of select="@name"/>
          <xsl:if test="@adr_rm!=''">
            (<xsl:value-of select="@adr_rm"/>)
          </xsl:if>
        </p>
      </td>
      <td>
        <xsl:value-of select="@izm_date"/>
      </td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
     <td>
        <xsl:value-of select="@kut"/>
      </td>
      <td>100</td>
    </tr>
    <!-- Краткое описание выполняемой работы -->
    <tr>
      <td align="left" colspan="9">
        <b>Краткое описание выполняемой работы:</b>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@src"/>
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="zone">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <td colspan="8">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="param">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <td></td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td></td>
      <td>
        <xsl:value-of select="@fact2"/>
      </td>
      <td>
        <xsl:value-of select="@unc"/>
      </td>
      <td>
        <xsl:value-of select="@norm"/>
      </td>
      <td>
        <xsl:value-of select="@otkl"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>