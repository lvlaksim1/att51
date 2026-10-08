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
        <td width="6%">№ (код) РМ</td>
        <td width="30%">Наименование должности, профессии или специальности работника, структурного подразделения, сведения о составляющих интервалах, контрольные точки рабочей зоны, определяемая характеристика (показатель)</td>
        <td width="15%">Дата измерения</td>
        <td width="15%">Результат измерений, дБ</td>
        <td width="10%">Среднегеометрическая частота, кГц</td>
        <td width="12%">Расширенная неопределенность измерений (U), (к=2, Р=95%), дБ</td>
        <td width="12%">Время воздействия, мин</td>
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
    </tr>
    <tr class="src">
      <td></td>
      <td colspan="5">
        Источник вредного фактора: <xsl:value-of select="@src"/>
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="param">
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
          <xsl:value-of select="@fact"/>
        </td>
        <td>
          <xsl:value-of select="@f_khz"/>
        </td>
        <td>
          <xsl:if test="@unc">
            <xsl:value-of select="@unc"/>
          </xsl:if>
        </td>
        <td>
          <xsl:value-of select="@time_min"/>
        </td>
      </tr>
    <xsl:apply-templates/>
  </xsl:template>
  


</xsl:stylesheet>