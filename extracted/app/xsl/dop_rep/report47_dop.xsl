<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения об организации, в которой проводится СОУТ</title>
    <style>
      /* Style Definitions */
      body
      {
      font-size:10.0pt;
      font-family: Arial, serif;
      text-align:left;
      }
      .prim {
      font-size:8.0pt;
      }

      table
      {
      font-size:9.0pt;
      text-align:left;
      }

      table.rm_name
      {
      font-weight:bold;
      }

      .h1 {
      font-weight:bold;
      font-size:14.0pt;
      text-align:center;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }

      td.center {
      text-align:center;
      }
      td.caption {
      text-align:center;
      font-size:8.0pt;
      }

      td.selected {
      border:3px solid black;
      }
      td.selected2 {
      border:3px solid black;
      height: 30pt;
      }

      td.rotate {
      mso-rotate:90;
      font-size:7.0pt;
      height:80pt;
      }

      table.comission,table.comission th,table.comission td
      {
      text-align:center;
      border:none;
      background:none;
      padding:0 5px 0 5px;
      }

      table.comission td.sign {
      border-bottom: 1px solid black;
      }

    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <p class="h1">Операции тяжести</p>
    <xsl:apply-templates/>
    <!-- Подписи -->
    <table width="100%" class="comission">
      <tr>
        <td class="sign" width="30%">Составил</td>
        <td width="2%"></td>
        <td class="sign" width="23%"></td>
        <td width="2%"></td>
        <td class="sign" width="23%"></td>
        <td width="2%"></td>
        <td class="sign" width="20%"></td>
      </tr>
      <tr>
        <td></td>
        <td></td>
        <td><sup>ФИО</sup></td>
        <td></td>
        <td><sup>подпись</sup></td>
        <td></td>
        <td><sup>дата</sup></td>
      </tr>
      <tr>
        <td class="sign">Согласовано</td>
        <td width="2%"></td>
        <td class="sign"></td>
        <td width="2%"></td>
        <td class="sign"></td>
        <td width="2%"></td>
        <td class="sign"></td>
      </tr>
      <tr>
        <td></td>
        <td></td>
        <td>
          <sup>ФИО</sup>
        </td>
        <td></td>
        <td>
          <sup>подпись</sup>
        </td>
        <td></td>
        <td>
          <sup>дата</sup>
        </td>
      </tr>
      <tr>
        <td class="sign">Руководитель подразделения</td>
        <td width="2%"></td>
        <td class="sign"></td>
        <td width="2%"></td>
        <td class="sign"></td>
        <td width="2%"></td>
        <td class="sign"></td>
      </tr>
      <tr>
        <td></td>
        <td></td>
        <td>
          <sup>ФИО</sup>
        </td>
        <td></td>
        <td>
          <sup>подпись</sup>
        </td>
        <td></td>
        <td>
          <sup>дата</sup>
        </td>
      </tr>
    </table>

    <p class="prim">1 – Мужской шаг в производственной обстановке в среднем равняется 0,6 м; женский - 0,5 м.<br/>
    2 – Перемещения по лестницам или наклонным поверхностям, угол наклона которых более 30° от горизонтали.<br/>
    3 – Удерживание предметов, поднятие груза или выполнение действия руками на высоте не более 50 см от пола.<br/>
    4 – Неудобное положение - это работа с наклоном или поворотом туловища, с поднятыми выше уровня плеч руками, с неудобным размещением ног. Неудобное рабочее положение характерно для работ, при которых органы управления или рабочие поверхности оборудования располо-жены вне пределов максимальной досягаемости рук работника либо в поле зрения работника находятся объекты, препятствующие наблюде-нию за обслуживающимся объектом или процессом. Неудобное положение работника может быть также связано с необходимостью удержания работником рук на весу.<br/>
    Фиксированное положение – это положение с невозможностью изменения взаимного положения различных частей тела работника относи-тельно друг друга. Подобные положения встречаются при выполнении работ, связанных с необходимостью в процессе производственной дея-тельности различать мелкие объекты. Примером работ с фиксированным рабочим положением являются работы, выполняемые с использова-нием оптических увеличительных приборов - луп и микроскопов. Фиксированное рабочее положение характеризуется либо полной неподвиж-ностью, либо ограниченным количеством высокоточных движений, совершаемых с малой амплитудой в ограниченном пространстве.
    </p>
    <p>&#160;</p>
  </xsl:template>


  <xsl:template match ="RM">
    <table width="100%">
      <tr>
        <td colspan="2" width="20%">Подразделение:</td>
        <td colspan="2" width="80%">
          <xsl:value-of select="@podr"/>
        </td>
      </tr>
      <xsl:if test="@uch">
        <tr>
          <td colspan="2">Участок:</td>
          <td colspan="2">
            <xsl:value-of select="@uch"/>
          </td>
        </tr>
      </xsl:if>
      <tr>
        <td colspan="2">Рабочее место:</td>
        <td colspan="2">
          <xsl:value-of select="@num"/>. <xsl:value-of select="@name"/>
        </td>
      </tr>
      <tr>
        <td>Пол:</td>
        <td align="center">
          <xsl:if test="@sex='0'">Мужской</xsl:if>
          <xsl:if test="@sex='1'">Женский</xsl:if>
        </td>
        <td>Длительность смены в минутах:</td>
        <td align="center">
          <xsl:value-of select="@timesmena"/>
        </td>
      </tr>
      <tr>
        <td colspan="2">Применяемое оборудование:</td>
        <td colspan="2">
          <xsl:value-of select="@oborud"/>
        </td>
      </tr>
      <tr>
        <td colspan="2">Используемые материалы и сырье:</td>
        <td colspan="2">
          <xsl:value-of select="@material"/>
        </td>
      </tr>
    </table>

    <table width="100%">
      <tr>
        <td colspan="7">Каждую смену выполняются работы со значительной физической нагрузкой (отметить нужные, выбрать диапазон среднесменных значений (отметить галочкой) или указать конкретное значение в поле «точно»):</td>
      </tr>
      <tr>
        <td width="5%" class="selected"></td>
        <td colspan="6">НЕТ (пункты 1 - 12 не заполняются)</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td colspan="6">Поднятие и переноска грузов вручную</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td colspan="6">Работа в вынужденном положении («лежа», «на коленях», «на корточках»)</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td colspan="6">Работа в положении «стоя» (невозможно выполнение такой работы в положении «сидя»)</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td colspan="6">Работа по перемещению в пространстве в соответствии с технологическим процессом</td>
      </tr>
      <!-- 1 -->
      <tr>
        <td rowspan="2" class="center">1</td>
        <td rowspan="2">
          Суммарное перемещение по горизонтали, обусловленное технологическим процессом, в течение рабочей смены (км)<sup>1</sup>
        </td>
        <td width="10%" class="caption">до 4 км</td>
        <td width="10%" class="caption">4-8 км</td>
        <td width="10%" class="caption">8-12 км</td>
        <td width="10%" class="caption">более 12</td>
        <td width="15%" class="caption">точно:</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
      </tr>
      <!-- 2 -->
      <tr>
        <td rowspan="2" class="center">2</td>
        <td rowspan="2">
          Суммарное перемещение по вертикали, обусловленное технологическим процессом, в течение рабочей смены (км)<sup>2</sup>
        </td>
        <td width="10%" class="caption">до 1 км</td>
        <td width="10%" class="caption">1-2.5 км</td>
        <td width="10%" class="caption">2.5-5 км</td>
        <td width="10%" class="caption">более 5</td>
        <td width="15%" class="caption">точно:</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
      </tr>
      <!-- 3 -->
      <tr>
        <td rowspan="2" class="center">3</td>
        <td rowspan="2">
          Суммарное количество наклонов корпуса тела более 30° (опускание рук ниже колена), обусловленное технологическим процессом в течение рабочей смены<sup>3</sup>
        </td>
        <td width="10%" class="caption">до 50</td>
        <td width="10%" class="caption">51-100</td>
        <td width="10%" class="caption">101-300</td>
        <td width="10%" class="caption">свыше 300</td>
        <td width="15%" class="caption">точно:</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
      </tr>
      <!-- 4 -->
      <tr>
        <td rowspan="2" class="center">4</td>
        <td rowspan="2">
          Суммарное нахождение в положении «си-дя» без перерывов, обусловленное техноло-гическим процессом в течение рабочей сме-ны (в % от смены). Или укажите конкретное значение в часах в поле «точно».
        </td>
        <td width="10%" class="caption">Нет (0 %)</td>
        <td width="10%" class="caption">1-60 %</td>
        <td width="10%" class="caption">60-80 %</td>
        <td width="10%" class="caption">Более 80 %</td>
        <td width="15%" class="caption">точно:</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
      </tr>
      <!-- 5 -->
      <tr>
        <td rowspan="2" class="center">5</td>
        <td rowspan="2">
          Суммарное нахождение в вынужденном положении («лежа», «на коленях», «на корточках»), обусловленное технологическим процессом в течение рабочей смены (в % от смены). Или укажите конкретное значение в часах в поле «точно».
        </td>
        <td width="10%" class="caption">Нет (0 %)</td>
        <td width="10%" class="caption">1 - 25 %</td>
        <td colspan="2" width="10%" class="caption">более 25 %</td>
        <td width="15%" class="caption">точно:</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td class="selected"></td>
        <td colspan="2" class="selected"></td>
        <td class="selected"></td>
      </tr>
      <!-- 6 -->
      <tr>
        <td rowspan="2" class="center">6</td>
        <td rowspan="2">
          Суммарное нахождение в неудобном и (или) фиксированном положении, обусловленное технологическим процессом в течение рабо-чей смены (в % от смены). Или укажите кон-кретное значение в часах в поле «точно».<sup>4</sup>
        </td>
        <td width="10%" class="caption">Нет (0 %)</td>
        <td width="10%" class="caption">1-25 %</td>
        <td width="10%" class="caption">25-50  %</td>
        <td width="10%" class="caption">Более 50 %</td>
        <td width="15%" class="caption">точно:</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
      </tr>
      <!-- 7 -->
      <tr>
        <td rowspan="2" class="center">7</td>
        <td rowspan="2">
          Суммарное нахождение положении «стоя» (невозможно выполнение такой работы в положении «сидя»), обусловленное техноло-гическим процессом в течение рабочей сме-ны (в % от смены). Или укажите конкретное значение в часах в поле «точно».
        </td>
        <td width="10%" class="caption">до 40 %</td>
        <td width="10%" class="caption">41-60 %</td>
        <td width="10%" class="caption">61-80 %</td>
        <td width="10%" class="caption">Более 80 %</td>
        <td width="15%" class="caption">точно:</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
      </tr>
      <!-- 8 -->
      <tr>
        <td rowspan="4" class="center">8</td>
        <td>
          8. Перемещение грузов с рабочей поверхности
        </td>
        <td width="10%" class="caption">Средний вес, кг</td>
        <td width="10%" class="caption">Среднее расстояние, м</td>
        <td width="10%" class="caption">Время удержания, сек</td>
        <td width="10%" class="caption">Общее кол-во перемещений</td>
        <td width="15%" class="caption">Примечание</td>
      </tr>
      <tr class="selected2">
        <td>
          8.1. 1 рукой (только на расстояние до 1 м):
        </td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
      </tr>
      <tr>
        <td>
          8.2. 2-мя руками (только на расстояние до 1 м)
        </td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
      </tr>
      <tr>
        <td>
          8.3. с участием мышц корпуса и ног (более 1 метра)
        </td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
      </tr>
      <!-- 9 -->
      <tr>
        <td rowspan="4" class="center">9</td>
        <td>
          9. Перемещение грузов с пола:
        </td>
        <td width="10%" class="caption">Средний вес, кг</td>
        <td width="10%" class="caption">Среднее расстояние, м</td>
        <td width="10%" class="caption">Время удержания, сек</td>
        <td width="10%" class="caption">Общее кол-во перемещений</td>
        <td width="15%" class="caption">Примечание</td>
      </tr>
      <tr class="selected2">
        <td>
          9.1. 1 рукой (только на расстояние до 1 м)
        </td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
      </tr>
      <tr>
        <td>
          9.2. 2-мя руками (только на расстояние до 1 м)
        </td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
      </tr>
      <tr>
        <td>
          9.3. с участием мышц корпуса и ног (более 1 метра)
        </td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
      </tr>
      <!-- 10 -->
      <tr>
        <td rowspan="2" class="center">10</td>
        <td rowspan="2">
          Максимальный вес груза поднимаемого и перемещаемого вручную не более 2-х раз в час (в числителе – для мужчин, в знаменателе – для женщин)
        </td>
        <xsl:if test="@sex='0'">
          <td width="10%" class="caption">до 15 кг</td>
          <td width="10%" class="caption">до 30 кг</td>
          <td width="10%" class="caption">до 35 кг</td>
          <td width="10%" class="caption">более 35 кг</td>
        </xsl:if>
        <xsl:if test="@sex='1'">
          <td width="10%" class="caption">до 5 кг</td>
          <td width="10%" class="caption">до 10 кг</td>
          <td width="10%" class="caption">до 12 кг</td>
          <td width="10%" class="caption">более 12 кг</td>
        </xsl:if>
        <td width="15%" class="caption">точно:</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
      </tr>
      <!-- 11 -->
      <tr>
        <td rowspan="2" class="center">11</td>
        <td rowspan="2">
          Максимальный вес груза поднимаемого и перемещаемого вручную более 2-х раз в час (в числителе – для мужчин, в знаменателе – для женщин)
        </td>
        <xsl:if test="@sex='0'">
          <td width="10%" class="caption">до 5 кг</td>
          <td width="10%" class="caption">до 15 кг</td>
          <td width="10%" class="caption">до 20 кг</td>
          <td width="10%" class="caption">более 20 кг</td>
        </xsl:if>
        <xsl:if test="@sex='1'">
          <td width="10%" class="caption">до 3 кг</td>
          <td width="10%" class="caption">до 7 кг</td>
          <td width="10%" class="caption">до 10 кг</td>
          <td width="10%" class="caption">более 10 кг</td>
        </xsl:if>
        <td width="15%" class="caption">точно:</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
      </tr>
      <!-- 12 -->
      <tr>
        <td rowspan="2" class="center">12</td>
        <td rowspan="2">
          Количество стереотипных рабочих движений за смену при локальной нагрузке (с участием мышц кистей и пальцев рук). Или укажите конкретное значение в часах в поле «точно».
        </td>
        <td width="10%" class="caption">до 20000</td>
        <td width="10%" class="caption">до 40000</td>
        <td width="10%" class="caption">до 60000</td>
        <td width="10%" class="caption">более 60000</td>
        <td width="15%" class="caption">точно:</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
      </tr>
      <!-- 13 -->
      <tr>
        <td rowspan="2" class="center">13</td>
        <td rowspan="2">
          Количество стереотипных рабочих движений за смену при региональной нагрузке (при работе с преимущественным участием мышц рук и плечевого пояса). Или укажите конкретное значение в часах в поле «точно».
        </td>
        <td width="10%" class="caption">до 10000</td>
        <td width="10%" class="caption">до 20000</td>
        <td width="10%" class="caption">до 30000</td>
        <td width="10%" class="caption">более 30000</td>
        <td width="15%" class="caption">точно:</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
        <td class="selected"></td>
      </tr>
    </table>
    <p>Особенности (при наличии):</p>
    <p/>
    <xsl:if test="position() != last()">
      <br clear="all" style='mso-special-character:line-break;page-break-before:always'/>
    </xsl:if>
    
  </xsl:template>

</xsl:stylesheet>