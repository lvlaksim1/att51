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
      tr.param2 {
      font-style:italic;
      }
      tr.param {
      font-size:10.0pt;
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
        <td width="5%" rowspan="2">№ (код) РМ</td>
        <td width="25%" rowspan="2">Наименование рабочего места, рабочей зоны</td>
        <td width="10%" rowspan="2">Дата измерения</td>
        <td width="50%" colspan="10">Уровень звукового давления воздушного ультразвука в третьоктавных полосах частот, дБ</td>
        <td width="9%" rowspan="2">Длительность измерения, мин</td>
        <td width="5%" rowspan="2">U095</td>
        <td width="7%" rowspan="2">КУТ</td>
        <td width="8%" rowspan="2">Время, мин</td>
      </tr>
      <tr>
        <td width="5%">12.5</td>
        <td width="5%">16.0</td>
        <td width="5%">20.0</td>
        <td width="5%">25.0</td>
        <td width="5%">31.5</td>
        <td width="5%">40.0</td>
        <td width="5%">50.0</td>
        <td width="5%">63.0</td>
        <td width="5%">80.0</td>
        <td width="5%">100.0</td>
      </tr>
        <xsl:apply-templates/>
    </table>
  </xsl:template>
  									
  <xsl:template match ="podr">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <td colspan="17">
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
      <td>-</td>
      <td>-</td>
      <td>-</td>
      <td>-</td>
      <td>-</td>
      <td>-</td>
      <td>-</td>
      <td>-</td>
      <td>-</td>
      <td>-</td>
      <td>-</td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
      <td>480</td>
    </tr>
    <xsl:apply-templates select="okt_data"/>
  </xsl:template>

  <xsl:template match ="okt_data">
    <xsl:apply-templates select="VibrItem"/>
  </xsl:template>
  
  <xsl:template match ="VibrItem">
      <!-- СТРОКИ!!! -->
      <tr>
        <xsl:attribute name="class">
          <xsl:value-of select="@class"/>
        </xsl:attribute>
        <td></td>
        <td>
          <xsl:value-of select="@name"/>
        </td>
        <td><xsl:value-of select="@izm_date"/></td>
        <td>
          <xsl:value-of select="@value12_5"/>
        </td>
        <td>
          <xsl:value-of select="@value16"/>
        </td>
        <td>
          <xsl:value-of select="@value20"/>
        </td>
        <td>
          <xsl:value-of select="@value25"/>
        </td>
        <td>
          <xsl:value-of select="@value31_5"/>
        </td>
        <td>
          <xsl:value-of select="@value40"/>
        </td>
        <td>
          <xsl:value-of select="@value50"/>
        </td>
        <td>
          <xsl:value-of select="@value63"/>
        </td>
        <td>
          <xsl:value-of select="@value80"/>
        </td>
        <td>
          <xsl:value-of select="@value100"/>
        </td>
        <td>
          <xsl:value-of select="@izm_level_times"/>
        </td>
        <td>
          <xsl:value-of select="@U095"/>
        </td>
        <td>-</td>
        <td>
          <xsl:value-of select="@time_min"/>
        </td>
      </tr>
    <xsl:apply-templates/>
  </xsl:template>
  


</xsl:stylesheet>