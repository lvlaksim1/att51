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
      font-size:9.0pt;
      }
      span.test {
      font-size:6.0pt;
      }
      p.prim {
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
        <td width="4%">№ (код) РМ</td>
        <td width="14%">Наименование рабочего места, рабочей зоны, фактора</td>
        <td width="7%">Дата оценки (измерения)</td>
        <td width="8%">Характер шума</td>
        <td width="8%">Уровень звука, дБА</td>
        <td width="8%">Длительность измерений, мин</td>
        <td width="10%">Эквивалентный уровень звука за интервал, дБА</td>
        <td width="5%">Кm, дБ</td>
        <td width="10%">
          <p>
            u(L <sub>EX,8h</sub> )*, дБА
          </p>
        </td>
        <td width="6%">ПДУ, дБА</td>
        <td width="6%">КУТ</td>
        <td width="6%">ОТКЛ</td>
        <td width="8%">Время воздействия, мин</td>
      </tr>
        <xsl:apply-templates/>
    </table>
    <p class="prim">
      Условные обозначения: Кm, дБ - поправка на характер шума; КУТ - класс условий труда; ОТКЛ - отклонение.
    </p>
    <p>
      <xsl:text>&#160;</xsl:text>
    </p>
    
  </xsl:template>

  <xsl:template match ="podr">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <td colspan="13">
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
      <td></td>
      <td></td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
      <td></td>
    </tr>
    <tr class="src">
      <td colspan="13">
        Источник вредного фактора: <xsl:value-of select="@src"/>
        <br/>
        <xsl:value-of select="@strategy"/>
        <xsl:if test="@shum_izm_info">
          <br/>Дополнительные сведения о рабочей обстановке и условиях измерения: <xsl:value-of select="@shum_izm_info"/>
        </xsl:if>
        <xsl:if test="@MeteorologicalConditions">
          <br/>Информация об особенностях метеорологических условий: <xsl:value-of select="@MeteorologicalConditions"/>
        </xsl:if>
        <xsl:if test="@MicrophonePosition">
          <br/>Расположение микрофона: <xsl:value-of select="@MicrophonePosition"/>
        </xsl:if>
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
      <td></td>
      <td>
        <xsl:value-of select="@shum_char"/>
      </td>
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:value-of select="@izm_level_times"/>
      </td>
      <td>
        <xsl:value-of select="@fact2"/>
      </td>
      <td>
        <xsl:value-of select="@Km"/>
      </td>
      <td>
        <xsl:if test="@bm='izm'">
          <xsl:value-of select="@unc"/>
        </xsl:if>
        <xsl:if test="@bm='Lekv'">
          <xsl:value-of select="@U8h"/>
        </xsl:if>
      </td>
      <td>
        <xsl:value-of select="@norm"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
      <td>
        <xsl:value-of select="@otkl"/>
      </td>
      <td>
        <xsl:value-of select="@time_min"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>