% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotCIs.R
\name{plotHistogramTrend}
\alias{plotHistogramTrend}
\title{plotHistogramTrend}
\usage{
plotHistogramTrend(eList, eBoot, caseSetUp = NA, flux = TRUE, xMin = NA,
  xMax = NA, xStep = NA, printTitle = TRUE, cex.main = 1.1,
  cex.axis = 1.1, cex.lab = 1.1, col.fill = "grey", ...)
}
\arguments{
\item{eList}{named list with at least the Daily, Sample, and INFO dataframes. Created from the EGRET package, after running \code{\link[EGRET]{modelEstimation}}.}

\item{eBoot}{named list. Returned from \code{\link{wBT}} or from \code{\link{runPairsBoot}}.}

\item{caseSetUp}{data frame. Returned from \code{\link{trendSetUp}}, or if \code{\link{runPairsBoot}} was used, need to specify caseSetUp = NA.}

\item{flux}{logical if TRUE, plots flux results, if FALSE plots concentration results.}

\item{xMin}{minimum bin value for histogram, it is good to have the xMin and xMax arguments straddle zero, default is NA (value set from the data).}

\item{xMax}{maximum bin value for histogram, default is NA (value set from the data).}

\item{xStep}{step size, typically multiples of 10 or 20, default is NA (value set from the data).}

\item{printTitle}{logical if TRUE, plot includes title.}

\item{cex.main}{numeric magnification of font size for title, default is 1.1.}

\item{cex.axis}{numeric magnification of font size for axis, default is 1.1.}

\item{cex.lab}{numeric magnification of font size for axis labels, default is 1.1.}

\item{col.fill}{character fill color for histogram, default is "grey".}

\item{\dots}{base R graphical parameters that can be passed to the hist function}
}
\description{
Produces a histogram of trend results from bootstrap process.  The histogram shows the trend results expressed as percentage change between the first year (or first period) 
and the second year (or second period).  It shows the zero line (no trend) and also shows the WRTDS 
estimate of the trend in percent.  It is based on the output of either wBT or 
runPairsBoot.
}
\details{
For any given set of results (from eBoot) it is best to run it first with the arguments
xMin = NA, xMax = NA, and xStep = NA.  Then, observing the range the histogram covers
it can be run again with values of these three arguments selected by the user to provide
for a more readable version of the histogram.
}
\examples{
library(EGRET)
eList <- Choptank_eList
eBoot <- Choptank_eBoot
caseSetUp <- Choptank_caseSetUp
plotHistogramTrend(eList, eBoot, caseSetUp, flux = FALSE)

\dontrun{
# Using wBT:	
caseSetUp <- trendSetUp(eList)
eBoot <- wBT(eList,caseSetUp)
plotHistogramTrend(eList, eBoot, caseSetUp,  
                   flux = FALSE, xMin = -20, xMax = 60, xStep = 5)
plotHistogramTrend(eList, eBoot, caseSetUp, 
                   flux = TRUE, xMin = -20, xMax = 60, xStep = 5)
   
# Using runPairs followed by runPairsBoot:
year1 <- 1985
year2 <- 2009          
pairOut_2 <- runPairs(eList, year1, year2, windowSide = 7)
boot_pair_out <- runPairsBoot(eList, pairOut_2, nBoot = 10)

plotHistogramTrend(eList, boot_pair_out, caseSetUp = NA, 
                   flux = TRUE, xMin = -20, xMax = 60, xStep = 5)          
}
}
