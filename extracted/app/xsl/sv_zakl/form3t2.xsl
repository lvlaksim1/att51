<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сводное заключение по результатам идентификации</title>
    <style>
      /* Style Definitions */
      table
      {
      font-size:9.0pt;
      font-family:Times new roman, arial, verdana, sans-serif;
      text-align:center;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
      th {
      background-color: #EAEAEA;
      }
      td.bold {
      font-weight: bold;
      font-size:9.0pt;
      }
      tr.factor {
      font-weight: bold;
      }
      tr.param p {
      text-align:left;
      }
      tr.zone {
      font-style:italic;
      }
      td.sign {
      height:30pt;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <table width="100%">
      <tr>
        <th width="6%">№ РМ</th>
        <th width="28%">Наименование РМ (по штатному расписанию)</th>
        <th width="10%">Наличие аналогичного РМ</th>
        <th width="10%">Присутствие работника на РМ в процессе идентификации</th>
        <th width="10%">Наличие/отсутствие предложений от работника</th>
        <th width="20%">Наименование идентифицированного вредного и (или) опасного производственного фактора</th>
        <th width="20%">Источник фактора</th>
        <th width="12%">Продолжительность воздействия в течение рабочего дня (смены), час.</th>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>
  
  <xsl:template match ="podr">
    <tr>
      <td colspan="8">
        <xsl:value-of select="@name"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="rm">
    <xsl:variable name="RowSpan" select="count(data/fac|data/fac0)"/>
    <tr>
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      <td>
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="@rm_num"/>
      </td>
      <td>
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="@rm_name"/>
      </td>
      <td>
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="@anal_rms"/>
      </td>
      <td>
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="@is_rab"/>
      </td>
      <td>
        <xsl:attribute name="rowspan">
          <xsl:value-of select ="$RowSpan"/>
        </xsl:attribute>
        <xsl:value-of select="@rab_descr"/>
      </td>
      <xsl:apply-templates select="data"/>
    </tr>
    <xsl:apply-templates select="data/fac"/>
  </xsl:template>

  <xsl:template match ="data">
    <td>
      <xsl:value-of select="fac0/@name"/>
    </td>
    <td>
      <xsl:value-of select="fac0"/>
    </td>
    <td>
      <xsl:value-of select="fac0/@time"/>
    </td>
  </xsl:template>

  <xsl:template match ="data/fac">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="."/>
      </td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>