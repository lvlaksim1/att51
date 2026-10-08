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
      text-align:left;
      }
      td.zone {
      text-align:center;
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
    <table>
      <tr>
        <td width="6%">№ (код) РМ</td>
        <td width="39%">Наименование рабочего места, рабочей зоны, фактора</td>
        <td width="15%">Дата оценки (измерения)</td>
        <td width="25%">Факт. уровень</td>
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
        <td colspan="5">
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
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="zone">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <td colspan="4">
        <xsl:value-of select="@name"/>
        <br/>
        Тип светильников - <xsl:value-of select="@sv_type"/>;
        тип ламп - <xsl:value-of select="@l_type"/>;
        мощность ламп - <xsl:value-of select="@Plamp"/> Вт;
        высота подвеса - <xsl:value-of select="@Hlamp"/> м;
        доля негорящих ламп - <xsl:value-of select="@Badlamp"/>
        %<xsl:if test="@Uizm">; напряжение сети, В (U1/U2) - <xsl:value-of select="@Uizm"/>.</xsl:if>
        <xsl:if test="@norm">
          <br/>Характеристика помещения (зрительной работы) - <xsl:value-of select="@norm"/>
        </xsl:if>
      </td>
      <td class="zone">
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
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>