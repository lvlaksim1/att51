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
      td.src {
      margin-left:0.5cm;
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
        <td width="10%">№ (код) РМ</td>
        <td width="30%">Наименование рабочего места, рабочей зоны, фактора</td>
        <td width="15%">Дата оценки (измерения)</td>
        <td width="15%">Группа патогенности</td>
        <td width="15%">Класс условий труда</td>
        <td width="15%">Время воздействия, %</td>
      </tr>
        <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="podr">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <td colspan="6">
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
      <td>-</td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
      <td>-</td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="zone">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <td colspan="5" class="src" align="left">
        <xsl:value-of select="@name"/>
        <br/>
        Источник вредного фактора: <xsl:value-of select="@bio_src"/>
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
      <td>-</td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>-</td>
      <td>
        <xsl:value-of select="@bio_group"/>
        <xsl:if test="@bio_group=''">-</xsl:if>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
      <td>
        <xsl:value-of select="@time"/>
        <xsl:if test="@time=''">-</xsl:if>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>