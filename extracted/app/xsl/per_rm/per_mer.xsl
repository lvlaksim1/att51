<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Перечень рабочих мест</title>
    <style>
      /* Style Definitions */
      table
      {
      font-size:8.0pt;
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
      font-size:7.0pt;
      height:80pt;
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
        <td>Наименование структурного подразделения, рабочего места</td>
        <td>Наименование мероприятия</td>
        <td>Цель мероприятия</td>
        <td>Срок выполнения</td>
        <td>Структурные подразделения, привлекаемые для выполнения</td>
        <td>Отметка о выполнении</td>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>
  
  <xsl:template match ="rm">
    <tr>
      <td>
        <xsl:value-of select="@name"/>
        <xsl:if test="@adr!=''">
          (<xsl:value-of select="@adr"/>)
        </xsl:if>
      </td>
      <td align="left">
        <xsl:value-of select="@measure"/>
      </td>
      <td align="left">
        <xsl:value-of select="@measure2"/>
      </td>
      <td>
        <xsl:value-of select="@srok_date"/>
      </td>
      <td>
        <xsl:value-of select="@service"/>
      </td>
      <td></td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="podr">
    <xsl:if test="@is_recs='true'">
      <tr>
        <td colspan="6">
          <xsl:value-of select="@name"/>
          <xsl:if test="@adr!=''">
            (<xsl:value-of select="@adr"/>)
          </xsl:if>
        </td>
      </tr>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>


</xsl:stylesheet>