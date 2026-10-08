<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем глобальные переменные -->
  <xsl:variable name="anal_rm_num" >Аналогичное рабочее место № </xsl:variable>
  
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Сведения об обеспеченности СИЗ</title>
      <style>
        body
        {
        font-size:10.0pt;
        font-family: Times new roman, serif;
        text-align:left;
        }

        p {
        margin-top:0pt;
        margin-bottom:0pt;
        }
        .h1 {
        font-weight:bold;
        font-size:12.0pt;
        text-align:center;
        }
        .h2 {
        font-weight:bold;
        margin-top:3pt;
        margin-bottom:3pt;
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
        tr.rm {
        font-weight: bold;
        font-size:12.0pt;
        }
        tr.factor {
        font-weight: bold;
        }
        tr.param p {
        text-align:left;
        }
        .bold {
        font-weight:bold;
        }
      </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <p class="h1">Приложение к карте специальной оценки условий труда № <xsl:value-of select="@card_num"/></p>
    <p class="h2">
      <b>1. Сведения об организации</b>
    </p>
    <table width="100%">
      <tr>
        <td colspan="5">
          <xsl:value-of select="@org"/>
        </td>
      </tr>
      <tr>
        <td colspan="5">
          <sup>(полное наименование организации)</sup>
        </td>
      </tr>
      <tr>
        <td colspan="5">
          <xsl:value-of select="@adr"/>, <xsl:value-of select="@boss_fio"/>, <xsl:value-of select="@email"/>
        </td>
      </tr>
      <tr>
        <td colspan="5">
          <sup>(адрес места нахождения работодателя, фамилия, имя, отчество руководителя, адрес электронной почты)</sup>
        </td>
      </tr>
      <tr>
        <td class="center" width="20%">ИНН организации</td>
        <td class="center" width="20%">Код организации по ОКПО</td>
        <td class="center" width="20%">Код органа государственной власти по ОКОГУ</td>
        <td class="center" width="20%">Код вида экономической деятельности по ОКВЭД</td>
        <td class="center" width="20%">Код территории по ОКТМО</td>
      </tr>
      <tr>
        <td class="center">
          <xsl:value-of select="@inn"/>
        </td>
        <td class="center">
          <xsl:value-of select="@okpo"/>
        </td>
        <td class="center">
          <xsl:value-of select="@okogu"/>
        </td>
        <td class="center">
          <xsl:value-of select="@okved"/>
        </td>
        <td class="center">
          <xsl:value-of select="@okato"/>
        </td>
      </tr>
    </table>

    <p class="h2">
      <b>2. Сведения о рабочем месте</b>
    </p>
    <table width="100%">
      <tr>
        <td width="15%">Номер рабочего места</td>
        <td width="35%">Наименование профессии (должности) работника</td>
        <td width="50%">Наименование структурного подразделения</td>
      </tr>
      <tr>
        <td>
          <xsl:value-of select="@rm_num"/>
        </td>
        <td>
          <xsl:value-of select="@rm_name"/>
        </td>
        <td>
          <xsl:value-of select="@rm_podr"/>
        </td>
      </tr>
    </table>

    <p class="h2">
      <b>3. Краткое описание выполняемой работы:</b>
    </p>
    <p>
      <xsl:value-of select="@operac_t"/>
    </p>
    
    <p class="h2">
      <b>4. Сводные результаты оценки вредных (опасных) факторов на рабочем месте</b>
    </p>

    <xsl:apply-templates select="factors"/>

    <!-- Пустой абзац: чисто для обхода проблемы форматирования Word в последнем абзацем -->
    <p>
      <xsl:text>&#160;</xsl:text>
    </p>
  </xsl:template>

  <xsl:template match ="factors">
    <xsl:apply-templates select="factor"/>
  </xsl:template>  
  
  <xsl:template match ="factor">
    <!-- ХИМ.ФАКТОР -->
    <xsl:if test="@factor_id='1'">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
      <b>4.<xsl:value-of select="$iFac"/>. Химический фактор – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
      </b>
    </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="10%">Класс опасности</td>
          <td width="10%">ФАКТ, мг/м³</td>
          <td width="10%">ПДК, мг/м³</td>
          <td width="15%">Время воздействия, %</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="zone|anal_rm" mode="him"/>
        <tr class="bold">
          <td></td>
          <td align="left">Результат оценки</td>
          <td></td>
          <td></td>
          <td></td>
          <td>100</td>
          <td><xsl:value-of select="@kut"/></td>
        </tr>
      </table>
    </xsl:if>
    
    <!-- АПФД -->
    <xsl:if test="@factor_id='3'">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
      <b>4.<xsl:value-of select="$iFac"/>. Аэрозоли ПФД – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
      </b>
    </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="10%">Класс опасности</td>
          <td width="10%">ФАКТ, мг/м³</td>
          <td width="10%">ПДК, мг/м³</td>
          <td width="15%">Время воздействия, %</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="zone|anal_rm" mode="him"/>
        <tr class="bold">
          <td></td>
          <td align="left">Результат оценки</td>
          <td></td>
          <td></td>
          <td></td>
          <td>100</td>
          <td><xsl:value-of select="@kut"/></td>
        </tr>
      </table>
    </xsl:if>
    
    <!-- БИО.ФАКТОР -->
    <xsl:if test="@factor_id='2'">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Биологический фактор – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="45%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="20%">Наличие фактора</td>
          <td width="15%">Время воздействия, %</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="zone|anal_rm" mode="bio"/>
      </table>
    </xsl:if>

    <!-- ШУМ -->
    <xsl:if test="@factor_id='4'">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Виброакустические факторы. Шум – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="15%">Эквивалентный уровень, дБ</td>
          <td width="15%">ПДУ, дБ</td>
          <td width="15%">Время воздействия, %</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="param|anal_rm" mode="shum"/>
      </table>
    </xsl:if>

    <!-- Инфразвук -->
    <xsl:if test="@factor_id='5'">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Виброакустические факторы. Инфразвук – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="15%">Эквивалентный уровень, дБ</td>
          <td width="15%">ПДУ, дБ</td>
          <td width="15%">Время воздействия, %</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="param|anal_rm" mode="infr"/>
      </table>
    </xsl:if>

    <!-- Ультразвук -->
    <xsl:if test="@factor_id='6'">
      <xsl:variable name="coParams" select="count(zone/param)"/>
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Виброакустические факторы. Ультразвук – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <xsl:if test="$coParams>0">
            <td width="15%">Частота источника, кГц</td>
          </xsl:if>
          <td width="10%">Эквивалентный уровень, дБ</td>
          <td width="8%">ПДУ, дБ</td>
          <td width="12%">Время воздействия, %</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <xsl:if test="$coParams>0">
          <xsl:apply-templates select="zone|anal_rm" mode="ultr"/>
        </xsl:if>
        <!-- Спец.режим для формы 1 (измерерния определены для зоны, нет параметров) -->
        <xsl:if test="$coParams=0">
          <xsl:apply-templates select="zone|anal_rm" mode="ultr2"/>
        </xsl:if>
      </table>
    </xsl:if>
    
    <!-- Вибрация общая -->
    <xsl:if test="@factor_id='7'">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Виброакустические факторы. Вибрация общая – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="15%">Эквивалентный уровень, дБ</td>
          <td width="15%">ПДУ, дБ</td>
          <td width="15%">Время воздействия, %</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="zone|anal_rm" mode="vibr"/>
      </table>
    </xsl:if>

    <!-- Вибрация локальная -->
    <xsl:if test="@factor_id='8'">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Виброакустические факторы. Вибрация локальная – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="15%">Эквивалентный уровень, дБ</td>
          <td width="15%">ПДУ, дБ</td>
          <td width="15%">Время воздействия, %</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="zone|anal_rm" mode="vibr_loc"/>
      </table>
    </xsl:if>

    <!-- ЭМП50 -->
    <xsl:if test="(@factor_id='9') and (@fac_name='ЭМП50')">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Неионизирующие излучения. Электрические поля промышленной частоты (50 Гц) – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="15%">ФАКТ</td>
          <td width="15%">ПДУ</td>
          <td width="15%">Время воздействия, мин</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="zone|anal_rm" mode="emp"/>
        <tr class="bold">
          <td></td>
          <td align="left">Результат оценки</td>
          <td></td>
          <td></td>
          <td></td>
          <td>
            <xsl:value-of select="@kut"/>
          </td>
        </tr>
      </table>
    </xsl:if>

    <!-- ЭСП -->
    <xsl:if test="(@factor_id='9') and (@fac_name='ЭСП')">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Неионизирующие излучения. Электростатическое поле – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="15%">ФАКТ</td>
          <td width="15%">ПДУ</td>
          <td width="15%">Время воздействия, мин</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="zone|anal_rm" mode="emp"/>
        <tr class="bold">
          <td></td>
          <td align="left">Результат оценки</td>
          <td></td>
          <td></td>
          <td></td>
          <td>
            <xsl:value-of select="@kut"/>
          </td>
        </tr>
      </table>
    </xsl:if>

    <!-- ПМП -->
    <xsl:if test="(@factor_id='9') and (@fac_name='ПМП')">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Неионизирующие излучения. Постоянное магнитное поле – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="15%">ФАКТ</td>
          <td width="15%">ПДУ</td>
          <td width="15%">Время воздействия, мин</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="zone|anal_rm" mode="emp"/>
        <tr class="bold">
          <td></td>
          <td align="left">Результат оценки</td>
          <td></td>
          <td></td>
          <td></td>
          <td>
            <xsl:value-of select="@kut"/>
          </td>
        </tr>
      </table>
    </xsl:if>

    <!-- ЭМП РЧ -->
    <xsl:if test="(@factor_id='9') and (@fac_name='ЭМП РЧ')">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Неионизирующие излучения. Электромагнитные излучения радиочастотного диапазона – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="16%">Диапазон ЭМП</td>
          <td width="10%">ФАКТ</td>
          <td width="10%">ПДУ</td>
          <td width="12%">Время воздействия, мин</td>
          <td width="12%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="zone|anal_rm" mode="emp_rd"/>
        <tr class="bold">
          <td></td>
          <td align="left">Результат оценки</td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td>
            <xsl:value-of select="@kut"/>
          </td>
        </tr>
      </table>
    </xsl:if>
    
    <!-- УФИ -->
    <xsl:if test="(@factor_id='26')">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Неионизирующие излучения. Ультрафиолетовое излучение – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="16%">Диапазон ЭМП</td>
          <td width="10%">ФАКТ</td>
          <td width="10%">ПДУ</td>
          <td width="12%">Время воздействия, мин</td>
          <td width="12%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="zone|anal_rm" mode="emp_rd"/>
        <tr class="bold">
          <td></td>
          <td align="left">Результат оценки</td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td>
            <xsl:value-of select="@kut"/>
          </td>
        </tr>
      </table>
    </xsl:if>

    <!-- Ионизирующее излучение -->
    <xsl:if test="@factor_id='10'">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Ионизирующие излучения – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="15%">ФАКТ</td>
          <td width="15%">ПДУ</td>
          <td width="15%">Время воздействия, %</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <tr>
          <td colspan="6" class="bold">
            <xsl:if test="@pers_group='0'">
              Персонал группы "А"
            </xsl:if>
            <xsl:if test="@pers_group='1'">
              Персонал группы "Б"
            </xsl:if>
          </td>
        </tr>
        <xsl:apply-templates select="zone|anal_rm" mode="emp"/>
        <tr class="bold">
          <td></td>
          <td align="left">Результат оценки</td>
          <td></td>
          <td></td>
          <td></td>
          <td>
            <xsl:value-of select="@kut"/>
          </td>
        </tr>
      </table>
    </xsl:if>

    <!-- Микроклиат -->
    <xsl:if test="@factor_id='11'">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Микроклимат – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="15%">ФАКТ</td>
          <td width="15%">ПДУ</td>
          <td width="15%">Время воздействия, %</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="zone|anal_rm" mode="micro"/>
        <tr class="bold">
          <td></td>
          <td align="left">Результат оценки</td>
          <td></td>
          <td></td>
          <td>100</td>
          <td>
            <xsl:value-of select="@kut"/>
          </td>
        </tr>
      </table>
    </xsl:if>

    <!-- Световая среда -->
    <xsl:if test="@factor_id='12'">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Световая среда – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="5%">№</td>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="15%">ФАКТ</td>
          <td width="15%">ПДУ</td>
          <td width="15%">Время воздействия, %</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="zone|anal_rm" mode="micro"/>
        <tr class="bold">
          <td></td>
          <td align="left">Результат оценки</td>
          <td></td>
          <td></td>
          <td>100</td>
          <td>
            <xsl:value-of select="@kut"/>
          </td>
        </tr>
      </table>
    </xsl:if>

    <!-- Тяжесть -->
    <xsl:if test="@factor_id='13'">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Тяжесть трудового процесса – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="20%">ФАКТ</td>
          <td width="15%">ПДУ</td>
          <td width="15%">Время воздействия, %</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="param|anal_rm" mode="tyag"/>
        <tr class="bold">
          <td align="left">Результат оценки</td>
          <td></td>
          <td></td>
          <td>100</td>
          <td>
            <xsl:value-of select="@kut"/>
          </td>
        </tr>
      </table>
    </xsl:if>

    <!-- Напряженность -->
    <xsl:if test="@factor_id='14'">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Напряженность трудового процесса – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="35%">Наименование рабочей зоны, выполняемая операция, (источник)</td>
          <td width="20%">ФАКТ</td>
          <td width="15%">ПДУ</td>
          <td width="15%">Время воздействия, %</td>
          <td width="15%">Класс условий труда</td>
        </tr>
        <xsl:apply-templates select="param|anal_rm" mode="tyag"/>
        <tr class="bold">
          <td align="left">Результат оценки</td>
          <td></td>
          <td></td>
          <td>100</td>
          <td>
            <xsl:value-of select="@kut"/>
          </td>
        </tr>
      </table>
    </xsl:if>

    <!-- Лазерное излучение (форма 1) -->
    <xsl:if test="(@factor_id='41') and (@form='1')">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Неионизирующие излучения. Лазерное излучение – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td rowspan="2" width="30%">Наименование рабочего места, место измерения (фактор)</td>
          <td rowspan="2" width="15%">Дата оценки (измерения)</td>
          <td colspan="2" width="20%">Энергетическая экспозиция, Дж/м2</td>
          <td colspan="2" width="20%">Энергия лазерного излучения, Дж</td>
          <td rowspan="2" width="15%">Класс условий труда</td>
        </tr>
        <tr>
          <td width="10%">Факт.</td>
          <td width="10%">ПДУ</td>
          <td width="10%">Факт.</td>
          <td width="10%">ПДУ</td>
        </tr>
        <tr>
          <td>1</td>
          <td>2</td>
          <td>3</td>
          <td>4</td>
          <td>5</td>
          <td>6</td>
          <td>7</td>
        </tr>
        <xsl:apply-templates select="anal_rm|lazer_info|modes_nodes|result_eyes|result_skin" mode="li2"/>
      </table>
    </xsl:if>

    <!-- Лазерное излучение (форма 2) -->
    <xsl:if test="(@factor_id='41') and (@form='2')">
      <xsl:variable name="iFac" select="count(preceding-sibling::factor)+1"/>
      <p class="h2">
        <b>
          4.<xsl:value-of select="$iFac"/>. Неионизирующие излучения. Лазерное излучение – Протокол испытаний № <xsl:value-of select="@sv_num_doc"/> от <xsl:value-of select="@sv_doc_date"/>
        </b>
      </p>
      <table>
        <tr>
          <td width="6%">№ (код) РМ</td>
          <td width="30%">Наименование рабочего места, место измерения (фактор)</td>
          <td width="10%">ФАКТ</td>
          <td width="10%">U095</td>
          <td width="10%">ПДУ1</td>
          <td width="10%">ПДУ2</td>
          <td width="10%">ОТКЛ</td>
          <td width="14%">Класс условий труда</td>
        </tr>
        <tr>
          <td>1</td>
          <td>2</td>
          <td>3</td>
          <td>4</td>
          <td>5</td>
          <td>6</td>
          <td>7</td>
          <td>8</td>
        </tr>
        <xsl:apply-templates select="zone|anal_rm" mode="li"/>
      </table>
    </xsl:if>

  </xsl:template>

  <!-- Вспомогательные блоки: зоны, измеряемые показатели -->

  <!-- Метки аналогичных РМ -->
  <xsl:template match ="anal_rm" mode="him">
    <tr class="bold">
      <td colspan="7" align="center">
        <xsl:value-of select="$anal_rm_num"/> <xsl:value-of select="@rm_num"/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="anal_rm" mode="bio">
    <tr class="bold">
      <td colspan="5" align="center">
        <xsl:value-of select="$anal_rm_num"/> <xsl:value-of select="@rm_num"/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="anal_rm" mode="shum">
    <tr class="bold">
      <td colspan="6" align="center">
        <xsl:value-of select="$anal_rm_num"/> <xsl:value-of select="@rm_num"/>
      </td>
    </tr>
  </xsl:template>  
  
  <xsl:template match ="anal_rm" mode="infr">
    <tr class="bold">
      <td colspan="6" align="center">
        <xsl:value-of select="$anal_rm_num"/> <xsl:value-of select="@rm_num"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="anal_rm" mode="ultr">
    <tr class="bold">
      <td colspan="7" align="center">
        <xsl:value-of select="$anal_rm_num"/> <xsl:value-of select="@rm_num"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="anal_rm" mode="ultr2">
    <tr class="bold">
      <td colspan="6" align="center">
        <xsl:value-of select="$anal_rm_num"/> <xsl:value-of select="@rm_num"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="anal_rm" mode="vibr">
    <tr class="bold">
      <td colspan="6" align="center">
        <xsl:value-of select="$anal_rm_num"/> <xsl:value-of select="@rm_num"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="anal_rm" mode="vibr_loc">
    <tr class="bold">
      <td colspan="6" align="center">
        <xsl:value-of select="$anal_rm_num"/>
        <xsl:value-of select="@rm_num"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="anal_rm" mode="emp">
    <tr class="bold">
      <td colspan="6" align="center">
        <xsl:value-of select="$anal_rm_num"/>
        <xsl:value-of select="@rm_num"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="anal_rm" mode="emp_rd">
    <tr class="bold">
      <td colspan="7" align="center">
        <xsl:value-of select="$anal_rm_num"/>
        <xsl:value-of select="@rm_num"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="anal_rm" mode="micro">
    <tr class="bold">
      <td colspan="6" align="center">
        <xsl:value-of select="$anal_rm_num"/>
        <xsl:value-of select="@rm_num"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="anal_rm" mode="tyag">
    <tr class="bold">
      <td colspan="5" align="center">
        <xsl:value-of select="$anal_rm_num"/>
        <xsl:value-of select="@rm_num"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="anal_rm" mode="li">
    <tr class="bold">
      <td colspan="8" align="center">
        <xsl:value-of select="$anal_rm_num"/>
        <xsl:value-of select="@rm_num"/>
      </td>
    </tr>
  </xsl:template>  

  <xsl:template match ="anal_rm" mode="li2">
    <tr class="bold">
      <td colspan="7" align="center">
        <xsl:value-of select="$anal_rm_num"/>
        <xsl:value-of select="@rm_num"/>
      </td>
    </tr>
  </xsl:template>  
  
  <!-- ЛИ (форма 2) -->
  <xsl:template match ="zone" mode="li">
    <tr>
      <!-- СТРОКИ!!! -->
      <td align="left" colspan="8">
        <b>
          <xsl:value-of select="@number"/>  интервал измерения
        </b>: <xsl:value-of select="@name"/>;
        Дата измерения: <xsl:value-of select="@izm_date"/>; Время пребывания: <xsl:value-of select="@time"/> мин
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="lu_info">
    <tr>
      <!-- СТРОКИ!!! -->
      <td align="left" colspan="8">
        <i>Сведения о лазерной установке:</i>
        <br/>
        <xsl:value-of select="@lu_name"/>;
        Длина волны, нм - <xsl:value-of select="@lu_wave"/>;
        Мощность, Вт - <xsl:value-of select="@lu_power"/>;
        Диаметр выходного луча, мм - <xsl:value-of select="@lu_d_mm"/> Вт;
        Класс опасности - <xsl:value-of select="@lu_class"/>;
        Доп.сведения - <xsl:value-of select="@lu_descr"/>.
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="regim_info">
    <tr>
      <!-- СТРОКИ!!! -->
      <td align="left" colspan="8">
        <i>Режим работы лазерной установки:</i>
        <br/>
        <xsl:if test="@ind=4">
          Непрерывное излучение с общей длительностью воздействия <xsl:value-of select="@Tsum"/> сек.
        </xsl:if>
        <xsl:if test="@ind!=4">
          <xsl:value-of select="@regim_name"/> (Тимп=<xsl:value-of select="@Timp"/> сек, Fимп=<xsl:value-of select="@Fimp"/> Гц, Твозд.=<xsl:value-of select="@Tsum"/> сек).
        </xsl:if>
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="res_A1">
    <tr>
      <td></td>
      <td colspan="2">
        <i>Облучение кожи (точка А1)</i>
      </td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td>
        <xsl:value-of select="@param_name"/>
      </td>
      <td>
        <xsl:value-of select="@fact_max"/>
      </td>
      <td>
        <xsl:value-of select="@fact_unc"/>
      </td>
      <td>
        <xsl:value-of select="@pdu1"/>
      </td>
      <td>
        <xsl:value-of select="@pdu2"/>
      </td>
      <td>
        <xsl:value-of select="@otkl"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="res_A2">
    <tr>
      <td></td>
      <td colspan="2">
        <i>Облучение глаз (точка А2)</i>
      </td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td>
        <xsl:value-of select="@param_name"/>
      </td>
      <td>
        <xsl:value-of select="@fact_max"/>
      </td>
      <td>
        <xsl:value-of select="@fact_unc"/>
      </td>
      <td>
        <xsl:value-of select="@pdu1"/>
      </td>
      <td>
        <xsl:value-of select="@pdu2"/>
      </td>
      <td>
        <xsl:value-of select="@otkl"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- ЛИ (форма 1) -->
  
  <xsl:template match ="lazer_info" mode="li2">
    <tr>
      <!-- СТРОКИ!!! -->
      <td align="left" colspan="7">
        <b>Сведения о лазерной установке:</b>
        <br/>
        <xsl:value-of select="@opt_lazer_info"/>;
        Длина волны, нм - <xsl:value-of select="@opt_lambda"/>;
        Мощность, Вт - <xsl:value-of select="@opt_power"/>;
        Диаметр выходного луча, мм - <xsl:value-of select="@opt_diametr"/> Вт;
        Класс опасности - <xsl:value-of select="@opt_danger"/>
      </td>
    </tr>
    <tr>
      <!-- СТРОКИ!!! -->
      <td align="left" colspan="7">
        <b>Место измерения: </b>
        <span class="no_bold">
          <xsl:value-of select="@LazerMeasuringPlace"/>;
        </span>
        <b>Тип облучения: </b>
        <span class="no_bold">
          <xsl:value-of select="@li_type"/>
        </span>

      </td>
    </tr>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match ="modes_nodes" mode="li2">
    <tr>
      <td align="left" colspan="7">
        <b>Режим работы лазерной установки:</b>
        <xsl:apply-templates/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="node">
    <br/>
    <xsl:number value="position()" format="1. "/>
    <xsl:if test="@gen_mode=1">
      Непрерывное излучение с общей длительностью воздействия <xsl:value-of select="@Tsum"/> секунд.
    </xsl:if>
    <xsl:if test="@gen_mode=0">
      Импульсное излучение с общей длительностью воздействия <xsl:value-of select="@Tsum"/> секунд (Тимп=<xsl:value-of select="@Timp"/> с, Fимп=<xsl:value-of select="@Fimp"/> Гц).
    </xsl:if>
  </xsl:template>

  <xsl:template match ="result_eyes" mode="li2">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <td colspan="2">Облучение глаз</td>
      <td>
        <xsl:value-of select="@fact1"/>
      </td>
      <td>
        <xsl:value-of select="@pdu1"/>
      </td>
      <td>
        <xsl:value-of select="@fact2"/>
      </td>
      <td>
        <xsl:value-of select="@pdu2"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="result_skin" mode="li2">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
      <!-- СТРОКИ!!! -->
      <td colspan="2">Облучение кожи</td>
      <td>
        <xsl:value-of select="@fact1"/>
      </td>
      <td>
        <xsl:value-of select="@pdu1"/>
      </td>
      <td>
        <xsl:value-of select="@fact2"/>
      </td>
      <td>
        <xsl:value-of select="@pdu2"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
  </xsl:template>

  <!-- Тяжесть -->
  <xsl:template match ="param" mode="tyag">
    <tr>
      <xsl:if test="@class='param_header'">
        <xsl:attribute name="class">bold</xsl:attribute>
      </xsl:if>
      <td align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:value-of select="@norm"/>
      </td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
  </xsl:template>

  <!-- Микроклимат -->
  <xsl:template match ="zone" mode="micro">
    <xsl:variable name="iZone" select="count(preceding-sibling::zone[@class='zone'])+1"/>
    <xsl:variable name="iParam" select="count(preceding-sibling::zone[@class='param'])+1"/>
    <tr class="bold">
      <td>
        <xsl:if test="@class='zone'">
          <xsl:value-of select="$iZone"/>
        </xsl:if>
        <xsl:if test="@class='param'">
          <xsl:value-of select="$iZone"/>.<xsl:value-of select="$iParam"/>
        </xsl:if>
      </td>
      <td colspan="2" align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@norm"/>
      </td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
      <td>-</td>
    </tr>
    <xsl:apply-templates select="param" mode="emp"/>
  </xsl:template>

  <!-- ЭМП РЧ и УФИ -->
  <xsl:template match ="zone" mode="emp_rd">
    <xsl:variable name="iZone" select="count(preceding-sibling::zone[@class='zone'])+1"/>
    <xsl:variable name="iParam" select="count(preceding-sibling::zone[@class='param'])+1"/>
    <tr class="bold">
      <td>
        <xsl:if test="@class='zone'">
          <xsl:value-of select="$iZone"/>
        </xsl:if>
        <xsl:if test="@class='param'">
          <xsl:value-of select="$iZone"/>.<xsl:value-of select="$iParam"/>
        </xsl:if>
      </td>
      <td colspan="3" align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td></td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
      <td>-</td>
    </tr>
    <xsl:apply-templates select="param" mode="emp_rd"/>
  </xsl:template>

  <xsl:template match ="param" mode="emp_rd">
    <xsl:variable name="iZone" select="count(parent::zone/preceding-sibling::zone[@class='zone'])+1"/>
    <xsl:variable name="iParam" select="count(preceding-sibling::param[@class='param'])+1"/>
    <tr>
      <td>
        <xsl:if test="@class='zone'">
          <xsl:value-of select="$iZone"/>
        </xsl:if>
        <xsl:if test="@class='param'">
          <xsl:value-of select="$iZone"/>.<xsl:value-of select="$iParam"/>
        </xsl:if>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@diapazon"/>
        <xsl:if test="@diapazon=''">
          <xsl:if test="contains(@bm,'UFA')">УФ-A</xsl:if>
          <xsl:if test="contains(@bm,'UFB')">УФ-B</xsl:if>
          <xsl:if test="contains(@bm,'UFC')">УФ-C</xsl:if>
          <xsl:if test="contains(@bm,'UF_BC')">УФ-B + УФ-C</xsl:if>
          <xsl:if test="contains(@bm,'ufinewA')">УФ-A</xsl:if>
          <xsl:if test="contains(@bm,'ufinewB')">УФ-B</xsl:if>
          <xsl:if test="contains(@bm,'ufinewC')">УФ-C</xsl:if>
          <xsl:if test="contains(@bm,'ufinew_B_C')">УФ-B + УФ-C</xsl:if>
        </xsl:if>
      </td>
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:value-of select="@norm"/>
      </td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
  </xsl:template>

  <!-- ЭМП -->
  <xsl:template match ="zone" mode="emp">
    <xsl:variable name="iZone" select="count(preceding-sibling::zone[@class='zone'])+1"/>
    <xsl:variable name="iParam" select="count(preceding-sibling::zone[@class='param'])+1"/>
    <tr class="bold">
      <td>
        <xsl:if test="@class='zone'">
          <xsl:value-of select="$iZone"/>
        </xsl:if>
        <xsl:if test="@class='param'">
          <xsl:value-of select="$iZone"/>.<xsl:value-of select="$iParam"/>
        </xsl:if>
      </td>
      <td colspan="3" align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
      <td>-</td>
    </tr>
    <xsl:apply-templates select="param" mode="emp"/>
  </xsl:template>

  <xsl:template match ="param" mode="emp">
    <xsl:variable name="iZone" select="count(parent::zone/preceding-sibling::zone[@class='zone'])+1"/>
    <xsl:variable name="iParam" select="count(preceding-sibling::param[@class='param'])+1"/>
    <tr>
      <td>
        <xsl:if test="@class='zone'">
          <xsl:value-of select="$iZone"/>
        </xsl:if>
        <xsl:if test="@class='param'">
          <xsl:value-of select="$iZone"/>.<xsl:value-of select="$iParam"/>
        </xsl:if>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:value-of select="@norm"/>
      </td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
  </xsl:template>

  <!-- Вибрация локальная -->
  <xsl:template match ="zone" mode="vibr_loc">
    <xsl:variable name="iZone" select="count(preceding-sibling::zone[@class='zone'])+1"/>
    <xsl:variable name="iParam" select="count(preceding-sibling::zone[@class='param'])+1"/>
    <tr>
      <xsl:if test="@class='zone'">
        <xsl:attribute name="class">bold</xsl:attribute>
      </xsl:if>
      <td>
        <xsl:if test="@class='zone'">
          <xsl:value-of select="$iZone"/>
        </xsl:if>
        <xsl:if test="@class='param'">
          <xsl:value-of select="$iZone"/>.<xsl:value-of select="$iParam"/>
        </xsl:if>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:if test="@class='param'">126</xsl:if>
        <xsl:if test="@class='zone'">-</xsl:if>
      </td>
      <td>
        <xsl:value-of select="@time"/>
        <xsl:if test="@class='param'">-</xsl:if>
      </td>
      <td>-</td>
    </tr>
    <xsl:apply-templates select="param" mode="vibr"/>
  </xsl:template>

  <!-- Вибрация -->
  <xsl:template match ="zone" mode="vibr">
    <xsl:variable name="iZone" select="count(preceding-sibling::zone[@class='zone'])+1"/>
    <xsl:variable name="iParam" select="count(preceding-sibling::zone[@class='param'])+1"/>
    <tr>
      <xsl:if test="@class='zone'">
        <xsl:attribute name="class">bold</xsl:attribute>
      </xsl:if>
      <td>
        <xsl:if test="@class='zone'">
          <xsl:value-of select="$iZone"/>
        </xsl:if>
        <xsl:if test="@class='param'">
          <xsl:value-of select="$iZone"/>.<xsl:value-of select="$iParam"/>
        </xsl:if>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:if test="@class='param'">
          <xsl:if test="contains(@bm,'_x_')">112</xsl:if>
          <xsl:if test="contains(@bm,'_y_')">112</xsl:if>
          <xsl:if test="contains(@bm,'_z_')">115</xsl:if>
        </xsl:if>
        <xsl:if test="@class='zone'">-</xsl:if>
      </td>
      <td>
        <xsl:value-of select="@time"/>
        <xsl:if test="@class='param'">-</xsl:if>
      </td>
      <td>-</td>
    </tr>
    <xsl:apply-templates select="param" mode="vibr"/>
  </xsl:template>

  <xsl:template match ="param" mode="vibr">
    <xsl:variable name="iZone" select="count(parent::zone/preceding-sibling::zone[@class='zone'])+1"/>
    <xsl:variable name="iParam" select="count(preceding-sibling::param[@class='param'])+1"/>
    <tr>
      <xsl:if test="@class='zone'">
        <xsl:attribute name="class">bold</xsl:attribute>
      </xsl:if>
      <td>
        <xsl:if test="@class='zone'">
          <xsl:value-of select="$iZone"/>
        </xsl:if>
        <xsl:if test="@class='param'">
          <xsl:value-of select="$iZone"/>.<xsl:value-of select="$iParam"/>
        </xsl:if>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@fact2"/>
        <xsl:if test="@fact2=''">-</xsl:if>
      </td>
      <td>
        <xsl:value-of select="@norm"/>
        <xsl:if test="@norm=''">-</xsl:if>
      </td>
      <td>100</td>
      <td>
        <xsl:value-of select="@kut"/>
        <xsl:if test="@kut=''">-</xsl:if>
      </td>
    </tr>
  </xsl:template>

  <!-- Ультразвук -->
  <xsl:template match ="zone" mode="ultr2">
    <xsl:variable name="iZone" select="count(preceding-sibling::zone)+1"/>
    <tr>
      <td>
        <xsl:value-of select="$iZone"/>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:value-of select="@norm"/>
      </td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match ="zone" mode="ultr">
    <xsl:variable name="iZone" select="count(preceding-sibling::zone)+1"/>
    <tr class="bold">
      <td>
        <xsl:value-of select="$iZone"/>
      </td>
      <td colspan="4" align="left">
        <xsl:value-of select="@name"/>
        <xsl:if test="@src!=''">
          (<xsl:value-of select="@src"/>)
        </xsl:if>
      </td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
      <td></td>
    </tr>
    <xsl:apply-templates select="param" mode="ultr"/>
  </xsl:template>

  <xsl:template match ="param" mode="ultr">
    <xsl:variable name="iParam" select="count(preceding-sibling::param)+1"/>
    <tr>
      <xsl:if test="@bm='Lekv'">
        <xsl:attribute name="class">bold</xsl:attribute>
      </xsl:if>
      <td>
        <xsl:value-of select="$iParam"/>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
        <xsl:if test="@descr!=''">
          (<xsl:value-of select="@descr"/>)
        </xsl:if>
      </td>
      <td>
        <xsl:value-of select="@freq"/>
      </td>
      <td>
        <xsl:value-of select="@fact2"/>
      </td>
      <td><xsl:value-of select="@norm"/></td>
      <td>
        <xsl:if test="@bm='Lekv'">100</xsl:if>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
  </xsl:template>

  <!-- Инфразвук -->
  <xsl:template match ="param" mode="infr">
    <xsl:variable name="iParam" select="count(preceding-sibling::param)+1"/>
    <tr>
      <xsl:if test="@class='param2'">
        <xsl:attribute name="class">bold</xsl:attribute>
      </xsl:if>
      <td>
        <xsl:value-of select="$iParam"/>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
        <xsl:if test="@descr!=''">
          (<xsl:value-of select="@descr"/>)
        </xsl:if>
      </td>
      <td>
        <xsl:if test="@class='param2'">
          <xsl:value-of select="@fact"/>
        </xsl:if>
        <xsl:if test="@class='param'">
          <xsl:value-of select="@fact2"/>
        </xsl:if>
      </td>
      <td>110</td>
      <td>
        <xsl:if test="@class='param2'">100</xsl:if>
        <xsl:if test="@class='param'">
          <xsl:value-of select="@time"/>
        </xsl:if>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
  </xsl:template>

  <!-- ШУМ -->
  <xsl:template match ="param" mode="shum">
    <xsl:variable name="iParam" select="count(preceding-sibling::param)+1"/>
    <tr>
      <xsl:if test="@class='param2'">
        <xsl:attribute name="class">bold</xsl:attribute>
      </xsl:if>
      <td>
        <xsl:value-of select="$iParam"/>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
        <xsl:if test="@descr!=''">
          (<xsl:value-of select="@descr"/>)
        </xsl:if>
      </td>
      <td>
        <xsl:if test="@class='param2'">
          <xsl:value-of select="@fact"/>
        </xsl:if>
        <xsl:if test="@class='param'">
          <xsl:value-of select="@fact2"/>
        </xsl:if>
      </td>
      <td>80</td>
      <td>
        <xsl:if test="@class='param2'">100</xsl:if>
        <xsl:if test="@class='param'">
          <xsl:value-of select="@time"/>
        </xsl:if>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
  </xsl:template>

  <!-- БИО.ФАКТОР -->
  <xsl:template match ="zone" mode="bio">
    <xsl:variable name="iZone" select="count(preceding-sibling::zone)+1"/>
    <tr class="bold">
      <td>
        <xsl:value-of select="$iZone"/>
      </td>
      <td colspan="4" align="left">
        <xsl:value-of select="@name"/>
      </td>
    </tr>
    <xsl:apply-templates select="param" mode="bio"/>
  </xsl:template>

  <xsl:template match ="param" mode="bio">
    <xsl:variable name="iZone" select="count(parent::zone/preceding-sibling::zone)+1"/>
    <xsl:variable name="iParam" select="count(preceding-sibling::param)+1"/>
    <tr>
      <td>
        <xsl:value-of select="$iZone"/>.<xsl:value-of select="$iParam"/>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@fact2"/>
      </td>
      <td>
        <xsl:value-of select="../@time"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
  </xsl:template>

  <!-- ХИМ и АПФД -->
  <xsl:template match ="zone" mode="him">
    <xsl:variable name="iZone" select="count(preceding-sibling::zone)+1"/>
    <tr class="bold">
      <td>
        <xsl:value-of select="$iZone"/>
      </td>
      <td colspan="6" align="left">
        <xsl:value-of select="@name"/>
        <xsl:if test="@src!=''">
          (<xsl:value-of select="@src"/>)
        </xsl:if>
      </td>
    </tr>
    <xsl:apply-templates select="param" mode="him"/>
  </xsl:template>

  <xsl:template match ="param" mode="him">
    <xsl:variable name="iZone" select="count(parent::zone/preceding-sibling::zone)+1"/>
    <xsl:variable name="iParam" select="count(preceding-sibling::param)+1"/>
    <tr>
      <td>
        <xsl:value-of select="$iZone"/>.<xsl:value-of select="$iParam"/>
      </td>
      <td align="left">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@him_class"/>
      </td>
      <td>
        <xsl:value-of select="@fact"/>
      </td>
      <td>
        <xsl:value-of select="@norm"/>
      </td>
      <td>
        <xsl:value-of select="@time"/>
      </td>
      <td>
        <xsl:value-of select="@kut"/>
      </td>
    </tr>
  </xsl:template>
  
</xsl:stylesheet>