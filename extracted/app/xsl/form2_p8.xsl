<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем константы -->

  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения об организации</title>
    <style>
      /* Style Definitions */
      table
      {
      font-size:10.0pt;
      font-family:Times new roman;
      text-align:center;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
      th {
      background-color: #EAEAEA;
      }
      tr.font9 {
      font-size:9.0pt;
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
      td.error {
      background-color: #FF0000;
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
      <tr class="font9">
        <td width="5%">№ п/п</td>
        <td width="10%">Дата проведения измерений</td>
        <td width="20%">Наименование вредного и (или) опасного фактора производственной среды и трудового процесса</td>
        <td width="25%">Наименование средства измерений</td>
        <td width="15%">Регистрационный номер в Государственном реестре средств измерений</td>
        <td width="10%">Заводской номер средства измерений</td>
        <td width="15%">Дата окончания срока поверки средства измерений</td>
      </tr>
      <tr>
        <td>1</td>
        <td>2</td>
        <td>3</td>
        <td>4</td>
        <td>5</td>
        <td>6</td>
        <td>7</td>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="factor">

    <xsl:variable name="factors" select="@fac_id"/>
    
    <xsl:variable name="factor_const">
      <xsl:choose>
        <xsl:when test="$factors='1'">Химический фактор</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='2'">Биологический фактор</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='3'">Аэрозоли преимущественно фиброгенного действия</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='4'">Шум</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='5'">Инфразвук</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='6'">Ультразвук</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='7'">Вибрация общая</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='8'">Вибрация локальная</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='9_1'">Переменное электромагнитное поле (промышленная частота 50 Гц)</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='9_2'">Постоянное магнитное поле</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='9_3'">Электростатическое поле</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='9_4'">Переменное электромагнитное поле радиочастотного диапазона</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='10'">Ионизирующие излучения</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='11'">Микроклимат</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='12'">Световая среда</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='13'">Тяжесть трудового процесса</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='14'">Напряженность трудового процесса</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='26'">Ультрафиолетовое излучение</xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$factors='41'">Лазерное излучение</xsl:when>
      </xsl:choose>
    </xsl:variable>
    
    <tr>
      <td>
        <xsl:value-of select="@num_pp"/>
      </td>
      <td>
        <xsl:value-of select="@izm_date"/>
      </td>
      <td>
        <xsl:value-of select="$factor_const"/>
      </td>
      <td>
        <xsl:value-of select="@si_name"/>
        <xsl:if test="@si_flag='1'" >
          <br/>МЕТЕОУСЛОВИЯ
        </xsl:if>
        <xsl:if test="@si_flag='2'" >
          <br/>ДОП.ОБОРУДОВАНИЕ
        </xsl:if>
      </td>
      <td>
        <xsl:value-of select="@reg_num"/>
      </td>
      <td>
        <xsl:value-of select="@factory_num"/>
      </td>
      <td>
        <xsl:attribute name="class">
          <xsl:value-of select="@class"/>
        </xsl:attribute>
        <xsl:value-of select="@end_date"/>
      </td>
    </tr>
  </xsl:template>
  
  

</xsl:stylesheet>