<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->

  <xsl:template match ="/">

    <html>
      <head>
        <title>Сводное заключение по результатам идентификации</title>
        <style>
          /* Style Definitions */
          table
          {
          font-size:10.0pt;
          font-family:Times new roman, arial, verdana, sans-serif;
          text-align:center;
          font-style:italic;
          }
          table,th,td {
          border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
          }
          th {
          font-size:11.0pt;
          }
          td.gray {
          background-color: #EAEAEA;
          text-align:left;
          }
          td.gray2 {
          background-color: #EAEAEA;
          text-align:center;
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
        </style>
      </head>
      <body>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match ="Document">
    <div align="center">
      <table width="100%">
        <tr>
          <th width="10%">№ п/п</th>
          <th width="70%">Номер рабочего места по Перечню, наименование должности</th>
          <th width="20%">Наличие аналогичного РМ</th>
        </tr>
        <xsl:apply-templates/>
        <xsl:if test="@no_data=1">
          <tr>
            <td align="center">-</td>
            <td align="center">-</td>
            <td align="center">-</td>
          </tr>
        </xsl:if>
      </table>
    </div>
  </xsl:template>

  <xsl:template match ="podr_disabled">
    <tr>
      <td colspan="8">
        <xsl:value-of select="@name"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="rm">
    <tr>
      <!--xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute-->
      <td>
        <xsl:value-of select="count(preceding-sibling::rm)+1"/>.
      </td>
      <td class="gray">
        <xsl:value-of select="@rm_num"/>.
        <xsl:value-of select="@rm_name"/>
      </td>
      <td class="gray2">
        <xsl:value-of select="@anal_rms"/>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>