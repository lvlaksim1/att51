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
      tr.src {
      font-weight: bold;
      text-align: left;
      }
      tr.podr {
      font-style:italic;
      font-weight: bold;
      }
      tr.zone {
      font-style:italic;
      }
      tr.param {
      font-size:9.0pt;
      }
      p.prim {
      font-size:9.0pt;
      }
      td.litle {
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
        <td width="10%">№ (код) РМ</td>
        <td width="30%">Наименование рабочего места, рабочей зоны, фактора</td>
        <td width="10%">Диапазон ЭМП</td>
        <td width="10%">Фактический уровень</td>
        <td class="litle" width="20%">Энергетическая экспозиция/напряженность<br/><b>расчетная*</b></td>
        <td class="litle" width="20%">Энергетическая экспозиция/напряженность<br/><b>ПДУ*</b></td>
      </tr>
        <xsl:apply-templates/>
    <tr>
      <td align="left" colspan="6">
        * - для диапазона 10 кГц - 30 кГц указывается напряженность электрического или магнитного поля.
      </td>
    </tr>
    </table>
  </xsl:template>

  <xsl:template match ="podr">
    <tr class="podr">
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
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="zone">
    <tr class="zone">
      <td colspan="6">
        <xsl:value-of select="@name"/>
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
        <xsl:value-of select="@diapazon"/>
      </td>
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:value-of select="@expose"/>
      </td>
      <td>
        <xsl:value-of select="@norm"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>