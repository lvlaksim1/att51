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
        <td width="6%">№ (код) РМ</td>
        <td width="25%">Наименование рабочего места, рабочей зоны, показателя</td>
        <td width="25%">Наименование вредного вещества</td>
        <td width="9%">Рабочая зона</td>
        <td width="9%">ФАКТ</td>
        <td width="9%">U095</td>
        <td width="8%">ПДК</td>
        <td width="9%">Класс условий труда</td>
      </tr>
        <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="podr">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <td colspan="8">
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
        <xsl:value-of select="@name"/>
      </td>
      <td>-</td>
      <td>-</td>
      <td>-</td>
      <td>-</td>
      <td>-</td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="zone">
    <xsl:if test="@bm='ss_razd'">
      <xsl:apply-templates select="param" mode="ss"/>
    </xsl:if>
    <xsl:if test="(@bm!='ss_razd') and (@bm!='max_razd')">
      <xsl:apply-templates select="param" mode="sum"/>
    </xsl:if>
    
  </xsl:template>

  <xsl:template match ="param" mode="sum">
    <xsl:if test="contains(@bm,'kosumm')">
      <tr>
        <xsl:attribute name="class">
          <xsl:value-of select="@class"/>
        </xsl:attribute>
        <!-- СТРОКИ!!! -->
        <td>-</td>
        <td>
          Комбинация веществ
        </td>
        <td>
          <xsl:value-of select="@matters"/>
        </td>
        <td>
          <xsl:value-of select="../@name"/>
        </td>
        <td>
          <xsl:value-of select="@fact"/>
        </td>
        <td>-</td>
        <td>
          <xsl:value-of select="@norm"/>
        </td>
        <td>
          <xsl:value-of select="@kut"/>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>  
  
  <xsl:template match ="param" mode="ss">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <td>-</td>
      <td>
        <xsl:if test="contains(@bm,'ef_ss')">
          Комбинация веществ по среднесменным концентрациям
        </xsl:if>
        <xsl:if test="not (contains(@bm,'ef_ss'))">
          Среднесменная концентрация, мг/м³
        </xsl:if>
      </td>
      <td>
        <xsl:if test="contains(@bm,'ef_ss')">
          <xsl:value-of select="@matters"/>
          <xsl:if test="not(@matters)">-</xsl:if>
        </xsl:if>
        <xsl:if test="not (contains(@bm,'ef_ss'))">
          <xsl:value-of select="@name"/>
        </xsl:if>
      </td>
      <td>-</td>
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:value-of select="@U095"/>
        <xsl:if test="not(@U095)">-</xsl:if>
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