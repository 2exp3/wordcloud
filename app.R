library(shiny);library(wordcloud2);library(tm);library(colourpicker);library(shinyMobile);library(shinyWidgets);
library(shinyscreenshot);
library(waiter);
library(tesseract); library(pdftools)

#  set some overall params ====
# set waiter theme
waiter_set_theme(html = spin_whirly(), color = "white")

# load available cloud languages
langs=readLines("www/langeng.txt",encoding="UTF-8")
names(langs)= readLines("www/langesp.txt",encoding="UTF-8")
langs = langs[order(names(langs))]

# instructions text
instructions=HTML(readLines("www/instructions.txt",encoding = "UTF-8") ) 

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


# UI ====
ui = f7Page(
  use_waiter(),
  title = "WordCloud",
  init = f7Init(skin = "auto", color = "blue",theme = "light",),
  f7TabLayout(
    navbar = 
      f7Navbar(
        title = "",
        hairline = TRUE,
        shadow = TRUE,
        left_panel = TRUE,
        right_panel = TRUE
      ),
    panels =  
      tagList(
        # left-hand side bar ====
        f7Panel(
          effect = "cover",
          resizable = T, 
          tagList(
            f7Radio(
              inputId = "source",
              label = "",
              choices = c(
                "Demo: AF",
                "Demo: MM",
                "Escribir",
                "Subir archivo"
              ),
              selected = "Demo: AF"
            ),
            # Add the selector for the language of the text
            f7Select(
              inputId = "language",
              label = "Idioma del texto",
              choices = langs,
              selected = "Spanish",
              width = "100%"
            ),
            # user text
            conditionalPanel(
              condition = "input.source == 'Escribir'",
              textAreaInput("text", "Ingresá texto", rows = 7, placeholder = "Acá va tu texto")
            ),
            # Wrap the file input in a conditional panel
            conditionalPanel(
              condition = "input.source == 'Subir archivo'",
              f7File("Archivo", "Elegí un archivo",buttonLabel = "Buscar...")
            ),
            br(),
            
            h3("   Filtrar palabras"),
            # num of words
            f7Slider(
              inputId = "num",
              label = "Cantidad",
              color = "green",
              min = 3,
              max = 1000, 
              labels = tagList(f7Icon("minus"),
                               f7Icon("plus")),
              value = 100,
              step = 10
            ),
            textAreaInput(inputId = "words_to_remove", label = "Remover",rows=7,value = "",
                          placeholder = "Separá las palabras a remover con un espacio..."),
            f7Block()
            
          ),
          theme = "dark",
          side = "left",
          title = ""
        ),
        
        # right-hand side bar ====
        f7Panel(
          effect = "cover",
          resizable = T, 
          tagList(
            #bkg color
            spectrumInput(
              inputId ="col", 
              label = "Color del fondo", selected = "white",
              update_on = "change",
              choices = NULL,options =  list(`choose-text` = "OK")
            ),
            # cloud shape
            f7Select(
              inputId = "wshape",
              label = "Forma de la nube",
              choices =  c("circle","cardioid","diamond",
                           "triangle", "pentagon","star"),
              selected = "circle",
              width = "100%"
            ),
            # cloud ellip
            f7Slider(
              inputId = "wellipticity",
              label = "Achatamiento",
              color = "green",
              min = 0.01,
              max = 0.99,
              labels = tagList(f7Icon("arrow_left_right"),
                               f7Icon("arrow_up_down")),
              value = 0.6,
              step = .05
            ),

            h3("   Palabras"),
            # font size
            f7Slider(
              inputId = "wsize",
              label = "Tamaño",
              color = "green",
              min = 0.05,
              max = 1.5,
              labels = tagList(f7Icon("zoom_out"),
                               f7Icon("zoom_in")),
              value = 0.5,
              step = .05
            ),

            # text color
            f7Select(
              inputId = "wcolor",
              label = "Color",
              choices =
                c("random-dark",
                  "random-light",
                  "tu color"
                ),
              selected = "random-dark"
            ),
            conditionalPanel(
              condition = "input.wcolor == 'tu color'",
              spectrumInput(
                inputId ="wcolorm", 
                label = "Tu color", selected = "blue",
                update_on = "change",
                choices = NULL,options =  list(`choose-text` = "OK")
              ),
            ),
            
            # font weight
            f7Slider(
              inputId = "wfontWeight",
              label = "Grosor",
              color = "green",
              min = 100,
              max = 900,
              labels = tagList(f7Icon("smallcircle_fill_circle"),
                               f7Icon("largecircle_fill_circle")),
              value = 400,
              step = 100
            ),
            # font family
            f7Select(
              inputId = "wfontFamily",
              label = "Tipografía",
              choices =  c(sort(c("Helvetica","Garamond","Frutiger","Segoe UI","Lucida","Arial","Bookman Old Style")),"Otra"),
              selected = "Segoe UI",
              width = "100%"
            ),
            conditionalPanel(
              condition = "input.wfontFamily == 'Otra'",
              textAreaInput(inputId = "wfontFamilym", label = "Tu tipografía",rows=2,value = "",
                            placeholder = "Ingresá el nombre de la fuente...")
              ),
            # grid size
            f7Slider(
              inputId = "wgridSize",
              label = "Separación",
              color = "green",
              min = 0,
              max = 50,
              labels = tagList(f7Icon("rectangle_arrow_up_right_arrow_down_left_slash"),
                               f7Icon("rectangle_arrow_up_right_arrow_down_left")),
              value = 0,
              step = 2
            ),
            # 
            # rotation
            h4("     Rotación"),
            # min
            knobInput(
              cursor = T,
              displayPrevious = T,
              inputId = "wminRotation",
              label = "Angulo mínimo",

              thickness = 0.3,
              width = 100, height=100,
              # height="50%",
              post = "",
              displayInput = T,
              min = -180,
              max = 180,angleOffset=180,
              rotation = "anticlockwise",
              value = 0,
              step = 1
            ),
            # max
            knobInput(
              cursor = T,
              inputId = "wmaxRotation",
              label = "Angulo máximo",
              thickness = 0.3,
              width = 100, height=100,
              fgColor = "#428BCA",
              inputColor = "#428BCA",
              post = "",
              displayInput = T,
              min = -180,
              max = 180,angleOffset=180,
              rotation = "anticlockwise",
              value = 0,
              step = 1
            ),
            # probability
            f7Slider(
              inputId = "wrotateRatio",
              label = "Probabilidad de rotar",
              min = 0,
              max = 1,
              labels = tagList(f7Icon("arrow_down_circle"),
                               f7Icon("arrow_up_circle")),
              value = 1,
              step = 0.1
            ),
          ),
          br(),
          theme = "dark",
          side = "right",
          title = ""
        )
      )
    ,
    # set 3 tabs
    f7Tabs(
      swipeable = T,animated = F,
      # 1. Create a "Word cloud" tab
      f7Tab(
        tabName = "Nube",
        icon = f7Icon("cloud"),
        active = FALSE,
        f7Shadow(
          intensity = 5,
          hover = T,
          f7Card(height = "600px",
            # display cloud!
            wordcloud2Output("cloud") 
          )
        )          
      ),
      
      # 2. Create a Download tab 
      f7Tab(
        tabName = "Descargar",
        icon = f7Icon("cloud_download"),
        active = FALSE,
        f7Block(),
        f7Flex(
          f7Block(),
          f7Shadow(
            intensity = 15,pressed = T,hover = T,
            f7Card(
              tagList(
                f7Flex(
                  f7Block(),
                  f7Icon("cloud_fill",
                         style = "font-size:100px")
                  ,
                  f7Block()
                ),
                screenshotButton(id = "cloud",filename = "mi_nube",scale = 3,timer = 1,
                                 icon = icon("download"), class="button button-fill",
                                 label = "NUBE (.PNG) ")
              )
            )
          ),
          f7Block()
        )
        ,
        f7Block()
        ,
        f7Flex(
          f7Block(),
          f7Shadow(
            intensity = 15,pressed = T,hover = T,
            f7Card(
              tagList(
                f7Flex(
                  f7Block(),
                  f7Icon("square_list_fill",
                         style = "font-size:100px;"),
                  f7Block()
                ),
                f7DownloadButton(
                  outputId = "download_csv",
                  label = "Lista (.csv)",
                  style="width:100%;",class="button button-fill external shiny-download-link")
              )
            )
          ),
          f7Block()
        )
      )
      ,
      # 3. Create an "About this app" tab (open at start)
      f7Tab(
        active = TRUE,
        tabName = "Ayuda",
        icon = f7Icon("question_circle"),
        br(),
        f7Shadow(
          intensity = 5,
          hover = F,
          f7Card(title =h1("WordCloud: Convertí tus palabras en una nube.", style="text-align: center;"),
                 instructions,
                 footer =
                   tagList(
                     f7Link(
                       external = T,
                       icon = f7Icon("logo_twitter"),
                       label = "",
                       src = "https://twitter.com/2exp3/"
                     ),
                     f7Link(
                       external = T,
                       icon = f7Icon("logo_github"),
                       label = "",
                       src = "https://github.com/2exp3/wordcloud"
                     )
                   )
          )
        )
      )
    )
  )
)


# SERVER ====
server = function(input, output, session) {
  # waiter on cloud output canvas
  wtr = Waiter$new(id="cloud")
  # input data
  data_source = reactive({
    if (input$source == "Demo: AF") {
      data = readLines("www/AF.txt",encoding = "UTF-8")
    }else if (input$source == "Demo: MM") {
      data=readLines("www/MM.txt",encoding = "UTF-8")
    } else if (input$source == "Escribir") {
      data = input$text
    } else if (input$source == "Subir archivo") {
      data = input_file()
    }
    return(data)
  })
  
  # upload input file
  input_file = reactive({
    if (is.null(input$Archivo)) {
      return("")
    }
    if (substr(input$Archivo$name,nchar(input$Archivo$name)-2,nchar(input$Archivo$name)) == "pdf"){
      return(pdf_file(input$Archivo$datapath,wtr=wtr))
    }else{
      # if csv or txt
      return(readLines(input$Archivo$datapath,encoding = "UTF-8") ) 
    }
  })
  
  # pdf conversion fn
  pdf_file=function(datapath,wtr=wtr){
    wtr$show()
    # pdf to png
    pngfile = pdf_convert(datapath, dpi = 300)
    # png to text
    text = ocr(pngfile)
    textcat=paste(text, collapse = '') # concat char vectors (for >1-page pdfs)
    wtr$hide()
    return(textcat)
  }

  # create cloud
  create_wordcloud = function(data, 
                              num_words = 100, 
                              wbackgroundColor = "white",
                              wsize = 0.5,
                              wgridSize = 0,
                              wfontFamily = "Segoe UI",
                              wfontFamilym = "",
                              wfontWeight=400,
                              wellipticity = 0.6,
                              wcolor = "random-dark",
                              wcolorm = "",
                              wminRotation = 0,
                              wmaxRotation = 0,
                              wrotateRatio = 1,
                              wshape = "circle",
                              wtr=wtr
                              ) {
    wtr$show()
    on.exit({wtr$hide()})
    # 
    # If text is provided, convert it to a dataframe of word frequencies
    if (is.character(data)) {
      corpus = Corpus(VectorSource(data))
      corpus = tm_map(corpus, tolower)
      corpus = tm_map(corpus, removePunctuation)
      corpus = tm_map(corpus, removeNumbers)
      corpus = tm_map(corpus, removeWords, 
                      stopwords(tolower(input$language)))
      corpus = tm_map(corpus, removeWords, 
                      tolower(unlist(strsplit(input$words_to_remove," ") )) )
      tdm = as.matrix(TermDocumentMatrix(corpus))
      data = sort(rowSums(tdm), decreasing = TRUE, method="quick")
      data = data.frame(word = names(data), freq = as.numeric(data))
    }
    
    # Make sure a proper num_words is provided
    if (!is.numeric(num_words) || num_words < 3) {
      num_words = 3
    }else if(num_words>nrow(data)) {
      num_words = nrow(data)
    }
    
    # Grab the top n most common words
    data = head(data, n = num_words)
    if (nrow(data) == 0) {
      return(NULL)
    }
    
    # transform degrees to radians
    wminRotation_rad=wminRotation * (pi/180)
    wmaxRotation_rad=wmaxRotation * (pi/180)
    
    # text color
    wcolorok=ifelse(wcolor=="tu color",
                  wcolorm,
                  wcolor)
    # text font
    wfontFamily=ifelse(wfontFamily=="Otra",
                  wfontFamilym,
                  wfontFamily)
    # cloud
    wordcloud2a(
      data,
      shuffle = F,
      
      backgroundColor = wbackgroundColor,
      color = wcolorok,
      
      size = wsize,
      fontFamily = wfontFamily,
      fontWeight = wfontWeight,
      
      minRotation =wminRotation_rad ,
      maxRotation = wmaxRotation_rad,
      rotateRatio =wrotateRatio,
      
      ellipticity = wellipticity,
      shape =wshape ,
      gridSize = wgridSize
      )

  }
  
  # render cloud
  output$cloud = renderWordcloud2({
    create_wordcloud(
      data_source(),
      num_words = input$num,
      wbackgroundColor = input$col,
      wsize = input$wsize,
      wgridSize = input$wgridSize,
      
      wfontFamily = input$wfontFamily,
      
      wfontFamilym = input$wfontFamilym,
      
      wfontWeight=input$wfontWeight,
      wellipticity = input$wellipticity,
      wcolor = input$wcolor,
      wcolorm = input$wcolorm,
      
      wminRotation = input$wminRotation,
      wmaxRotation = input$wmaxRotation,
      wrotateRatio = input$wrotateRatio,
      wshape = input$wshape,
      wtr=wtr
    )
  })
  
  
  
  # create cloud
  create_data2csv = function(data,num_words = 100) {
    if (is.character(data)) {
      corpus = Corpus(VectorSource(data))
      corpus = tm_map(corpus, tolower)
      corpus = tm_map(corpus, removePunctuation)
      corpus = tm_map(corpus, removeNumbers)
      corpus = tm_map(corpus, removeWords, 
                      stopwords(tolower(input$language)))
      corpus = tm_map(corpus, removeWords, 
                      tolower(unlist(strsplit(input$words_to_remove," ") )) )
      tdm = as.matrix(TermDocumentMatrix(corpus))
      data = sort(rowSums(tdm), decreasing = TRUE, method="quick")
      data = data.frame(word = names(data), freq = as.numeric(data))
    }
    # Make sure a proper num_words is provided
    if (!is.numeric(num_words) || num_words < 3) {
      num_words = 3
    }else if(num_words>nrow(data)) {
      num_words = nrow(data)
    }
    # Grab the top n most common words
    data = head(data, n = num_words)
    if (nrow(data) == 0) {
      return(NULL)
    }
    return(data)
  }
  # export word data
  output$download_csv = downloadHandler(
    filename = function() {paste0('tus_palabras','.csv')},
    content = function(file) {
      write.csv(    
        create_data2csv(
          data_source(),
          num_words = input$num
          ),
        file)
    }
  )
}

shinyApp(ui = ui, server = server)