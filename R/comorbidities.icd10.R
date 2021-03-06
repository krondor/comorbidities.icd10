#' Categorizes ICD-9-CM and ICD-10 codes based on published comorbidity indices
#' 
#' This package is for calculating comorbidities using administrative 
#' ICD-9 and ICD-10 codes. Methods to categorize codes into
#' sensible disease categories have been developed and published by numerous 
#' authors.  Two of the most widely used such methods are the Deyo/Quan adaptation
#' of Charlson index and the Elixhauser index. This package has functions to
#' categorize comorbidites into four Charlson-index alternatives, two Elixhauser
#' index alternatives,  and the AHRQ comorbidity index (an update to the original
#' Elixhauser method, currently only available for ICD-9).
#' 
#' In this remake of the comorbidity package the main comorbidity calculator function 
#' is the \code{\link{cmrbdt.calc}} function. You should try to use this instead 
#' of the \bold{deprecated} \code{\link{deyo}}, \code{\link{elixhauser}}, and
#' \code{\link{ahrq}} functions. The function is more flexible and allows 
#' a more unified approach to calculating comorbidities. You can provide the function
#' any of the available cmrbdt.finder* functions or write your own finder using as 
#' long as you comply to the same API. 
#' 
#' The value returned consists of a vector + one or two data frames. The vector is the
#' total comorbidity count, or in the case of the Charlson score, the total Charlson
#' score. Each row in the data frame is devoted to a particular patient according to 
#' the corresponding ID-codes provided to the function. The data frame codes a
#' \code{FALSE} if the patient does not have that diagnosis and \code{TRUE} if the
#' patient does have that diagnosis. 
#' 
#' @docType package
#' @name comorbidities.icd10-package
#' @keywords package
#' @author Paul Gerrard, Max Gordon
NULL
