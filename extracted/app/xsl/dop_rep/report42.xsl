<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения по организациям в базе РМ</title>
    <style>
      /* Style Definitions */
      body
      {
      font-size:12.0pt;
      font-family: Times new roman, serif;
      text-align:left;
      }
      p.right
      {
      font-size:9.0pt;
      text-align:right;
      margin-left:750px;
      }
      table
      {
      font-size:9.0pt;
      text-align:center;
      }
      table.org
      {
      font-size:10.0pt;
      text-align:left;
      }

      .prim {
      font-size:10.0pt;
      }
      .h1 {
      font-weight:bold;
      font-size:14.0pt;
      text-align:center;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
      table.comission,table.comission th,table.comission td
      {
      font-size:12.0pt;
      text-align:center;
      border:none;
      background:none;
      padding:0 5px 0 5px;
      }
      td.center {
      text-align:center;
      }
      table.comission,table.comission th,table.comission td
      {
      font-size:12.0pt;
      text-align:center;
      border:none;
      background:none;
      padding:0 5px 0 5px;
      }
      table.comission td.sign {
      border-bottom: 1px solid black;
      }
      table.comission td.left {
      text-align:left;
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
    <p class="right">Приложение 1 к Порядку мониторинга состояния условий и охраны труда в Московской области, утвержденному распоряжением Министерства социального развития Московской области от 11.08.2017 г. N 19РВ-62</p>
    <p class="h1">Отчет о проделанной работе по специальной оценке условий труда</p>
    <table>
      <tr>
        <td rowspan="4" width="5%">№<br/>п/п</td>
        <td rowspan="4" width="10%">Наименование хозяйствующего субъекта</td>
        <td rowspan="4" width="5%">ИНН</td>
        <td colspan="2" width="10%">Количество (всего)</td>
        <td rowspan="4" width="10%">Основной вид деятельности</td>
        <td colspan="3" width="15%">Количество рабочих мест и работников, на  которых проведена СОУТ в отчетный период</td>
        <td colspan="12" width="10%">Установлен класс условий труда по результатам СОУТ</td>
        <td rowspan="4" width="30%">Материал по СОУТ(файл в формате PDF) с 2014 года</td>
        <td rowspan="4" width="15%">Номер отчета по СОУТ во ФГИС СОУТ</td>
      </tr>
      <tr>
        <td rowspan="3">РМ</td>
        <td rowspan="3">Чел.</td>
        <td rowspan="3">РМ всего</td>
        <td rowspan="3">РМ в том числе в отчетном периоде</td>
        <td rowspan="3">Чел. всего</td>
        <td rowspan="2" colspan="2">1-2 классы</td>
        <td colspan="8">3 класс</td>
        <td rowspan="2" colspan="2">4 класс</td>
      </tr>
      <tr>
        <td colspan="2">3.1</td>
        <td colspan="2">3.2</td>
        <td colspan="2">3.3</td>
        <td colspan="2">3.4</td>
      </tr>
      <tr>
        <td>РМ всего</td>
        <td>Чел. всего</td>
        <td>РМ всего</td>
        <td>Чел. всего</td>
        <td>РМ всего</td>
        <td>Чел. всего</td>
        <td>РМ всего</td>
        <td>Чел. всего</td>
        <td>РМ всего</td>
        <td>Чел. всего</td>
        <td>РМ всего</td>
        <td>Чел. всего</td>
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
        <td>9</td>
        <td>10</td>
        <td>11</td>
        <td>12</td>
        <td>13</td>
        <td>14</td>
        <td>15</td>
        <td>16</td>
        <td>17</td>
        <td>18</td>
        <td>19</td>
        <td>20</td>
        <td>21</td>
        <td>22</td>
        <td>23</td>
      </tr>
      <xsl:apply-templates/>
      </table>
    <p/>
    <table width="50%" class="comission">
      <tr>
        <td class="sign" width="35%">
          
        </td>
        <td width="5%"></td>
        <td class="sign" width="20%"></td>
        <td width="5%"></td>
        <td class="sign" width="35%">
          
        </td>
      </tr>
      <tr>
        <td width="20%">
          <sup>(должность руководителя)</sup>
        </td>
        <td width="3%"></td>
        <td width="20%">
          <sup>(подпись)</sup>
        </td>
        <td width="3%"></td>
        <td width="20%">
          <sup>И.О. Фамилия</sup>
        </td>
      </tr>
    </table>
    <p/>
  </xsl:template>

  <xsl:template match ="ORG">
    <tr>
      <td>
        <xsl:value-of select="count(preceding-sibling::ORG)+1"/>
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@inn"/>
      </td>
      <td>
        <xsl:value-of select="@colrm"/>
      </td>
      <td>
        <xsl:value-of select="@colrab"/>
      </td>
      <td>
        <xsl:value-of select="@okved2"/>
      </td>
      <td>
        <xsl:value-of select="@att_colrm"/>
      </td>
      <td>
        <xsl:value-of select="@att_colrm"/>
      </td>
      <td>
        <xsl:value-of select="@att_colrab"/>
      </td>
      <!-- edit flag -->
      <td>
        <xsl:value-of select="@colrm1_2"/>
      </td>
      <td>
        <xsl:value-of select="@colrab1_2"/>
      </td>
      <td>
        <xsl:value-of select="@colrm31"/>
      </td>
      <td>
        <xsl:value-of select="@colrab31"/>
      </td>
      <td>
        <xsl:value-of select="@colrm32"/>
      </td>
      <td>
        <xsl:value-of select="@colrab32"/>
      </td>
      <td>
        <xsl:value-of select="@colrm33"/>
      </td>
      <td>
        <xsl:value-of select="@colrab33"/>
      </td>
      <td>
        <xsl:value-of select="@colrm34"/>
      </td>
      <td>
        <xsl:value-of select="@colrab34"/>
      </td>
      <td>
        <xsl:value-of select="@colrm4"/>
      </td>
      <td>
        <xsl:value-of select="@colrab4"/>
      </td>
      <td></td>
      <td></td>
    </tr>
  </xsl:template>

</xsl:stylesheet>