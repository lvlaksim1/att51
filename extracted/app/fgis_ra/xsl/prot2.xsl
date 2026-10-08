<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения о протоколах для ФГИС РА</title>
    <style>
      /* Style Definitions */
      body {
      font-family:"Arial";
      }
      .prim
      {
      font-size:9.0pt;
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
      .gray {
      color: #777777;
      }
      td.gray2 {
      background-color: #DDDDDD;
      color: #777777;
      }
      .hr-line {
      margin: 20px 0;
      padding: 0;
      height: 0;
      border: none;
      border-top: 1px solid #333;
      }
    </style>	
  </head>
	<body>
    <h1>Сведения о протоколах, содержащихся в файле экспорта для ФГИС РА</h1>
    <p class="prim">
      Сведения, указанные серым цветом шрифта не передаются в систему ФГИС РА. Данные сведения указаны только для пояснения.
      Отправка сведений в ФГИС РА производится на основе ссылочного принципа: передается только идентификатор (ссылка) на передаваемое сведение. 
      В связи с этим, важно установить точное соответствие между идентификаторами оборудования и работников в ФГИС РА и справочником ресурсов А-5.1.
    </p>
    <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match ="protocol">
    <p>
      Номер протокола: <b><xsl:value-of select="@DocId"/></b>
    </p>
    <p>
      Дата протокола: <b><xsl:value-of select="@DocCreationDate"/></b>
      <br/>
      Дата начала/окончания измерения: <b><xsl:value-of select="@DocStartDate"/> / <xsl:value-of select="@DocValidityDate"/></b>
      <br/>
      Дата начала/окончания измерения: <b><xsl:value-of select="@DocStartDate"/> / <xsl:value-of select="@DocValidityDate"/></b>
    </p>
    <p>
      Идентификатор статуса данных протокола (13 - Отправлен; 20 - Черновик): <b><xsl:value-of select="@DataStatusId"/></b>
      <br/>
      Идентификатор статуса протокола (6 - Действует): <b><xsl:value-of select="@ProtocolStatusId"/></b>
    </p>
    <xsl:if test="@ProtocolScan!=''">
      <p>
        Внедрен скан протокола: 
        <b><xsl:value-of select="@ProtocolScan"/></b>
      </p>
    </xsl:if>
    <p>
      <xsl:apply-templates select="Address"/>
    </p>
    <p>
      Дата подачи заявления (заявки): <b><xsl:value-of select="@ApplicationDate"/></b>
    </p>
    <p>
      Заказчик: 
      <b>
        {<xsl:value-of select="@CustomerKindId"/>}
        <span class="gray"> <xsl:value-of select="@org_type"/> </span> 
        <xsl:value-of select="@org"/>
      </b>
      <xsl:apply-templates select="CustomerAddress"/>
    </p>
    <!--Указание сведений об оборудовании, использованном при проведении испытаний (исследований), измерений не предусмотрено-->
    <xsl:if test="@NoEquipmentInfo='true'">
      <p>
        Указание сведений об оборудовании не предусмотрено.
      </p>
    </xsl:if>
    <xsl:if test="@Equipment">
      <p>
        Сведения об оборудовании: 
        <xsl:apply-templates select="si"/>
      </p>
    </xsl:if>
    <xsl:if test="@ApprovedUser">
      <p>
        Сведения о лицах, указанных в протоколе:
        <xsl:apply-templates select="pers"/>
      </p>
    </xsl:if>
    <p>
      Сведения об объекте измерения: 
      <b>
        {<xsl:value-of select="@TypeObjectId"/>} <span class="gray"><xsl:value-of select="@TypeObjectName"/></span> - <xsl:value-of select="@FullNameObject"/>
      </b>
    </p>
    <xsl:if test="@MethodDocId">
      <p>
        Сведения о НД, устанавливающим требования к объекту (идентификатор НД в системе ФГИС РА):
        <b><xsl:apply-templates select="@MethodDocId"/></b>
      </p>
    </xsl:if>
    <p>
      Наличие сведений об образце отобранном испытательной лабораторией:
      <b>
        <xsl:if test="@IsLab='false'">
          отсутствуют
        </xsl:if>
        <xsl:if test="@IsLab='true'">
          имеются
        </xsl:if>
      </b>
    </p>
    <xsl:apply-templates select="AnotherDoc"/>
    <xsl:if test="@DocNameId">
      <p>
        Сведения о методе измерения (идентификатор НД в системе ФГИС РА):
        <b><xsl:apply-templates select="@DocNameId"/></b>
      </p>
    </xsl:if>
    <!-- 30/01/2025 -->
    <xsl:apply-templates select="IzmMethods"/>
    <hr class="hr-line"/>
  </xsl:template>

  <xsl:template match ="IzmMethods">
    <p>
      <b>Сведения о методах измерения:</b>
    <xsl:apply-templates select="IzmMethod"/>
    </p>
  </xsl:template>

  <xsl:template match ="IzmMethod">
    <br/>
    <xsl:if test="@type='UniqueMethod'">
      Уникальный (произвольный) НД: <span class="gray"><xsl:value-of select="@value"/></span>
    </xsl:if>
    <xsl:if test="@type='DocNameId'">
      Идентификатор НД в системе ФГИС РА: 
      <b>
        <xsl:value-of select="@value"/>
      </b>
    
    </xsl:if>
  </xsl:template>
  
  <xsl:template match ="AnotherDoc">
    <p>
      Иной НД: <b><xsl:value-of select="@name"/></b>
    </p>
  </xsl:template>
  
  <xsl:template match ="si">
    <br/> {<xsl:value-of select="@id"/>} <span class="gray"><xsl:value-of select="@name"/></span>
  </xsl:template>

  <xsl:template match ="pers">
    <br/> {<xsl:value-of select="@id"/>} <span class="gray"><xsl:value-of select="@name"/></span>
    (Роль: {<xsl:value-of select="@idRoleName"/>} <span class="gray"><xsl:value-of select="@RoleName"/></span>)
    <xsl:if test="@idRoleName2">
      (Роль2: {<xsl:value-of select="@idRoleName2"/>} <span class="gray">
        <xsl:value-of select="@RoleName2"/>
      </span>)
    </xsl:if>
    <xsl:if test="@idRoleName3">
      (Роль3: {<xsl:value-of select="@idRoleName3"/>} <span class="gray">
        <xsl:value-of select="@RoleName3"/>
      </span>)
    </xsl:if>
    <br/> Должность <b> <xsl:value-of select="@PostName"/></b>
  </xsl:template>
  
  <xsl:template match ="Address">
    Адрес: <b><xsl:value-of select="@name"/></b><br/>
  </xsl:template>
  
  <xsl:template match ="CustomerAddress">
    <br/>Адрес заказчика: <b><xsl:value-of select="@name"/></b>
  </xsl:template>
  
</xsl:stylesheet>