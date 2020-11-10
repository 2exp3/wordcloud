# extras ====

# set waiter theme
waiter_set_theme(html = spin_whirly(), color = "white")

# load available cloud languages
langs=readLines("www/langeng.txt",encoding="UTF-8")
names(langs)= readLines("www/langesp.txt",encoding="UTF-8")
langs = langs[order(names(langs))]

# instructions text
instructions=HTML(readLines("www/instructions.txt",encoding = "UTF-8") ) 

# get system fonts
fontnames=sysfonts::font_files()$ps_name

# to get reproducible clouds
set.seed(291)

# load spa engine for ocr (sadly, this is unbearably slow for a shinyapps free account :/)
# Sys.setenv(TESSDAT_PREFIX = ".")
# path=paste0(getwd(), '/tessdata')
# 
# tesseract_download('spa', datapath = path)
# spa = tesseract('spa', datapath = path)


# f7Card with patched css style
f7Card_hw=function (..., img = NULL, title = NULL, footer = NULL, outline = FALSE, 
                    height = NULL, width= NULL) 
{
  cardCl = "card"
  if (!is.null(img)) 
    cardCl = paste0(cardCl, " demo-card-header-pic")
  if (outline) 
    cardCl = paste0(cardCl, " card-outline")
  cardStyle = NULL
  if (!is.null(height)) {
    cardStyle = paste0("height: ", shiny::validateCssUnit(height), "; ",
                        "width: ", shiny::validateCssUnit(width),"; ",
                        "overflow-y: auto;")
  }
  contentTag = shiny::tags$div(class = "card-content card-content-padding", 
                                style = cardStyle, ...)
  headerTag = if (!is.null(title)) {
    if (!is.null(img)) {
      shiny::tags$div(style = paste0("background-image:url(", 
                                     img, ")"), class = "card-header align-items-flex-end", 
                      title)
    }
    else {
      shiny::tags$div(class = "card-header", title)
    }
  }
  footerTag = if (!is.null(footer)) {
    shiny::tags$div(class = "card-footer", footer)
  }
  mainTag = if (!is.null(img)) {
    shiny::tags$div(class = "card demo-card-header-pic", 
                    headerTag, contentTag, footerTag)
  }
  else {
    shiny::tags$div(class = cardCl, headerTag, contentTag, 
                    footerTag)
  }
  return(mainTag)
}

# cloud button
cloudBttn=function (inputId, label = NULL, icon = NULL, style = "unite", 
                    color = "default", size = "md", block = FALSE, 
                    no_outline = TRUE) 
{
  value = shiny::restoreInput(id = inputId, default = NULL)
  style = match.arg(arg = style, choices = c("simple", 
                                              "bordered", "minimal", "stretch", "jelly", 
                                              "gradient", "fill", "material-circle", 
                                              "material-flat", "pill", "float", "unite"))
  color = match.arg(arg = color, choices = c("default", 
                                              "primary", "warning", "danger", "success", 
                                              "royal"))
  size = match.arg(arg = size, choices = c("xs", "sm", 
                                            "md", "lg"))
  tagBttn = tags$button(id = inputId, type = "button", 
                         class = "action-button bttn", `data-val` = value, 
                         class = paste0("bttn-", style), class = paste0("bttn-", 
                                                                        size), 
                         class = paste0("bttn-", color), list(icon, 
                                                              label), 
                         class = if (block) 
                           "bttn-block",
                         class = if (no_outline) 
                           "bttn-no-outline",
                         style = " width:20%;margin:0 auto;
    display:block;")
  shinyWidgets:::attachShinyWidgetsDep(tagBttn, "bttn")
}

wordcloud2OutputNC <- function(outputId, width = "100%", height = "400px") {
  widget_out <- htmlwidgets::shinyWidgetOutput(outputId, "wordcloud2", width, height, package = "wordcloud2")
}