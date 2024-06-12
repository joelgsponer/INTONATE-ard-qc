# not defined
not_defined <- function(base, rec) return(0)

# always meaningful
always_meaningful <- function(base, rec) return(1)
# any increase
any_increase <-  function(base, rec){
  as.numeric(rec$aval > base$aval)
}
# if Yes
if_Yes <- function(base, rec){
  as.numeric(rec$aval == "Yes")
}
# if No
if_No <- function(base, rec){
  as.numeric(rec$aval == "No")
}
# FSS worsening
FSS_worsening <- function(base, rec){
  delta <- rec$aval - base$aval
  if(base$aval == 0) return(0)
  if(base$aval > 0) return(as.numeric(delta >= 1))
}
# EDSS worsening
EDSS_worsening <- function(base, rec){
  delta <- rec$aval - base$aval
  if(base$aval  <= 5) return(as.numeric(delta >=1))
  if(base$aval > 5) return(as.numeric(delta >= 0.5))
}
# increase over 20 percent
increase_over_20_percent <- function(base, rec){
  delta <- rec$aval - base$aval
  res <- delta > (0.2 * base$aval)
  return(as.numeric(res))
}

# decrease over 20 percents
decrease_over_0_5 <- function(base, rec){
  delta <- rec$aval - base$aval
  res <- delta < -0.5
  return(as.numeric(res))
}
#increase over 0.5
increase_over_0_5 <- function(base, rec){
   delta <- rec$aval - base$aval
   res <- delta > 0.5
   return(as.numeric(res))
}
# decrease over 5
decrease_over_5 <- function(base, rec){
  delta <- rec$aval - base$aval
  res <- delta < -5
  return(as.numeric(res))
}
# increase over  10
increase_over_10 <- function(base, rec){
  delta <- rec$aval - base$aval
  res <- delta > 10
  return(as.numeric(res))
}
# Values over 0
value_over_0 <- function(base,rec){
  return(as.numeric(rec$aval > 0))
}

# Worsening functions
WORSENING_FUNCTIONS <- list(
    "relapse"= always_meaningful,
    "MRI Gd+ T1 lesion count"= any_increase,
    "MRI Gd+ T1 lesion count increased"= if_Yes,
    "MRI Gd+ T1 lesion count not increased"= if_No,
    "MRI T2 new lesion count" = value_over_0,
    "MRI T2 lesion count"= any_increase,
    "MRI T2 lesion count increased"= if_Yes,
    "MRI T2 lesion count not increased"= if_No,
    "MRI T2 lesion volume"= any_increase,
    "MRI T2 lesions worsening"= if_Yes,
    "Body weight"= not_defined,
    "Body height"= not_defined,
    "BMI"= not_defined,
    "Smoking frequency"= not_defined,
    "Vitamin D serum level"= not_defined,
    "9HPT"= increase_over_0_5,
    "AI"= not_defined,
    "BAI"= not_defined,
    "BDI"= increase_over_10,
    "BLCS"= not_defined,
    "BWCS"= not_defined,
    "DS"= not_defined,
    "EDSS"= EDSS_worsening,
    "EDSS - ambulation"= EDSS_worsening,
    "EQ- 5D"= not_defined,
    "EQ-VAS"= not_defined,
    "FIM"= not_defined,
    "FSS - bowel & bladder"= FSS_worsening,
    "FSS - brainstem"= FSS_worsening,
    "FSS - cerebellar"= FSS_worsening,
    "FSS - cerebral"= FSS_worsening,
    "FSS - other"= FSS_worsening,
    "FSS - pyramidal"= FSS_worsening,
    "FSS - sensory"= FSS_worsening,
    "FSS - visual"= FSS_worsening,
    "GNDS"= not_defined,
    "HADS – Anxiety"= not_defined,
    "HADS – Depression"= not_defined,
    "IVIS"= not_defined,
    "LCLA"= not_defined,
    "MFIS"= not_defined,
    "MHI"= not_defined,
    "MHA"= not_defined,
    "MHD"= not_defined,
    "MHC"= not_defined,
    "MHP"= not_defined,
    "MMSE"= not_defined,
    "MSDRS"= not_defined,
    "MSFC"= decrease_over_0_5,
    "MSFOL-54"= not_defined,
    "MSIS-29"= not_defined,
    "MSSS"= not_defined,
    "TAN"= not_defined,
    "EMI"= not_defined,
    "AFF"= not_defined,
    "POS"= not_defined,
    "MusiQol"= not_defined,
    "NFI-MS"= not_defined,
    "PASAT"= decrease_over_0_5,
    "PASAT-2"= not_defined,
    "PASAT-3"= not_defined,
    "PDQ"= not_defined,
    "PES"= not_defined,
    "SDMT"= not_defined,
    "SF-36"= not_defined,
    "SMSS"= not_defined,
    "SSS"= not_defined,
    "T25FWT"= increase_over_0_5,
    "TUG duration"= not_defined,
    "TUG falls"= not_defined,
    "VCWS-4"= not_defined,
    "FSMC"= increase_over_10,
    "FSMC-cognitive"= increase_over_10,
    "FSMC-motor"= increase_over_10,
    "MUSIC-cognitive"= decrease_over_5,
    "MUSIC-fatigue"= decrease_over_5
)

