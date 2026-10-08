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
        <td width="7%">№ (код) РМ</td>
        <td width="20%">Наименование рабочего места, рабочей зоны, фактора</td>
        <td width="13%">Дата оценки (измерения)</td>
        <td width="10%">Факт. уровень</td>
        <td width="10%">Длительность измерения, мин</td>
        <td width="10%">U095</td>
        <td width="10%">ПДУ</td>
        <td width="10%">Класс условий труда</td>
        <td width="10%">Время воздействия, мин</td>
      </tr>
        <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="podr">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <td colspan="9">
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
      <td>
        <xsl:value-of select="@kut"/>
      </td>
      <td></td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="zone">
      <!-- СТРОКИ!!! -->
      <xsl:if test="@class='zone'">
        <tr class="zone">
          <td></td>
          <td>
          <xsl:value-of select="@name"/>
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
          <xsl:value-of select="@time_min"/>
          </td>
        </tr>
        <xsl:if test="@descr">
          <tr class="zone">
            <td align="left" colspan="9">
                Краткое описание операции: <xsl:value-of select="@descr"/>
              <xsl:if test="@descr1">
                <br/>Место установки и ориентация акселерометров: <xsl:value-of select="@descr1"/>
              </xsl:if>
              <xsl:if test="@descr2">
                <br/>Дополнительные сведения о месте измерения: <xsl:value-of select="@descr2"/>
              </xsl:if>
            </td>
          </tr>
        </xsl:if>
      </xsl:if>
      <xsl:if test="@class='param'">
        <tr class="param">
          <td></td>
          <td>
            <xsl:value-of select="@name"/>
          </td>
          <td></td>
          <td>
            <xsl:value-of select="@fact"/>
          </td>
          <td>
            <xsl:value-of select="@izm_level_times"/>
          </td>
          <td>
            <xsl:value-of select="@unc"/>
          </td>
          <td>
            <xsl:value-of select="@norm"/>
          </td>
          <td>
            <xsl:value-of select="@kut"/>
          </td>
          <td></td>
        </tr>
      </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- Данный блок используется для вывода эквивалентного значения-->
  <xsl:template match ="param">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <xsl:if test="@class='zone'">
        <td colspan="9">
          <xsl:value-of select="@name"/>
        </td>
      </xsl:if>
      <xsl:if test="@class='param'">
        <td></td>
        <td>
          <xsl:value-of select="@name"/>
        </td>
        <td></td>
        <td>
          <xsl:value-of select="@fact"/>
        </td>
        <td></td>
        <td>
          <xsl:value-of select="@unc"/>
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
      </xsl:if>
    </tr>
  </xsl:template>

</xsl:stylesheet>