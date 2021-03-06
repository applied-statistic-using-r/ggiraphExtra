% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ggErrorBar.R
\name{ggErrorBar}
\alias{ggErrorBar}
\title{Make an interactive bar plot with error bar}
\usage{
ggErrorBar(data, mapping, interactive = FALSE, digits = 1, mode = 2,
  errorbar = "se", use.label = TRUE, use.labels = TRUE)
}
\arguments{
\item{data}{A data.frame}

\item{mapping}{Set of aesthetic mappings created by aes or aes_.}

\item{interactive}{A logical value. If TRUE, an interactive plot will be returned}

\item{digits}{An integer indicating the number of decimal places}

\item{mode}{if 2, two-sided error bar will be displayed, if 1 one-sided errorbar will be displayed}

\item{errorbar}{which value is displayed with errorbar :"se" or "sd"}

\item{use.label}{Logical. Whether or not use column label in case of labelled data}

\item{use.labels}{Logical. Whether or not use value labels in case of labelled data}
}
\value{
An interactive catepillar plot
}
\description{
Make an interactive bar plot with error bar
}
\examples{
require(ggplot2)
require(ggiraph)
ggErrorBar(mpg,aes(x=drv,y=cty))
ggErrorBar(mpg,aes(x=drv,y=hwy,color=cyl),mode=1,interactive=TRUE,errorbar="sd")
}

