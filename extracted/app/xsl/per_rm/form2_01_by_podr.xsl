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
      font-size:9.0pt;
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
      font-size:8.0pt;
      height:110pt;
      }
      p.line {
      margin-bottom:0;
      margin-top:0;
      font-size:6.0pt;
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
        <td rowspan="2">Номер рабочего места</td>
        <td rowspan="2">Профессия/должность/специальность работника</td>
        <td colspan="14">Классы (подклассы) условий труда</td>
        <!--Компенсации-->
        <td rowspan="2" class="rotate">Итоговый класс (подкласс) условий труда</td>
        <td rowspan="2" class="rotate">Итоговый класс (подкласс) условий труда с учетом эффективного применения СИЗ</td>
        <td rowspan="2" class="rotate">Повышенный размер оплаты труда (да,нет)</td>
        <td rowspan="2" class="rotate">Ежегодный дополнительный оплачиваемый отпуск (да/нет)</td>
        <td rowspan="2" class="rotate">Сокращенная продолжительность рабочего времени (да/нет)</td>
        <td rowspan="2" class="rotate">Молоко или другие равноценные пищевые продукты (да/нет)</td>
        <td rowspan="2" class="rotate">Лечебно-профилактическое питание  (да/нет)</td>
        <td rowspan="2" class="rotate">
          <xsl:if test="$prikaz_sout='817'">
            Право на досрочное назначение страховой пенсии (да/нет)
          </xsl:if>
          <xsl:if test="$prikaz_sout!='817'">
            Льготное пенсионное обеспечение (да/нет)
          </xsl:if>
        </td>
      </tr>
      <tr>
        <td class="rotate">Химический фактор</td>
        <td class="rotate">Биологический фактор</td>
        <td class="rotate">Аэрозоли преимущественно фиброгенного действия</td>
        <td class="rotate">Шум</td>
        <td class="rotate">Инфразвук</td>
        <td class="rotate">Ультразвук воздушный</td>
        <td class="rotate">Вибрация общая</td>
        <td class="rotate">Вибрация локальная</td>
        <td class="rotate">Неионизирующие излучения</td>
        <td class="rotate">Ионизирующие излучения</td>
        <td class="rotate">Параметры микроклимата</td>
        <td class="rotate">Параметры световой среды</td>
        <td class="rotate">Тяжесть трудового процесса</td>
        <td class="rotate">Напряженность трудового процесса</td>
      </tr>
      <tr>
        <td width="5%">1</td>
        <td width="29%">2</td>
        <td width="3%">3</td>
        <td width="3%">4</td>
        <td width="3%">5</td>
        <td width="3%">6</td>
        <td width="3%">7</td>
        <td width="3%">8</td>
        <td width="3%">9</td>
        <td width="3%">10</td>
        <td width="3%">11</td>
        <td width="3%">12</td>
        <td width="3%">13</td>
        <td width="3%">14</td>
        <td width="3%">15</td>
        <td width="3%">16</td>
        <td width="3%">17</td>
        <td width="3%">18</td>
        <td width="3%">19</td>
        <td width="3%">20</td>
        <td width="3%">21</td>
        <td width="3%">22</td>
        <td width="3%">23</td>
        <td width="3%">24</td>
      </tr>
    </table>
    <xsl:apply-templates select="ceh"/>
  </xsl:template>

  <xsl:template match ="ceh">
    <p class="line">&#160;</p>
    <table width="100%">
      <tr>
        <td colspan="24">
          <xsl:value-of select="@name"/>
        </td>
      </tr>
      <tr>
        <td width="5%">1</td>
        <td width="29%">2</td>
        <td width="3%">3</td>
        <td width="3%">4</td>
        <td width="3%">5</td>
        <td width="3%">6</td>
        <td width="3%">7</td>
        <td width="3%">8</td>
        <td width="3%">9</td>
        <td width="3%">10</td>
        <td width="3%">11</td>
        <td width="3%">12</td>
        <td width="3%">13</td>
        <td width="3%">14</td>
        <td width="3%">15</td>
        <td width="3%">16</td>
        <td width="3%">17</td>
        <td width="3%">18</td>
        <td width="3%">19</td>
        <td width="3%">20</td>
        <td width="3%">21</td>
        <td width="3%">22</td>
        <td width="3%">23</td>
        <td width="3%">24</td>
      </tr>
      <xsl:apply-templates select="uch|rm"/>
    </table>
  </xsl:template>

  <xsl:template match ="uch">
      <tr>
        <td colspan="24">
          <xsl:value-of select="@name"/>
        </td>
      </tr>
      <xsl:apply-templates select="uch|rm"/>
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
        <xsl:value-of select="@col3"/>
      </td>
      <td>
        <xsl:value-of select="@col4"/>
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
      <td>
        <xsl:value-of select="@col22"/>
      </td>
      <td>
        <xsl:value-of select="@col23"/>
      </td>
      <td>
        <xsl:value-of select="@col24"/>
      </td>
    </tr>
  </xsl:template>



</xsl:stylesheet>