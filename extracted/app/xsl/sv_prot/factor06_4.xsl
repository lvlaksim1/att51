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
        <td width="20%">Наименование рабочего места, рабочей зоны, фактора</td>
        <td width="12%">Дата оценки (измерения)</td>
        <td width="10%">Факт. уровень</td>
        <td width="7%">f, кГц</td>
        <td width="9%">Длительность измерения, мин</td>
        <td width="9%">U095</td>
        <td width="9%">ПДУ</td>
        <td width="9%">Класс условий труда</td>
        <td width="9%">Время воздействия, мин</td>
      </tr>
        <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="podr">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <td colspan="10">
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
      <td>
        <xsl:value-of select="@kut"/>
      </td>
      <td></td>
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
          <xsl:value-of select="@izm_level_times"/>
        </td>
        <td>
          <xsl:if test="@unc">
            <xsl:value-of select="@unc"/>
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
      <xsl:if test="@descr">
        <tr class="param2">
          <td align="left" colspan="9">
            Краткое описание источников ультразвука: <xsl:value-of select="@descr"/>
            <xsl:if test="@MicrophonePosition">
              <br/>
              Положение микрофона: <xsl:value-of select="@MicrophonePosition"/>
            </xsl:if>
          </td>
        </tr>
      </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  


</xsl:stylesheet>