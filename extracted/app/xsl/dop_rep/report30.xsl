<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->
  <xsl:variable name="tab">
    <xsl:text>&#x09;</xsl:text>
  </xsl:variable>
  <xsl:template match ="/">    

	<html>
	<head>
	    <title>Содержание</title>
    <style>
      /* Style Definitions */
      body
      {
      font-size:12.0pt;
      font-family: Times new roman, serif;
      text-align:left;
      }
      .h1 {
      font-weight:bold;
      font-size:14.0pt;
      text-align:center;
      }
      table,th,td {
      border:none;
      background:none;
      border-collapse:collapse;
      padding:4 3px 0 3px;
      vertical-align: top;
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
      td.sign {
      height:30pt;
      }
      td.page {
      text-align:center;
      border-bottom: 1px solid black;
      }
    </style>	
  </head>
	<body>
        <xsl:apply-templates/>
	</body>
	</html>
  </xsl:template>

  <xsl:template match ="Document">
    <p class="h1">СОДЕРЖАНИЕ</p>
    <table>
    <tr>
      <td width="6%">1.</td>
      <td colspan="2" width="86%">Сведения об организации, проводящей специальную оценку условий труда</td>
      <td class="page" width="8%"></td>
    </tr>
    <tr>
      <td>2.</td>
      <td colspan="2" >Перечень рабочих мест, на которых проводилась специальная оценка условий труда</td>
      <td class="page"></td>
    </tr>
	  <tr>
        <td>3.</td>
        <td colspan="2" >Карты специальной оценки условий труда с протоколами измерений и оценок:</td>
        <td></td>
    </tr>
    <xsl:apply-templates select="ORG/RM|ORG/PODR" />

    <!-- Дополнительный раздел для сводных протоколов -->
    <xsl:variable name="co_sv_prots" select="count(ORG/prot)"></xsl:variable>
    <xsl:if test="$co_sv_prots>0">
      <xsl:variable name="co_sv_prots_fac1" select="count(ORG/prot[@fac_id2='1'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac3" select="count(ORG/prot[@fac_id2='3'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac2" select="count(ORG/prot[@fac_id2='2'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac4" select="count(ORG/prot[@fac_id2='4'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac5" select="count(ORG/prot[@fac_id2='5'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac6" select="count(ORG/prot[@fac_id2='6'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac7" select="count(ORG/prot[@fac_id2='7'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac8" select="count(ORG/prot[@fac_id2='8'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac9_1" select="count(ORG/prot[@fac_id2='9_1'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac9_2" select="count(ORG/prot[@fac_id2='9_2'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac9_3" select="count(ORG/prot[@fac_id2='9_3'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac9_4" select="count(ORG/prot[@fac_id2='9_4'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac10" select="count(ORG/prot[@fac_id2='10'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac11" select="count(ORG/prot[@fac_id2='11'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac12" select="count(ORG/prot[@fac_id2='12'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac13" select="count(ORG/prot[@fac_id2='13'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac14" select="count(ORG/prot[@fac_id2='14'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac26" select="count(ORG/prot[@fac_id2='26'])"></xsl:variable>
      <xsl:variable name="co_sv_prots_fac41" select="count(ORG/prot[@fac_id2='41'])"></xsl:variable>
      <!-- Создание системы нумерации: достаточно замороченный способ, но другого не вижу в xslt.1 -->
      <xsl:variable name="shift_fac1">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac1>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac2">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac2>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac3">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac3>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac4">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac4>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac5">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac5>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac6">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac6>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac7">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac7>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac8">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac8>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac9_1">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac9_1>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac9_2">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac9_2>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac9_3">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac9_3>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac9_4">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac9_4>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac10">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac10>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac11">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac11>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac12">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac12>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac13">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac13>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac14">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac14>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac26">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac26>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="shift_fac41">
        <xsl:choose>
          <xsl:when test="$co_sv_prots_fac41>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <!-- промежуточные объединенные переменные, чтобы сократить строки для суммации -->
      <xsl:variable name="shift_fac1_3" select="$shift_fac1 + $shift_fac2 + $shift_fac3"/>
      <xsl:variable name="shift_fac1_8" select="$shift_fac1_3 + $shift_fac4 + $shift_fac5 + $shift_fac6 + $shift_fac7+ $shift_fac8"/>
      <xsl:variable name="shift_fac_uf_lazer" select="$shift_fac1_8 + $shift_fac26 + $shift_fac41"/>
      <xsl:variable name="shift_fac1_9" select="$shift_fac_uf_lazer + $shift_fac9_1 + $shift_fac9_2 + $shift_fac9_3 + $shift_fac9_4"/>
      <xsl:variable name="shift_fac1_12" select="$shift_fac1_9 + $shift_fac10 + $shift_fac11 + $shift_fac12"/>
        
      <!-- Вывод строк для сводных протоколов -->
      <tr>
          <td>4.</td>
          <td colspan="2" >
            Сводные протоколы:
          </td>
          <td></td>
      </tr>
      <xsl:if test="$co_sv_prots_fac1>0">
        <tr>
            <td>
              4.<xsl:value-of select="$shift_fac1"/>
            </td>
            <td colspan="2" >
              Воздух рабочей зоны. Химический фактор (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='1']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac3>0">
        <tr>
            <td>
              4.<xsl:value-of select="$shift_fac1+$shift_fac3"/>
            </td>
            <td colspan="2" >
              Воздух рабочей зоны. Аэрозоли преимущественно фиброгенного действия (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='3']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac2>0">
        <tr>
            <td>
              4.<xsl:value-of select="$shift_fac1+$shift_fac3+$shift_fac2"/>
            </td>
            <td colspan="2" >
              Биологический фактор (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='2']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac4>0">
        <tr>
            <td>
              4.<xsl:value-of select="$shift_fac1_3+$shift_fac4"/>
            </td>
            <td colspan="2" >
              Виброакустические факторы. Шум (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='4']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac5>0">
        <tr>
            <td>
              4.<xsl:value-of select="$shift_fac1_3+$shift_fac4+$shift_fac5"/>
            </td>
            <td colspan="2" >
              Виброакустические факторы. Инфразвук (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='5']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac6>0">
        <tr>
            <td>
              4.<xsl:value-of select="$shift_fac1_3+$shift_fac4+$shift_fac5+$shift_fac6"/>
            </td>
            <td colspan="2" >
              Виброакустические факторы. Ультразвук воздушный (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='6']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac7>0">
        <tr>
          <td>
            4.<xsl:value-of select="$shift_fac1_3+$shift_fac4+$shift_fac5+$shift_fac6+$shift_fac7"/>
          </td>
          <td colspan="2" >
              Виброакустические факторы. Вибрация общая (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='7']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac8>0">
        <tr>
          <td>
            4.<xsl:value-of select="$shift_fac1_3+$shift_fac4+$shift_fac5+$shift_fac6+$shift_fac7+$shift_fac8"/>
          </td>
          <td colspan="2" >
              Виброакустические факторы. Вибрация локальная (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='8']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac26>0">
        <tr>
          <td>
            4.<xsl:value-of select="$shift_fac1_8+$co_sv_prots_fac26"/>
          </td>
          <td colspan="2" >
              Неионизирующие излучения оптического диапазона (ультрафиолетовое) (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='26']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac41>0">
        <tr>
          <td>
            4.<xsl:value-of select="$shift_fac1_8+$co_sv_prots_fac26+$co_sv_prots_fac41"/>
          </td>
          <td colspan="2" >
            Неионизирующие излучения оптического диапазона (лазерное) (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='41']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac9_1>0">
        <tr>
          <td>
            4.<xsl:value-of select="$shift_fac_uf_lazer+$co_sv_prots_fac9_1"/>
          </td>
          <td colspan="2" >
              Неионизирующие излучения. Электрические и магнитные поля промышленной частоты (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='9_1']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac9_4>0">
        <tr>
          <td>
            4.<xsl:value-of select="$shift_fac_uf_lazer+$co_sv_prots_fac9_1+$co_sv_prots_fac9_4"/>
          </td>
          <td colspan="2" >
              Неионизирующие излучения. Электрические и магнитные поля радиочастотного диапазона (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='9_4']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac9_3>0">
        <tr>
          <td>
            4.<xsl:value-of select="$shift_fac_uf_lazer+$co_sv_prots_fac9_1+$co_sv_prots_fac9_4+$co_sv_prots_fac9_3"/>
          </td>
          <td colspan="2" >
              Неионизирующие излучения. Электростатическое поле (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='9_3']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac9_2>0">
        <tr>
          <td>
            4.<xsl:value-of select="$shift_fac_uf_lazer+$co_sv_prots_fac9_1+$co_sv_prots_fac9_4+$co_sv_prots_fac9_3+$co_sv_prots_fac9_2"/>
          </td>
          <td colspan="2" >
              Неионизирующие излучения. Постоянное магнитное поле (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='9_2']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac10>0">
        <tr>
          <td>
            4.<xsl:value-of select="$shift_fac1_9+$co_sv_prots_fac10"/>
          </td>
          <td colspan="2" >
            Ионизирующие излучения (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='10']"/>)
          </td>
          <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac11>0">
        <tr>
          <td>
            4.<xsl:value-of select="$shift_fac1_9+$co_sv_prots_fac10+$co_sv_prots_fac11"/>
          </td>
          <td colspan="2" >
              Микроклимат (параметры микроклимата) (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='11']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac12>0">
        <tr>
          <td>
            4.<xsl:value-of select="$shift_fac1_9+$co_sv_prots_fac10+$co_sv_prots_fac11+$co_sv_prots_fac12"/>
          </td>
          <td colspan="2" >
              Световая среда (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='12']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac13>0">
        <tr>
          <td>
            4.<xsl:value-of select="$shift_fac1_12+$co_sv_prots_fac13"/>
          </td>
          <td colspan="2" >
              Факторы трудового процесса. Тяжесть трудового процесса (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='13']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
      <xsl:if test="$co_sv_prots_fac14>0">
        <tr>
          <td>
            4.<xsl:value-of select="$shift_fac1_12+$co_sv_prots_fac13+$co_sv_prots_fac14"/>
          </td>
          <td colspan="2" >
              Факторы трудового процесса. Напряжённость трудового процесса (Протокол № <xsl:apply-templates select="ORG/prot[@fac_id2='14']"/>)
            </td>
            <td class="page"></td>
        </tr>
      </xsl:if>
    </xsl:if>
      <!-- Продолжение сводных отчетов сразу же после протоколов -->
      <xsl:variable name="shift_num">
        <xsl:choose>
          <xsl:when test="$co_sv_prots>0">
            <xsl:copy-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <tr>
        <td>
          <xsl:value-of select="4 + $shift_num"/>.
        </td>
        <td colspan="2">Сводная ведомость результатов проведения специальной оценки условий труда</td>
        <td class="page"></td>
      </tr>
      <tr>
        <td>
          <xsl:value-of select="5 + $shift_num"/>.
        </td>
        <td colspan="2">Перечень рекомендуемых мероприятий по улучшению условий труда</td>
        <td class="page"></td>
      </tr>
      <tr>
        <td>
          <xsl:value-of select="6 + $shift_num"/>.
        </td>
        <td colspan="2">Заключение эксперта по результатам проведения специальной оценки условий труда</td>
        <td class="page"></td>
      </tr>
    </table>
  </xsl:template>

  <xsl:template match ="prot" >
    <xsl:if test="position()>1">; </xsl:if>
    <xsl:value-of select="@num_doc"/> от <xsl:value-of select="@fill_date"/>
  </xsl:template>
  
  <xsl:template match ="RM[@anal_rm=0]">
    <tr>
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      <td>
        3.<xsl:value-of select="count(preceding-sibling::RM[@anal_rm=0])+1"/>
      </td>
      <td width="6%">
        РМ<xsl:text>&#xa0;</xsl:text>№<xsl:value-of select="@num"/>.
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td class="page"></td>
    </tr>
  </xsl:template>

  <xsl:template match ="PODR">
    <tr>
      <td></td>
      <td colspan="2">
        <b>
          <xsl:value-of select="@name"/>
        </b>
      </td>
      <td></td>
    </tr>
  </xsl:template>

</xsl:stylesheet>