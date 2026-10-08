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
        <td rowspan="2" width="6%">№ (код) РМ</td>
        <td rowspan="2" width="30%">Наименование рабочего места, рабочей зоны, фактора</td>
        <td rowspan="2" width="10%">Дата оценки (измерения)</td>
        <td colspan="4" width="24%">Уровни звукового давления, дБ в октавных полосах со среднегеометрическими частотами, Гц</td>
        <td rowspan="2" width="9%">Общий уровень звукового давления,  дБ</td>
        <td rowspan="2" width="7%">ПДУ, дБ</td>
        <td rowspan="2" width="7%">Класс условий труда</td>
        <td rowspan="2" width="7%">Время воздействия, %</td>
      </tr>
      <tr>
        <td width="6%">2</td>
        <td width="6%">4</td>
        <td width="6%">8</td>
        <td width="6%">16</td>
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
      <td>
        <xsl:value-of select="@izm_date"/>
      </td>
      <td></td>
      <td></td>
      <td></td>
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
      <td></td>
      <td>
        <xsl:value-of select="@L2"/>
      </td>
      <td>
        <xsl:value-of select="@L4"/>
      </td>
      <td>
        <xsl:value-of select="@L8"/>
      </td>
      <td>
        <xsl:value-of select="@L16"/>
      </td>
      <td>
        <xsl:value-of select="@fact"/>
        <xsl:if test="@U8h">
          ±<xsl:value-of select="@U8h"/>
        </xsl:if>

      </td>
      <td>
        <xsl:value-of select="@norm"/>
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