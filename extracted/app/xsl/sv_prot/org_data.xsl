<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип предписания -->
  
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
      tr.src {
      font-weight: bold;
      text-align: left;
      }
      tr.zone {
      font-style:italic;
      }
      tr.param {
      font-size:9.0pt;
      }
      table.empty
      {
      margin-bottom:0cm;
      margin-top:0cm;
      }

      table.empty,table.empty th,table.empty td
      {
      font-size:12.0pt;
      text-align:left;
      border:none;
      background:none;
      padding:0 5px 0 5px;
      vertical-align: top;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="ORG">
    <table class="empty" width="100%" align="center">
      <tr>
        <td width="40%">1. Заказчик:</td>
        <td width="60%">
          <xsl:value-of select="@name"/>
        </td>
      </tr>
      <tr>
        <td>
          2. Адрес места нахождения Заказчика:
        </td>
        <td>
          <xsl:value-of select="@adr"/>
        </td>
      </tr>
      <tr>
        <td>
          3. Контакты (телефон, Е-mail):
        </td>
        <td>
          <xsl:value-of select="@phone"/>, <xsl:value-of select="@email"/>
        </td>
      </tr>
      <tr>
        <td>4. Адрес места осуществления деятельности Заказчика:</td>
        <td>
          <xsl:value-of select="@adr2"/>
        </td>
      </tr>
      <tr>
        <td>5. ИНН Заказчика:</td>
        <td>
          <xsl:value-of select="@inn"/>
        </td>
      </tr>
      <tr>
        <td>6. Договор/заявка (№, дата):</td>
        <td>
          <xsl:value-of select="@N_dog"/> от <xsl:value-of select="@D_dog"/>
        </td>
      </tr>
      <tr>
        <td>7. Наименование производственного объекта:</td>
        <td>
          <xsl:value-of select="@name"/>
        </td>
      </tr>
      <tr>
        <td>
          8. Адрес производственного объекта (проведения испытаний/отбора проб):
        </td>
        <td>
          <xsl:value-of select="@adr3"/>
          <xsl:if test="@adr3=''">
            <xsl:value-of select="@adr2"/>
          </xsl:if>
        </td>
      </tr>
      <tr>
        <td>
          9. Цель испытаний:
        </td>
        <td>
          специальная оценка условий труда
        </td>
      </tr>
      <tr>
        <td>
          10. Наименование объекта испытаний:
        </td>
        <td>
          рабочие места
        </td>
      </tr>
    </table>
  </xsl:template>

</xsl:stylesheet>