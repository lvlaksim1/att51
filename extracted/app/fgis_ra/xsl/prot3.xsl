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
      p.msg {
      color:red;
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
    <!-- Выводим ошибку: если нет @MethodDocId и AnotherDoc count=0  -->
    <xsl:if test="not (@MethodDocId)">
      <xsl:variable name="co_AnotherDoc">
        <xsl:value-of select="count(AnotherDoc)"/>
      </xsl:variable>
      <xsl:if test="$co_AnotherDoc=0">
        <p class="msg">
          <b>ОШИБКА: Отсутствуют НД, устанавливающие требования к объекту!</b>
        </p>
      </xsl:if>
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
    <xsl:apply-templates select="ResearchObject"/>
    <!-- Выводим сообщение, если нет ResearchObject -->
    <xsl:variable name="co_ResearchObject">
      <xsl:value-of select="count(ResearchObject)"/>
    </xsl:variable>
    <xsl:if test="$co_ResearchObject=0">
      <p class="msg">
        <b>ОШИБКА: Отсутствуют измеряемые показатели!</b>
      </p>
    </xsl:if>

    <hr class="hr-line"/>
  </xsl:template>

  <xsl:template match ="ResearchObject">
    <b>Сведения об измерениях:</b>
    <table width="100%">
      <tr>
        <td width="25%">Измеряемый показатель</td>
        <td width="15%">Фактическое значение</td>
        <td width="10%">Единица измерения</td>
        <td width="25%">Методика измерений (DocNameId или UniqueMethod)</td>
        <td width="25%">Метод измерения из ОА (DocNameMethodikId или UniqueMethodik)</td>
      </tr>
      <xsl:apply-templates select="ResearchObjectInfo "/>
    </table>
  </xsl:template>

  <xsl:template match ="ResearchObjectInfo">
    <!-- param_name -->
    <xsl:variable name="param_name">
      <xsl:choose>
        <xsl:when test="@IndicatorId='16'">Освещенность рабочей поверхности</xsl:when>
        <xsl:when test="@IndicatorId='9'">Уровень звука</xsl:when>
        <xsl:when test="@IndicatorId='10'">Общий уровень звукового давления инфразвука</xsl:when>
        <xsl:when test="@IndicatorId='11'">Уровень звукового давления в 1\3 октавных полосах ультразвука воздушного</xsl:when>
        <xsl:when test="@IndicatorId='13'">Уровень виброускорения при оценке общей вибрации</xsl:when>
        <xsl:when test="@IndicatorId='14'">Уровень виброускорения при оценке локальной вибрации</xsl:when>
        <xsl:when test="@IndicatorId='3'">Температура воздуха</xsl:when>
        <xsl:when test="@IndicatorId='5'">Скорость движения воздуха</xsl:when>
        <xsl:when test="@IndicatorId='4'">Относительная влажность воздуха</xsl:when>
        <xsl:when test="@IndicatorId='3645'">ТНС-индекс (не действующий показатель)</xsl:when>
        <xsl:when test="@IndicatorId='122114'">ТНС-индекс</xsl:when>
        <xsl:when test="@IndicatorId='6'">Интенсивность инфракрасного излучения</xsl:when>
        <xsl:when test="@IndicatorId='21'">Напряженность электрического поля 50 Гц</xsl:when>
        <xsl:when test="@IndicatorId='51'">Напряженность магнитного поля 50 Гц</xsl:when>
        <xsl:when test="@IndicatorId='23'">Напряженность электростатического поля</xsl:when>
        <xsl:when test="@IndicatorId='24'">Напряженность ПМП / Индукция ПМП</xsl:when>
        <xsl:when test="@IndicatorId='22'">Напряженность ЭП в диапазоне частот от 0,01 до 0,03 МГц</xsl:when>
        <xsl:when test="@IndicatorId='52'">Напряженность ЭП в диапазоне частот 30 кГц - 3 МГц</xsl:when>
        <xsl:when test="@IndicatorId='56'">Напряженность МП в диапазоне частот 30 кГц - 3 МГц</xsl:when>
        <xsl:when test="@IndicatorId='53'">Напряженность ЭП в диапазоне частот 3 МГц - 30 МГц</xsl:when>
        <xsl:when test="@IndicatorId='54'">Напряженность ЭП в диапазоне частот 30 МГц - 50 МГц</xsl:when>
        <xsl:when test="@IndicatorId='57'">Напряженность МП в диапазоне частот 30 МГц - 50 МГц</xsl:when>
        <xsl:when test="@IndicatorId='55'">Напряженность ЭП в диапазоне частот 50 МГц - 300 МГц</xsl:when>
        <xsl:when test="@IndicatorId='58'">Плотность потока энергии, мкВт/см2</xsl:when>
        <xsl:when test="@IndicatorId='59'">Энергетическая освещенность УФ-А</xsl:when>
        <xsl:when test="@IndicatorId='60'">Энергетическая освещенность УФ-B</xsl:when>
        <xsl:when test="@IndicatorId='61'">Энергетическая освещенность УФ-C</xsl:when>
        <xsl:when test="@IndicatorId='26'">Энергетическая экспозиция лазерного излучения</xsl:when>
        <xsl:when test="@IndicatorId='27'">Ионизирующие излучения</xsl:when>
        <xsl:when test="@IndicatorId='37'">Масса перемещаемых грузов</xsl:when>
        <xsl:when test="@IndicatorId='42'">Длина пути перемещения груза</xsl:when>
        <xsl:when test="@IndicatorId='39'">Время удержания груза</xsl:when>
        <xsl:when test="@IndicatorId='49'">Время работы с оптическими приборами</xsl:when>
        <xsl:when test="@IndicatorId='50'">Нагрузка на голосовой аппарат</xsl:when>
        <xsl:when test="@IndicatorId='44'">Длительность сосредоточенного наблюдения</xsl:when>
        <xsl:when test="@IndicatorId='48'">Время активного наблюдения за ходом производственного процесса</xsl:when>
        <xsl:when test="@IndicatorId='66'">Массовая концентрация вредных веществ в воздухе рабочей зоны</xsl:when>
        <xsl:when test="@IndicatorId='123116'">Плотность сигналов (световых, звуковых) и сообщений в среднем за 1 час работы</xsl:when>
        <xsl:when test="@IndicatorId='123117'">Число производственных объектов одновременного наблюдения</xsl:when>
        <xsl:when test="@IndicatorId='123118'">Работа с оптическими приборами (% времени смены)</xsl:when>
        <xsl:when test="@IndicatorId='147961'">Число элементов (приемов), необходимых для реализации простого задания или многократно повторяющихся операций</xsl:when>
        <xsl:when test="@IndicatorId='123122'">Монотонность производственной обстановки (время пассивного наблюдения за ходом технологического процесса в % от времени смены)</xsl:when>
        <xsl:when test="@IndicatorId='131455'">Физическая динамическая нагрузка при региональной нагрузке перемещаемого работником груза (с преимущественным участием мышц рук и плечевого пояса работника) при перемещении груза на расстояние до 1 м</xsl:when>
        <xsl:when test="@IndicatorId='131456'">Физическая динамическая нагрузка при общей нагрузке перемещаемого работником груза (с участием мышц рук, корпуса, ног тела работника) при перемещении груза на расстояние от 1 до 5 м</xsl:when>
        <xsl:when test="@IndicatorId='131457'">Физическая динамическая нагрузка при общей нагрузке перемещаемого работником груза (с участием мышц рук, корпуса, ног тела работника) при перемещении груза на расстояние более 5 м</xsl:when>
        <xsl:when test="@IndicatorId='131458'">Масса поднимаемого и перемещаемого груза вручную. Подъем и перемещение (разовое) тяжести при чередовании с другой работой (до 2 раз в час)</xsl:when>
        <xsl:when test="@IndicatorId='131459'">Масса поднимаемого и перемещаемого груза вручную. Подъем и перемещение тяжести постоянно (более 2 раз в час)</xsl:when>
        <xsl:when test="@IndicatorId='131460'">Масса поднимаемого и перемещаемого груза вручную. Суммарная масса грузов, перемещаемых в течение каждого часа рабочего дня (смены) с рабочей поверхности</xsl:when>
        <xsl:when test="@IndicatorId='131461'">Масса поднимаемого и перемещаемого груза вручную. Суммарная масса грузов, перемещаемых в течение каждого часа рабочего дня (смены) с пола</xsl:when>
        <xsl:when test="@IndicatorId='131462'">Стереотипные рабочие движения. Количество стереотипных рабочих движений работника при локальной нагрузке (с участием мышц кистей и пальцев рук) за рабочий день (смену)</xsl:when>
        <xsl:when test="@IndicatorId='131463'">Стереотипные рабочие движения. Количество стереотипных рабочих движений работника при региональной нагрузке (при работе с преимущественным участием мышц рук и плечевого пояса) за рабочий день (смену)</xsl:when>
        <xsl:when test="@IndicatorId='166546'">Статическая нагрузка за рабочий день (смену) при удержании работником груза, приложении усилий при удержании груза одной рукой</xsl:when>
        <xsl:when test="@IndicatorId='166547'">Статическая нагрузка за рабочий день (смену) при удержании работником груза, приложении усилий при удержании груза двумя руками</xsl:when>
        <xsl:when test="@IndicatorId='172845'">Статическая нагрузка за рабочий день (смену) при удержании работником груза, приложении усилий при удержании груза с участием мышц корпуса и ног</xsl:when>
        <xsl:when test="@IndicatorId='131467'">Рабочее положение тела работника (свободное положение) в течение рабочего дня (смены)</xsl:when>
        <xsl:when test="@IndicatorId='131468'">Рабочее положение тела работника (положение «стоя») в течение рабочего дня (смены)</xsl:when>
        <xsl:when test="@IndicatorId='131469'">Рабочее положение тела работника (неудобное положение) в течение рабочего дня (смены)</xsl:when>
        <xsl:when test="@IndicatorId='131470'">Рабочее положение тела работника (фиксированное положение) в течение рабочего дня (смены)</xsl:when>
        <xsl:when test="@IndicatorId='131471'">Рабочее положение тела работника (вынужденное положение) в течение рабочего дня (смены)</xsl:when>
        <xsl:when test="@IndicatorId='131472'">Рабочее положение тела работника (положение «сидя» без перерывов) в течение рабочего дня (смены)</xsl:when>
        <xsl:when test="@IndicatorId='131473'">Наклоны корпуса тела работника более 30° за рабочий день (смену)</xsl:when>
        <xsl:when test="@IndicatorId='131474'">Перемещения работника в пространстве, обусловленные технологическим процессом, в течение рабочей смены по горизонтали</xsl:when>
        <xsl:when test="@IndicatorId='131475'">Перемещения работника в пространстве, обусловленные технологическим процессом, в течение рабочей смены по вертикали</xsl:when>
        <xsl:when test="@IndicatorId='144614'">Вибрация общая. Эквивалентный корректированный уровень виброускорения</xsl:when>
        <xsl:when test="@IndicatorId='156886'">Вибрация локальная. Эквивалентный корректированный уровень виброускорения</xsl:when>
        <xsl:when test="@IndicatorId='281'">Эквивалентный уровень звука</xsl:when>
        <xsl:when test="@IndicatorId='131616'">Эквивалентный общий уровень звукового давления инфразвука</xsl:when>
        <xsl:when test="@IndicatorId='152610'">Эквивалентный уровень звукового давления в октавных полосах ультразвука со среднегеометрическими частотами от 16 до 31,5 кГц</xsl:when>
        <xsl:when test="@IndicatorId='122794'">Интенсивность теплового облучения</xsl:when>
        <xsl:when test="@IndicatorId='123119'">Нагрузка на голосовой аппарат (суммарное количество часов, наговариваемое в неделю)</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@IndicatorName"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- measur_name -->
    <xsl:variable name="measur_name">
      <xsl:choose>
        <xsl:when test="@MeasurementId='64'">Лк</xsl:when>
        <xsl:when test="@MeasurementId='650'">
          акустический децибел
        </xsl:when>
        <xsl:when test="@MeasurementId='429'">децибел</xsl:when>
        <xsl:when test="@MeasurementId='61'">ºC</xsl:when>
        <xsl:when test="@MeasurementId='90'">м/с</xsl:when>
        <xsl:when test="@MeasurementId='292'">Процент</xsl:when>
        <xsl:when test="@MeasurementId='532'">Вт/м2</xsl:when>
        <xsl:when test="@MeasurementId='555'">В/м</xsl:when>
        <xsl:when test="@MeasurementId='557'">А/м</xsl:when>
        <xsl:when test="@MeasurementId='719'">мкТл</xsl:when>
        <xsl:when test="@MeasurementId='680'">мкВт/см2</xsl:when>
        <xsl:when test="@MeasurementId='559'">Дж/см2</xsl:when>
        <xsl:when test="@MeasurementId='684'">мкЗв/ч</xsl:when>
        <xsl:when test="@MeasurementId='35'">кг</xsl:when>
        <xsl:when test="@MeasurementId='4'">метр</xsl:when>
        <xsl:when test="@MeasurementId='96'">секунда</xsl:when>
        <xsl:when test="@MeasurementId='98'">час</xsl:when>
        <xsl:when test="@MeasurementId='533'">мг/м3</xsl:when>
        <xsl:when test="@MeasurementId='282'">ед.</xsl:when>
        <xsl:when test="@MeasurementId='5'">км</xsl:when>
        <xsl:when test="@MeasurementId='985'">кг*м</xsl:when>
        <xsl:when test="@MeasurementId='987'">кгс*с</xsl:when>
        <xsl:when test="@MeasurementId='1076'">кВ/м</xsl:when>
        <xsl:when test="@MeasurementId='1107'">Вт/см2</xsl:when>
        <xsl:when test="@MeasurementId='995'">мТл</xsl:when>
        <xsl:when test="@MeasurementId='1198'">кА/м</xsl:when>
        <xsl:when test="@MeasurementId='993'">нТл</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@MeasurementName"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <tr>
      <td>
        <xsl:if test="@IndicatorId">
          {<xsl:value-of select="@IndicatorId"/>} <xsl:value-of select="$param_name"/>
        </xsl:if>
        <xsl:if test="@UniqueIndicator!=''">
          {UNQ} <xsl:value-of select="@UniqueIndicator"/>
        </xsl:if>
        <xsl:if test="@Directory!=''">
          <br/>{<xsl:value-of select="@Directory"/>}
        </xsl:if>
      </td>
      <td>
        <xsl:value-of select="@FactValue"/>
      </td>
      <td>
        <xsl:if test="@MeasurementId">
          {<xsl:value-of select="@MeasurementId"/>} <xsl:value-of select="$measur_name"/>
        </xsl:if>
        <xsl:if test="@UniqueMeasurement">
          <br/>{<xsl:value-of select="@UniqueMeasurement"/>} комментарий
        </xsl:if>
      </td>
      <td>
        <xsl:if test="@DocNameId!=''">
          {<xsl:value-of select="@DocNameId"/>} <xsl:value-of select="@fgis_nd_name"/>
        </xsl:if>
        <xsl:if test="@UniqueMethod!=''">
          {UNQ} <xsl:value-of select="@UniqueMethod"/>
        </xsl:if>
      </td>
      <td>
        <xsl:if test="@DocNameMethodikId">
          {<xsl:value-of select="@DocNameMethodikId"/>} <xsl:value-of select="@DocNameMethodik"/>
        </xsl:if>
        <xsl:if test="@UniqueMethodik">
          {UNQ} <xsl:value-of select="@UniqueMethodik"/>
        </xsl:if>
      </td>
    </tr>
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