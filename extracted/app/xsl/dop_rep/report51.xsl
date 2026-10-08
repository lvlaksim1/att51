<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сводная таблица по компенсациям за вредные условия труда</title>
    <style>
      /* Style Definitions */
      body
      {
      font-size:10.0pt;
      font-family: Times new roman, serif;
      text-align:left;
      }
      .h1 {
      font-weight:bold;
      font-size:14.0pt;
      text-align:center;
      }

      p.org_name {
      font-size:12.0pt;
      font-weight:bold;
      text-align:center;
      margin-bottom:0pt;
      }

      p.org_sign {
      border-top: 1px solid black;
      text-align:center;
      margin-top:0pt;
      }

      .header {
      font-size:12.0pt;
      text-align:center;
      margin-left:200pt;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      font-size:9.0pt;
      }
      td.center {
      text-align:center;
      }
      .factor {
      font-size:9.0pt;
      }
      tr.param p {
      text-align:left;
      }
      tr.zone {
      font-style:italic;
      }
      td.sign {
      height:30pt;
      text-align:center;
      }

      td.red {
      background-color: #FFAAAA;
      }

      table.comission,table.comission th,table.comission td
      {
      font-size:10.0pt;
      text-align:center;
      border:none;
      background:none;
      padding:0 5px 0 5px;
      }
      table.comission td.sign {
      border-bottom: 1px solid black;
      }
      table.comission td.sign2 {
      border-bottom: 1px solid black;
      text-align:right;
      margin-top:7pt;
      }
      table.comission td.sign3 {
      border-bottom: 1px solid black;
      text-align:center;
      margin-top:5pt;
      }
      table.comission td.left {
      text-align:left;
      }
      table.comission td.italic {
      font-size:8.0pt;
      font-style:italic;
      text-align:center;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
     <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="ORG">

  <p class="h1">
    Сводная таблица по компенсациям за вредные условия труда
  </p>
    <p class="org_name"><xsl:value-of select="@name"/></p>
    <p class="org_sign">(наименование организации)</p>
    

    <table>
      <tr>
        <td rowspan="3" class="center" width="3%">№ п/п</td>
        <td rowspan="3" class="center" width="11%">Номер РМ</td>
        <td rowspan="3" class="center" width="20%">Наименование подразделения, рабочего места</td>
        <td colspan="12" class="center" width="66%">Гарантии и компенсации, предоставляемые работнику (работникам).  В графе «ФАКТ» указывается дробное значение: в числителе – фактическое наличие (да/нет), в знаменателе – необходимость по результатам  СОУТ (да/нет)</td>
      </tr>
      <tr>
        <td colspan="2" class="center">Повышенный размер оплаты труда (%)</td>
        <td colspan="2" class="center">Ежегодный дополнительный оплачиваемый отпуск</td>
        <td colspan="2" class="center">Сокращенная продолжительность рабочего времени</td>
        <td colspan="2" class="center">Молоко или другие равноценные пищевые продукты</td>
        <td colspan="2" class="center">Лечебно-профилактическое питание</td>
        <td colspan="2" class="center">Льготное пенсионное обеспечение</td>
      </tr>
      <tr>
        <td width="3%" class="center">ФАКТ</td>
        <td width="8%" class="center">Основание</td>
        <td width="3%" class="center">ФАКТ</td>
        <td width="8%" class="center">Основание</td>
        <td width="3%" class="center">ФАКТ</td>
        <td width="8%" class="center">Основание</td>
        <td width="3%" class="center">ФАКТ</td>
        <td width="8%" class="center">Основание</td>
        <td width="3%" class="center">ФАКТ</td>
        <td width="8%" class="center">Основание</td>
        <td width="3%" class="center">ФАКТ</td>
        <td width="8%" class="center">Основание</td>
      </tr>
      <xsl:apply-templates select="PODR|RM"/>
    </table>
    
    <p>
      Примечание: цветом выделены ячейки, в которых имеется расхождение меду фактическим наличием компенсации и необходимостью по результатам  СОУТ.
    </p>
    <!-->xsl:apply-templates select="comission"/-->
    </xsl:template>
  
  
  <xsl:template match ="RM">
    <xsl:variable name="RowSpan" select="count(factor)"/>
    <tr>
      <td align="center">
        <xsl:value-of select="count(preceding-sibling::RM)+1"/>
      </td>
      <td align="center">
        <xsl:value-of select="@num"/>
      </td>
      <td align="center">
        <xsl:value-of select="@name"/>
      </td>
       <td align="center">
         <xsl:attribute name="class">
           <xsl:value-of select="@dopl_class"/>
         </xsl:attribute>      
        <xsl:value-of select="@dopl"/>/<xsl:value-of select="@dopl_norm"/>
       </td>
       <td align="center">
        <xsl:value-of select="@dopl_osn"/>
      </td>
       <td align="center">
         <xsl:attribute name="class">
           <xsl:value-of select="@dop_otpusk_class"/>
         </xsl:attribute>
        <xsl:value-of select="@dop_otpusk"/>/<xsl:value-of select="@dop_otpusk_norm"/>
       </td>
       <td align="center">
        <xsl:value-of select="@dop_otpusk_osn"/>
      </td>
      <td align="center">
        <xsl:attribute name="class">
          <xsl:value-of select="@week_class"/>
        </xsl:attribute>
        <xsl:value-of select="@week"/>/<xsl:value-of select="@week_norm"/>
      </td>
      <td align="center">
        <xsl:value-of select="@week_osn"/>
      </td>
      <td align="center">
        <xsl:attribute name="class">
          <xsl:value-of select="@milk_class"/>
        </xsl:attribute>
        <xsl:value-of select="@milk"/>/<xsl:value-of select="@milk_norm"/>
      </td>
      <td align="center">
        <xsl:value-of select="@milk_osn"/>
      </td>
      <td align="center">
        <xsl:attribute name="class">
          <xsl:value-of select="@profpit_class"/>
        </xsl:attribute>
        <xsl:value-of select="@profpit"/>/<xsl:value-of select="@profpit_norm"/>
      </td>
      <td align="center">
        <xsl:value-of select="@profpit_osn"/>
      </td>
      <td align="center">
        <xsl:attribute name="class">
          <xsl:value-of select="@lpo_class"/>
        </xsl:attribute>
        <xsl:value-of select="@lpo"/>/<xsl:value-of select="@lpo_norm"/>
      </td>
      <td align="center">
        <xsl:value-of select="@lpo_osn"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="PODR">
    <tr>
      <td align="center" colspan="15">
        <b>
          <xsl:value-of select="@name"/>
        </b>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="comission">
    <table class="comission">
      <xsl:apply-templates select="member"/>
    </table>
  </xsl:template>

  <xsl:template match ="member">
    <xsl:variable name="iRow" select="count(preceding-sibling::member)+1"/>
    <xsl:if test="$iRow='1'">
      <tr>
        <td class="left"  colspan="7">Председатель комиссии по проведению специальной оценки условий труда:</td>
      </tr>
    </xsl:if>
    <xsl:if test="$iRow='2'">
      <tr>
        <td class="left" colspan="7">Члены комиссии по проведению специальной оценки условий труда:</td>
      </tr>
    </xsl:if>
    <tr>
      <td class="sign3" width="20%">
        <xsl:value-of select="@proff"/>
      </td>
      <td width="3%"></td>
      <td class="sign3" width="20%"></td>
      <td width="3%"></td>
      <td class="sign3" width="20%">
        <xsl:value-of select="@fio"/>
      </td>
      <td width="3%"></td>
      <td class="sign3" width="20%"></td>
    </tr>
    <tr>
      <td width="20%">
        <sup>(должность)</sup>
      </td>
      <td width="3%"></td>
      <td width="20%">
        <sup>(подпись)</sup>
      </td>
      <td width="3%"></td>
      <td width="20%">
        <sup>Ф.И.О.</sup>
      </td>
      <td width="3%"></td>
      <td width="20%">
        <sup>(дата)</sup>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>