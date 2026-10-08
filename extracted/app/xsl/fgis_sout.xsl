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
      font-size:12.0pt;
      font-family: Times new roman, serif;
      text-align:left;
      }
      .prim {
      font-size:9.0pt;
      }
      table
      {
      font-size:10.0pt;
      text-align:center;
      }
      table.org
      {
      font-size:10.0pt;
      text-align:left;
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
      td.rotate {
      mso-rotate:90;
      font-size:7.0pt;
      height:80pt;
      }
      table.comission td.sign {
      border-bottom: 1px solid black;
      }
      table.comission td.left {
      text-align:left;
      }
      td.gray {
      background-color: #DDDDDD;
      }
      th.gray {
      background-color: #DDDDDD;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <p class="h1">Протокол решения комиссии СОУТ</p>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="ORG">
    <p>
      <b>1. Реквизиты протокола</b>
    </p>
    <table align="center" width="50%" class="org">
      <tr>
        <td width="25%" class="gray">
          <a name="num_table"></a>№ протокола:
        </td>
        <td align="center" width="25%"></td>
        <td width="25%" class="gray">Дата протокола:</td>
        <td align="center" width="25%"></td>
      </tr>
    </table>
    <p>
      <b>2. Сведения об организации</b>
    </p>
    <table width="100%">
      <tr>
        <th class="gray" width="10%" align="center">
          <a name="org_table"></a>№ строки
        </th>
        <th class="gray" width="30%" align="center">Наименование сведения</th>
        <th class="gray" width="70%" align="center">Значение сведения</th>
      </tr>
      <tr>
        <td class="gray" align="center">01</td>
        <td class="gray">Название организации:</td>
        <td>
          <xsl:value-of select="@name"/>
        </td>
      </tr>
      <tr>
        <td class="gray" align="center">02</td>
        <td class="gray">ИНН организации:</td>
        <td>
          <xsl:value-of select="@inn"/>
        </td>
      </tr>
      <tr>
        <td class="gray" align="center">03</td>
        <td class="gray">ОГРН организации:</td>
        <td>
          <xsl:value-of select="@ogrn"/>
        </td>
      </tr>
      <tr>
        <td class="gray" align="center">04</td>
        <td class="gray">Адрес организации:</td>
        <td>
          <xsl:value-of select="@adr"/>
        </td>
      </tr>
      <tr>
        <td class="gray" align="center">05</td>
        <td class="gray">КПП организации:</td>
        <td>
          <xsl:value-of select="@kpp"/>
        </td>
      </tr>
    </table>
    <p>
      <b>3. Сведения о рабочих местах</b>
    </p>
    <table>
      <tr>
        <th class="gray" align="center" width="5%">
          <a name="rm_table"></a> № п/п
        </th>
        <th class="gray" width="10%">ReportId</th>
        <th class="gray" width="20%">Наименование РМ</th>
        <th class="gray" width="10%">Номер РМ</th>
        <th class="gray" width="10%">Новый номер РМ</th>
        <th class="gray" width="5%">Ликвидация РМ (да/нет)</th>
        <th class="gray" width="20%">Новое наименование РМ (необязательно)</th>
        <th class="gray" width="10%">Код профессии (необязательно)</th>
      </tr>
      <xsl:apply-templates select="RMS/RM"/>
    </table>
    <p class="prim">Примечание: Если графа "Номер РМ" или "Новый номер РМ" не заполнена, тогда рабочее место не выгрузится в XML-отчет. Таким образом, можно использовать выборочную выгрузку РМ.</p>
    <p>
      <b>4. Сведения о комиссии СОУТ</b>
    </p>
    <xsl:apply-templates select="comission"/>
  </xsl:template>
  
  <xsl:template match ="PODR">
    <tr>
      <td colspan="5">
        <xsl:value-of select="@name"/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="RM">
    <tr>
      <td class="gray">
        <xsl:value-of select="count(preceding-sibling::RM)+1"/>
      </td>
      <td class="gray">
        <xsl:value-of select="@ReportId"/>
      </td>
      <td class="gray">
        <xsl:value-of select="@rm_name"/>
      </td>
      <td>
        <xsl:value-of select="@rm_num"/>
      </td>
      <td>
        <xsl:value-of select="@new_rm_num"/>
      </td>
      <td>нет</td>
      <td></td>
      <td></td>
    </tr>
  </xsl:template>

  <xsl:template match ="rab">
    <xsl:value-of select="@fio"/>/<xsl:value-of select="@snils"/>;<br/>
  </xsl:template>
  
  <xsl:template match ="comission">
    <table width="100%">
      <tr>
        <th class="gray">
          <a name="com_table"></a>Роль
        </th>
        <th class="gray">Должность</th>
        <th class="gray">Фамилия</th>
        <th class="gray">Имя</th>
        <th class="gray">Отчество</th>
      </tr>
        <xsl:apply-templates select="member"/>
    </table>
  </xsl:template>
  
  <xsl:template match ="member">
    <tr>
      <td class="gray">
        <xsl:value-of select="@state"/>
      </td>
      <td>
        <xsl:value-of select="@proff"/>
      </td>
      <td>
        <xsl:value-of select="@LastName"/>
      </td>
      <td>
        <xsl:value-of select="@FirstName"/>
      </td>
      <td>
        <xsl:value-of select="@MiddleName"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>