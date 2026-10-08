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
      text-align:left;
      }
      td.zone {
      text-align:center;
      }
      tr.param {
      font-size:9.0pt;
      td.no_bold {
      font-weight: bold;
      }
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
        <td width="34%">Наименование рабочего места, место измерения (фактор)</td>
        <td width="10%">Дата оценки (измерения)</td>
        <td width="20%">Энергетическая экспозиция, Дж/м2</td>
        <td width="20%">Энергия лазерного излучения, Дж</td>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="podr">
    <tr>
        <xsl:attribute name="class">
          <xsl:value-of select="@class"/>
        </xsl:attribute>
        <td colspan="5">
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
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="lazer_info">
    <tr>
      <!-- СТРОКИ!!! -->
      <td align="left" colspan="5">
        <b>Сведения о лазерной установке:</b>
        <br/>
        <xsl:value-of select="@opt_lazer_info"/>;
        Длина волны, нм - <xsl:value-of select="@opt_lambda"/>;
        Мощность, Вт - <xsl:value-of select="@opt_power"/>;
        Диаметр выходного луча, мм - <xsl:value-of select="@opt_diametr"/> Вт;
        Класс опасности - <xsl:value-of select="@opt_danger"/>
      </td>
    </tr>
    <tr>
      <!-- СТРОКИ!!! -->
      <td align="left" colspan="5">
        <b>Место измерения: </b>
        <span class="no_bold">
          <xsl:value-of select="@LazerMeasuringPlace"/>;
        </span>
        <b>Тип облучения: </b>
        <span class="no_bold">
          <xsl:value-of select="@li_type"/>
        </span>

      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="modes_nodes">
    <tr>
      <td align="left" colspan="5">
        <b>Режим работы лазерной установки:</b>
        <xsl:apply-templates/>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match ="node">
    <br/>
    <xsl:number value="position()" format="1. "/>
    <xsl:if test="@gen_mode=1">
      Непрерывное излучение с общей длительностью воздействия <xsl:value-of select="@Tsum"/> секунд.
    </xsl:if>
    <xsl:if test="@gen_mode=0">
      Импульсное излучение с общей длительностью воздействия <xsl:value-of select="@Tsum"/> секунд (Тимп=<xsl:value-of select="@Timp"/> с, Fимп=<xsl:value-of select="@Fimp"/> Гц).
    </xsl:if>
  </xsl:template>

  <xsl:template match ="result_eyes">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <td colspan="3">Облучение глаз</td>
      <td>
        <xsl:value-of select="@fact1"/>
      </td>
      <td>
        <xsl:value-of select="@fact2"/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="result_skin">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <td colspan="3">Облучение кожи</td>
      <td>
        <xsl:value-of select="@fact1"/>
      </td>
      <td>
        <xsl:value-of select="@fact2"/>
      </td>
    </tr>
  </xsl:template>
  
  
</xsl:stylesheet>