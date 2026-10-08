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
      tr.src {
      font-weight: bold;
      text-align: left;
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
      tr.param2 {
      font-style:italic;
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
        <td width="6%">№ РМ</td>
        <td width="34%">Наименование рабочего места, рабочей зоны, фактора</td>
        <td width="15%">Эквивалентный общий уровень звукового давления,  дБ</td>
        <td width="10%">U0.95, дБ</td>
        <td width="10%">ПДУ, дБ</td>
        <td width="10%">Класс условий труда</td>
        <td width="15%">Время воздействия, мин*</td>
      </tr>
        <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="podr">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <td colspan="7">
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
      <td></td>
      <td></td>
      <td></td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
      <td></td>
    </tr>
    <tr class="src">
      <td colspan="7">
        Источник вредного фактора: <xsl:value-of select="@src"/>
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
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:if test="@bm='izm'">
          <xsl:value-of select="@unc"/>
        </xsl:if>
        <xsl:if test="@bm='Lekv'">
          <xsl:value-of select="@U8h"/>
        </xsl:if>
      </td>
      <td>
        <xsl:value-of select="@norm"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
      <td>
        <xsl:value-of select="@time_min"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>