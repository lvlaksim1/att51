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
      text-align:center;
      }
      td.selected2 {
      border:3px solid black;
      text-align:center;
      height: 20pt;
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
    <p class="h1">Операции напряженности</p>
    <xsl:apply-templates/>
    <!-- Подписи -->
    <p>&#160;</p>
    <p>&#160;</p>
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
  </xsl:template>


  <xsl:template match ="RM">
    <table width="100%">
      <tr>
        <td width="30%">Подразделение:</td>
        <td width="70%">
          <xsl:value-of select="@podr"/>
        </td>
      </tr>
      <xsl:if test="@uch">
        <tr>
          <td>Участок:</td>
          <td>
            <xsl:value-of select="@uch"/>
          </td>
        </tr>
      </xsl:if>
      <tr>
        <td>Рабочее место:</td>
        <td>
          <xsl:value-of select="@num"/>. <xsl:value-of select="@name"/>
        </td>
      </tr>
      <tr>
        <td>Длительность смены в минутах:</td>
        <td>
          <xsl:value-of select="@timesmena"/>
        </td>
      </tr>
    </table>

    <table width="100%">
      <!-- 1 -->
      <tr>
        <td rowspan="5" class="center">1</td>
        <td colspan="7">
          Выполняется работа с использованием оптических приборов - устройств, применяемых в производственном процессе для увеличения размеров рассматриваемого объекта (лупы, микроскопы, дефектоскопы и т.п.):
        </td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td colspan="6">НЕТ (пункт 1.1. не заполняется)</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td colspan="6">ДА (выберите диапазон среднесменных значений или укажите конкретное значение в поле «точно»):</td>
      </tr>
      <tr>
        <td rowspan="2">1.1</td>
        <td rowspan="2">Время работы с оптическими приборами (% времени  смены)</td>
        <td width="10%" align="center">до 25</td>
        <td width="10%" align="center">26–50</td>
        <td width="10%" align="center">51–75</td>
        <td width="10%" align="center">более 75</td>
        <td width="10%" align="center">точно:</td>
      </tr>
      <tr>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
      </tr>
      <!-- 2 -->
      <tr>
        <td rowspan="5" class="center">2</td>
        <td colspan="7">
          Выполняется работа с ежедневной нагрузкой на голосовой аппарат (голосовой ввод и передача информации, диктование, преподавание и т.п.):
        </td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td colspan="6">НЕТ (пункт 2.1. не заполняется)</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td colspan="6">ДА (выберите диапазон среднесменных значений или укажите конкретное значение в поле «точно»):</td>
      </tr>
      <tr>
        <td rowspan="2">2.1</td>
        <td rowspan="2">Суммарное количество часов, наговариваемое в неделю</td>
        <td align="center">до 16</td>
        <td align="center">до 20</td>
        <td align="center">до 25</td>
        <td align="center">более 25</td>
        <td align="center">точно:</td>
      </tr>
      <tr>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
      </tr>

      <!-- 3 -->
      <tr>
        <td rowspan="9" class="center">3</td>
        <td colspan="7">
          Выполняется работа (отметить нужную, выбрать диапазон среднесменных значений (отметить галочкой) или указать конкретное значение в поле «точно»):
        </td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td colspan="6">по диспетчеризации производственных процессов, в том числе конвейерного типа</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td colspan="6">оператором технологического (производственного) оборудования</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td colspan="6">по управлению транспортными средствами</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td colspan="6">НЕТ (пункты 3.1-3.2. не заполняются)</td>
      </tr>
      <tr>
        <td rowspan="2">3.1</td>
        <td rowspan="2">Плотность сигналов (световых и звуковых) и сообщений в среднем за 1 час работы (количество)</td>
        <td align="center">до 75</td>
        <td align="center">76-175</td>
        <td align="center">176-300</td>
        <td align="center">более 300</td>
        <td align="center">точно:</td>
      </tr>
      <tr>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
      </tr>
      <tr>
        <td rowspan="2">3.2</td>
        <td rowspan="2">Число производственных объектов одновременного наблюдения (количество)</td>
        <td align="center">до 5</td>
        <td align="center">6-10</td>
        <td align="center">11-25</td>
        <td align="center">более 25</td>
        <td align="center">точно:</td>
      </tr>
      <tr>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
        <td class="selected2"></td>
      </tr>

      <!-- 4 -->
      <tr>
        <td rowspan="7" class="center">4</td>
        <td colspan="7">
          Выполняются опасные и/или особо опасные операции (по приказам 46н и 433н):
        </td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td colspan="6">НЕТ (пункты 4.1-4.2. не заполняются)</td>
      </tr>
      <tr>
        <td class="selected"></td>
        <td colspan="6">ДА (выберите диапазон среднесменных значений или укажите конкретное значение в поле «точно»):</td>
      </tr>
      <tr>
        <td rowspan="2">4.1</td>
        <td rowspan="2">Однократное выполнение разнотипных опасных операций в смену (количество)</td>
        <td colspan="2" align="center">от 1 до 3</td>
        <td colspan="2" align="center">более 3</td>
        <td align="center">точно:</td>
      </tr>
      <tr>
        <td colspan="2" class="selected2"></td>
        <td colspan="2" class="selected2"></td>
        <td class="selected2"></td>
      </tr>
      <tr>
        <td rowspan="2">4.2</td>
        <td rowspan="2">Однократное выполнение разнотипных особо опасных операций в смену (количество)</td>
        <td colspan="2" align="center">1</td>
        <td colspan="2" align="center">более 1</td>
        <td align="center">точно:</td>
      </tr>
      <tr>
        <td colspan="2" class="selected2"></td>
        <td colspan="2" class="selected2"></td>
        <td class="selected2"></td>
      </tr>
    </table>
    <p>Особенности (при наличии):</p>
    <p/>
    <xsl:if test="position() != last()">
      <br clear="all" style='mso-special-character:line-break;page-break-before:always'/>
    </xsl:if>
    
  </xsl:template>

</xsl:stylesheet>