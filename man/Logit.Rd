\name{Logit}
\alias{Logit}
\alias{lr}

\title{Logit Regression Analysis}

\description{
Abbreviation: \code{lr}

Based directly on the standard R \code{\link{glm}} function with \code{family="binomial"}, automatically provides a logit regression analysis with graphics from a single, simple function call with many default settings, each of which can be re-specified.  By default the data exists as a data frame with the default name of \code{mydata}, such as data read by the \code{lessR} \code{Read} function.  Specify the model in the function call according to an R \code{\link{formula}}, that is, the response variable followed by a tilde, followed by the list of predictor variables, each pair separated by a plus sign. The response variable is either a factor with two levels or a numeric variable with values only of 0 and 1. 

Default output includes the inferential analysis of the estimated coefficients and model, sorted residuals and Cook's Distance, and sorted fitted values for existing data or new data.  For a single predictor variable model, the scatterplot of the data with plotted logit function is provided.

Can also be called from the more general \code{\link{model}} function.
}

\usage{
Logit(my.formula, data=mydata, rows=NULL,
      digits.d=4, text.width=120, 

     brief=getOption("brief"),

     res.rows=NULL, res.sort=c("cooks","rstudent","dffits","off"), 
     pred=TRUE, pred.all=FALSE, cooks.cut=1, 

     X1.new=NULL, X2.new=NULL, X3.new=NULL, X4.new=NULL, 
     X5.new=NULL, X6.new=NULL,

     pdf.file=NULL, width=5, height=5, \ldots)

lr(\ldots) 
}


\arguments{
  \item{my.formula}{Standard R \code{\link{formula}} for specifying a model.  For
       example, for a response variable named Y and two predictor variables, X1 and 
       X2, specify the corresponding linear model as Y ~ X1 + X2.}
  \item{data}{The default name of the data frame that contains the data for analysis 
       is \code{mydata}, otherwise explicitly specify.}
  \item{rows}{A logical expression that specifies a subset of rows of the data frame
       to analyze.}
  \item{digits.d}{For the Basic Analysis, it provides the number of decimal digits.
        For the rest of the output, it is a suggestion only.}
  \item{text.width}{Width of the text output at the console.}
  \item{brief}{If set to \code{TRUE}, reduced text output. Can change system default
       with \code{\link{style}} function.}
  \item{res.rows}{Default is 25, which lists the first 25 rows of data sorted by the
       specified sort criterion.  To turn this option off, specify a value of 0.  To see 
       the output for all observations, specify a value of \code{"all"}.}
  \item{res.sort}{Default is \code{"cooks"}, for specifying Cook's distance as the sort
       criterion for the display of the rows of data and associated residuals. Other values 
       are \code{"rstudent"} for Studentized residuals, and \code{"off"} to not provide the
       analysis.}
  \item{pred}{Default is \code{TRUE}, which, produces confidence and prediction intervals 
       for each row, or selected rows, of data.}
  \item{pred.all}{Default is \code{FALSE}, which produces prediction intervals only for the
       first, middle and last five rows of data.}
  \item{cooks.cut}{Cutoff value of Cook's Distance at which observations with a larger value 
       are flagged in red and labeled in the resulting scatterplot of Residuals and Fitted 
       Values.  Default value is 1.0.}
  \item{X1.new}{Values of the first listed predictor variable for which forecasted values
        and corresponding prediction intervals are calculated.}
  \item{X2.new}{Values of the second listed predictor variable for which forecasted values
        and corresponding prediction intervals are calculated.}
  \item{X3.new}{Values of the third listed predictor variable for which forecasted values
        and corresponding prediction intervals are calculated.}
  \item{X4.new}{Values of the fourth listed predictor variable for which forecasted values
        and corresponding prediction intervals are calculated.}
  \item{X5.new}{Values of the fifth listed predictor variable for which forecasted values
        and corresponding prediction intervals are calculated.}
  \item{X6.new}{Values of the sixth listed predictor variable for which forecasted values
        and corresponding prediction intervals are calculated.}
  \item{pdf.file}{Name of the pdf file to which graphics are redirected.}
  \item{width}{Width of the pdf file in inches.}
  \item{height}{Height of the pdf file in inches.}
  \item{\dots}{Other parameter values for R function \code{\link{glm}} which provides the core computations.} 
}



\details{
OVERVIEW\cr
The purpose of \code{Logit} is to combine the following function calls into one, as well as provide ancillary analyses such as as graphics, organizing output into tables and sorting to assist interpretation of the output.  The basic analysis successively invokes several standard R functions beginning with the standard R function for estimation of the logit model, \code{\link{glm}} with \code{family="binomial"}. The output of the analysis is stored in the object \code{lm.out}, available for further analysis in the R environment upon completion of the \code{Logit} function. By default automatically provides the analyses from the standard R functions, \code{\link{summary}}, \code{\link{confint}} and \code{\link{anova}}, with some of the standard output modified and enhanced. The residual analysis invokes \code{\link{fitted}}, \code{\link{resid}}, \code{\link{rstudent}}, and \code{\link{cooks.distance}} functions.  The option for prediction intervals calls the standard generic R function \code{\link{predict}}.  

The default analysis provides the model's parameter estimates and corresponding hypothesis tests and confidence intervals, goodness of fit indices, the ANOVA table, analysis of residuals and influence as well as the fitted value and standard error for each observation in the model. 

DATA\cr
The name \code{mydata} is by default provided by the \code{\link{Read}} function included in this package for reading and displaying information about the data in preparation for analysis. If all the variables in the model are not in the same data frame, the analysis will not be complete.  The data frame does not need to be attached, just specified by name with the \code{data} option if the name is not the default \code{mydata}.

The \code{rows} parameter subsets rows (cases) of the input data frame according to a logical expression. Use the standard R operators for logical statements as described in \code{\link{Logic}} such as \code{&} for and, \code{|} for or and \code{!} for not, and use the standard R relational operators as described in \code{\link{Comparison}} such as \code{==} for logical equality \code{!=} for not equals, and \code{>} for greater than. See the Examples.

GRAPHICS\cr
For models with a single predictor variable, a scatter plot of the data is produced, which also includes the fitted values. As with the density histogram plot of the residuals and the scatterplot of the fitted values and residuals, the scatterplot includes a colored background with grid lines. If more than a single predictor variable, then a scatter plot matrix is produced. 

FORECASTS\cr
Fitted and forecasted values are listed for all rows of data if the number of rows is less than 25 or if \code{pred.all=TRUE}. If only some of the rows are listed, sorted by the fitted value, the first and last four rows of data are listed. Also the 4 rows immediately around the fitted value of 0.5 are listed.

RESIDUAL ANALYSIS\cr
By default the residual analysis lists the data and fitted value for each observation as well as the residual, Studentized residual, Cook's distance and dffits, with the first 20 observations listed and sorted by Cook's distance. The residual displayed is the actual difference between fitted and observed, that is, with the setting in the \code{\link{residuals}} of \code{type="response"}.  The \code{res.sort} option provides for sorting by the Studentized residuals or not sorting at all.  The \code{res.rows} option provides for listing these rows of data and computed statistics statistics for any specified number of observations (rows).  To turn off the analysis of residuals, specify \code{res.rows=0}.

INVOKED R OPTIONS\cr
The \code{\link{options}} function is called to turn off the stars for different significance levels (show.signif.stars=FALSE), to turn off scientific notation for the output (scipen=30), and to set the width of the text output at the console to 120 characters. The later option can be re-specified with the \code{text.width} option.  After \code{reg} is finished with a normal termination, the options are re-set to their values before the \code{reg} function began executing.

COLORS\cr
The default color theme is \code{dodgerblue}, but a gray scale is available with \code{"gray"}, and other themes are available as explained in \code{\link{style}}, such as \code{"red"} and \code{"green"}. Use the option \code{style(sub.theme="black")} for a black background and partial transparency of plotted colors. 
}

\value{
Following the standard \code{R} function \code{\link{glm}}, invisibly returns an object of \code{\link{class}} inheriting from "glm" which inherits from the \code{\link{class}} "lm". Particularly useful for comparing nested models. Assign the output of \code{Logit} for a model to an object.  Then for a nested model.  Then use the \code{\link{anova}} function to compare the models as shown in the examples below.
}

\author{David W. Gerbing (Portland State University; \email{gerbing@pdx.edu})}

\seealso{
\code{\link{formula}}, \code{\link{glm}}, \code{\link{summary.glm}}, \code{\link{anova}}, \code{\link{confint}}, \code{\link{fitted}}, \code{\link{resid}}, \code{\link{rstudent}}, \code{\link{cooks.distance}}
}

\examples{
# Gender has values of "M" and "F"
mydata <- Read("Employee", in.lessR=TRUE, quiet=TRUE)
# logit regression
Logit(Gender ~ Years)

# short name
lr(Gender ~ Years)

# Modify the default settings as specified
Logit(Gender ~ Years, res.row=8, res.sort="rstudent", digits.d=8, pred=FALSE)

# just for employees who have worked more than 5 years at the firm
Logit(Gender ~ Years, rows=(Years > 5))

# Multiple logistic regression model
# Provide all default analyses
Logit(Gender ~ Years + Salary)

# compare nested models
# easier and better treatment of missing data to use lessR function:  Nest
full.model <- Logit(Gender ~ Years + Salary)
reduced.model <- Logit(Gender ~ Years)
anova(reduced.model, full.model)

# Save the three plots as pdf files 4 inches square, gray scale
Logit(Gender ~ Years, pdf.file="MyModel.pdf",
      width=4, height=4, colors="gray")

# Specify new values of the predictor variables to calculate
#  forecasted values
# Specify an input data frame other than mydata
mydata <- Read("Cars93", in.lessR=TRUE)
Logit(Source ~ HP + MidPrice, X1.new=seq(100,250,50), X2.new=c(10,60,10))
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ regression }
\keyword{ logit }


