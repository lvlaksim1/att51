<?xml version = "1.0" encoding = "UTF-8" ?>
<xsl:stylesheet version = "1.0"	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
  <!-- определяем тип -->

  <xsl:template match ="/">

    <html>
      <head>
        <title>Сводный протокол измерений показателей тяжести трудового процесса</title>
        <style>
          /* Style Definitions */
          body
          {
          font-size:11.0pt;
          font-family:"Times New Roman";
          text-align:left;
          }
          p
          {
          margin-bottom:0cm;
          margin-top:0.5cm;
          }
          .rep_data{
          font-size:12.0pt;
          font-style:italic;
          text-decoration: underline;
          margin-left:10px
          margin-right:10px
          }
          p.razdel
          {
          font-size:11.0pt;
          font-weight: bold;
          margin-top:0.1cm;
          margin-bottom:0.1cm;
          }
          .razdel2
          {
          font-size:11.0pt;
          font-weight: bold;
          }

          .underline
          {
          text-decoration: underline;
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
          tr.prot {
          font-weight: bold;
          }
          tr.zone {
          font-style:italic;
          }
          tr.param {
          font-size:9.0pt;
          }
          tr.param_header {
          font-size:9.0pt;
          font-weight: bold;
          }

          .prim
          {
          font-size:9.0pt;
          margin-bottom:0cm;
          margin-top:0cm;
          }

          .prot
          {
          font-size:12.0pt;
          font-weight: bold;
          text-align: center;
          margin-bottom:0.2cm;
          margin-top:0.2cm;
          }
          table.header
          {
          font-size:9.0pt;
          border:1px solid black;border-collapse:collapse;padding:0 0px 0 5px;
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
        </style>
      </head>
      <body>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match ="Document">
    <p>
      3. Результат проведения специальной оценки условий труда (СОУТ).<br/>
      3.1. Количество рабочих мест, на которых проведена СОУТ:<span class="rep_data">
        <xsl:text>&#160;</xsl:text><xsl:value-of select="@col_rm"/><xsl:text>&#160;</xsl:text>
      </span><br/>
      3.2. Рабочие места, подлежащие декларированию:<br/>
      3.2.1. Рабочие места, на которых вредные факторы не идентифицированы:<br/>
      <xsl:apply-templates select="ident_rms"/>
      3.2.2. Рабочие места, на которых вредные факторы не выявлены по результатам СОУТ (оптимальные или допустимые условия труда):<br/>
      <xsl:apply-templates select="rms_cl1_2"/>
      3.3. Количество рабочих мест с оптимальными и допустимыми условиями труда:<span class="rep_data">
      <xsl:text>&#160;</xsl:text><xsl:value-of select="@dop_rm"/><xsl:text>&#160;</xsl:text>
      </span><br/>
      3.4. Количество рабочих мест с вредными и опасными условиями труда:<span class="rep_data">
      <xsl:text>&#160;</xsl:text><xsl:value-of select="@bad_rm"/><xsl:text>&#160;</xsl:text>
      </span><br/>
      3.5. Количество рабочих мест с правом на досрочную страховую пенсию:<span class="rep_data">
      <xsl:text>&#160;</xsl:text><xsl:value-of select="@lpo_rm"/><xsl:text>&#160;</xsl:text>
      </span><br/>
      3.6. Количество рабочих мест на которых были выявлены профессиональные заболевания:<span class="rep_data">
      <xsl:text>&#160;</xsl:text><xsl:value-of select="@profzab_rm"/><xsl:text>&#160;</xsl:text>
      </span><br/>
      3.7. Количество рабочих мест на которых были зафиксированы несчастные случаи:<span class="rep_data">
      <xsl:text>&#160;</xsl:text><xsl:value-of select="@accident_rm"/><xsl:text>&#160;</xsl:text>
      </span><br/>
      3.8. Выявленные вредные и (или) опасные производственные факторы на основе измерений и оценок:
      <xsl:apply-templates select="factors"/>
      3.9. Рабочие места, на которых в соответствии с пунктом 6 статьи 10 426-ФЗ идентификация не проводилась:
      <xsl:apply-templates select="rms_no_ident"/>
      3.9.1. Рабочие места с оптимальными и допустимыми условиями труда, на которых в соответствии с пунктом 6 статьи 10 426-ФЗ идентификация не проводилась:
      <xsl:apply-templates select="rms_no_ident_1_2"/>
      3.9.2. Рабочие места с вредными и опасными условиями труда, на которых в соответствии с пунктом 6 статьи 10 426-ФЗ идентификация не проводилась:
      <xsl:apply-templates select="rms_no_ident_3_4"/>
      3.10. Количество рабочих мест, на которых в соответствии с пунктом 6 статьи 10 426-ФЗ идентификация не проводилась:<span class="rep_data">
      <xsl:text>&#160;</xsl:text><xsl:value-of select="rms_no_ident/@col"/><xsl:text>&#160;</xsl:text>
      </span><br/>
      3.11. Количество рабочих мест, подлежащих декларированию:<span class="rep_data">
      <xsl:text>&#160;</xsl:text><xsl:value-of select="@decl_rms_co"/><xsl:text>&#160;</xsl:text>
      </span><br/>
      3.12. Количество рабочих, на которых вредные факторы не идентифицированы:<span class="rep_data">
      <xsl:text>&#160;</xsl:text>
      <xsl:value-of select="@good_rm_co"/>
      <xsl:text>&#160;</xsl:text>
      </span><br/>
      3.13. Количество рабочих мест с оптимальными и допустимыми условиями труда, подлежащих декларированию:<span class="rep_data">
      <xsl:text>&#160;</xsl:text>
      <xsl:value-of select="@good_rm1_2_co"/>
      <xsl:text>&#160;</xsl:text></span><br/>
      3.14. Количество рабочих, на которых проведена идентификация:<span class="rep_data">
      <xsl:text>&#160;</xsl:text>
      <xsl:value-of select="@ident_rm_co"/>
      <xsl:text>&#160;</xsl:text></span><br/>
      3.15. Рабочие места, не подлежащие декларированию (требуется оценка в следующий цикл проведения СОУТ):
      <xsl:apply-templates select="rms_no_declare"/>
    </p>
    <p>
      4. Результаты специальной оценки условий труда представлены в:<br/>
      - картах СОУТ;<br/>
      - протоколах оценок и измерений ОВПФ;<br/>
      - сводной ведомости результатов СОУТ.
    </p>
    <p>
      5. По результатам специальной оценки условий труда разработан перечень рекомендуемых мероприятий 
      по улучшению условий труда для <span class="rep_data"><xsl:text>&#160;</xsl:text><xsl:value-of select="@meas_rm"/><xsl:text>&#160;</xsl:text></span> рабочих мест.
    </p>
    <p>
      6. Рассмотрев результаты специальной оценки условий труда, эксперт заключил:<br/>
      1) считать работу по СОУТ завершенной;<br/>
      2) перечень рекомендуемых мероприятий по улучшению условий труда передать для утверждения работодателю.<br/>
      Дополнительные предложения эксперта:<span class="rep_data"> отсутствуют</span>.
    </p>
    <p>
      <xsl:text>&#160;</xsl:text>
    </p>
  </xsl:template>


  <xsl:template match ="podr">
    <xsl:if test="@ceh_name">
      <tr>
        <td colspan="3">
          <b><xsl:value-of select="@ceh_name"/></b>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="rms_no_ident|rms_no_ident_1_2|rms_no_ident_3_4|rms_no_declare">
    <xsl:if test="@col=0">
      <span class="rep_data">Отсутствуют</span><br/></xsl:if>
    <xsl:if test="@col>0">
      <table width="100%">
        <tr>
          <td align="center" width="15%">№ РМ</td>
          <td align="center" width="70%">Наименование РМ</td>
          <td align="center" width="15%">Кол-во работников</td>
       </tr>
        <xsl:apply-templates select="podr|rm_no_ident"/>
      </table>
    </xsl:if>
  </xsl:template>


  <xsl:template match ="rm_no_ident">
    <tr>
      <td align="center">
        <xsl:value-of select="@code"/>
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td align="center">
        <xsl:value-of select="@colrab"/>
      </td>
    </tr>
  </xsl:template>  
  
  <xsl:template match ="ident_rms">
    <xsl:if test="@col=0">
      <span class="rep_data">Отсутствуют</span><br/></xsl:if>
    <xsl:if test="@col>0">
      <table width="100%">
        <tr>
          <td align="center" width="15%">№ РМ</td>
          <td align="center" width="70%">Наименование РМ</td>
          <td align="center" width="15%">Кол-во работников</td>
       </tr>
        <xsl:apply-templates select="podr|ident_rm"/>
      </table>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="ident_rm">
    <tr>
      <td align="center">
        <xsl:value-of select="@code"/>
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td align="center">
        <xsl:value-of select="@colrab"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match ="rms_cl1_2">
    <xsl:if test="@col=0">
      <span class="rep_data">Отсутствуют</span><br/></xsl:if>
    <xsl:if test="@col>0">
      <table width="100%">
        <tr>
          <td align="center" width="15%">№ РМ</td>
          <td align="center" width="70%">Наименование РМ</td>
          <td align="center" width="15%">Кол-во работников</td>
       </tr>
        <xsl:apply-templates select="podr|rm_cl1_2"/>
      </table>
    </xsl:if>
  </xsl:template>

  <xsl:template match ="rm_cl1_2">
    <tr>
      <td align="center">
        <xsl:value-of select="@code"/>
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td align="center">
        <xsl:value-of select="@colrab"/>
      </td>
    </tr>
  </xsl:template>


  <xsl:template match ="factors">
    <table width="100%">
      <tr>
        <td align="center" width="75%">Наименование вредного и (или) опасного производственного фактора</td>
        <td align="center" width="25%">Кол-во рабочих мест</td>
      </tr>
      <xsl:apply-templates select="factor"/>
    </table>
  </xsl:template>

  <xsl:template match ="factor">
    <tr>
      <td align="center">
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:value-of select="@col"/>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>