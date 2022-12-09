# EGRETci <img src="man/figures/egret-02.png" alt="EGRET" style="width:90px;height:auto;" align="right" class="logo" />

This package **EGRETci** implements a set of approaches to the analysis
of uncertainty associated with WRTDS trend analysis as implemented in
the **EGRET** package.

See: <http://authors.elsevier.com/sd/article/S1364815215300220> for more
details.

The **EGRETci** package is designed to carry out three specific types of
tasks.

1.  Evaluate a water quality trend over a specific span of years and
    produce a variety of tabular results. This is done with a short
    workflow involving the functions: `trendSetUp` and `wBT`. The
    results come in three forms: 1) console output, which shows the
    bootstrap replicate process as it is underway and the results when
    it has finished, 2) a text file that shows the results of the
    bootstrap analysis (a subset of what is included in the console
    output), and 3) a set of outputs in a named list called eBoot. The
    contents of eBoot are described below.

2.  Plot histograms of values for the trend magnitudes, expressed in
    percent change over the specified period, for flow-normalized
    concentration and flow-normalized flux. This is done with the
    function `plotHistogramTrend`. It depends on outputs contained in
    eBoot. Note that there are a number of custom outputs similar to
    these histograms that can be developed from the contents of eBoot
    (for example, what is the likelihood that the flow normalized flux
    decreased by more than 2000 kg/year over the trend period). Such
    analyses would require a small amount of script writing by the user.

3.  Plot confidence bands around the computed trends in flow-normalized
    concentration and flow-normalized flux. This is done using a
    function called `ciCalculations` and then, using the output from
    that function running two functions that produce the confidence band
    graphics for concentration and flux respectively
    (`plotConcHistBoot`, and `plotFluxHistBoot`).

## How to cite EGRETci:

``` r
citation(package = "EGRETci")
#> 
#> To cite EGRETci in publications, please use:
#> 
#>   Hirsch, R.M., Archfield, S.A., De Cicco, L.A., "A bootstrap method
#>   for estimating uncertainty of water quality trends", Environmental
#>   Modelling & Software, Vol 73, Nov 2015, p 148-166. doi:
#>   10.1016/j.envsoft.2015.07.017
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Article{,
#>     author = {Robert M. Hirsch and Stacey A. Archfield and Laura A. {De Cicco}},
#>     title = {A bootstrap method for estimating uncertainty of water quality trends},
#>     journal = {Journal of Environmental Modelling and Software},
#>     year = {2015},
#>   }
```

### Reporting bugs

Please consider reporting bugs and asking questions on the Issues page:
[https://github.com/USGS-R/EGRETci/issues](https://github.com/USGS-R/EGRET/issues)

### Code of Conduct

We want to encourage a warm, welcoming, and safe environment for
contributing to this project. See the [code of
conduct](https://github.com/USGS-R/EGRETci/blob/master/CONDUCT.md) for
more information.

## Model Archive

When using the `WRTDS` model (and corresponding confidence intervals),
it is important to be able to reproduce the results in the future. The
following version of R and package dependencies were used most recently
to pass the embedded tests within this package. There is no guarantee of
reproducible results using future versions of R or updated versions of
package dependencies; however, we will make diligent efforts to test and
update future modeling environments.

``` r
sessioninfo::session_info()
#> ─ Session info ───────────────────────────────────────────────────────────────
#>  setting  value
#>  version  R version 4.2.2 (2022-10-31 ucrt)
#>  os       Windows 10 x64 (build 19044)
#>  system   x86_64, mingw32
#>  ui       RTerm
#>  language (EN)
#>  collate  English_United States.utf8
#>  ctype    English_United States.utf8
#>  tz       America/Chicago
#>  date     2022-12-09
#>  pandoc   2.19.2 @ C:/Program Files/RStudio/bin/quarto/bin/tools/ (via rmarkdown)
#> 
#> ─ Packages ───────────────────────────────────────────────────────────────────
#>  package     * version date (UTC) lib source
#>  cli           3.4.1   2022-09-23 [1] CRAN (R 4.2.1)
#>  digest        0.6.30  2022-10-18 [1] CRAN (R 4.2.2)
#>  evaluate      0.18    2022-11-07 [1] CRAN (R 4.2.2)
#>  fastmap       1.1.0   2021-01-25 [1] CRAN (R 4.2.1)
#>  glue          1.6.2   2022-02-24 [1] CRAN (R 4.1.3)
#>  htmltools     0.5.4   2022-12-07 [1] CRAN (R 4.2.2)
#>  knitr         1.41    2022-11-18 [1] CRAN (R 4.2.2)
#>  lifecycle     1.0.3   2022-10-07 [1] CRAN (R 4.2.1)
#>  magrittr      2.0.3   2022-03-30 [1] CRAN (R 4.1.3)
#>  rlang         1.0.6   2022-09-24 [1] CRAN (R 4.2.1)
#>  rmarkdown     2.18    2022-11-09 [1] CRAN (R 4.2.2)
#>  rstudioapi    0.14    2022-08-22 [1] CRAN (R 4.2.1)
#>  sessioninfo   1.2.2   2021-12-06 [1] CRAN (R 4.2.1)
#>  stringi       1.7.8   2022-07-11 [1] CRAN (R 4.2.1)
#>  stringr       1.5.0   2022-12-02 [1] CRAN (R 4.2.2)
#>  vctrs         0.5.1   2022-11-16 [1] CRAN (R 4.2.2)
#>  xfun          0.35    2022-11-16 [1] CRAN (R 4.2.2)
#>  yaml          2.3.6   2022-10-18 [1] CRAN (R 4.2.1)
#> 
#>  [1] C:/Users/ldecicco/Documents/R/win-library/4.2
#>  [2] C:/Program Files/R/R-4.2.2/library
#> 
#> ──────────────────────────────────────────────────────────────────────────────
```

# Disclaimer

This software is preliminary or provisional and is subject to revision.
It is being provided to meet the need for timely best science. The
software has not received final approval by the U.S. Geological Survey
(USGS). No warranty, expressed or implied, is made by the USGS or the
U.S. Government as to the functionality of the software and related
material nor shall the fact of release constitute any such warranty. The
software is provided on the condition that neither the USGS nor the U.S.
Government shall be held liable for any damages resulting from the
authorized or unauthorized use of the software.
