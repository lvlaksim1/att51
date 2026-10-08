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
    <table>
      <tr>
        <td width="10%">№ (код) РМ</td>
        <td width="50%">Наименование рабочего места, рабочей зоны, фактора</td>
        <td width="10%">Дата оценки</td>
        <td width="10%">Факт. уровень</td>
        <td width="10%">ПДУ</td>
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
      <td colspan="7">
        <xsl:value-of select="@name"/>
        <xsl:if test="@adr!=''">
          (<xsl:value-of select="@adr"/>)
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="rm">
    <xsl:variable name="co_doza" select="zone/param[contains(@bm, 'doza')]/@bm"/>
    <xsl:if test="($co_doza!='')">
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
    </tr>
    <xsl:apply-templates select="zone"/>
     
    </xsl:if>
  </xsl:template>

  <xsl:template match ="zone">
    <xsl:variable name="co_doza" select="param[contains(@bm, 'doza')]/@bm"/>
    <xsl:if test="($co_doza!='')">
      <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <td colspan="6">
        <xsl:value-of select="@name"/>
      </td>
    </tr>
    <xsl:apply-templates select="param"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="param">
    <xsl:if test="(contains(@bm, 'doza'))">
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
      <xsl:value-of select="@norm"/>
      </td>
      <td>
      <xsl:value-of select="@kut"/>
      </td>
      </tr>
    </xsl:if>
    
  </xsl:template>

</xsl:stylesheet>