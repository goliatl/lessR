Read <-
function(ref=NULL, format=NULL, in.lessR=FALSE,

         labels=NULL, widths=NULL, stringsAsFactors=FALSE,
         missing="", n.mcut=1,

         miss.show=30, miss.zero=FALSE, miss.matrix=FALSE,

         max.lines=30, sheet=1,

         brief=TRUE, quiet=getOption("quiet"),

         fun.call=NULL, ...) {

  if (is.null(fun.call)) fun.call <- match.call()

  if (!is.null(ref))
    if (nchar(ref) == 0) ref <- NULL  #  "" to NULL

  if (hasArg(labels)) {
    #cat("\n"); stop(call.=FALSE, "\n","------\n",
      cat(">>> Note: ",
      "VariableLabels function, vl, now preferred to read labels\n\n")
  }

  miss.format <- ifelse (missing(format), TRUE, FALSE)
  fmts <- c("text", "csv", "tsv", "Excel", "R", "SPSS", "SAS")
  if (!is.null(format)) {
    if (!(format %in% c(fmts, "lessR"))) {
      cat("\n"); stop(call.=FALSE, "\n","------\n",
          ">>> Specified format must be one of:\n",
               "\"text\", \"Excel\", \"R\", \"SPSS\", \"SAS\",\n\n")
    }
    if (format %in% c("text", "tsv")) format <- "csv"

    if (is.null(ref) && format=="lessR") {
      cat("\n"); stop(call.=FALSE, "\n","------\n",
          "Cannot browse for a data file that is part of lessR.\n",
          "Specify the file name.\n\n")
    }
  }

  # option to browse for data file, and then display file name
  browse <- FALSE
  if (is.null(ref)) {
    if (options("device") == "RStudioGD")
      cat(">>> Browse window may be hidden behind RStudio window\n")
    browse <- TRUE
    ref <- file.choose()
    fncl <- paste("Read(", "ref = \"", ref,  "\", quiet = TRUE)", sep="")
    fncl2 <- paste("Read(", "ref = \"", ref,  "\")", sep="")
  }
  else {
    fncl <- .fun.call.deparse(fun.call)
    fncl2 <- .fun.call.deparse(fun.call)  # for read_excel currency bug
  }

  options(read.call=fncl)  # save for knitr run

  if (miss.format) {
         if (in.lessR) format <- "lessR"
    else if (!is.null(widths)) format <- "fwd"
    else if (grepl(".csv$", ref)) format <- "csv"
    else if (grepl(".tsv$", ref)) format <- "csv"
    else if (grepl(".txt$", ref)) format <- "csv"
    else if (grepl(".sav$", ref)) format <- "SPSS"
    else if (grepl(".sas7bdat$", ref)) format <- "SAS"
    else if (grepl(".rda$", ref)) format <- "R"
    else if (grepl(".xls$", ref) || grepl(".xlsx$", ref)) format <- "Excel"
  }
  if (!is.null(labels) && format=="R") {
    cat("\n"); stop(call.=FALSE, "\n","------\n",
        "An R data file should already contain labels before it was created.\n",
        "Or add them manually with the lessR function: label\n\n")
  }

  # construct full path name for label file if not already
  if (!is.null(labels)) {
    if (labels == "")
      ref.lbl <- file.choose()
    else {
      if (labels!="row2") {
        if (!grepl("/", labels) && !grepl("\\\\", labels)) {  # not full path
          nc <- nchar(ref)
          ch <- substr(ref, start=1, stop=nc)
          n.gone <- 0
          while ((ch != "/")  &&  (ch != "\\")) {
            n.gone <- n.gone + 1
            ch <- substr(ref, start=nc-n.gone, stop=nc-n.gone)
          }
          ref.lbl <- substr(ref, start=1, stop=nc-n.gone)
          ref.lbl <- paste(ref.lbl, labels, sep="")
        }
        else
          ref.lbl <- labels
      }  # not row2
      else
        ref.lbl <- "labels in second row of data file"
    }
  }

  if (!quiet) {
    max.chr <- nchar(ref)
    if (!is.null(labels))
      if (nchar(ref.lbl) > max.chr) max.chr <- nchar(ref.lbl)
    if (format == "Excel") {
      txt <- "Alexander Walker's openxlsx package]"
      cat("[with the read.xlsx function from", txt, "\n")
    }

    if (browse) {
      cat("\n")
      cat("Data File:  ", ref, "\n")
      if (!is.null(labels))  cat("Label File:  ", ref.lbl, "\n")
    }

    # function call for suggestions
    fncl <- .fun.call.deparse(fun.call)

    if (getOption("suggest")) {
      if (brief || !grepl("labels", fncl))
        cat("\n>>> Suggestions\n")
      if (!grepl("labels", fncl)  &&  format != "lessR")
        cat("Use the VariableLabels function, or vl, to read\n",
            "  a csv or Excel file of variable labels\n",
            "  Each row of the file is Variable Name, Variable Label\n")
      if (brief) {
        cat("Details about your data, Enter:  details()  for mydata, or",
           " details(name)\n")
        if (options("device") == "RStudioGD")
          cat("To view your data, Enter:  View(name)  such as ",
          " View(mydata)\n")
      }
      cat("\n")
    }
  }

  # see if labels=="row2"
  if (is.null(labels))
    isnot.row2 <- TRUE
  else
    isnot.row2 <- ifelse (labels != "row2", TRUE, FALSE)


  # do the read (into object d)
  # ---------------------------

  if (format=="fwd" || format=="csv") {  # text file

    if (format=="fwd")
      d <- read.fwf(file=ref, widths=widths, ...)

    else if (format=="csv") {
      line1 <- scan(ref, what="character", nlines=1, sep="\t", quiet=TRUE)
      if (length(line1) > 1) {
        message(">>> A tab character detected in the first row of the data file.\n",
            "    Presume tab delimited data.\n", sep="")
        delim <- "\t"
      }
      else
        delim <- ","
      if (isnot.row2)  # read data
         d <- read.csv(file=ref, na.strings=missing, sep=delim,
                       stringsAsFactors=stringsAsFactors, ...)
    }

  }  # end text file

  else if (format == "Excel") {

    if (isnot.row2) {  # read data
      d <- openxlsx::read.xlsx(ref, sheet=sheet)
      # d <- readxl::read_excel(path=ref, sheet=sheet)
      if (!is.null(list(...)$row.names))  # add row.names to read function
        d <- data.frame(d, row.names=list(...)$row.names)
      # class(d) <- "data.frame"  # otherwise nonstandard class from read_excel
    }
  }


  if (!is.null(labels)) {  # process labels
    if (format %in% c("fwd", "csv", "Excel")) {

      if (labels != "row2") {  # read labels file
        if (grepl(".xlsx$", ref.lbl))
          format.lbl <- "Excel"
        else if (grepl(".csv$", ref.lbl))
          format.lbl <- "csv"
        else {
          cat("\n"); stop(call.=FALSE, "\n","------\n",
              "Format of label file must be .csv or .xlsx\n\n")
        }

        if (format.lbl != "Excel")
          mylabels <- read.csv(file=ref.lbl, row.names=1, header=FALSE)
        else {  # openxlsx
          mylabels <- read.xlsx(ref.lbl, rowNames=TRUE, colNames=FALSE)
          # mylabels <- read_excel(path=ref.lbl, col_names=FALSE)
          #  mylabels <- data.frame(mylabels, row.names=1)
        }
        if (ncol(mylabels) == 1) names(mylabels) <- c("label")
        if (ncol(mylabels) == 2) names(mylabels) <- c("label", "unit")
      }

      else {  # labels == "row2", usually from Qualtrics data download
        if (format != "Excel")
          mylabels <- read.csv(file=ref, skip=1, nrows=1, sep=delim, ...)
        else {
          mylabels <- read.xlsx(ref, rows=1:2, colNames=FALSE, ...)
          mylabels <- mylabels[1,]
        }
        var.names <- names(mylabels)
        mylabels <- data.frame(t(mylabels))  # var names are row names
        names(mylabels) <- "label"
       if (format != "Excel")  # read the data
          d <- read.csv(file=ref, skip=2,
                        na.strings=missing, col.names=var.names, sep=delim, ...)
        else {
          d <- read.xlsx(ref, cols=1)  # read just 1st col to get num rows
          num.rows <- nrow(d) + 1  # account for label row
          d <- read.xlsx(ref, rows=c(1,3:(num.rows)))  # skip Row 2
        }
      }  # end row2

      # transfer labels and maybe units to data
      attr(d, which="variable.labels") <- as.character(mylabels$label)
      names(attr(d, which="variable.labels")) <- as.character(row.names(mylabels))
      if (ncol(mylabels) == 2) {
        attr(d, which="variable.units") <- as.character(mylabels$unit)
        names(attr(d, which="variable.units")) <- as.character(row.names(mylabels))
      }
    }
  }

  else if (format == "SPSS")  # data and any labels
    d <- read.spss(file=ref, to.data.frame=TRUE, ...)

  else if (format == "SAS") { # data
    d <- read.sas7bdat(file=ref, ...)
    txt <- "Matt Shotwell's sas7bdat package]"
    cat("[with the read.sas7bdat function from", txt, "\n")
  }

  else if (format == "R") {  # data and any labels
    x.env <- new.env()  # scratch environment
    load(ref, envir=x.env)
    dname <- ls(x.env)
    d <- get(dname, pos=x.env)
  }

  else if (format == "lessR") {  # data and any labels
    txt <- ifelse (substr(ref,1,4) == "data", "", "data")
    file.name <- paste(txt, ref, ".rda", sep="")

    path.name <- paste(find.package("lessR"), "/data/",  file.name, sep="")

    if (!file.exists(path.name)) {
      cat("\n"); stop(call.=FALSE, "\n","------\n",
        "No lessR data file with that name.\n\n",
        "To view the list of data files, enter  > Help(lessR)\n",
        "The data file names begin with  'data.'\n\n")
    }

    x.env <- new.env()  # scratch environment
    load(path.name, envir=x.env)

    dname <- paste(txt, ref, sep="")
    d <- get(dname, pos=x.env)
  }

  if (is.data.frame(d)) {
    n.col <- apply(d, 2, function(x) sum(!is.na(x)))  # num values per variable
    nu.col <- apply(d, 2, function(x) length(unique(na.omit(x))))  # num unique
    fnu.col <- logical(length=ncol(d))  # logical vector, initial values to FALSE
    # !Excel: if a column is unique non-numeric, convert read as factor to char
    # if (format != "Excel") {
    #   for (i in 1:ncol(d)) if (nu.col[i]==n.col[i] && (is.factor(d[,i])))
    #     fnu.col[i] <- TRUE
    #   d[fnu.col] <- lapply(d[fnu.col], as.character)
    # }
    # else {  # get read_excel results to be equivalent to other formats
    if (format == "Excel") {
      rows <- min(50, nrow(d))  # save some time scanning
      if (stringsAsFactors) {
      # read_excel does not convert strings to factors, do so if !unique
        for (i in 1:ncol(d))
          if (is.character(d[,i])) if (nu.col[i] != n.col[i])
          fnu.col[i] <- TRUE
          d[fnu.col] <- lapply(d[fnu.col], as.factor)
          # d[fnu.col] <- lapply(d[fnu.col], type.convert) # as in read.csv
      }
        fnu.col <- logical(length=ncol(d))  # reset
        for (i in 1:ncol(d))
          if (is.double(d[,i]))
            if (is.integer(type.convert(as.character(d[1:rows,i]))))
              fnu.col[i] <- TRUE
         d[fnu.col] <- lapply(d[fnu.col], as.integer) # move to integer

      # bug: POSIXct misinterpretation of currency data
      # f.call <- gsub(")$", "", fncl2)  # get function call less closing )
      # fnu.col <- logical(length=ncol(d))  # reset
      # for (i in 1:ncol(d))
      #   if (class(d[1:rows,i])[1] == "POSIXct") fnu.col[i] <- TRUE
      # if (any(fnu.col)) {  # construct alternate Read function call
      #   typ <- paste("mydata <- ", f.call, ", col_types=c(", sep="")
      #   for (i in 1:ncol(d)) {
      #     if (class(d[,i])[1] %in% c("integer", "double", "POSIXct"))
      #       typ <- paste(typ, ", \"double\"", sep="")
      #     else if (class(d[,i])[1] %in% c("character", "factor"))
      #       typ <- paste(typ, ", \"text\"", sep="")
      #   }
      #   typ <- paste(typ, ")", sep="")
      #   typ <- gsub("c(, ", "c(", typ, fixed=TRUE)
      #   typ <- gsub("ref = ", "", typ, fixed=TRUE)
      #   typ <- paste(typ, ")", sep="")  #  add back removed closing )
      #   message("\nThe read_excel function sometimes mistakenly reads numbers in\n",
      #     "the Excel Currency format as the type POSIXct, a date format\n\n",
      #     "Type POSIXct was assigned to one or more of your variables\n\n",
      #     "IF the variable assigned type POSIXct is NOT a date, then\n",
      #     "  explicitly specify if a variable is text, double or a date\n",
      #     "  by adding the  col_types  option to Read\n",
      #     "To do this re-read the data\n",
      #     "  by copying and pasting the following: \n\n",
      #     "   ", typ, "\n")
      # }
    }
  }  # end is data.frame


  # check for valid characters in the variable names
  if (format %in% c("csv", "Excel")) {
    dg <- character(length=10)
    for (i in 0:9) dg[i+1] <- as.character(i)
    ltr <- c(letters, LETTERS, dg, "_", ".", "(", ")")

    # get rid of variables that are not named (NA's)
    nm.miss <- is.na(names(d))
    d[nm.miss] <- NULL

    badchar <- FALSE
    for (i in 1:length(names(d))) {
      cc <- names(d)[i]
      if (!is.na(cc)) for (j in 1:nchar(cc)) {
        if (!(substr(cc,j,j) %in% ltr)) {
          badchar <- TRUE
          names(d)[i] <- gsub(substr(cc,j,j), "", names(d)[i])
          if (substr(cc,j,j) == " ")
            txt <- "Removed the blank space,"
          else
            txt <- paste("Removed the character, ", substr(cc,j,j), ",", sep="")
          cat(txt, "new variable name: ", names(d)[i], "\n")
        }
      }
    }
    if (badchar)
      cat("\nR only allows letters, digits and . or  _ in variable names\n\n")
  }


  # feedback
  # --------
  if (!quiet  &&  is.data.frame(d))
    details(d, n.mcut, miss.zero, max.lines, miss.show,
                      miss.matrix, brief)
  else
    cat("\n")

  return(d)

}

