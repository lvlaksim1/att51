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

    </style>	
  </head>
	<body>
    <h1>Импорт сведений для перечня опасностей (используются для оценки риска)</h1>
    <p>
    <b>Порядок заполнения перечня опасностей:</b><br/>
    <span class="prim">Допускается редактирование только сведений в ячейках с белым фоном.
    В первой ячейке каждой таблицы находится уникальный идентификатор рабочего места, редактировать его категорически запрещено.
    Для каждой новой опасность добавить дополнительную строку в таблицу.
    </span>
  </p>    
    <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <xsl:apply-templates select="rm"/>
  </xsl:template>

  <xsl:template match ="podr">
    <p>
      <b><xsl:value-of select="@name"/></b>
    </p>
  </xsl:template>
  
  <xsl:template match ="rm">
    <p>
      <b><xsl:value-of select="@rm_code"/>. <xsl:value-of select="@rm_name"/></b>
    </p>
    <table width="100%">
      <tr>
        <td class="gray" colspan="3">
          Уникальный идентификатор РМ:
        </td>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>
        </td>
      </tr>
      <tr>
        <td width="5%" class="gray">№<br/>п/п</td>
        <td width="30%" class="gray">Опасность</td>
        <td width="20%" class="gray">Опасное событие (последствие)</td>
        <td width="15%" class="gray">Объект (место выполнения работы)</td>
        <td width="30%" class="gray">Выполняемая работа (операция)</td>
      </tr>
      <xsl:apply-templates select="danger"/>
    </table>
  </xsl:template>


  <xsl:template match ="danger">
    <tr>
      <td>
        <xsl:value-of select="@num"/>
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@event"/>
      </td>
      <td>
        <xsl:value-of select="@object"/>
      </td>
      <td>
        <xsl:value-of select="@work"/>
      </td>
    </tr>
  </xsl:template>  
  
  
</xsl:stylesheet>
