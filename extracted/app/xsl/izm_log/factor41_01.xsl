<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Журнал регистрации измерений</title>
    <style>
      /* Style Definitions */
      table
      {
      font-size:9.0pt;
      font-family:arial, verdana, sans-serif;
      text-align:center;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
      td.bold {
      font-weight: bold;
      font-size:9.0pt;
      }
      tr.factor {
      font-weight: bold;
      }
      td.group {
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
    <xsl:if test="not(@all_facs)">
      <h1>Журнал регистрации измерений</h1>
    </xsl:if>
    <xsl:if test="@all_facs">
      <h1>Лазерное излучение</h1>
    </xsl:if>
    <table>
      <tr>
        <td width="4%">№ п/п</td>
        <td width="15%">Наименование организации</td>
        <td width="4%">№ РМ</td>
        <td width="36%">Наименование рабочего места, рабочей зоны, фактора</td>
        <td width="8%">Дата проведения измерения</td>
        <td width="10%">ФАКТ</td>
        <td width="9%">Подпись работника, проводившего измерения</td>
        <td width="14%">Ф.И.О., должность присутствовавшего представителя заказчика</td>
      </tr>
      <tr>
        <td>1</td>
        <td>2</td>
        <td>3</td>
        <td>4</td>
        <td>5</td>
        <td>6</td>
        <td>7</td>
        <td>8</td>
      </tr>
        <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="row">
    <tr>
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      <td>
        <xsl:value-of select="@cell1"/>
      </td>
      <xsl:if test="@class='rm'">
        <td>
          <xsl:attribute name="rowspan">
            <xsl:value-of select="@rowspan_rm"/>
          </xsl:attribute>
          <xsl:value-of select="@cell2"/>
        </td>
      </xsl:if>
      <td>
        <xsl:attribute name="class"><xsl:value-of select="@cell3_class"/></xsl:attribute>
        <xsl:value-of select="@cell3"/>
      </td>
      <td>
        <xsl:attribute name="class"><xsl:value-of select="@cell4_class"/></xsl:attribute>
        <xsl:value-of select="@cell4"/>
      </td>
      <td>
        <xsl:attribute name="class"><xsl:value-of select="@cell5_class"/></xsl:attribute>
        <xsl:value-of select="@cell5"/>
      </td>
      <td>
        <xsl:value-of select="@cell6"/>
      </td>
      <td>
        <xsl:value-of select="@cell8"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="row_fact">
    <tr>
      <td></td>
      <td></td>
      <td align="left" colspan="2"><xsl:value-of select="@name"/></td>
      <td><xsl:value-of select="@fact"/></td>
      <td></td>
      <td></td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="row_laser_info">
    <tr>
      <td></td>
      <td></td>
      <td align="left" colspan="3">
        <b>Сведения о лазерной установке:</b>
        <br/>
        <xsl:value-of select="@opt_lazer_info"/>;
        Длина волны, нм - <xsl:value-of select="@opt_lambda"/>;
        Мощность, Вт - <xsl:value-of select="@opt_power"/>;
        Диаметр выходного луча, мм - <xsl:value-of select="@opt_diametr"/> Вт;
        Класс опасности - <xsl:value-of select="@opt_danger"/>
        <br/>
        <b>Место измерения: </b>
        <span class="no_bold">
          <xsl:value-of select="@LazerMeasuringPlace"/>;
        </span>
        <xsl:if test="@li_type">
          <b>Тип облучения: </b>
          <span class="no_bold">
            <xsl:value-of select="@li_type"/>
          </span>
        </xsl:if>
      </td>
      <td></td>
      <td></td>
    </tr>
  </xsl:template>

  <xsl:template match ="row_laser_modes">
    <tr>
      <td></td>
      <td></td>
      <td align="left" colspan="3">
        <b>Режим работы лазерной установки:</b>
        <xsl:apply-templates select="node"/>
      </td>
      <td></td>
      <td></td>
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

  <xsl:template match ="row_laser_mode2000">
    <tr>
      <td></td>
      <td></td>
      <td align="left" colspan="3">
        Вид излучения: <xsl:value-of select="@regim_name"/>; τ<sub>и</sub> = <xsl:value-of select="@Timp"/> мкс; F<sub>N</sub> = <xsl:value-of select="@Fimp"/> Гц;
            t<sub>СИ,НП</sub> = <xsl:value-of select="@Tsi"/> с; t<sub>В</sub> = <xsl:value-of select="@Tsum"/> с.
      </td>
      <td></td>
      <td></td>
    </tr>
  </xsl:template>


</xsl:stylesheet>
