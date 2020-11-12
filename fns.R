f7Card_hw= function (..., img = NULL, title = NULL, footer = NULL, outline = FALSE, 
          height = NULL, width=NULL) 
{
  cardCl <- "card"
  if (!is.null(img)) 
    cardCl <- paste0(cardCl, " demo-card-header-pic")
  if (outline) 
    cardCl <- paste0(cardCl, " card-outline")
  cardStyle <- NULL
  if (!is.null(height)) {
    style <- paste0("height: ", shiny::validateCssUnit(height), ";",
                    " width: ", shiny::validateCssUnit(width), ";",
                    " overflow-y: auto;"
                    )
  }
  contentTag <- shiny::tags$div(class = "card-content card-content-padding", 
                                style = cardStyle, ...)
  headerTag <- if (!is.null(title)) {
    if (!is.null(img)) {
      shiny::tags$div(style = paste0("background-image:url(", 
                                     img, ")"), class = "card-header align-items-flex-end", 
                      title)
    }
    else {
      shiny::tags$div(class = "card-header", title)
    }
  }
  footerTag <- if (!is.null(footer)) {
    shiny::tags$div(class = "card-footer", footer)
  }
  mainTag <- if (!is.null(img)) {
    shiny::tags$div(class = "card demo-card-header-pic", 
                    headerTag, contentTag, footerTag)
  }
  else {
    shiny::tags$div(class = cardCl, headerTag, contentTag, 
                    footerTag)
  }
  return(mainTag)
}


#

# remove annoying refreshing
wordcloud2a <- function (data, size = 1, minSize = 0, gridSize = 0, fontFamily = "Segoe UI", 
                         fontWeight = "bold", color = "random-dark", backgroundColor = "white", 
                         minRotation = -pi/4, maxRotation = pi/4, shuffle = TRUE, 
                         rotateRatio = 0.4, shape = "circle", ellipticity = 0.65, 
                         widgetsize = NULL, figPath = NULL, hoverFunction = NULL) 
{
  if ("table" %in% class(data)) {
    dataOut = data.frame(name = names(data), freq = as.vector(data))
  }
  else {
    data = as.data.frame(data)
    dataOut = data[, 1:2]
    names(dataOut) = c("name", "freq")
  }
  if (!is.null(figPath)) {
    if (!file.exists(figPath)) {
      stop("cannot find fig in the figPath")
    }
    spPath = strsplit(figPath, "\\.")[[1]]
    len = length(spPath)
    figClass = spPath[len]
    if (!figClass %in% c("jpeg", "jpg", "png", "bmp", "gif")) {
      stop("file should be a jpeg, jpg, png, bmp or gif file!")
    }
    base64 = base64enc::base64encode(figPath)
    base64 = paste0("data:image/", figClass, ";base64,", 
                    base64)
  }
  else {
    base64 = NULL
  }
  weightFactor = size * 180/max(dataOut$freq)
  settings <- list(word = dataOut$name, freq = dataOut$freq, 
                   fontFamily = fontFamily, fontWeight = fontWeight, color = color, 
                   minSize = minSize, weightFactor = weightFactor, backgroundColor = backgroundColor, 
                   gridSize = gridSize, minRotation = minRotation, maxRotation = maxRotation, 
                   shuffle = shuffle, rotateRatio = rotateRatio, shape = shape, 
                   ellipticity = ellipticity, figBase64 = base64, hover = htmlwidgets::JS(hoverFunction))
  chart = htmlwidgets::createWidget("wordcloud2", settings, 
                                    width = widgetsize[1], height = widgetsize[2], sizingPolicy = htmlwidgets::sizingPolicy(viewer.padding = 0, 
                                                                                                                            browser.padding = 0, browser.fill = TRUE))
  chart
}

