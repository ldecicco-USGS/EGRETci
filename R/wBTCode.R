.onAttach <- function(libname, pkgname) {
  if (!interactive()) return()
  EGRET_version = utils::packageVersion("EGRETci")
  packageStartupMessage("EGRETci ", EGRET_version,"
Extended Documentation: https://doi-usgs.github.io/EGRETci/")
}

#' EGRETci package for bootstrap hypothesis tests and confidence interval analysis for WRTDS (Weighted 
#' Regressions on Time, Discharge, and Season) statistical models. This 
#' package is designed to be used in conjunction with the EGRET package, 
#' which estimates and describes WRTDS models.
#'
#' \tabular{ll}{
#' Package: \tab EGRETci\cr
#' Type: \tab Package\cr
#' License: \tab Unlimited for this package, dependencies have more restrictive licensing.\cr
#' Copyright: \tab This software is in the public domain because it contains materials
#' that originally came from the United States Geological Survey, an agency of
#' the United States Department of Interior. For more information, see the
#' official USGS copyright policy at
#' \url{https://www.usgs.gov/information-policies-and-instructions/copyrights-and-credits}\cr
#' LazyLoad: \tab yes\cr
#' }
#' Collection of functions to evaluate uncertainty of results from water quality analysis using 
#' the Weighted Regressions on Time Discharge and Season (WRTDS) method. This package is an add-on 
#' to the EGRET package that performs the WRTDS analysis.
#'
#' @name EGRETci-package
#' @docType package
#' @author Robert M. Hirsch \email{rhirsch@@usgs.gov}, Laura De Cicco \email{ldecicco@@usgs.gov}
#' @references Hirsch, R.M., and De Cicco, L.A., 2015, User guide to Exploration and Graphics for RivEr Trends 
#' (EGRET) and dataRetrieval: R packages for hydrologic data: U.S. Geological Survey Techniques and Methods book 4, 
#' chap. A10, 94 p., \doi{10.3133/tm4A10}
#' @references Hirsch, R.M., Archfield, S.A., and De Cicco, L.A., 2015, 
#' A bootstrap method for estimating uncertainty of water quality trends.  
#' Environmental Modelling & Software, 73, 148-166. 
#' @keywords internal  
"_PACKAGE"

#' Interactive setup for running wBT, the WRTDS Bootstrap Test
#'
#' Walks user through the set-up for the WRTDS Bootstrap Test.  Establishes 
#' start and end year for the test period.  Sets the minimum number of 
#' bootstrap replicates to be run, the maximum number of bootstrap replicates 
#' to be run, and the block length (in days) for the block bootstrapping.
#' The test is designed to evaluate the uncertainty about the trend between any pair of years.
#'
#' @param eList named list with at least the Daily, Sample, and INFO dataframes. Created from the EGRET package, after running \code{\link[EGRET]{modelEstimation}}.
#' @param \dots  additional arguments to bring in to reduce interactive options 
#' (year1, year2, nBoot, bootBreak, blockLength)
#' @keywords WRTDS water-quality
#' @return caseSetUp data frame with columns year1, yearData1, year2, yearData2, 
#' numSamples, nBoot, bootBreak, blockLength, confStop. These correspond to:
#' \tabular{ll}{
#' Column Name \tab Manuscript Variable\cr
#' year1 \tab \eqn{y_s} \cr
#' year2 \tab \eqn{y_e} \cr
#' nBoot \tab \eqn{M_max} \cr
#' bootBreak \tab \eqn{M_min} \cr
#' blockLength \tab \eqn{B} \cr
#' }
#' @export
#' @seealso \code{\link{setForBoot}}, \code{\link{wBT}}
#' @examples
#' eList <- EGRET::Choptank_eList
#' 
#' # Completely interactive:
#' # caseSetUp <- trendSetUp(eList)
#' # Semi-interactive:
#' # caseSetUp <- trendSetUp(eList, nBoot = 100, blockLength = 200)
#' 
#' # fully scripted:
#' caseSetUp <- trendSetUp(eList,
#'   year1=1985, 
#'   year2=2005,
#'   nBoot = 50, 
#'   bootBreak = 39,
#'   blockLength = 200)
#' 
trendSetUp <- function(eList, ...){
  
  matchReturn <- list(...)
  
  numSamples <- length(eList$Sample$Date)
  message("Sample set runs from ", as.integer(eList$Sample$DecYear[1])," to ",
          as.integer(eList$Sample$DecYear[numSamples]))
  
  if(!is.null(matchReturn$year1)){
    year1 <- matchReturn$year1
  } else {
    message("Enter first water year of trend period")
    year1 <- as.numeric(readline())
  }
  message("year1 = ",year1," this is the first water year of trend period")
  
  if(!is.null(matchReturn$year2)){
    year2 <- matchReturn$year2
  } else {
    message("Enter last water year of trend period")
    year2 <- as.numeric(readline())
  }
  message("year2 = ",year2," this is the last water year of trend period")
  
  yearData1 <- trunc(eList$Sample$DecYear[1]+0.25)
  yearData2 <- trunc(eList$Sample$DecYear[numSamples]+0.25)
  
  if(!is.null(matchReturn$nBoot)){
    nBoot <- as.numeric(matchReturn$nBoot)
  } else {
    message("Enter nBoot, the maximum number of bootstrap replicates to be used, typically 100")
    nBoot <- as.numeric(readline())
  }
  message("nBoot = ",nBoot," this is the maximum number of replicates that will be run")
  
  if(!is.null(matchReturn$bootBreak)){
    bootBreak <- as.numeric(matchReturn$bootBreak)
  } else {
    message("Enter min (minimum number of replicates), between 9 and nBoot, values of 39 or greater produce more accurate CIs")
    bootBreak <- as.numeric(readline())
  }
  
  bootBreak <- if(bootBreak>nBoot) nBoot else bootBreak
  
  message("bootBreak = ",bootBreak," this is the minimum number of replicates that will be run")
  
  if(!is.null(matchReturn$blockLength)){
    blockLength <- as.numeric(matchReturn$blockLength)
  } else {
    message("Enter blockLength, in days, typically 200 is a good choice")
    blockLength <- as.numeric(readline())
  }
  message("blockLength = ",blockLength," this is the number of days in a bootstrap block")
  
  confStop <- 0.7
  
  if(year1 < floor(min(eList$Sample$DecYear, na.rm = TRUE))){
    stop("year1 is less than the first Sample year")
  }
  
  if(year2 > ceiling(max(eList$Sample$DecYear, na.rm = TRUE))){
    stop("year2 is greater than the last Sample year")
  }
  
  caseSetUp <- data.frame(year1=year1,
                          yearData1=yearData1,
                          year2=year2,
                          yearData2=yearData2,
                          numSamples=numSamples,
                          nBoot=nBoot,
                          bootBreak=bootBreak,
                          blockLength=blockLength,
                          confStop=confStop)
  
  return(caseSetUp)
  
}

#' Save EGRETci workspace after running wBT (the WRTDS bootstrap test)
#'
#'
#' Saves critical information in a EGRETci workflow when analyzing trends between a starting and ending year.
#'
#' @param eList named list with at least the Daily, Sample, and INFO dataframes. Created from the EGRET package, after running \code{\link[EGRET]{modelEstimation}}.
#' @param eBoot named list. Returned from \code{\link{wBT}}.
#' @param caseSetUp data frame. Returned from \code{\link{trendSetUp}}.
#' @param fileName character. If left blank (empty quotes), the function will interactively ask for a name to save.
#' @export
#' @seealso \code{\link{wBT}}, \code{\link{trendSetUp}}, \code{\link[EGRET]{modelEstimation}}
#' @return
#' A .RData file containing three objects: eList, eBoot, and caseSetUp
#' @examples
#' eList <- EGRET::Choptank_eList
#' \dontrun{
#' caseSetUp <- trendSetUp(eList)
#' eBoot <- wBT(eList,caseSetUp)
#' saveEGRETci(eList, eBoot, caseSetUp)
#' }
saveEGRETci <- function(eList, eBoot, caseSetUp, fileName = ""){
  
  if(fileName == ""){
    message("Enter a filename for output (it will go in the working directory)\n")
    fileName<-readline()    
  }
  
  fullName<-paste0(fileName,".RData")
  save(eList, eBoot, caseSetUp, file = fullName)
  message("Saved to: ",getwd(),"/",fullName)
}

#' Run the WBT (WRTDS Bootstrap Test)
#'
#' Runs the WBT for a given data set to evaluate the significance level and 
#' confidence intervals for the trends between two specified years.  The trends 
#' evaluated are trends in flow normalized concentration and flow normalized flux.  
#' Function produces text outputs and a named list (eBoot) that contains all of the 
#' relevant outputs. Check out \code{\link{runPairsBoot}} and \code{\link{runGroupsBoot}}
#' for more bootstrapping options. 
#' The wBT only runs stationary flow normalization (i.e. making the assumption that discharge is stationary).  
#' The \code{\link{runPairsBoot}} and \code{\link{runGroupsBoot}} allow for generalized flow normalization (i.e. non-stationary discharge).
#'
#' @param eList named list with at least the Daily, Sample, and INFO dataframes. Created from the EGRET package, after running \code{\link[EGRET]{modelEstimation}}.
#' @param caseSetUp data frame. Returned from \code{\link{trendSetUp}}.
#' @param saveOutput logical. If \code{TRUE}, a text file will be saved in the working directory.
#' @param fileName character. Name to save the output file if \code{saveOutput=TRUE}.
#' @param startSeed setSeed value. Defaults to 494817. This is used to make repeatable output.
#' @param jitterOn logical, if TRUE, adds "jitter" to the data in an attempt to avoid some numerical problems.  Default = FALSE.  See Details below.
#' @param V numeric a multiplier for addition of jitter to the data, default = 0.2.  See Details below.
#' @importFrom binom binom.bayes
#' @importFrom stats quantile
#' @export
#' @details
#' In some situations numerical problems are encountered in the bootstrap process, resulting in highly unreasonable spikes in the confidence intervals.
#' The use of "jitter" can often prevent these problems, but should only be used when it is clearly needed.
#' It adds a small amount of random "jitter" to the explanatory variables of the WRTDS model.  The V parameter sets the scale of variation in the log discharge values.
#' The standard deviation of the added jitter is V * standard deviation of Log Q.
#' The default for V is 0.2.  Larger values should generally be avoided, and smaller values may be sufficient.
#' 
#' @return eBoot, a named list with bootOut, wordsOut, xConc, xFlux, pConc, pFlux values.
#' \tabular{ll}{
#' Object \tab Description\cr
#' bootOut \tab a data frame with the results of the bootstrap test. \cr
#' wordsOut \tab a character vector describing the results. \cr
#' xConc and xFlux \tab vectors of length iBoot, of the change in flow normalized concentration
#'    and flow normalized flux computed from each of the bootstrap replicates. \cr
#' pConc and pFlux \tab vectors of length iBoot, of the change in flow normalized concentration
#'    or flow normalized flux computed from each of the bootstrap replicates expressed as \% change. \cr
#' } 
#' 
#' @seealso \code{\link{trendSetUp}}, \code{\link{setForBoot}}, \code{\link{runGroupsBoot}}, \code{\link{runPairsBoot}}
#' @examples
#' eList <- EGRET::Choptank_eList
#' caseSetUp <- trendSetUp(eList,
#'                         year1 = 1985, 
#'                         year2 = 2005,
#'                         nBoot = 50, 
#'                         bootBreak = 39,
#'                         blockLength = 200)
#' # Very long-running function:                     
#' \dontrun{
#' eBoot <- wBT(eList,caseSetUp)
#' }
wBT<-function(eList, caseSetUp, 
              saveOutput = TRUE, 
              fileName = "temp.txt", startSeed = 494817,
              jitterOn = FALSE, V = 0.2){
  
  message("runPairs/runPairsBoot is recommended over the wBT function.")
  
  #   This is the version of wBT that includes the revised calculation of the 
  #    two-sided p-value, added 16Jul2015, RMHirsch
  #
  eList <- setForBoot(eList, caseSetUp)
  localINFO <- eList$INFO
  localDaily <- eList$Daily
  localSample <- eList$Sample
  prob = c(0.025, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 0.975)

  year1 <- caseSetUp$year1
  yearData1 <- caseSetUp$yearData1
  year2 <- caseSetUp$year2
  yearData2 <- caseSetUp$yearData2
  numSamples <- caseSetUp$numSamples
  nBoot <- caseSetUp$nBoot
  bootBreak <- caseSetUp$bootBreak
  blockLength <- caseSetUp$blockLength
  periodName <- EGRET::setSeasonLabel(data.frame(PeriodStart = localINFO$paStart, 
                                                 PeriodLong = localINFO$paLong))
  confStop <- caseSetUp$confStop
  
  xConc <- rep(NA, nBoot)
  xFlux <- rep(NA, nBoot)
  pConc <- rep(NA, nBoot)
  pFlux <- rep(NA, nBoot)
  posXConc <- 0
  posXFlux <- 0
  possibleError1 <- tryCatch(surfaces1 <- estSliceSurfacesSimpleAlt(eList, year1), error = function(e) e)
  possibleError2 <- tryCatch(surfaces2 <- estSliceSurfacesSimpleAlt(eList, year2), error = function(e) e)
  
  if (!inherits(possibleError1, "error") &&
      !inherits(possibleError2, "error")) {
    
    combo <- makeCombo(surfaces1, surfaces2)
    eListCombo <- suppressMessages(EGRET::as.egret(localINFO, localDaily, localSample, 
                                                   combo))
    res <- makeTwoYearsResults(eListCombo, year1, year2)
    regDeltaConc <- res[2] - res[1]
    estC <- regDeltaConc
    baseConc <- res[1]
    regDeltaConcPct <- (regDeltaConc/baseConc) * 100
    LConcDiff <- log(res[2]) - log(res[1])
    regDeltaFlux <- (res[4] - res[3]) * 0.00036525
    estF <- regDeltaFlux
    baseFlux <- res[3] * 0.00036525
    regDeltaFluxPct <- (regDeltaFlux/baseFlux) * 100
    LFluxDiff <- log(res[4]) - log(res[3])
    fcc <- format(regDeltaConc, digits = 3, width = 7)
    ffc <- format(regDeltaFlux, digits = 4, width = 8)
    if (saveOutput) {
      sink(fileName)
    }
    cat("\n\n", eList$INFO$shortName, "  ", eList$INFO$paramShortName)
    cat("\n\n", periodName)
    if(eList$INFO$paStart == 1 & eList$INFO$paLong == 12){
      cat("\n\n  Bootstrap process, for change from Calendar Year", 
          year1, " to ", year2)      
    } else if (eList$INFO$paStart == 10 & eList$INFO$paLong == 12){
      cat("\n\n  Bootstrap process, for change from Water Year ", 
          year1, " to Water Year ", year2)       
    } else {
      cat("\n\n  Bootstrap process, for change from ", 
          year1, " to ", year2, ":",periodName) 
    }
    
    cat("\n                   data set runs from Water Year", 
        yearData1, "to Water Year", yearData2)
    cat("\n  Bootstrap block length in days", blockLength)
    cat("\n  bootBreak is", bootBreak, " confStop is", confStop)
    cat("\n\n WRTDS estimated concentration change is", fcc, 
        " mg/L")
    cat("\n WRTDS estimated flux change is        ", ffc, 
        " 10^6 kg/yr")
    
    if (saveOutput) {
      message("\n", eList$INFO$shortName, "  ", eList$INFO$paramShortName)
      message("\n", periodName)
      if(eList$INFO$paStart == 1 & eList$INFO$paLong == 12){
        message("\n  Bootstrap process, for change from Calendar Year", 
                year1, " to ", year2)      
      } else if (eList$INFO$paStart == 10 & eList$INFO$paLong == 12){
        message("\n  Bootstrap process, for change from Water Year", 
                year1, " to Water Year", year2)       
      } else {
        message("\n  Bootstrap process, for change from ", 
                year1, " to ", year2, ":",periodName) 
      }
      message("                   data set runs from ", 
              yearData1, " to Year ", yearData2)
      message("  Bootstrap block length in days ", blockLength)
      message("  bootBreak is ", bootBreak, "  confStop is ", 
              confStop)
      message("\n WRTDS estimated concentration change is ", 
              fcc, "  mg/L")
      message(" WRTDS estimated flux change is         ", 
              ffc, "  10^6 kg/yr")
      message(" nPos is cumulative number of positive trends")
      message("\n post_p is posterior mean estimate of probability of a positive trend")
      message(" Lower and Upper are estimates of the 90% CI values for magnitude of trend")
      message("\n      rep              Concentration             |              Flux")
      message("          value     nPos post_p   Lower   Upper  |     value   nPos  post_p    Lower   Upper")
    }
    nBootGood <- 0
    for (iBoot in 1:(2*nBoot)) {
      
      bootSample <- blockSample(localSample = localSample, 
                                blockLength = blockLength,
                                startSeed = startSeed + iBoot)
      
      if(jitterOn) bootSample <- EGRET::jitterSam(bootSample, V = V)
      
      eListBoot <- suppressMessages(EGRET::as.egret(localINFO, localDaily, bootSample, NA))
      possibleError3 <- tryCatch(surfaces1 <- estSliceSurfacesSimpleAlt(eListBoot, 
                                                                        year1), error = function(e) e)
      possibleError4 <- tryCatch(surfaces2 <- estSliceSurfacesSimpleAlt(eListBoot, 
                                                                        year2), error = function(e) e)
      if (!inherits(possibleError3, "error") & !inherits(possibleError4, 
                                                         "error")) {
        combo <- makeCombo(surfaces1, surfaces2)
        eListBoot <- suppressMessages(EGRET::as.egret(localINFO, localDaily, bootSample, combo))
        res <- makeTwoYearsResults(eListBoot, year1, year2)
        
        nBootGood <- nBootGood + 1
        
        xConc[nBootGood] <- (2 * regDeltaConc) - (res[2] - res[1])
        xFlux[nBootGood] <- (2 * regDeltaFlux) - ((res[4] - res[3]) * 0.00036525)
        LConc <- (2 * LConcDiff) - (log(res[2]) - log(res[1]))
        pConc[nBootGood] <- (100 * exp(LConc)) - 100
        LFlux <- (2 * LFluxDiff) - (log(res[4]) - log(res[3]))
        pFlux[nBootGood] <- (100 * exp(LFlux)) - 100
        ####### From here on out, no longer parallizable:
        posXConc <- ifelse(xConc[nBootGood] > 0, posXConc + 1, posXConc)
        binomIntConc <- binom::binom.bayes(posXConc, nBootGood, confStop, "central")
        belowConc <- ifelse(binomIntConc$upper < 0.05, 1, 0)
        aboveConc <- ifelse(binomIntConc$lower > 0.95, 1, 0)
        midConc <- ifelse(binomIntConc$lower > 0.05 & 
                            binomIntConc$upper < 0.95, 1, 0)
        posXFlux <- ifelse(xFlux[nBootGood] > 0, posXFlux + 1, posXFlux)
        binomIntFlux <- binom::binom.bayes(posXFlux, 
                                           iBoot, confStop, "central")
        belowFlux <- ifelse(binomIntFlux$upper < 0.05, 1, 0)
        aboveFlux <- ifelse(binomIntFlux$lower > 0.95, 1, 0)
        midFlux <- ifelse(binomIntFlux$lower > 0.05 & 
                            binomIntFlux$upper < 0.95, 1, 0)
        
        quantConc <- quantile(xConc[1:nBootGood], prob, type = 6, na.rm = TRUE)
        lowConc <- quantConc[2]
        highConc <- quantConc[8]
        quantFlux <- quantile(xFlux[1:nBootGood], prob, type = 6, na.rm = TRUE)
        lowFlux <- quantFlux[2]
        highFlux <- quantFlux[8]
        
        prints <- c(format(nBootGood, digits = 3, width = 7), 
                    format(xConc[nBootGood], digits = 3, width = 7), 
                    format(posXConc, digits = 3, width = 5), 
                    format(binomIntConc$mean,digits = 3), 
                    format(quantConc[2], digits = 3, width = 7), 
                    format(quantConc[8], digits = 3, width = 7), "  |  ", 
                    format(xFlux[nBootGood], digits = 4, width = 8), 
                    format(posXFlux, digits = 3, width = 5), 
                    format(binomIntFlux$mean, digits = 3, width = 7), 
                    format(quantFlux[2], digits = 4, width = 8), 
                    format(quantFlux[8], digits = 4, width = 8))
        if (!saveOutput) {
          cat("\n value is bootstrap replicate result (deltack or deltafk in paper)")
          cat("\n nPos is cumulative number of positive trends")
          cat("\n post_p is posterior mean estimate of probability of a positive trend")
          cat("\n Lower and Upper are estimates of the 90% CI values for magnitude of trend")
          cat("\n\n      rep              Concentration             |              Flux")
          cat("\n          value     nPos post_p   Lower   Upper  |     value   nPos  post_p    Lower   Upper")
          cat("\n", prints)
        } else {
          message(" ", paste(prints, collapse = " "))
        }
        
        test1 <- as.numeric(belowConc + aboveConc + midConc > 
                              0.5 & belowFlux + aboveFlux + midFlux > 0.5 & 
                              nBootGood >= bootBreak & iBoot > 30)
        test2 <- as.numeric(midConc > 0.5 & midFlux > 
                              0.5 & nBootGood >= bootBreak & nBootGood <= 30)
        if (!is.na(test1) && !is.na(test2) && test1 + test2 > 0.5) {
          break
        }
        if(nBootGood >= nBoot) {
          break()
        }
      } 
    }
    
    if(iBoot == 2*nBoot){
      message(iBoot, " iterations were run. They only achieved ", nBootGood, " sucessful runs.")
    } else if (iBoot > nBoot){
      message("It took ", iBoot, " iterations to achieve ", nBoot, " sucessful runs.")
    }
    
    rejectC <- lowConc * highConc > 0
    rejectF <- lowFlux * highFlux > 0
    cat("\n\nShould we reject Ho that Flow Normalized Concentration Trend = 0 ?", 
        words(rejectC))
    fquantConc <- format(quantConc, digits = 3, width = 8)
    cat("\n best estimate is", fcc, "mg/L\n  Lower and Upper 90% CIs", 
        fquantConc[2], fquantConc[8])
    lowC <- quantConc[2]
    upC <- quantConc[8]
    cat("\n also 95% CIs", fquantConc[1], fquantConc[9], 
        "\n and 50% CIs", fquantConc[4], fquantConc[6])
    lowC50 <- quantConc[4]
    upC50 <- quantConc[6]
    lowC95 <- quantConc[1]
    upC95 <- quantConc[9]
    pValC <- pVal(xConc)
    cat("\n approximate two-sided p-value for Conc", format(pValC, 
                                                            digits = 2, width = 9))
    if (!is.na(posXConc) && ( posXConc == 0 | posXConc == nBootGood) ){
      cat("\n* Note p-value should be considered to be < stated value")
    }
    likeCUp <- (posXConc + 0.5)/(nBootGood + 1)
    likeCDown <- 1 - likeCUp
    cat("\n Likelihood that Flow Normalized Concentration is trending up =", 
        format(likeCUp, digits = 3, width = 10), " is trending down =", 
        format(likeCDown, digits = 3, width = 10))
    cat("\n\nShould we reject Ho that Flow Normalized Flux Trend = 0 ?", 
        words(rejectF))
    fquantFlux <- format(quantFlux, digits = 3, width = 8)
    cat("\n best estimate is", ffc, "10^6 kg/year\n  Lower and Upper 90% CIs", 
        fquantFlux[2], fquantFlux[8])
    lowF <- quantFlux[2]
    upF <- quantFlux[8]
    cat("\n also 95% CIs", fquantFlux[1], fquantFlux[9], 
        "\n and 50% CIs", fquantFlux[4], fquantFlux[6])
    lowF50 <- quantFlux[4]
    upF50 <- quantFlux[6]
    lowF95 <- quantFlux[1]
    upF95 <- quantFlux[9]
    p <- binomIntFlux$mean
    pValF <- pVal(xFlux)
    cat("\n approximate two-sided p-value for Flux", format(pValF, 
                                                            digits = 2, width = 9))
    if (!is.na(posXFlux) && (posXFlux == 0 | posXFlux == nBootGood)) {
      cat("\n* Note p-value should be considered to be < stated value")
    }
    
    likeFUp <- (posXFlux + 0.5)/(nBootGood + 1)
    likeFDown <- 1 - likeFUp
    cat("\n Likelihood that Flow Normalized Flux is trending up =", 
        format(likeFUp, digits = 3), " is trending down=", 
        format(likeFDown, digits = 3))
    bootOut <- data.frame(rejectC, pValC, estC, lowC, upC, 
                          lowC50, upC50, lowC95, upC95, likeCUp, likeCDown, 
                          rejectF, pValF, estF, lowF, upF, lowF50, upF50, lowF95, 
                          upF95, likeFUp, likeFDown, baseConc, baseFlux, iBoot,
                          startSeed, nBootGood)
    likeList <- c(likeCUp, likeCDown, likeFUp, likeFDown)
    wordsOut <- wordLike(likeList)
    cat("\n\n", format(wordsOut[1], width = 30), "\n", format(wordsOut[3], 
                                                              width = 30))
    cat("\n", format(wordsOut[2], width = 30), "\n", format(wordsOut[4], 
                                                            width = 30))
    xConc <- xConc[1:iBoot]
    xFlux <- xFlux[1:iBoot]
    pConc <- pConc[1:iBoot]
    pFlux <- pFlux[1:iBoot]
    eBoot <- list(bootOut = bootOut, wordsOut = wordsOut, 
                  xConc = xConc, xFlux = xFlux, pConc = pConc, pFlux = pFlux)
    if (saveOutput) {
      sink()
      message("\nShould we reject Ho that Flow Normalized Concentration Trend = 0 ? ", 
              words(rejectC))
      message("  best estimate is ", fcc, " mg/L\n  Lower and Upper 90% CIs ", 
              fquantConc[2], " ", fquantConc[8])
      message("  also 95% CIs", fquantConc[1], " ", fquantConc[9], 
              "\n and 50% CIs ", fquantConc[4], " ", fquantConc[6])
      
      if (!is.na(posXConc) && (posXConc == 0 | posXConc == iBoot)) {
        message("* Note p-value should be considered to be < stated value")
      }
      
      message("  approximate two-sided p-value for Conc ", 
              format(pValC, digits = 2, width = 9))
      message("  Likelihood that Flow Normalized Concentration is trending up = ", 
              format(likeCUp, digits = 3, width = 10), " is trending down = ", 
              format(likeCDown, digits = 3, width = 10))
      message("\n Should we reject Ho that Flow Normalized Flux Trend = 0 ? ", 
              words(rejectF))
      message("  best estimate is ", ffc, " 10^6 kg/year\n  Lower and Upper 90% CIs ", 
              fquantFlux[2], " ", fquantFlux[8])
      message("  also 95% CIs ", fquantFlux[1], " ", fquantFlux[9], 
              "\n and 50% CIs ", fquantFlux[4], " ", fquantFlux[6])
      message("  approximate two-sided p-value for Flux ", 
              format(pValF, digits = 2, width = 9))
      
      if (!is.na(posXFlux) && (posXFlux == 0 | posXFlux == iBoot)){
        message("* Note p-value should be considered to be < stated value")
      } 
      
      message("  Likelihood that Flow Normalized Flux is trending up = ", 
              format(likeFUp, digits = 3), " is trending down= ", 
              format(likeFDown, digits = 3))
      message("\n ", format(wordsOut[1], width = 30), "\n ", 
              format(wordsOut[3], width = 30))
      message(" ", format(wordsOut[2], width = 30), "\n ", 
              format(wordsOut[4], width = 30))
    }
    attr(eBoot, "year1") <- year1
    attr(eBoot, "year2") <- year2
    return(eBoot)
  } else {
    if("message" %in% names(possibleError1) && 
       "message" %in% names(possibleError2)){
      stop(possibleError1$message, "/n", possibleError2)
    } else if ("message" %in% names(possibleError1)){
      stop(possibleError1$message)
    } else {
      stop(possibleError2$message)
    }
    
  }
}





estSliceSurfacesSimpleAlt <- function(eList,year){
  
  localINFO <- eList$INFO
  localSample <- eList$Sample
  localDaily <- eList$Daily
  
  windowY <- localINFO$windowY
  windowS <- localINFO$windowS
  windowQ <- localINFO$windowQ
  
  edgeAdjust <- TRUE
  if(!is.null(localINFO$edgeAdjust)){
    edgeAdjust <- localINFO$edgeAdjust
  }
  
  originalColumns <- names(localSample)
  minNumUncen <- min(c(localINFO$minNumUncen, sum(localSample$Uncen)), na.rm=TRUE)
  minNumObs <- min(c(localINFO$minNumObs, length(localSample$ConcLow)), na.rm=TRUE)
  
  bottomLogQ <- localINFO$bottomLogQ
  stepLogQ <- localINFO$stepLogQ
  topLogQ <- bottomLogQ + 13 * stepLogQ
  vectorLogQ <- seq(bottomLogQ,topLogQ,stepLogQ)
  nVectorLogQ <- localINFO$nVectorLogQ
  stepYear <- localINFO$stepYear
  bottomYear <-localINFO$bottomYear
  nVectorYear <- localINFO$nVectorYear
  topYear <- bottomYear + (nVectorYear - 1)* stepYear 
  vectorYear <-seq(bottomYear,topYear,stepYear)
  surfaces <- array(NA,dim=c(14,length(vectorYear),3))
  
  vectorIndex <- paVector(year,localINFO$paStart,localINFO$paLong,vectorYear)
  # Tack on one data point on either side
  vectorIndex <- c(vectorIndex[1]-1,vectorIndex,vectorIndex[length(vectorIndex)]+1)
  
  vectorIndex <- vectorIndex[vectorIndex != 0]
  
  vectorYear <- vectorYear[vectorIndex]
  nVectorYear <- length(vectorYear)
  estPtLogQ <- rep(vectorLogQ,nVectorYear)
  estPtYear <- rep(vectorYear,each=14)
  
  numDays <- localINFO$numDays
  DecLow <- localINFO$DecLow
  DecHigh <- localINFO$DecHigh
  
  if(utils::packageVersion("EGRET") >= "2.6.1"){
    resultSurvReg <- EGRET::runSurvReg(estPtYear = estPtYear,estPtLQ = estPtLogQ,
                                       DecLow = DecLow,DecHigh = DecHigh, 
                                       Sample = localSample,windowY = windowY,windowQ = windowQ,
                                       windowS = windowS,minNumObs = minNumObs,minNumUncen = minNumUncen,
                                       verbose =FALSE,edgeAdjust = edgeAdjust)
  } else {
    message("Consider updating the EGRET package")
    resultSurvReg <- EGRET::runSurvReg(estPtYear = estPtYear,estPtLQ = estPtLogQ,
                                       numDays = numDays,DecLow = DecLow,DecHigh = DecHigh, 
                                       Sample = localSample,windowY = windowY,windowQ = windowQ,
                                       windowS = windowS,minNumObs = minNumObs,minNumUncen = minNumUncen,
                                       interactive =  FALSE,edgeAdjust = edgeAdjust)
  }
  
  
  for(iQ in 1:14) {
    for(iY in 1:length(vectorIndex)){ 
      k<-(iY-1)*14+iQ
      if(k <= dim(resultSurvReg)[1]){
        surfaces[iQ,vectorIndex[iY],]<-resultSurvReg[k,]
      }
    }
  }
  
  return(surfaces)
}

#' Create a paVector
#' 
#' Internal doc for paVector
#' 
#' @export
#' @keywords internal 
#' @param year description
#' @param paStart description
#' @param paLong description
#' @param vectorYear description

paVector <- function(year,paStart,paLong, vectorYear){
  
  if (paStart + paLong > 13){
    # Crosses January
    minYear_int <- year-1
    maxTime <- as.POSIXct(as.Date(paste(year,(paStart + paLong - 12),1,sep="-"))-1)
  } else {
    minYear_int <- year
    if(paStart + paLong <= 12){
      maxTime <- as.POSIXct(as.Date(paste(year,(paStart + paLong),1,sep="-"))-1)
    } else {
      #Special december issue
      maxTime <- as.POSIXct(as.Date(paste(year,12,31,sep="-")))
    }
  }
  
  minTime <- as.POSIXct(paste(minYear_int,paStart,1,sep="-"))
  minYear <- as.POSIXct(paste0(minYear_int,"-01-01 00:00"))
  endMinYear <- as.POSIXct(paste0(minYear_int,"-12-31 23:59"))
  
  maxYear <- as.POSIXct(paste0(year,"-01-01 00:00"))
  endMaxYear <- as.POSIXct(paste0(year,"-12-31 23:59"))
  
  minTime_dec <- minYear_int + as.numeric(difftime(minTime, minYear, units = "secs"))/as.numeric(difftime(endMinYear, minYear, units = "secs"))
  
  maxTime_dec <- year + as.numeric(difftime(maxTime, maxYear, units = "secs"))/as.numeric(difftime(endMaxYear, maxYear, units = "secs"))
  
  vectorIndex <- which(vectorYear >= minTime_dec & vectorYear <= maxTime_dec)
  
  return(vectorIndex)
}


makeCombo <- function (surfaces1,surfaces2) {
  surfaces1[is.na(surfaces1)]<-0
  surfaces2[is.na(surfaces2)]<-0
  combo <- surfaces1 + surfaces2
  combo[combo == 0] <- NA
  return(combo)
}

makeTwoYearsResults <- function(eList,year1,year2){
  
  paStart <- eList$INFO$paStart
  paLong <- eList$INFO$paLong
  returnDaily <- EGRET::estDailyFromSurfaces(eList)
  
  bootAnnRes<- EGRET::setupYears(localDaily=returnDaily, 
                                 paStart=paStart, 
                                 paLong=paLong)
  twoYearsResults <- c(bootAnnRes$FNConc[!is.na(bootAnnRes$FNConc)],
                       bootAnnRes$FNFlux[!is.na(bootAnnRes$FNFlux)])
  
  return(twoYearsResults)
}

#' Allows user to set window parameters for the WRTDS model prior to running the bootstrap procedure
#'
#' Adds window parameters to INFO file in eList.
#'
#' @param eList named list with at least the Daily, Sample, and INFO dataframes. Created from the EGRET package, after running \code{\link[EGRET]{modelEstimation}}.
#' @param caseSetUp data frame returned from \code{\link{trendSetUp}}.
#' @param windowY numeric specifying the half-window width in the time dimension, in units of years, default is 7.
#' @param windowQ numeric specifying the half-window width in the discharge dimension, units are natural log units, default is 2.
#' @param windowS numeric specifying the half-window with in the seasonal dimension, in units of years, default is 0.5.
#' @param edgeAdjust logical specifying whether to use the modified method for calculating the windows at the edge of the record, default is TRUE.  
#' @keywords WRTDS flow
#' @return eList list with Daily,Sample, INFO data frames and surface matrix.
#' @export
#' @examples
#' eList <- EGRET::Choptank_eList
#' 
#' caseSetUp <- trendSetUp(eList,
#'   year1=1985, 
#'   year2=2005,
#'   nBoot = 50, 
#'   bootBreak = 39,
#'   blockLength = 200)
#' 
#' bootSetUp <- setForBoot(eList,caseSetUp)
#' 
setForBoot<-function (eList,caseSetUp, windowY = 7, windowQ = 2, 
                      windowS = 0.5, edgeAdjust=TRUE) {
  #  does the setup functions usually done by modelEstimation
  localINFO <- eList$INFO
  localDaily <- eList$Daily
  localSample <- eList$Sample
  
  numDays <- length(localDaily$DecYear)
  DecLow <- localDaily$DecYear[1]
  DecHigh <- localDaily$DecYear[numDays]
  numSamples <- length(localSample$Julian)
  
  if(is.null(localINFO$windowY)){
    localINFO$windowY <- windowY
  }
  
  if(is.null(localINFO$windowQ)){
    localINFO$windowQ <- windowQ
  }
  
  if(is.null(localINFO$windowS)){
    localINFO$windowS <- windowS
  }
  
  if(is.null(localINFO$edgeAdjust)){
    localINFO$edgeAdjust <-edgeAdjust
  }
  
  if (is.null(localINFO$minNumObs)) {
    localINFO$minNumObs <- min(100, numSamples - 20)
  }
  if (is.null(localINFO$minNumUncen)) {
    # localINFO$minNumUncen <- 0.5
    localINFO$minNumUncen <- min(100, numSamples - 20)
  }
  
  surfaceIndexParameters <- EGRET::surfaceIndex(localDaily)
  if(utils::packageVersion("EGRET") > '2.6.1'){
    localINFO$bottomLogQ <- surfaceIndexParameters[['bottomLogQ']]
    localINFO$stepLogQ <- surfaceIndexParameters[['stepLogQ']]
    localINFO$nVectorLogQ <- surfaceIndexParameters[['nVectorLogQ']]
    localINFO$bottomYear <- surfaceIndexParameters[['bottomYear']]
    localINFO$stepYear <- surfaceIndexParameters[['stepYear']]
    localINFO$nVectorYear <- surfaceIndexParameters[['nVectorYear']]
  } else {
    localINFO$bottomLogQ <- surfaceIndexParameters[1]
    localINFO$stepLogQ <- surfaceIndexParameters[2]
    localINFO$nVectorLogQ <- surfaceIndexParameters[3]
    localINFO$bottomYear <- surfaceIndexParameters[4]
    localINFO$stepYear <- surfaceIndexParameters[5]
    localINFO$nVectorYear <- surfaceIndexParameters[6]
  }
  
  localINFO$numDays <- numDays
  localINFO$DecLow <- DecLow
  localINFO$DecHigh <- DecHigh
  localINFO$edgeAdjust <- edgeAdjust
  
  eList$INFO <- localINFO
  return(eList)
}

#' blockSample
#'
#' Get a bootstrap replicate of the Sample data frame based on the user-specified blockLength. 
#' The bootstrap replicate is made up randomly selected blocks of 
#' data from Sample data frame.  Each block includes all the samples in a standard period of time (the blockLength measured in days).
#' The blocks are created based on the random selection (with 
#' replacement) of starting dates from the full Sample data frame.  The bootstrap replicate  
#' has the same number of observations as the original Sample, but some 
#' observations are included once, some are included multiple times, and some are not 
#' included at all.
#'
#' @param localSample Sample data frame
#' @param blockLength integer size of subset, expressed in days.  200 days has been found to be a good choice.
#' @param startSeed setSeed value. This is used to make repeatable output. Default = NA.
#' @keywords WRTDS water quality
#' @return newSample data frame in same format as Sample data frame.  It has the same number of rows as the Sample data frame.
#' @export
#' @examples
#' library(EGRET)
#' eList <- Choptank_eList
#' Sample <- eList$Sample
#' bsReturn <- blockSample(Sample, 200)
blockSample <- function(localSample, blockLength, startSeed = NA){
  
  if(!is.na(startSeed)){
    suppressWarnings(RNGversion("3.5.0"))
    set.seed(startSeed)
  }
  
  numSamples <- length(localSample$Julian)
  dayOne <- localSample$Julian[1]
  newSample <- data.frame()
  firstJulian <- localSample$Julian[1] - blockLength + 1
  lastJulian <- localSample$Julian[numSamples]
  possibleStarts <- seq(firstJulian,lastJulian)
  while(nrow(newSample) <= nrow(localSample)){
    randomDate <- sample(possibleStarts, 1)
    blockStart <- max(randomDate,dayOne)
    blockEnd <- min(lastJulian,randomDate+blockLength-1)
    oneYear <- localSample[which(localSample$Julian >= blockStart & 
                                   localSample$Julian < blockEnd),]
    newSample <- rbind(oneYear, newSample)
    
  }
  newSample <- newSample[-c((nrow(localSample)+1):nrow(newSample)),]
  newSample <- newSample[order(newSample$Julian),]
  return(newSample)
}


wordLike <- function(likeList){
  firstPart <- c("Upward trend in concentration is",
                 "Downward trend in concentration is",
                 "Upward trend in flux is",
                 "Downward trend in flux is")
  
  secondPart <- c("highly unlikely",
                  "very unlikely",
                  "unlikely",
                  "about as likely as not",
                  "likely",
                  "very likely",
                  "highly likely")
  
  breaks <- c(0, 0.05, 0.1, 0.33, 0.67, 0.9, 0.95, 1)
  
  levelLike <- cut(likeList,breaks=breaks,labels=FALSE)
  wordLikeFour <- paste(firstPart,secondPart[levelLike])
  return(wordLikeFour)
}

#' pVal
#'
#' Computes the two-sided p value for the null hypothesis, where the null 
#' hypothesis is that the slope is zero.  It is based on the binomial distribution. 
#' Note that the result does not depend on the magnitude of the individual slope 
#' values only depends on the number of positive slopes and number of negative slopes.
#'
#' @param s numeric vector of slope values from the bootstrap 
#' @export
#' @return pVal numeric value
#' @importFrom stats na.omit
#' @examples
#' s <- c(-1.0, 0, 0.5, 0.55, 3.0)
#' pValue <- pVal(s)
pVal <- function(s){
  # this function computes the two-sided p value for the null hypothesis
  # s are the slope values from the bootstrap 
  s <- na.omit(s)
  s <- subset(s, abs(s) > 0)
  s <- sort(s)
  m <- length(s)
  xvec <- ifelse(s>0,1,0)
  x <- sum(xvec)
  #  kn is the order statistic of the largest negative
  #  kp is the order statistic of the smallest positive
  kp <- m - x + 1
  kn <- kp - 1
  # this if statement looks out for the case of all plus slopes or all minus slopes
  # it computes the special case p value for these
  # note that when it gets reported, it should be as "less than" the reported value
  pval <- if(x == 0 | x == m) 2 / (m + 1) else {
    b1 <- (kn - kp) / (s[kn] - s[kp])
    k0 <- kp - (b1 * s[kp])
    p <- k0 / (m + 1)
    2 * (min(p,1-p))}
  return(pval)	
}

