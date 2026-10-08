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
      font-size:9.0pt;
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
      td.header {
      font-size:8.0pt;
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
        <td width="20%">Наименование рабочего места, рабочей зоны, фактора</td>
        <td width="8%">Дата оценки (измерения)</td>
        <td width="8%">Диапазон ЭМП</td>
        <td width="10%">Результаты измерений</td>
        <td width="8%">Факт. уровень</td>
        <td width="5%">U095</td>
        <td class="header" width="10%">
          Энергетическая экспозиция/ напряженность
          <br/><b>расчетная*</b>
        </td>
        <td class="header" width="10%">
          Энергетическая экспозиция/ напряженность<br/><b>ПДУ*</b>
        </td>
        <td width="8%">Класс условий труда</td>
        <td width="8%">Время воздействия, мин</td>
      </tr>
        <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="podr">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <td colspan="11">
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
      <td colspan="6"></td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
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
      <td colspan="10">
        <xsl:value-of select="@name"/>
      </td>
      <td>
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
      <td align="center" colspan="2">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@diapazon"/>
      </td>
      <td>
        <xsl:value-of select="@results"/>
      </td>
      <td>
        <xsl:value-of select="@fact2"/>
      </td>
      <td>
        <xsl:value-of select="@U095"/>
      </td>
      <td>
        <xsl:value-of select="@expose"/>
      </td>
      <td>
        <xsl:value-of select="@norm"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
      <xsl:choose>
        <xsl:when test="@p_time">
          <td>
            <xsl:value-of select="@p_time"/>
          </td>
        </xsl:when>
        <xsl:when test="../@time=''">
          <td>
            <xsl:value-of select="@time"/>
          </td>
        </xsl:when>
        <xsl:otherwise>
          <td></td>
        </xsl:otherwise>
      </xsl:choose>
      
    </tr>
  </xsl:template>

</xsl:stylesheet>