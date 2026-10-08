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
    <table>
      <tr>
        <td width="5%">№ (код) РМ</td>
        <td width="35%">Наименование рабочего места, рабочей зоны, показателя</td>
        <td width="30%">Наименование вредного вещества</td>
        <td width="10%">ФАКТ</td>
        <td width="10%">ПДК</td>
        <td width="10%">Класс условий труда</td>
      </tr>
        <xsl:apply-templates select="rm"/>
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
    <xsl:if test="zone/@bm='pn_data'">
      <tr>
        <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
        <td>
          <xsl:value-of select="@num"/>
        </td>
        <td>
          <xsl:value-of select="@name"/>
        </td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
      <xsl:apply-templates select="zone"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="zone">
    <xsl:if test="@bm='pn_data'">
      <xsl:apply-templates select="param" mode="pn"/>
    </xsl:if>
    
  </xsl:template>


  <xsl:template match ="param" mode="pn">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <td></td>
      <td>
        <xsl:if test="@bm='plvn_sum'">
          Кратность превышения КПН
        </xsl:if>
        <xsl:if test="@bm='plvn_sum2'">
          Суммарная пылевая нагрузка
        </xsl:if>
        <xsl:if test="@bm!='plvn_sum' and @bm!='plvn_sum2'">
          Пылевая нагрузка, мг
        </xsl:if>
        <xsl:if test="not(@bm)">
          <xsl:value-of select="@name"/>
        </xsl:if>
      </td>
      <td>
        <xsl:if test="@bm='plvn_sum' or @bm='plvn_sum2'">
          <xsl:value-of select="@matters"/>
        </xsl:if>
        <xsl:if test="@bm!='plvn_sum' and @bm!='plvn_sum2'">
          <xsl:value-of select="@name"/>
        </xsl:if>
        <xsl:if test="not(@bm)">-</xsl:if>
      </td>
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:value-of select="@norm"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>