<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- переменная -->
  <xsl:variable name="ExposureType" select="Document/izm_data2/@ExposureType"/>
  
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
        <td width="30%">Наименование рабочего места, место измерения (фактор)</td>
        <td width="10%">ФАКТ</td>
        <td width="10%">U095</td>
        <td width="10%">ПДУ1</td>
        <td width="10%">ПДУ2</td>
        <td width="10%">ОТКЛ</td>
        <td width="14%">Класс условий труда</td>
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

  <xsl:template match ="podr">
    <tr>
        <xsl:attribute name="class">
          <xsl:value-of select="@class"/>
        </xsl:attribute>
        <td colspan="8">
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
      <td></td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="zone">
    <tr>
      <!-- СТРОКИ!!! -->
      <td align="left" colspan="8">
        <b><xsl:value-of select="@number"/>  интервал измерения</b>: <xsl:value-of select="@name"/>;
        Дата измерения: <xsl:value-of select="@izm_date"/>; Время пребывания: <xsl:value-of select="@time"/> мин
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="lu_info">
    <tr>
      <!-- СТРОКИ!!! -->
      <td align="left" colspan="8">
        <i>Сведения о лазерной установке:</i>
        <br/>
        <xsl:value-of select="@lu_name"/>;
        Длина волны, нм - <xsl:value-of select="@lu_wave"/>;
        Мощность, Вт - <xsl:value-of select="@lu_power"/>;
        Диаметр выходного луча, мм - <xsl:value-of select="@lu_d_mm"/> Вт;
        Класс опасности - <xsl:value-of select="@lu_class"/>;
        Доп.сведения - <xsl:value-of select="@lu_descr"/>.
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match ="regim_info">
    <tr>
      <!-- СТРОКИ!!! -->
      <td align="left" colspan="8">
        <i>Режим работы лазерной установки:</i>
        <br/>
        <xsl:if test="@ind=4">
          Непрерывное излучение с общей длительностью воздействия <xsl:value-of select="@Tsum"/> сек.
        </xsl:if>
        <xsl:if test="@ind!=4">
          <xsl:value-of select="@regim_name"/> (Тимп=<xsl:value-of select="@Timp"/> сек, Fимп=<xsl:value-of select="@Fimp"/> Гц, Твозд.=<xsl:value-of select="@Tsum"/> сек).
        </xsl:if>
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match ="res_A1">
    <tr>
      <td></td>
      <td colspan="2">
        <i>Облучение кожи (точка А1)</i>
      </td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td>
        <xsl:value-of select="@param_name"/>
      </td>
      <td>
        <xsl:value-of select="@fact_max"/>
      </td>
      <td>
        <xsl:value-of select="@fact_unc"/>
      </td>
      <td>
        <xsl:value-of select="@pdu1"/>
      </td>
      <td>
        <xsl:value-of select="@pdu2"/>
      </td>
      <td>
        <xsl:value-of select="@otkl"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="res_A2">
    <tr>
      <td></td>
      <td colspan="2">
        <i>Облучение глаз (точка А2)</i>
      </td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td>
        <xsl:value-of select="@param_name"/>
      </td>
      <td>
        <xsl:value-of select="@fact_max"/>
      </td>
      <td>
        <xsl:value-of select="@fact_unc"/>
      </td>
      <td>
        <xsl:value-of select="@pdu1"/>
      </td>
      <td>
        <xsl:value-of select="@pdu2"/>
      </td>
      <td>
        <xsl:value-of select="@otkl"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>


</xsl:stylesheet>