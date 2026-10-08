<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем переменные -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сокращенный перечень РМ</title>
    <style>
      /* Style Definitions */
      body
      {
      font-size:10.0pt;
      font-family: Times new roman, serif;
      text-align:left;
      }
      p.h1 {
      font-weight:bold;
      font-size:14.0pt;
      text-align:center;
      }
      p.h2 {
      font-weight:bold;
      font-size:12.0pt;
      text-align:left;
      margin-top:6pt;
      margin-bottom:6pt;
      }
      p.h3 {
      font-weight:bold;
      font-size:11.0pt;
      text-align:left;
      margin-top:0pt;
      margin-bottom:3pt;
      }
      p.zone {
      margin-top:0pt;
      margin-bottom:0pt;
      }
      p.factor {
      font-weight:bold;
      font-size:11.0pt;
      text-align:left;
      margin-top:0pt;
      margin-bottom:0pt;
      }
      table,th,td {
      border:1px solid black;border-collapse:collapse;padding:0 5px 0 5px;
      }
      td.center {
      text-align:center;
      }
      table.empty,table.empty th,table.empty td
      {
      border:none;
      background:none;
      padding:0 5px 0 5px;
      }
      td.h30 {
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
    <p class="h1" >РАБОЧАЯ ТЕТРАДЬ</p>
    <p>
      Дата измерения/ №:     <xsl:apply-templates select="izm_dates/izm_date"/><br/>
      Наименование объекта, фактический адрес:<xsl:value-of select="@org_name"/>; <xsl:value-of select="@org_adr"/><br/>
      Измерения вредных производственных факторов выполнены для целей специальной оценке условий труда.
    </p>
    <xsl:apply-templates select="si_data"/>
    <xsl:apply-templates select="podr|rm"/>
  </xsl:template>

  
  <xsl:template match ="izm_date">
    <xsl:value-of select="count(preceding-sibling::izm_date)+1"/>) <xsl:value-of select="@value"/>; 
  </xsl:template>  
  
  <xsl:template match ="si_data">
    <p>
      <b>Перечень используемых СИ:</b>
      <br/>
      <xsl:apply-templates select="si"/>
    </p>
  </xsl:template>
  
  <xsl:template match ="si">
    <xsl:value-of select="@name"/>;<br/>
  </xsl:template>

  <xsl:template match ="podr">
    <p class="h2" >
      <xsl:value-of select="@name"/>
    </p>
  </xsl:template>  

  <xsl:template match ="rm">
    <hr/>
    <p class="h3">
      <xsl:value-of select="@rm_code"/>. <xsl:value-of select="@rm_name"/>    
    </p>
    <xsl:apply-templates select="factor"/>

  </xsl:template>
  
  
  <xsl:template match ="factor">
    <xsl:variable name="fac_id">
      <xsl:value-of select="@fac_id"/>
    </xsl:variable>
    <p class="factor">
      <b>
        <xsl:value-of select="@name"/> (дата измерения: <xsl:value-of select="@izm_date"/>)
      </b>
    </p>
    <xsl:if test="($fac_id!='2') and ($fac_id!='13') and ($fac_id!='14') ">
      <xsl:apply-templates select="zone"/>
    </xsl:if>
    <xsl:if test="($fac_id='2')">
      <p class="zone">
        Сведения о патогенных микроорганизмах:<br/>&#160;<br/>
      </p>
    </xsl:if>
    <xsl:if test="($fac_id='13')">
      <!-- ТЯЖЕСТЬ -->
      <table width="100%">
        <tr>
          <td class="h30">Показатель</td>
          <td width="40%" align="center">для мужчин</td>
          <td width="40%" align="center">для женщин</td>
        </tr>
        <tr>
          <td class="h30" width="20%">1.Физическая динамическая  нагрузка за смену, кг.м</td>
          <td width="40%"></td>
          <td width="40%"></td>
        </tr>
        <tr>
          <td class="h30">2. Масса поднимаемого и перемещаемого груза вручную, кг</td>
          <td width="40%"></td>
          <td width="40%"></td>
        </tr>
        <tr>
          <td class="h30">3. Стереотипные рабочие движения</td>
          <td width="40%"></td>
          <td width="40%"></td>
        </tr>
        <tr>
          <td class="h30">4. Статическая нагрузка</td>
          <td width="40%"></td>
          <td width="40%"></td>
        </tr>
        <tr>
          <td class="h30">5. Рабочая поза, % смены</td>
          <td width="40%"></td>
          <td width="40%"></td>
        </tr>
        <tr>
          <td class="h30">6. Наклоны корпуса</td>
          <td width="40%"></td>
          <td width="40%"></td>
        </tr>
        <tr>
          <td class="h30">7. Перемещение в пространстве, км</td>
          <td width="40%"></td>
          <td width="40%"></td>
        </tr>
      </table>
    </xsl:if>
    <xsl:if test="($fac_id='14')">
      <!-- НАПРЯЖЕННОСТЬ -->
      <table width="100%">
        <tr>
          <td class="h30" width="20%">Плотность сигналов и сообщений в среднем за 1 ч, ед.</td>
          <td width="80%"></td>
        </tr>
        <tr>
          <td class="h30">Число объектов одновременного наблюдения, ед.</td>
          <td></td>
        </tr>
        <tr>
          <td class="h30">Работа с оптическими приборами (% времени смены)</td>
          <td></td>
        </tr>
        <tr>
          <td class="h30">Нагрузка на голосовой аппарат, час</td>
          <td></td>
        </tr>
        <tr>
          <td class="h30">Число элементов (приемов), необходимых для реализации …, ед.</td>
          <td></td>
        </tr>
        <tr>
          <td class="h30">Монотонность (время пассивного наблюдения в % от времени смены)</td>
          <td></td>
        </tr>
      </table>
    </xsl:if>
  </xsl:template>


  <xsl:template match ="zone">
    <xsl:variable name="fac_id">
      <xsl:value-of select="../@fac_id"/>
    </xsl:variable>
    <p class="zone">
      <b>Рабочая зона: </b><xsl:value-of select="@name"/>
      <xsl:if test="($fac_id!='1') and ($fac_id!='3')">
        &#160;&#160;&#160;&#160;
        <b>Время, %: </b><xsl:value-of select="@time"/>
      </xsl:if>
    </p>
    <!-- ХИМ -->
    <xsl:if test="($fac_id='1') or ($fac_id='3')">
      <xsl:apply-templates select="him"/>
    </xsl:if>
    <!-- ШУМ -->
    <xsl:if test="$fac_id='4'">
      <!-- Здесь можно отредактировать сведения по шуму-->
      <table class="empty" width="100%">
        <tr>
          <td width="70%">Источник:</td>
          <td width="15%">Время измерения:</td>
          <td width="15%">Уровень:</td>
        </tr>
      </table>
    </xsl:if>
    <!-- Инфразвук -->
    <xsl:if test="$fac_id='5'">
      <!-- Здесь можно отредактировать сведения по инфразвуку-->
      <table class="empty" width="100%">
        <tr>
          <td width="70%">Источник:</td>
          <td width="15%">Время измерения:</td>
          <td width="15%">Уровень:</td>
        </tr>
      </table>
    </xsl:if>
    <!-- Ультразвук -->
    <xsl:if test="$fac_id='6'">
      <!-- Здесь можно отредактировать сведения по ультразвуку-->
      <table class="empty" width="100%">
        <tr>
          <td width="70%">Источник:</td>
          <td width="15%">Время измерения:</td>
          <td width="15%">Уровень:</td>
        </tr>
      </table>
    </xsl:if>
    <!-- вибрация общая -->
    <xsl:if test="$fac_id='7'">
      <!-- Здесь можно отредактировать сведения по вибрации общей-->
      <table class="empty" width="100%">
        <tr>
          <td width="60%">Источник:</td>
          <td width="10%">Время измерения:</td>
          <td width="10%">Уровень:</td>
          <td width="7%">X:</td>
          <td width="7%">Y:</td>
          <td width="6%">Z:</td>
        </tr>
      </table>
    </xsl:if>
    <!-- вибрация лок -->
    <xsl:if test="$fac_id='8'">
      <!-- Здесь можно отредактировать сведения по вибрации лок-->
      <table class="empty" width="100%">
        <tr>
          <td width="60%">Источник:</td>
          <td width="10%">Время измерения:</td>
          <td width="10%">Уровень:</td>
          <td width="7%">X:</td>
          <td width="7%">Y:</td>
          <td width="6%">Z:</td>
        </tr>
      </table>
    </xsl:if>
    <!-- ЭМП -->
    <xsl:if test="$fac_id='9'">
      <!-- Здесь можно отредактировать сведения по ЭМП-->
      <table class="empty" width="100%">
        <tr>
          <td width="50%">Вид ЭМП (частота):</td>
          <td width="10%">Время:</td>
          <td width="10%">Уровень:</td>
          <td width="10%">h-0.5:</td>
          <td width="10%">h-1.0:</td>
          <td width="10%">h-1.5:</td>
        </tr>
      </table>
      Доп. сведения:
    </xsl:if>
    <!-- ИИ -->
    <xsl:if test="$fac_id='10'">
      <!-- Здесь можно отредактировать сведения по ИИ-->
      <table class="empty" width="100%">
        <tr>
          <td width="55%">Источник:</td>
          <td width="15%">Персонал (А или Б):</td>
          <td width="10%">Время:</td>
          <td width="20%">Мощность дозы, мкЗв/час:</td>
        </tr>
      </table>
      Доп. сведения:
    </xsl:if>
    <!-- УФ -->
    <xsl:if test="$fac_id='10'">
      <!-- Здесь можно отредактировать сведения по УФ-->
      <table class="empty" width="100%">
        <tr>
          <td width="55%">Источник:</td>
          <td width="15%">Тип излучения(A,B,C): </td>
          <td width="10%">Время:</td>
          <td width="20%">Уровень:</td>
        </tr>
      </table>
      Доп. сведения:
    </xsl:if>
    <!-- ОСВ -->
    <xsl:if test="$fac_id='12'">
      <!-- Здесь можно отредактировать сведения по ОСВ-->
      <p>
        <hr/>
        Тип ламп:&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
        Мощн.:&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
        Освещенность (общ):&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
        Освещенность (комб.):&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
        Светильник:<br/>
        Доп. сведения:
      </p>
    </xsl:if>
    <!-- МИКРО -->
    <xsl:if test="$fac_id='11'">
      <!-- Здесь можно отредактировать сведения по МИКРО-->
      <p>
        Вид микроклимата (обвести): нагревающий / охлаждающий<br/><br/>
        <table width="100%">
          <tr>
            <td width="10%">Высота</td>
            <td width="10%">Темп-ра</td>
            <td width="10%">Скор.возд.</td>
            <td width="10%">Влажность</td>
            <td width="10%">ТНС</td>
            <td width="10%">Тепл.изл.</td>
            <td width="40%">Доп.информация по измерениям</td>
          </tr>
          <tr>
            <td>0.5</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td rowspan="3"></td>
          </tr>
          <tr>
            <td>1.0</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
          </tr>
          <tr>
            <td>1.5</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
          </tr>
        </table>
        Доп. сведения:
      </p>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="him">
      <p class="zone">
        <!-- Здесь можно отредактировать сведения по ХИМ и АПФД-->
        <b>Вредное вещество: </b><xsl:value-of select="@name"/>;&#160;&#160;&#160;<b>Время, %: </b><xsl:value-of select="@time"/>
        <br/><br/>
        Подчеркнуть:&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
        Улица&#160;&#160;&#160;&#160;&#160;С вентиляцией&#160;&#160;&#160;&#160;&#160;Без вентиляции&#160;&#160;&#160;&#160;&#160;
        Фильтр&#160;&#160;&#160;&#160;&#160;ИТ&#160;&#160;&#160;&#160;&#160;ГАНК&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
        <u>&#160;&#160;1 проба&#160;&#160;</u>&#160;&#160;&#160;&#160;&#160;
        <u>&#160;&#160;2 проба&#160;&#160;</u>&#160;&#160;&#160;&#160;&#160;
        <u>&#160;&#160;3 проба&#160;&#160;</u>&#160;&#160;&#160;&#160;&#160;
        <u>&#160;&#160;4 проба&#160;&#160;</u>&#160;&#160;&#160;&#160;&#160;
        <u>&#160;&#160;5 проба&#160;&#160;</u>&#160;&#160;&#160;&#160;&#160;
        <br/><br/>
        ºС:&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;Давление:&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
        Скорость:&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;Объем:
        <br/><br/>
        Источник:<br/><br/>
      </p>
  </xsl:template>
  
</xsl:stylesheet>