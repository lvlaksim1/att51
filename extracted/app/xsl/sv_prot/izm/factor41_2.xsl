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
        <td width="5%">№ РМ</td>
        <td width="30%">Наименование рабочего места (место проведения исследований (испытаний) и измерений</td>
        <td width="30%">Определяемая характеристика (показатель), единицы измерения</td>
        <td width="20%">Результат измерений</td>
        <td width="15%">ПДУ</td>
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
    <xsl:variable name="LazerMeasuringPlace">
      <xsl:value-of select="lazer_info/@LazerMeasuringPlace"/>
    </xsl:variable>
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
    </tr>
    <!-- Облучение глаз-->
    <xsl:apply-templates select="result_eyes">
      <xsl:with-param name="LazerMeasuringPlace">
        <xsl:value-of select="$LazerMeasuringPlace"/>
      </xsl:with-param>
    </xsl:apply-templates>
    <!-- Облучение кожи-->
    <xsl:apply-templates select="result_skin">
      <xsl:with-param name="LazerMeasuringPlace">
        <xsl:value-of select="$LazerMeasuringPlace"/>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match ="result_eyes">
    <xsl:param name = "LazerMeasuringPlace" />
    <!-- строка 1 -->
    <tr>
      <td></td>
      <td>
        <xsl:value-of select="$LazerMeasuringPlace"/>
        <br/>
        Облучение глаз
      </td>
      <td>Энергетическая экспозиция, Дж/м2</td>
      <td>
        <xsl:value-of select="@fact1"/>
      </td>
      <td>
        <xsl:value-of select="@pdu1"/>
      </td>
    </tr>
    <!-- строка 2 -->
    <tr>
      <td></td>
      <td>
        <xsl:value-of select="$LazerMeasuringPlace"/>
        <br/>
        Облучение глаз
      </td>
      <td>Энергия лазерного излучения, Дж</td>
      <td>
        <xsl:value-of select="@fact2"/>
      </td>
      <td>
        <xsl:value-of select="@pdu2"/>
      </td>
    </tr>
  </xsl:template>


  <xsl:template match ="result_skin">
    <xsl:param name = "LazerMeasuringPlace" />
    <!-- строка 1 -->
    <tr>
      <td></td>
      <td>
        <xsl:value-of select="$LazerMeasuringPlace"/>
        <br/>
        Облучение кожи
      </td>
      <td>Энергетическая экспозиция, Дж/м2</td>
      <td>
        <xsl:value-of select="@fact1"/>
      </td>
      <td>
        <xsl:value-of select="@pdu1"/>
      </td>
    </tr>
    <!-- строка 2 -->
    <tr>
      <td></td>
      <td>
        <xsl:value-of select="$LazerMeasuringPlace"/>
        <br/>
        Облучение кожи
      </td>
      <td>Энергия лазерного излучения, Дж</td>
      <td>
        <xsl:value-of select="@fact2"/>
      </td>
      <td>
        <xsl:value-of select="@pdu2"/>
      </td>
    </tr>
  </xsl:template>


  <!-- Дтеальные сведения-->
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

</xsl:stylesheet>