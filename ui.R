require(shiny)
require(shinyjs)

shinyUI(fluidPage(
			useShinyjs(),
			tags$head(tags$script(src = "message-handler.js")),
			# Application title
			tags$div(id = 'Top'),
			tags$nav(class = 'navbar navbar-inverse navbar-fixed-bottom', tags$div(align = 'center', class = 'container-fluid', tags$ul(class = 'nav navbar-nav', tags$li(tags$a(href = '#Top', 'Top')), tags$li(tags$a(href = '#Cages', 'Cages')), tags$li(tags$a(href = '#Labels', 'Labels')), tags$li(tags$a(href = '#Mapping', 'Mapping'))))),
			titlePanel("Interactive LabelMaker Assistant"),
			helpText('Use this interactive UI to help facilitate the making of labels for sample collection. Any labels generated here can be exported to the', a('LabelMaker Spreasheet', href = ' https://docs.google.com/spreadsheets/d/1ngMyWLLtBerwBpAPl713UGix9b-jHmzALFPLHiP7UY0/edit?usp=sharing', target = '_blank'), ' directly. You can generate labels interactively and download them directly to the desktop from here.'),
			fluidRow(column(3, textInput(inputId = 'experiment_id', label = 'Experiment ID', value = "EXPID")),
			column(3, numericInput(inputId = 'n_cages', label = 'Number of Cages', value = 1, min = 1, max = 100, step = 1)),
			column(2, dateInput(inputId = 'date_selected', label = "Select Dates", format = 'mm/dd/yy', value = Sys.Date()-3)),
			column(2, verbatimTextOutput('sampling_dates_selected'), p(), actionButton(inputId = 'reset_dates', label = "Reset Dates", icon = icon('refresh')))
			),
			fluidRow(column(3, selectizeInput(inputId = 'sample_type', label = 'Select Sample Type', choices = c('General' = ' ', 'Fecal Pellet' = '-FP', 'Duodenum' = '-D', 'Jejunum' = '-J', 'Ileum' = '-I', 'Cecum' = '-C', 'Proximal Colon' = '-PC', 'Colon' = '-Colon', 'IgA' = '-IgA', 'Lipocalin' = '-LCN'), multiple = T, selected = ' '))
			),
			hr(),
			tags$div(id = 'Cages'),
			h4('Caging Scheme'),
			helpText('Select/deselect animals that are in each cage.'),
			fluidRow(column(12, uiOutput('cages_ui'))),
			hr(),
			fluidRow(column(12, h5("Total # of Samples/Labels:"), textOutput('total_number_of_samples'))),
			hr(),
			tags$div(id = 'Labels'),
			h4('View Label Output'),
			helpText('The entries in the table below can be downloaded locally as a .csv file to use with the LabelMark software, and can also be exported into the label database in the LabelMaker Spreadsheet (the tab titled Master List 2).'),
			fluidRow(column(6, offset = 1, 
				downloadButton('download_labels_file', 'Download Labels.csv file'), actionButton(inputId = 'add_to_master', label = "Push to 'Master List 2' tab in LabelMaker Spreadsheet"),
				HTML("<br><br>"),
				tableOutput('labelmaker_output')
#			helpText(a("Open LabelMaker Spreadsheet in a new tab", href = 'https://docs.google.com/spreadsheets/d/1ngMyWLLtBerwBpAPl713UGix9b-jHmzALFPLHiP7UY0/edit?usp=sharing', target = "_blank")),
			)), 
			hr(),
			tags$div(id = 'Mapping'),
			h4('Output for Mapping File'),
			helpText('This table has a more complete description of the samples, which can be downloaded for further uses downstream.'),
			fluidRow(column(10, offset = 1,  
				downloadButton('download_mapping', 'Download Mapping File (.csv)'),
				HTML("<br><br>"),
				tableOutput('mapping_output'),
				HTML("<br><br><br>")))
			)
			)