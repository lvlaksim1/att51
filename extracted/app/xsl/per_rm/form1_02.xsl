<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем номер приказа -->
  <xsl:variable name="prikaz_sout">
    <xsl:value-of select="Document/@prikaz_sout" />
  </xsl:variable>

  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Перечень рабочих мест</title>
    <style>
      /* Style Definitions */
      table
      {
      font-size:8.0pt;
      font-family:Times New Roman, arial, verdana, sans-serif;
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
      tr.param p {
      text-align:left;
      }
      tr.zone {
      font-style:italic;
      }
      td.sign {
      height:30pt;
      }
      td.rotate {
      mso-rotate:90;
      font-size:7.0pt;
      height:80pt;
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
        <td rowspan="3">Индивидуальный номер рабочего места</td>
        <td rowspan="3">Наименование рабочего места и источников вредных и (или) опасных факторов производственной среды и трудового процесса</td>
        <td rowspan="3">Численность работников, занятых на данном рабочем месте (чел.)</td>
        <td rowspan="3">Наличие аналогичного рабочего места (рабочих мест)</td>
        <td colspan="17">
          <xsl:value-of select="@cell_header"/>
        </td>
      </tr>
      <tr>
        <td rowspan="2" class="rotate">Химический фактор</td>
        <td rowspan="2" class="rotate">Биологический фактор</td>
        <td colspan="15">Физические факторы</td>
      </tr>
      <tr>
        <td class="rotate">Аэрозоли преимущественно фиброгенного действия</td>
        <td class="rotate">Шум</td>
        <td class="rotate">Инфразвук</td>
        <td class="rotate">Ультразвук воздушный</td>
        <td class="rotate">Вибрация общая</td>
        <td class="rotate">Вибрация локальная</td>
        <td class="rotate">
          <xsl:if test="$prikaz_sout='817'">
            Электромагнитные поля фактора "Неионизирующие поля и излучения"
          </xsl:if>
          <xsl:if test="$prikaz_sout!='817'">
            Электромагнитные поля фактора неионизирующие поля и излучения
          </xsl:if>
        </td>
        <td class="rotate">
          <xsl:if test="$prikaz_sout='817'">
            Ультрафиолетовое излучение фактора "Неионизирующие поля и излучения"
          </xsl:if>
          <xsl:if test="$prikaz_sout!='817'">
            Ультрафиолетовое излучение фактора неионизирующие поля и излучения
          </xsl:if>
        </td>
        <td class="rotate">
          <xsl:if test="$prikaz_sout='817'">
            Лазерное излучение фактора "Неионизирующие поля и излучения"
          </xsl:if>
          <xsl:if test="$prikaz_sout!='817'">
            Лазерное излучение фактора неионизирующие поля и излучения
          </xsl:if>
        </td>
        <td class="rotate">Ионизирующие излучения</td>
        <td class="rotate">Микроклимат</td>
        <td class="rotate">Световая среда</td>
        <td class="rotate">Тяжесть трудового процесса</td>
        <td class="rotate">Напряженность трудового процесса</td>
        <td class="rotate">Травмоопасность</td>
      </tr>
      <tr>
        <td width="7%">1</td>
        <td width="16%">2</td>
        <td width="7%">3</td>
        <td width="7%">4</td>
        <td width="3%">5</td>
        <td width="3%">6</td>
        <td width="5%">7</td>
        <td width="3%">8</td>
        <td width="3%">9</td>
        <td width="3%">10</td>
        <td width="3%">11</td>
        <td width="3%">12</td>
        <td width="5%">13</td>
        <td width="5%">14</td>
        <td width="5%">15</td>
        <td width="4%">16</td>
        <td width="3%">17</td>
        <td width="3%">18</td>
        <td width="4%">19</td>
        <td width="5%">20</td>
        <td width="3%">21</td>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="podr">
    <tr>
      <td colspan="21">
        <xsl:value-of select="@name"/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="rm">
    <tr>
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      <td>
        <xsl:value-of select="@rm_num"/>
      </td>
      <td>
        <xsl:value-of select="@rm_name"/>
      </td>
      <td>
        <xsl:value-of select="@colrab"/>
      </td>
      <td>
        <xsl:value-of select="@anal_rms"/>
      </td>
      <td>
        <xsl:value-of select="@col5"/>
      </td>
      <td>
        <xsl:value-of select="@col6"/>
      </td>
      <td>
        <xsl:value-of select="@col7"/>
      </td>
      <td>
        <xsl:value-of select="@col8"/>
      </td>
      <td>
        <xsl:value-of select="@col9"/>
      </td>
      <td>
        <xsl:value-of select="@col10"/>
      </td>
      <td>
        <xsl:value-of select="@col11"/>
      </td>
      <td>
        <xsl:value-of select="@col12"/>
      </td>
      <td>
        <xsl:value-of select="@col13"/>
      </td>
      <td>
        <xsl:value-of select="@col14"/>
      </td>
      <td>
        <xsl:value-of select="@col15"/>
      </td>
      <td>
        <xsl:value-of select="@col16"/>
      </td>
      <td>
        <xsl:value-of select="@col17"/>
      </td>
      <td>
        <xsl:value-of select="@col18"/>
      </td>
      <td>
        <xsl:value-of select="@col19"/>
      </td>
      <td>
        <xsl:value-of select="@col20"/>
      </td>
      <td>
        <xsl:value-of select="@col21"/>
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="zone">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <td></td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td></td>
      <td></td>
      <td>
        <xsl:value-of select="@col5"/>
      </td>
      <td>
        <xsl:value-of select="@col6"/>
      </td>
      <td>
        <xsl:value-of select="@col7"/>
      </td>
      <td>
        <xsl:value-of select="@col8"/>
      </td>
      <td>
        <xsl:value-of select="@col9"/>
      </td>
      <td>
        <xsl:value-of select="@col10"/>
      </td>
      <td>
        <xsl:value-of select="@col11"/>
      </td>
      <td>
        <xsl:value-of select="@col12"/>
      </td>
      <td>
        <xsl:value-of select="@col13"/>
      </td>
      <td>
        <xsl:value-of select="@col14"/>
      </td>
      <td>
        <xsl:value-of select="@col15"/>
      </td>
      <td>
        <xsl:value-of select="@col16"/>
      </td>
      <td>
        <xsl:value-of select="@col17"/>
      </td>
      <td>
        <xsl:value-of select="@col18"/>
      </td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>


</xsl:stylesheet>