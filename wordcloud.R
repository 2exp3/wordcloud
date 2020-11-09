library(shiny);library(wordcloud2);library(tm);library(colourpicker);library(shinyMobile); library(sysfonts);library(shinyWidgets);
library(htmlwidgets); library(tesseract); library(shinyscreenshot); library(data.table);library(pdftools);

source("helper.R")


# UI ====
ui = f7Page(
  title = "WordCloud",
  init = f7Init(skin = "auto", color = "blue",theme = "light"),
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
        # left-hand side bar
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
            # Add the selector for the language of the text
            f7Select(
              inputId = "language",
              label = "Idioma del texto",
              choices =  langs,
              selected = "Spanish",
              width = "100%"
            ),
            f7Toggle(inputId = "remove_words",label =  "Remover palabras específicas",checked =  FALSE),
            conditionalPanel(
              condition = "input.remove_words == 1",
              textAreaInput(inputId = "words_to_remove", label = "Separá las palabras con un espacio",rows=7,
                            placeholder = "Palabras a remover...")
            )
          ),
          theme = "dark",
          side = "left",
          title = ""
        ),

        # right-hand side bar
        f7Panel(
          effect = "cover",
          resizable = T, 
          tagList(
            
            #bkg color
            f7ColorPicker(inputId = "col",label =  "Color del fondo", 
                          value = "#ffffff",modules = "hsb-sliders"), # white as default
            # cloud shape
            f7Select(
              inputId = "wshape",
              label = "Forma de la nube",
              choices =  c("circle","cardioid","diamond",
                           "triangle", "pentagon","star"),
              selected = "circle",
              width = "100%"
            ),
            
            h3("   Palabras"),
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
            f7Radio(
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
              condition = "input.wcolor == tu color ",
              f7ColorPicker(inputId = "wcolorm",label = "Tu color",
                            value = "#ffffff",modules = "hsb-sliders"),
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
              choices =  fontnames,
              selected = "Segoe UI",
              width = "100%"
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

            # rotation
            h3("   Rotación"),
            # min
            knobInput(
              cursor = T,
              inputId = "wminRotation",
              label = "Ángulo mínimo",
              thickness = 0.2,
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
              label = "Ángulo máximo",
              thickness = 0.2,
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
              # color = "blue",
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
          f7Card_hw(
            height = "500px",
            tagList(
              cloudBttn(
                icon = icon("cloud"),size = "lg",style = "jelly",
                inputId = "go_cloud",label = "",color = "primary"
              ), br(), br(),
              # display cloud!
              wordcloud2Output("cloud") 
            )
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
            f7Card_hw(
              tagList(
                f7Flex(
                  f7Block(),
                  f7Icon("cloud_fill",
                         style = "font-size:100px")
                  , 
                  f7Block() 
                ),  
                screenshotButton(id = "cloud",filename = "mi_nube.png",scale = 3,timer = 1,
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
            f7Card_hw(
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
server = function(input, output) {
  # functions ====
  # pdf - text  conversion
  pdf2text=function(input,  dpi=300){
    # pdf to png
    pngfile = pdf_convert(input$Archivo$datapath, dpi = dpi)
    # ppng to text using lang specific engine
    text = ocr(pngfile)
    textcat=paste(text, collapse = '') # concat char vectors (for >1-page pdfs)
    return(textcat)
  }
  
  # to get wordfreq data from input
  create_data = function(data, num_words = 100) {
    # If text is provided, convert it to a data table of word frequencies
    if (is.character(data)) {
      corpus = Corpus(VectorSource(data)) 
      corpus = tm_map(corpus, tolower)
      corpus = tm_map(corpus, removePunctuation)
      corpus = tm_map(corpus, removeNumbers)
      corpus = tm_map(corpus, 
                      removeWords, stopwords(tolower(input$language)))
      # remove user words
      if (input$remove_words==T){corpus = tm_map(corpus, 
                                                 removeWords, unlist(strsplit(input$words_to_remove)," "))}

      tdm = as.matrix(TermDocumentMatrix(corpus))
      data = sort(rowSums(tdm), decreasing = TRUE, method="quick")
      data = data.table(word = names(data), freq = as.numeric(data))
      
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
    }else{
      return(data)
    }
  }
  
  # to get the cloud from the data with freqs
  create_cloud = function(data, 
                          wbackgroundColor = "#ffffff", 
                          wsize = 0.5,
                          wgridSize = 0,
                          wfontFamily = "Segoe UI",
                          wfontWeight = 400,
                          wcolor="random-dark",
                          wcolorm = NULL,
                          wminRotation = 0,
                          wmaxRotation = 0,
                          wrotateRatio = 1,
                          wshape = "circle") {
    # transform degrees to radians
    wminRotation_rad=input$wminRotation * (pi/180)
    wmaxRotation_rad=input$wmaxRotation * (pi/180)
    
    # text color
    wcolor=ifelse(wcolor=="tu color",wcolorm,wcolor)
    
    # customize cloud
    wordcloud2(
      data,
      # widgetsize = c("50%","50%"),
      backgroundColor = wbackgroundColor,
      size = wsize,
      gridSize = wgridSize,
      fontFamily = wfontFamily,
      fontWeight=wfontWeight,
      color = wcolor,
      minRotation = wminRotation_rad,
      maxRotation = wmaxRotation_rad,
      shuffle = F,
      rotateRatio = wrotateRatio,
      shape = wshape
    )
}
  
  # Reactions ====

  # input data
  data_source = reactive({
    if (input$source == "Demo: MM") {
      wdata=readLines("www/MM.txt",encoding = "UTF-8")
    } else if (input$source == "Demo: AF") {
      wdata=readLines("www/AF.txt",encoding = "UTF-8")
    } else if (input$source == "Escribir") {
      wdata = input$text
    } else if (input$source == "Subir archivo") {
      wdata = input_file()
    }
    return(wdata)
  })
  
  # parse input file
  input_file = reactive({
    if (is.null(input$Archivo)) {
      return("")
    }
    # if pdf
    if (substr(input$Archivo$name,nchar(input$Archivo$name)-2,nchar(input$Archivo$name)) == "pdf"){
      return(pdf2text(input))
    }else{
      # if csv or txt
      return(readLines(input$Archivo$datapath,encoding = "UTF-8") )}
  })
  
  # data with word freqs
  datafreq = reactive ( {create_data(data = data_source(),input$num)} )
  
  # create cloud on go
  datacloud = eventReactive(
    input$go_cloud,
    {return(
      create_cloud(datafreq(),
                   wbackgroundColor = input$col,
                   wsize = input$wsize,
                   wgridSize = input$wgridSize,
                   wfontFamily = input$wfontFamily,
                   wfontWeight=input$wfontWeight,
                   wcolor = input$wcolor,
                   wcolorm = input$wcolorm,
                   wminRotation = input$wminRotation,
                   wmaxRotation = input$wmaxRotation,
                   wrotateRatio = input$wrotateRatio,
                   wshape = input$wshape) )
    })
  # render cloud
  output$cloud = 
    renderWordcloud2( { datacloud() })
  

  # export word data
  output$download_csv = downloadHandler(
    filename = function() {paste0('tus_palabras','.csv')},
    content = function(file) {write.csv(datafreq(),file)
    }
  )
  
}

# RUN APP ====
shinyApp(ui = ui, server = server)

