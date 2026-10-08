<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения о рабочих местах</title>
    <style>
      /* Style Definitions */
      body {
      font-family:"Arial";
      }
      .prim
      {
      font-size:10.0pt;
      }
      table
      {
      font-size:10.0pt;
      font-family:"Times New Roman";
      text-align:center;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
      }
      td.gray {
      background-color: #DDDDDD;
      }
      td.gray2 {
      background-color: #DDDDDD;
      color: #777777;
      }
      .red {
      color: #ff0000;
      }

    </style>	
  </head>
	<body>
    <h1>Сведения о факторах</h1>
    <p>
    <b>Порядок заполнения ведомости:</b><br/>
    <span class="prim">
      Для каждого рабочего места определена отдельная таблица со сведениями. Допускается редактирование только сведений в ячейках с белым фоном.
      Сведения, введенные в данную ведомость, попадают в раздел для сведений о факторах и рабочих зонах (кнопка "Ф" – Добавить рабочую зону – вкладка "Условия измерения").
    </span>
  </p>    
    <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="podr">
    <p>
      <b><xsl:value-of select="@name"/></b>
    </p>
  </xsl:template>
  
  <xsl:template match ="rm">
    <p>
      <xsl:value-of select="@rm_code"/>. <xsl:value-of select="@rm_name"/>
    </p>
    <xsl:apply-templates select="zones"/>
    <xsl:apply-templates select="no_zones"/>
  </xsl:template>

  <xsl:template match="zones">
    <table>
      <tr>
        <td class="gray">ID зоны</td>
        <td class="gray">Рабочая зона</td>
        <td class="gray">Температура воздуха, ºС</td>
        <td class="gray">Скорость воздуха, м/с</td>
        <td class="gray">Относительная влажность, %</td>
        <td class="gray">Атмосферное давление, ед.изм.</td>
      </tr>
      <xsl:apply-templates select="zone"/>
    </table>
  </xsl:template>

  <xsl:template match="zone">
    <tr>
      <td class="gray2">
        <xsl:value-of select="@zona_id"/>
      </td>
      <td class="gray2">
        <xsl:value-of select="@zona_name"/>
      </td>
      <td>
        <xsl:value-of select="@os_temp"/>
      </td>
      <td>
        <xsl:value-of select="@os_skor"/>
      </td>
      <td>
        <xsl:value-of select="@os_vlag"/>
      </td>
      <td>
        <xsl:value-of select="@os_patm"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="no_zones">
    <p class="red">
      Рабочие зоны не определены!
    </p>
  </xsl:template>
  
</xsl:stylesheet>