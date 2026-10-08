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
    <h1>Сведения о факторах</h1>
    <p>
    <b>Порядок заполнения ведомости:</b><br/>
    <span class="prim">
    Для каждого рабочего места определена отдельная таблица со сведениями. Допускается редактирование только сведений в ячейках с белым фоном.
    Для ввода сведений о наличии факторов трудового процесса и/или факторов травмоопасности и СИЗ используется <b>символ "+"</b>.
    В первой ячейке каждой таблицы находится уникальный идентификатор рабочего места, редактировать его категорически запрещено. 
    Новые рабочие зоны вводятся за счет добавления строк в конце таблицы. Чтобы добавить время для санитарно-гигиенических факторов допускается ввод значка "+" или конкретное время воздействия вредного фактора (в процентах).<br/>
    Сокращения используемые в отчете приведены в конце документа.
    </span>
  </p>    
    <xsl:apply-templates/>
    <p>
      <b>Используемые сокращения:</b>
      <br/>
      <span class="prim">
      ХИМ - Химический;	БИО - Биологический; АПФД - Аэрозоли ПФД; ИНФР - инфразвук;	УЗ - Ультразвук; ВиО - Вибрация общая; ВиЛ - Вибрация локальная;
      ЭМП - Электромагнитные поля; РАД - ионизирующее излучение;	МИКР - микроклимат;	ОСВ - освещение; УФИ = ультрафиолетовое излучение; ЛИ - лазерное излучение.
      </span>
    </p>
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
    <table width="100%">
      <tr>
        <td class="gray2" colspan="2">
          <xsl:value-of select="@rm_guid"/>
        </td>
        <td class="gray" colspan="3" align="right">Кол-во работников:</td>
        <td>
          <xsl:value-of select="@co_rab"/>
        </td>
        <td class="gray" colspan="2" align="right">- из них женщин:</td>
        <td>
          <xsl:value-of select="@co_wom"/>
        </td>
        <td class="gray" colspan="3" align="right">- лиц моложе 18:</td>
        <td>
          <xsl:value-of select="@co_18"/>
        </td>
        <td class="gray" colspan="2" align="right">- инвалидов:</td>
        <td>
          <xsl:value-of select="@co_inv"/>
        </td>
      </tr>
      <tr>
        <td class="gray" align="right">Время смены, мин:</td>
        <td>
          <xsl:value-of select="@timesmena"/>
        </td>
        <td class="gray" colspan="4">Факторы трудового процесса (+/-):</td>
        <td class="gray" align="right">ТЯЖ:</td>
        <td>
          <xsl:value-of select="@f13"/>
        </td>
        <td class="gray" align="right">НАПР:</td>
        <td>
          <xsl:value-of select="@f14"/>
        </td>
         <td class="gray" colspan="3" align="right">Травмоопасность:</td>
        <td>
          <xsl:value-of select="@f15"/>
        </td>
        <td class="gray" align="right">СИЗ:</td>
        <td>
          <xsl:value-of select="@f16"/>
        </td>
      </tr>
      <tr>
        <td class="gray" colspan="16">Санитарно-гигиенические факторы (по рабочим зонам):</td>
      </tr>
      <tr>
        <td class="gray">Наименование рабочей зоны</td>
        <td class="gray">Время, %</td>
        <td class="gray">ХИМ</td>
        <td class="gray">БИО</td>
        <td class="gray">АПФД</td>
        <td class="gray">ШУМ</td>
        <td class="gray">ИНФР</td>
        <td class="gray">УЗ</td>
        <td class="gray">ВиО</td>
        <td class="gray">ВиЛ</td>
        <td class="gray">ЭМП</td>
        <td class="gray">РАД</td>
        <td class="gray">МИКР</td>
        <td class="gray">ОСВ</td>
        <td class="gray">УФИ</td>
        <td class="gray">ЛИ</td>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match ="zone">
    <tr>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
      <td>
        <xsl:value-of select="@him"/>
      </td>
      <td>
        <xsl:value-of select="@bio"/>
      </td>
      <td>
        <xsl:value-of select="@apfd"/>
      </td>
      <td>
        <xsl:value-of select="@shum"/>
      </td>
      <td>
        <xsl:value-of select="@infr"/>
      </td>
      <td>
        <xsl:value-of select="@uzi"/>
      </td>
      <td>
        <xsl:value-of select="@vibr_o"/>
      </td>
      <td>
        <xsl:value-of select="@vibr_l"/>
      </td>
      <td>
        <xsl:value-of select="@emp"/>
      </td>
      <td>
        <xsl:value-of select="@rad"/>
      </td>
      <td>
        <xsl:value-of select="@micro"/>
      </td>
      <td>
        <xsl:value-of select="@osv"/>
      </td>
      <td>
        <xsl:value-of select="@ufi"/>
      </td>
      <td>
        <xsl:value-of select="@lazer"/>
      </td>
    </tr>
    
  </xsl:template>

</xsl:stylesheet>