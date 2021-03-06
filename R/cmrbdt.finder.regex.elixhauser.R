#' Finds the matching codes for the different comorbidity groups
#'
#' The functions loop through all the comorbidity groups in search
#' for a matching group to the provided \code{icd_codes}.
#'
#' The \code{_regex} indicates that these functions use regular expressions
#' for identification of codes of interest. The match is case-insensitive.
#' The function can also identify acute conditions and ignore those if specified.
#'
#' @param icd_codes The icd code of interest, either a number or a string
#' @param out If the function has been run previously there
#'  may already be matches for a particular group, if the
#'  out parameter is supplied with a vector equal to the
#'  number of Elixhauser comorbidities with their corresponding
#'  names only new findings will be appended.
#' @param country_code The two-letter \code{ISO 3166-1 alpha-2}
#'  code indicating the country of interest (the same as the top-level
#'  internet domain name of that country). As certain countries
#'  have adapted country-specific ICD-coding there may be minor
#'  differences between countries. Currently only Swedish (SE) and
#'  US codes are implemented. The function defaults to 'US'.
#' @param include_acute Certain codes may indicate a non-chronic
#'  disease such as heart infarction, stroke or similar. Under some
#'  circumstances these should be ignored, e.g. when studying predictors
#'  for hip arthroplasty re-operations codes during the admission
#'  for the surgery should not include myocardial infarction as this
#'  is most likely a postoperative condition not available for scoring
#'  prior to the surgery.
#' @param icd_ver The icd version of interest. If FALSE the software tries
#'  to automatically identify code version depending on the first letter,
#'  \code{\link{pr.get.icd.ver}}
#' @return \code{vector} Returns a vector with the names of each comorbidity
#'  group. If the entry is FALSE this correspond to that no code matched the
#'  other group otherwise it returns TRUE.
#' @references H. Quan, V. Sundararajan, P. Halfon, A. Fong, B. Burnand, J.-C. Luthi,
#' L. D. Saunders, C. A. Beck, T. E. Feasby, and W. A. Ghali, "Coding algorithms for
#' defining comorbidities in ICD-9-CM and ICD-10 administrative data" Med Care,
#' vol. 43, no. 11, pp. 1130-1139, Nov. 2005. - Elixhauser section
#' @rdname cmrbdt.finder.regex
#' @export
#' @seealso \code{\link{cmrbdt.calc}}
#' @family cmrbdtf.finder functions
cmrbdt.finder.regex.elixhauser_Quan2005 <-
  local({
    elixhausers <- list(US = list())

    #Congestive heart failure
    elixhausers$US[['CHF']] <-
      list(icd10 = c('^I099', '^I1(10|3[02])',
                     '^I255', '^I4(2[056789]|3)', '^I50', '^P290'),
           icd9 = c('^39891', '^402(01|11|91)',
                    '^404(01|03|[19][13])', '^42(5[456789]|8)'))

    # Cardiac arrhythmias
    elixhausers$US[['ARRHYTHMIA']] <-
      list(icd10 = c('^I44[123]', '^I456', '^I459',
                     '^I4[789]', '^R00[018]', '^T821',
                     '^Z[49]50'),
           icd9 = c('^426([079]|1[023])',
                    '^427[012346789]', # Maybe '^427[^5]' is faster
                    '^7850',
                    '^9960[14]',
                    '^V450', '^V533'))

    # Valvular disease
    elixhausers$US[['VALVE']] <-
      list(icd10 = c('^A520', '^I0[5678]',
                     '^I09[18]', '^I3[456789]',
                     '^Q23[0123]', '^Z95[234]'),
           icd9 = c('^0932', '^39[4567]', '^424',
                    '^746[3456]', '^V422', '^V433'))

    # Pulmonary circulation disorders
    elixhausers$US[['PULM.CIRC']] <-
      list(icd10 = c('^I2([67]|8[089])'),
           icd9 = c('^415[01]', '^416',
                    '^417[089]'))

    elixhausers$US[['PVD']] <-
      list(icd10 = c('^I7([01]|3[189]|71|9[02])', '^K55[189]', '^Z95[89]'),
           icd9 = c('^0930', '^4373', '^44([01]|3[123456789])', '^4471',
                    '^557[19]', '^V434'))

    # Hypertension, uncomplicated
    elixhausers$US[['HTN.UNCOMP']] <-
      list(icd10 = c('^I10'),
           icd9 = c('^401'))

    # Hypertension, complicated
    elixhausers$US[['HTN.COMP']] <-
      list(icd10 = c('^I1[1235]'),
           icd9 = c('^40[2345]'))

    # Paralysis
    elixhausers$US[['PARALYSIS']] <-
      list(icd10 = c('^G041', '^G114', '^G8(0[12]|[12]|3[012349])'),
           icd9 = c('^3341', '^34([23]|4[01234569])'))

    # Other neurological disorders
    elixhausers$US[['NEURO.OTHER']] <-
      list(icd10 = c('^G1[0123]', '^G2[012]', '^G25[45]',
                     '^G31[289]',
                     '^G3[2567]',
                     '^G4[01]', '^G93[14]',
                     '^R470', '^R56'),
           icd9 = c('^3319', '^332[01]',
                    '^333[45]',
                    '^33([45]|62)',
                    '^34([015]|8[13])',
                    '^78[04]3'))

    # Chronic pulmonary disease
    elixhausers$US[['CHRONIC.PULM']] <-
      list(icd10 = c('^I27[89]', '^J4[01234567]', '^J6([01234567]|84)', '^J70[13]'),
           icd9 = c('^416[89]', '^49', '^50([012345]|64|8[18])'))


    # Diabetes, uncomplicated
    # Slightly different from charlsons
    elixhausers$US[['DM.UNCOMP']] <-
      list(icd10 = c('^E1[01234][019]'),
           icd9 = c('^250[0123]'))

    # Diabetes, complicated
    # Slightly different from charlsons
    elixhausers$US[['DM.COMP']] <-
      list(icd10 = c('^E1[01234][2345678]'),
           icd9 = c('^250[456789]'))

    # Hypothyroidism
    elixhausers$US[['HYPOTHYROID']] <-
      list(icd10 = c('^E0[0123]', '^E890'),
           icd9 = c('^2409', '^24([34]|6[18])'))

    # Renal failure
    # Differs from Charlsons
    elixhausers$US[['RENAL']] <-
      list(icd10 = c('^I120', '^I131', '^N1[89]', '^N250', '^Z49[012]', '^Z940', '^Z992'),
           icd9 = c('^403[019]1', '^404[019][23]', '^58([56]|80)',
                    '^V4(20|51)', '^V56'))


    # Liver disease
    elixhausers$US[['LIVER']] <-
      list(icd10 = c('^B18', '^I8(5|64)', '^I982', '^K7(0|1[13457]|[234]|6[023456789])', '^Z944'),
           icd9 = c('^070([23][23]|[45]4|[69])', '^456[012]',
                    '^57([01]|2[2345678]|3[3489])', '^V427'))


    # Peptic ulcer disease excluding bleeding
    elixhausers$US[['PUD']] <-
      list(icd10 = c('^K2[5678][79]'),
           icd9 = c('^53[1234][79]'))


    # AIDS/HIV
    elixhausers$US[['HIV']] <-
      list(icd10 = c('^B2[0124]'),
           icd9 = c('^04[234]'))

    # Lymphoma
    elixhausers$US[['LYMPHOMA']] <-
      list(icd10 = c('^C8[123458]',
                     '^C96', '^C90[02]'),
           icd9 = c('^20[012]', '^2030', '^2386'))

    # Metastatic cancer
    elixhausers$US[['METS']] <-
      list(icd10 = c('^C7[789]', '^C80'),
           icd9 = c('^19[6789]'))

    # Solid tumor without metastasis
    elixhausers$US[['SOLID.TUMOR']] <-
      list(icd10 = c('^C[01]', '^C2[0123456]',
                     '^C3[01234789]', '^C4[01356789]', '^C5[012345678]',
                     '^C6', '^C7[0123456]', '^C97'),
           icd9 = c('^1[456]', '^17[012456789]', '^18', '^19([012345])'))


    # Rheumatoid arthritis/collagen vascular diseases
    elixhausers$US[['RHEUM']] <-
      list(icd10 = c('^L94[013]', '^M0[568]', '^M12[03]',
                     '^M3(0|1[0123]|[2345])', '^M4(5|6[189])'),
           icd9 = c('^446', '^7010', '^71(0[0123489]|12|4|93)',
                    '^72([05]|8(5|89)|930)'))

    # Coagulopathy
    elixhausers$US[['COAG']] <-
      list(icd10 = c('^D6[5678]',
                     '^D69[13456]'),
           icd9 = c('^286', '^2871', '^287[345]'))

    # Obesity
    elixhausers$US[['OBESITY']] <-
      list(icd10 = c('^E66'),
           icd9 = c('^2780'))

    # Weight loss
    elixhausers$US[['WT.LOSS']] <-
      list(icd10 = c('^E4[0123456]', '^R634', '^R64'),
           icd9 = c('^26[0123]', '^7832', '^7994'))

    # Fluid and electrolyte disorders
    elixhausers$US[['LYTES']] <-
      list(icd10 = c('^E222', '^E8[67]'),
           icd9 = c('^2536', '^276'))

    # Blood loss anemia
    elixhausers$US[['ANEMIA.LOSS']] <-
      list(icd10 = c('^D500'),
           icd9 = c('^2800'))

    # Deficiency anemia
    elixhausers$US[['ANEMIA.DEF']] <-
      list(icd10 = c('^D50[89]', '^D5[123]'),
           icd9 = c('^280[123456789]', '^281'))

    # Alcohol abuse
    elixhausers$US[['ETOH']] <-
      list(icd10 = c('^F10', '^E52', '^G621', '^I426',
                     '^K292', '^K70[039]',
                     '^T51', '^Z502',
                     '^Z714', '^Z721'),
           icd9 = c('^2652', '^291[12356789]',
                    '^303[09]', '^3050', '^3575',
                    '^4255', '^5353', '^571[0123]', '^980', '^V113'))

    # Drug abuse
    elixhausers$US[['DRUGS']] <-
      list(icd10 = c('^F1[12345689]',
                     '^Z715', '^Z722'),
           icd9 = c('^292', '^304', '^305[23456789]', '^V6542'))

    # Psychoses
    elixhausers$US[['PSYCHOSES']] <-
      list(icd10 = c('^F2[0234589]',
                     '^F3([01]2|15)'),
           icd9 = c('^2938',
                    '^296[0145]4',
                    '^29[578]'))


    # Depression
    elixhausers$US[['DEPRESSION']] <-
      list(icd10 = c('^F204',
                     '^F31[345]', '^F3[23]',
                     '^F341', '^F4[13]2'),
           icd9 = c('^296[235]',
                    '^30(04|9)', '^311'))

    # The Swedish version
    elixhausers$SE <- elixhausers$US
    #Congestive heart failure
    elixhausers$SE$CHF$icd9 <-
      c('^3980', '^402', '^4040', '^42(5[456789]|8)')

    # Cardiac arrhythmias
    elixhausers$SE$ARRHYTHMIA$icd9 <-
      c('^426[079]', # The .1 codes are not valid for Sweden
        '^427[012346789]', # Maybe '^427[^5]' is faster
        '^7850',
        #'^9960[14]',
        '^V450', '^V533')

    # Valvular disease - no change

    # Pulmonary circulation disorders - no change

    # PVD  - no change

    # Hypertension, uncomplicated - no change

    # Hypertension, complicated - no change

    # Paralysis - no change

    # Other neurological disorders - no change

    # Chronic pulmonary disease - no change

    # Diabetes, uncomplicated - no change

    # Diabetes, complicated - no change

    # Hypothyroidism - no change

    # Renal failure
    elixhausers$SE$RENAL$icd9 <-
      c('^403', '^404', '^58([56]|80)',
        '^V4(20|51)', '^V56')


    # Liver disease
    elixhausers$SE$LIVER$icd9 <-
      c('^070([23]|[45])', '^456[012]',
        '^57([01]|2[2345678]|3[3489])', '^V427')

    # Peptic ulcer disease excluding bleeding
    elixhausers$SE$PUD$icd9 <-
      c('^53[1234][79]')

    # AIDS/HIV
    elixhausers$SE$HIV$icd9 <-
      c('279K')

    # Lymphoma - no change

    # Metastatic cancer - no change

    # Solid tumor without metastasis - no change

    # Rheumatoid arthritis/collagen vascular diseases
    elixhausers$SE$RHEUM$icd9 <-
      c('^446', '^7010', '^71(0[0123489]|12|4|93)',
        '^72([05]|8[58]|93)')

    # Coagulopathy - no change

    # Obesity - no change

    # Weight loss - no change

    # Fluid and electrolyte disorders - no change

    # Blood loss anemia - no change

    # Deficiency anemia - no change

    # Alcohol abuse - no change

    # Drug abuse - no change

    # Psychoses
    elixhausers$SE$PSYCHOSES$icd9 <-
      c('^2938',
        #'^296[0145]4',
        # Changes in Swedish version
        '^296[08]',
        '^29[578]')

    # Depression
    elixhausers$SE$DEPRESSION$icd9 <-
      c('^296[135]',
        '^30(04|9)', '^311')

    acute_icd_codes <- list(icd10= '^(I2[123]|J46|N17[12]|N19)',
                            # Used the translator from the Swedish National Board of Healthe and Welfare (Socialstyrelsen)
                            icd9 = '^(410|42(30|95|96|98)|4939|58[34][67]|5908|586|7919|5939)')

    function(icd_codes,
             out,
             country_code,
             include_acute = rep(TRUE, times=length(icd_codes)),
             icd_ver = rep(FALSE, times=length(icd_codes))){

      # Speeds up only to check the codes that are possible
      icd_ver <- pr.get.icd.ver(icd_codes, icd_ver)

      # Check that the country code is available
      if (!country_code %in% names(elixhausers))
        stop("The requested country code '", country_code ,"''",
             " is not yet available for Elixhausers.",
             " The only country codes available are:",
             " '", paste(names(elixhausers), collapse="', '", "'"))

      # Get a correctly formatted output vector
      out <- pr.get.out.vector(out, elixhausers[[country_code]])

      # Do the actual test loop
      out <- pr.regex.code.match(out = out,
                                 icd_codes = icd_codes,
                                 cmrbdt.finder.regex.comorbidity = elixhausers[[country_code]],
                                 icd_ver =  icd_ver,
                                 include_acute = include_acute,
                                 cmrbdt.finder.regex.acute = acute_icd_codes)

      return(out)
    }
  })
