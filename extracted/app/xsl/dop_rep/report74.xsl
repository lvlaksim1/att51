<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Опись документов по СОУТ</title>
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
      table,th,td {
        border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
      td.center {
      text-align:center;
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

      table.empty
      {
      margin-bottom:0cm;
      margin-top:0cm;
      }

      table.empty,table.empty th,table.empty td
      {
      font-size:9.0pt;
      text-align:center;
      border:none;
      background:none;
      padding:0 5px 0 5px;
      }
      table.empty td.sign {
      border-bottom: 1px solid black;
      }
      table.empty td.align_left {
      text-align:left;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <p class="h1">Опись документов по СОУТ</p>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="ORG">
    <table width="100%" class="empty">
      <tr>
        <td align="center" class="sign">
          <xsl:value-of select="@name"/>
        </td>
      </tr>
      <tr>
        <td>
          <sup>(наименование организации)</sup>
        </td>
      </tr>
    </table>
    <!-- Задаем последовательность вывода отчетов -->
    <table width="100%">
      <tr>
        <td align="center" width="5%">№ п/п<a name="renum_rows2"></a>
      </td>
        <td align="center" width="80%">Документ</td>
        <td align="center" width="10%">
          Кол-во страниц<a name="pages_col"></a>
        </td>
      </tr>
      
      <!-- СВОДНЫЕ ДОКУМЕНТЫ -->
      <!-- Титульный лист -->
      <xsl:apply-templates select="doc" mode="sv">
        <xsl:with-param name="doc_type">8</xsl:with-param>
      </xsl:apply-templates>
      <!-- Перечень РМ -->
      <xsl:apply-templates select="doc" mode="sv">
        <xsl:with-param name="doc_type">4</xsl:with-param>
      </xsl:apply-templates>
      <!-- Сводное заключение -->
      <xsl:apply-templates select="doc" mode="sv">
        <xsl:with-param name="doc_type">1</xsl:with-param>
      </xsl:apply-templates>
      <!-- Сводная ведомость -->
      <xsl:apply-templates select="doc" mode="sv">
        <xsl:with-param name="doc_type">5</xsl:with-param>
      </xsl:apply-templates>
      <!-- Сведения об организации -->
      <xsl:apply-templates select="doc" mode="sv">
        <xsl:with-param name="doc_type">7</xsl:with-param>
      </xsl:apply-templates>
      <!-- Сводный протокол -->
      <xsl:apply-templates select="doc" mode="sv">
        <xsl:with-param name="doc_type">3</xsl:with-param>
      </xsl:apply-templates>

      <!-- ДОКУМЕНТЫ ДЛЯ РАБОЧИХ МЕСТ -->
      <!-- Карта СОУТ -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">20</xsl:with-param>
      </xsl:apply-templates>
      <!-- Химический -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">1</xsl:with-param>
      </xsl:apply-templates>
      <!-- Биологический -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">2</xsl:with-param>
      </xsl:apply-templates>
      <!-- Аэрозоли ПФД -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">3</xsl:with-param>
      </xsl:apply-templates>
      <!-- Шум -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">4</xsl:with-param>
      </xsl:apply-templates>
      <!-- Инфразвук -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">5</xsl:with-param>
      </xsl:apply-templates>
      <!-- Ультразвук -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">6</xsl:with-param>
      </xsl:apply-templates>
      <!-- Вибрация общая -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">7</xsl:with-param>
      </xsl:apply-templates>
      <!-- Вибрация локальная -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">8</xsl:with-param>
      </xsl:apply-templates>
      <!-- ЭМП -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">9</xsl:with-param>
      </xsl:apply-templates>
      <!-- ЭМП_ПК -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">10009</xsl:with-param>
      </xsl:apply-templates>
      <!-- УФ -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">26</xsl:with-param>
      </xsl:apply-templates>
      <!-- ЛИ -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">41</xsl:with-param>
      </xsl:apply-templates>
      <!-- ИИ -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">10</xsl:with-param>
      </xsl:apply-templates>
      <!-- Микроклимат -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">11</xsl:with-param>
      </xsl:apply-templates>
      <!-- Освещение -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">12</xsl:with-param>
      </xsl:apply-templates>
      <!-- Тяжесть -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">13</xsl:with-param>
      </xsl:apply-templates>
      <!-- Напряженность -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">14</xsl:with-param>
      </xsl:apply-templates>
      <!-- Приказ 96н -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">1096</xsl:with-param>
      </xsl:apply-templates>
      <!-- Приказ 102н -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">1102</xsl:with-param>
      </xsl:apply-templates>
      <!-- Заключение эксперта -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">101</xsl:with-param>
      </xsl:apply-templates>
      <!-- Хронометраж -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">105</xsl:with-param>
      </xsl:apply-templates>
      <!-- Профриск -->
      <xsl:apply-templates select="RM/doc" mode="rm">
        <xsl:with-param name="fac_id">11102</xsl:with-param>
      </xsl:apply-templates>
    </table>
  </xsl:template>

  <xsl:template match ="doc" mode="sv">
    <xsl:param name="doc_type"></xsl:param>
    <xsl:if test="@doc_type=$doc_type">
      <tr>
        <td align="center"></td>
        <td align="left">
          <xsl:choose>
            <xsl:when test="@doc_type=4">
              Перечень рабочих мест
            </xsl:when>
            <xsl:when test="@doc_type=3">
              Сводный протокол №<xsl:value-of select="@num_doc"/>, дата оформления: <xsl:value-of select="@date_doc"/>
            </xsl:when>
            <xsl:when test="@doc_type=1">
              <xsl:choose>
                <xsl:when test="contains(@name,'инд')">
                  Заключение эксперта о проведении идентификации потенциально вредных и (или) опасных производственных факторов №	<xsl:value-of select="@num_doc"/>
                </xsl:when>
                <xsl:otherwise>
                  Заключение эксперта по результатам специальной оценки условий труда №	<xsl:value-of select="@num_doc"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@name"/>
            </xsl:otherwise>
          </xsl:choose>
          <!-- prot_id -->
          <xsl:if test="@docx_file">
            <a>
              <xsl:attribute name="name">
                <xsl:value-of select="@prot_id"/>
              </xsl:attribute>
            </a>
          </xsl:if>

        </td>
        <td align="center"></td>
      </tr>
      
    </xsl:if>
  </xsl:template>
  
  <xsl:template match ="doc" mode="rm">
    <xsl:param name="fac_id"></xsl:param>
    <xsl:if test="@factor_id=$fac_id">
      <xsl:variable name="doc_date" >
        <xsl:choose>
          <xsl:when test="@sign_date!=''">, дата выдачи: <xsl:value-of select="@sign_date"/></xsl:when>
          <xsl:when test="@fill_date!=''">, дата оформления: <xsl:value-of select="@fill_date"/></xsl:when>
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <tr>
        <td align="center"></td>
        <td align="left">
          <xsl:choose>
            <xsl:when test="@factor_id=20">
              Карта СОУТ № <xsl:value-of select="@num_doc"/>, дата оформления: <xsl:value-of select="@fill_date"/>
            </xsl:when>
            <xsl:otherwise>
              Протокол № <xsl:value-of select="@num_doc"/> (<xsl:value-of select="@factor_name"/>)<xsl:value-of select="$doc_date"/>
            </xsl:otherwise>
          </xsl:choose>
          <!-- prot_id -->
          <xsl:if test="@docx_file">
            <a>
              <xsl:attribute name="name">
                <xsl:value-of select="@prot_id"/>
              </xsl:attribute>
            </a>
          </xsl:if>
          
        </td>
        <td align="center"></td>
      </tr>
      
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>