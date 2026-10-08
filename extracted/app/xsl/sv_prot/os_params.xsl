<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  
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
      table.empty
      {
      margin-bottom:0cm;
      margin-top:0cm;
      }

      table.empty,table.empty th,table.empty td
      {
      font-size:12.0pt;
      text-align:left;
      border:none;
      background:none;
      padding:0 5px 0 5px;
      vertical-align: top;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <table width="100%" align="center">
      <tr>
        <td width="7%">№ РМ</td>
        <td width="20%" align="center">
          Наименование рабочего места
        </td>
        <td width="25%" align="center">
          Наименование рабочей зоны
        </td>
        <td width="12%">Температура<br/>воздуха, °C</td>
        <td width="12%">Относительная<br/>влажность, %</td>
        <td width="12%">Атмосферное<br/>давление, кПа</td>
        <td width="12%">Скорость<br/>воздуха, м/с</td>
      </tr>
      <xsl:apply-templates select="rm"/>
    </table>
  </xsl:template>

  <xsl:template match ="rm">
    <xsl:variable name="z_count" select="count(zones_info/zone)">
    </xsl:variable>
    <xsl:if test="$z_count>0">
      <tr>
        <td>
          <xsl:value-of select="@num"/>
        </td>
        <td>
          <xsl:value-of select="@name"/>
        </td>
        <xsl:apply-templates select="zones_info/zone" mode="row1"/>
      </tr>
      <xsl:apply-templates select="zones_info/zone" mode="row2"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="zone" mode="row1">
    <xsl:variable name="z_num" select="count(preceding-sibling::zone)+1">
    </xsl:variable>
    <xsl:if test="$z_num=1">
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@os_t"/>
      </td>
      <td>
        <xsl:value-of select="@os_v"/>
      </td>
      <td>
        <xsl:value-of select="@os_p"/>
      </td>
      <td>
        <xsl:value-of select="@os_sk"/>
        <xsl:if test="@os_sk=''">-</xsl:if>
      </td>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="zone" mode="row2">
    <xsl:variable name="z_num" select="count(preceding-sibling::zone)+1">
    </xsl:variable>
    <xsl:if test="$z_num>1">
      <tr>
        <td>-</td>
        <td>-</td>
        <td>
          <xsl:value-of select="@name"/>
        </td>
        <td>
          <xsl:value-of select="@os_t"/>
        </td>
        <td>
          <xsl:value-of select="@os_v"/>
        </td>
        <td>
          <xsl:value-of select="@os_p"/>
        </td>
        <td>
          <xsl:value-of select="@os_sk"/>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>
  
  
</xsl:stylesheet>