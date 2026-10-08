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
        <td width="10%">№ (код) РМ</td>
        <td width="25%">Наименование рабочего места, фактора</td>
        <td width="20%">Результат нескольких измерений</td>
        <td width="15%">ФАКТ</td>
        <td width="15%">Длительность измерений, мин</td>
        <td width="15%">U095</td>
      </tr>
        <xsl:apply-templates/>
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
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="param">
   <!-- Объединенная строка для описания сведений о РМ -->
    <xsl:if test="@descr">
      <tr class="param2">
        <td align="left" colspan="6">
          <xsl:value-of select="@name"/>;
          Дата измерения: <xsl:value-of select="@izm_date"/>;
          Краткое описание операции: <xsl:value-of select="@descr"/>
          <xsl:if test="@MicrophonePosition">
            ; Положение микрофона: <xsl:value-of select="@MicrophonePosition"/>
          </xsl:if>
          <xsl:if test="@MeasuringSystemConfiguration">
            ; Дополнительные сведения о месте измерения: <xsl:value-of select="@MeasuringSystemConfiguration"/>
          </xsl:if>
        </td>
      </tr>
    </xsl:if>
   <!-- Объединенная строка для описания сведений о поправках на АЧХ микрофона -->
    <xsl:if test="@delta_okt2">
      <tr class="param">
        <td align="center" colspan="6">
          Поправки  в октавных полосах частот со среднегеометрическими частотами 2, 4, 8 и 16 Гц: 2 Гц - <xsl:value-of select="@delta_okt2"/> дБ; 4 Гц - <xsl:value-of select="@delta_okt4"/> дБ;
          8 Гц - <xsl:value-of select="@delta_okt8"/> дБ; 16 Гц - <xsl:value-of select="@delta_okt16"/> дБ
        </td>
      </tr>
    </xsl:if>
   <!-- Объединенная строка 'Результаты расчета эквивалентного УЗД инфразвука за 8-часовой рабочий день'  bm_id="Lekv" -->
    <xsl:if test="@bm_id='gen_ekv'">
      <tr class="param">
        <td align="center" colspan="6">
          Результаты расчета эквивалентного УЗД инфразвука за 8-часовой рабочий день:
        </td>
      </tr>
    </xsl:if>

    <xsl:variable name="bm_id" select="@bm_id"/>

   <!-- Справочник наименований - доступен для редатирования пользователем -->
    <xsl:variable name="param_name">
      <xsl:choose>
        <xsl:when test="$bm_id='gen'">Общий УЗД, дБ</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$bm_id='okt2'">УЗД в полосе частот 2 Гц, дБ</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$bm_id='okt4'">УЗД в полосе частот 4 Гц, дБ</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$bm_id='okt8'">УЗД в полосе частот 8 Гц, дБ</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$bm_id='okt16'">УЗД в полосе частот 16 Гц, дБ</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$bm_id='gen_ekv'">Эквивалентный общий УЗД, дБ</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$bm_id='okt2_ekv'">Эквивалентный УЗД в полосе частот 2 Гц, дБ</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$bm_id='okt4_ekv'">Эквивалентный УЗД в полосе частот 4 Гц, дБ</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$bm_id='okt8_ekv'">Эквивалентный УЗД в полосе частот 8 Гц, дБ</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$bm_id='okt16_ekv'">Эквивалентный УЗД в полосе частот 16 Гц, дБ</xsl:when>
      </xsl:choose>
    </xsl:variable>


    <tr>
        <xsl:attribute name="class">
          <xsl:value-of select="@class"/>
        </xsl:attribute>
        <td></td>
        <td>
          <xsl:choose>
            <xsl:when test="@param">
              <xsl:value-of select="$param_name"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@name"/>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td><xsl:value-of select="@fact"/></td>
        <td>
          <xsl:value-of select="@fact_avg"/>
        </td>
        <td>
          <xsl:value-of select="@izm_level_times"/>
        </td>
        <td>
          <xsl:if test="@U8h">
            <xsl:value-of select="@U8h"/>
          </xsl:if>
        </td>
      </tr>
    <xsl:apply-templates/>
  </xsl:template>
  


</xsl:stylesheet>