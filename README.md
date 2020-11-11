# wordcloud
Shiny app to customize wordclouds from different text input-types. In spanish.

Inspired by this [post](https://www.statsandr.com/blog/draw-a-word-cloud-with-a-shiny-app/), I relied on [ShinyMobile](https://cran.r-project.org/web/packages/shinyMobile/) to assure a cross-device app and addedd a few controls and functionality I deemed useful.
You may try it [here](https://2exp3.shinyapps.io/wordcloud/).
***

Shiny app para convertir tu texto en nubes de palabras personalizables. En español.
Inspirado por este [post](https://www.statsandr.com/blog/draw-a-word-cloud-with-a-shiny-app/), recurrí a [ShinyMobile](https://cran.r-project.org/web/packages/shinyMobile/) para asegurarme que la app funcione bien en cualquier dispositivo, y además agregué algunos controles y funcionalidades que consideré útiles.
Podés probarla [áca](https://2exp3.shinyapps.io/wordcloud/).

## Con esta app vas a poder         
### Usar distintos inputs de texto con el **menú de la izquierda**:
- Los [discursos de inicio de sesiones del Congreso](https://www.casarosada.gob.ar/informacion/discursos?start=0) de 
  - Alberto Fernández en 2020 (AF)
  - Mauricio Macri en 2017 (MM)
- Escribir o copiar-y-pegar texto
- Subir un archivo con formato
  - **.csv**: OJO, todo el texto tiene que estar en la primera columna [ejemplo](https://www.github.com/2exp3/examples/JC.csv)
  - **.txt**: [ejemplo](https://www.github.com/2exp3/examples/JC.txt)
  - **.pdf**: Por ahora, es una función experimental. Tené en cuenta que mientras más largo sea, más tiempo de procesamiento toma [ejemplo](https://www.github.com/2exp3/examples/JC.pdf)
- No te olvides de elegir el <b>idioma</b> en el que está tu texto <b>antes</b> de cambiar tu input, para que podamos remover los signos de puntuación y las [palabras vacías] (https://es.wikipedia.org/wiki/Palabra_vac%C3%ADa).
- Elegir el número de palabras (más frecuentes) a usar.
- Filtrar más palabras que quieras remover manualmente.

### Personalizar tu nube de palabras con el **menú de la derecha**
- Los controles son intuitivos, jugá con ellos para ver cómo cambia tu nube (el tamaño de las letras define el tamaño de la nube).

### Tocar la solapa del medio para descargar tu
- nube en imagen **.png**
- texto procesado (palabras y frecuencias) en una lista **.csv**

Los cambios que hagas sobre la nube se actualizan en tiempo real, para que puedas personalizar con ayuda del feedback.

**¡Que lluevan palabras!**
