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
        <td rowspan="2">№ п/п</td>
        <td rowspan="2">Дата проведения измерений</td>
        <td rowspan="2">Ф.И.О. эксперта (работника)</td>
        <td rowspan="2">Должность</td>
        <td colspan="2">Сведения о сертификате эксперта на право выполнения работ по специальной оценке условий труда</td>
        <td rowspan="2">Регистрационный номер в реестре экспертов организаций, проводящих специальную оценку условий труда</td>
      </tr>
      <tr>
        <td>номер</td>
        <td>дата выдачи</td>
      </tr>
      <tr>
        <td width="5%">1</td>
        <td width="15%">2</td>
        <td width="20%">3</td>
        <td width="15%">4</td>
        <td width="15%">5</td>
        <td width="15%">6</td>
        <td width="15%">7</td>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="row">
    
    <tr>
      <td>
        <xsl:value-of select="@num_pp"/>
      </td>
      <td>
        <xsl:value-of select="@izm_date"/>
      </td>
      <td>
        <xsl:value-of select="@fio"/>
      </td>
      <td>
        <xsl:value-of select="@dolg"/>
      </td>
      <td>
        <xsl:value-of select="@sertif"/>
      </td>
      <td>
        <xsl:value-of select="@sertif_date"/>
      </td>
      <td>
        <xsl:value-of select="@expert_num"/>
      </td>
    </tr>
  </xsl:template>
  
  

</xsl:stylesheet>