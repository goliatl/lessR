Histogram <-
function(x=NULL, dframe=mydata, ncut=4, ...)  {

  # produce actual argument, such as from an abbreviation, and flag if not exist

  is.df <- FALSE  # is data frame

  if (missing(x)) {
    x.name <- ""  # in case x is missing, i.e., data frame mydata
    is.df <- TRUE
    dframe <- eval(substitute(mydata))
  }
  else {
    # get actual variable name before potential call of dframe$x
    x.name <- deparse(substitute(x)) 
    options(xname = x.name)
    if (exists(x.name, where=1)) if (is.data.frame(x)) {
       is.df <- TRUE
       dframe <- x
    }
  }

  if (!is.df) {

    dframe.name <- deparse(substitute(dframe))

    # get conditions and check for dframe existing
    xs <- .xstatus(x.name, dframe.name)
    is.frml <- xs$ifr
    in.global <- xs$ig 

    # warn user that old formula mode no longer works
    if (is.frml) {
      cat("\n"); stop(call.=FALSE, "\n","------\n",
          "Instead, of 'Y ~ X', now use the by option, 'Y, by=X' \n\n")
    }

    # see if the variable exists in data frame, if x not in Global Env 
    if (!in.global) .xcheck(x.name, dframe.name, dframe)

    if (!in.global) x.call <- eval(substitute(dframe$x))
    else {  # vars that are function names get assigned to global
      x.call <- x
      if (is.function(x.call)) x.call <- eval(substitute(dframe$x))
    }

  }  # x not data frame


  if (is.df) hst.data.frame(dframe, ncut, ...) 

  else {
    .graphwin()
    hst.default(x.call, ...)
  }   

}
