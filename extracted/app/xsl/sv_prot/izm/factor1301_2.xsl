<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <xsl:variable name="co_2_1">
    <xsl:value-of select="count(Document/rm/param[@bm='bm_2_1'])"/>
  </xsl:variable>  
  <xsl:variable name="co_2_2">
    <xsl:value-of select="count(Document/rm/param[@bm='bm_2_2'])"/>
  </xsl:variable>  
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
      }
      tr.param {
      font-size:9.0pt;
      }
      tr.param_header {
      font-size:9.0pt;
      font-weight: bold;
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
        <td width="35%">Наименование рабочего места, рабочей зоны, фактора</td>
        <td width="11%">Дата оценки (измерения)</td>
        <td width="13%">Факт. уровень</td>
        <td width="11%">Время воздействия, %</td>
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
      <td>100</td>
    </tr>
    <!-- Краткое описание выполняемой работы -->
    <tr>
      <td align="left" colspan="5">
        <b>Краткое описание выполняемой работы:</b>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@src"/>
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="zone">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <td colspan="4">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="param">
    
    <xsl:if test="@bm='bm_1'">
      <tr class="param_header">
        <td></td>
        <td align="left">1. Физическая динамическая нагрузка за рабочий день (смену)</td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
    </xsl:if>
    
    <xsl:if test="@bm='bm_1_1'">
      <tr class="param">
        <td></td>
        <td align="left">1.1. Региональная нагрузка при перемещении груза на расстояние до 1 м</td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">1.1.1. Масса груза, кг</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">1.1.2. Расстояние перемещения, м</td>
        <td></td>
        <td>
          <xsl:value-of select="@param2"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">1.1.3. Количество перемещений</td>
        <td></td>
        <td>
          <xsl:value-of select="@param3"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>
    
    <xsl:if test="@bm='bm_1_2'">
      <tr class="param">
        <td></td>
        <td align="left">1.2. Региональная нагрузка при перемещении груза на расстояние от 1 до 5 м</td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">1.2.1. Масса груза, кг</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">1.2.2. Расстояние перемещения, м</td>
        <td></td>
        <td>
          <xsl:value-of select="@param2"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">1.2.3. Количество перемещений</td>
        <td></td>
        <td>
          <xsl:value-of select="@param3"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_1_3'">
      <tr class="param">
        <td></td>
        <td align="left">1.3. Региональная нагрузка при перемещении груза на расстояние более 5 м</td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">1.3.1. Масса груза, кг</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">1.3.2. Расстояние перемещения, м</td>
        <td></td>
        <td>
          <xsl:value-of select="@param2"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">1.3.3. Количество перемещений</td>
        <td></td>
        <td>
          <xsl:value-of select="@param3"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_2_h'">
      <tr class="param_header">
        <td></td>
        <td align="left">2. Масса поднимаемого и перемещаемого груза вручную</td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_2_1'">
      <tr class="param">
        <td></td>
        <td align="left">2.1. Подъем и перемещение (разовое) тяжести при чередовании с другой работой (до 2-х раз в час), кг</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>
    
    <xsl:if test="@bm='bm_2_2'">
      <tr class="param">
        <td></td>
        <td align="left">2.2. Подъем и перемещение тяжести постоянно в течение рабочего дня (смены) (более 2 раз в час), кг</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_2_3_h'">
      <tr class="param_header">
        <td></td>
        <td align="left">2.3. Суммарная масса грузов, перемещаемых в течение каждого часа смены, в том числе</td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_2_3_1'">
      <tr class="param">
        <td></td>
        <td align="left">2.3.1. Масса груза, перемещаемого c рабочей поврехности, кг</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">2.3.1.1. Количество перемещений</td>
        <td></td>
        <td>
          <xsl:value-of select="@param2"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_2_3_2'">
      <tr class="param">
        <td></td>
        <td align="left">2.3.2. Масса груза, перемещаемого c пола, кг</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">2.3.2.1. Количество перемещений</td>
        <td></td>
        <td>
          <xsl:value-of select="@param2"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_3_h'">
      <tr class="param_header">
        <td></td>
        <td align="left">3. Стереотипные рабочие движения</td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_3_1'">
      <tr class="param">
        <td></td>
        <td align="left">3.1. Количество движений за операцию (при локальной нагрузке)</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">3.1.1. Количество операций</td>
        <td></td>
        <td>
          <xsl:value-of select="@param2"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_3_2'">
      <tr class="param">
        <td></td>
        <td align="left">3.2. Количество движений за операцию (при региональной нагрузке)</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">3.2.1. Количество операций</td>
        <td></td>
        <td>
          <xsl:value-of select="@param2"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_4_h'">
      <tr class="param_header">
        <td></td>
        <td align="left">4. Статическая нагрузка - величина статической нагрузки за рабочий день (смену) при удержании груза, приложении усилий</td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_4_1'">
      <tr class="param">
        <td></td>
        <td align="left">4.1. Одной рукой</td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">4.1.1. Измеренная сила при удержании груза (приложении усилия), кгс</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">4.1.2. Время удержания груза (приложения усилия), с</td>
        <td></td>
        <td>
          <xsl:value-of select="@param2"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">4.1.3. Количество перемещений</td>
        <td></td>
        <td>
          <xsl:value-of select="@param3"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_4_2'">
      <tr class="param">
        <td></td>
        <td align="left">4.2. Двумя руками</td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">4.2.1. Измеренная сила при удержании груза (приложении усилия), кгс</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">4.2.2. Время удержания груза (приложения усилия), с</td>
        <td></td>
        <td>
          <xsl:value-of select="@param2"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">4.2.3. Количество перемещений</td>
        <td></td>
        <td>
          <xsl:value-of select="@param3"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_4_3'">
      <tr class="param">
        <td></td>
        <td align="left">4.3. С участием мышц корпуса и ног</td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">4.3.1. Измеренная сила при удержании груза (приложении усилия), кгс</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">4.3.2. Время удержания груза (приложения усилия), с</td>
        <td></td>
        <td>
          <xsl:value-of select="@param2"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">4.3.3. Количество перемещений</td>
        <td></td>
        <td>
          <xsl:value-of select="@param3"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_5_h'">
      <tr class="param_header">
        <td></td>
        <td align="left">5. Рабочая поза (рабочее положение тела работника в течение рабочего дня (смены))</td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_5_1'">
      <tr class="param">
        <td></td>
        <td align="left">5.1. Свободная, % смены</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_5_2'">
      <tr class="param">
        <td></td>
        <td align="left">5.2. Стоя, % смены</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_5_3'">
      <tr class="param">
        <td></td>
        <td align="left">5.3. Неудобная, % смены</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_5_4'">
      <tr class="param">
        <td></td>
        <td align="left">5.4. Фиксированная, % смены</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_5_5'">
      <tr class="param">
        <td></td>
        <td align="left">5.5. Вынужденная, % смены</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_5_6'">
      <tr class="param">
        <td></td>
        <td align="left">5.6. Поза «сидя» без перерывов, % смены</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_6'">
      <tr class="param">
        <td></td>
        <td align="left">
          <b>6. Наклоны корпуса тела работника более 30º, количе-ство за рабочий день (смену)</b>
        </td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
      <xsl:if test="@param2>0">
        <tr class="param">
          <td></td>
          <td align="left">6.1. Количество операций</td>
          <td></td>
          <td>
            <xsl:value-of select="@param2"/>
            <td></td>
          </td>
        </tr>
      </xsl:if>
    </xsl:if>

    <xsl:if test="@bm='bm_7_h'">
      <tr class="param_header">
        <td></td>
        <td align="left">7. Перемещения работника в пространстве, обусловленные технологическим процессом</td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_7_1_data'">
      <tr class="param">
        <td></td>
        <td align="left">7.1. Измеренное расстояние перемещения по горизонтали, м</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">7.1.1. Количество перемещений</td>
        <td></td>
        <td>
          <xsl:value-of select="@param2"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

     <xsl:if test="@bm='bm_7_2_data'">
      <tr class="param">
        <td></td>
        <td align="left">7.2. Измеренное расстояние перемещения по вертикали, м</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
      <tr class="param">
        <td></td>
        <td align="left">7.2.1. Количество перемещений</td>
        <td></td>
        <td>
          <xsl:value-of select="@param2"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_7_1'">
      <tr class="param">
        <td></td>
        <td align="left">7.1. Перемещения работника по горизонтали, км</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

    <xsl:if test="@bm='bm_7_2'">
      <tr class="param">
        <td></td>
        <td align="left">7.2. Перемещения работника по вертикали, км</td>
        <td></td>
        <td>
          <xsl:value-of select="@param1"/>
        </td>
        <td></td>
      </tr>
    </xsl:if>

  </xsl:template>

</xsl:stylesheet>