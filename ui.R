require(shiny)

shinyUI(fluidPage(
			# Application title
			titlePanel("LabelMaker Assistant"),
			helpText('Use this tool to help facilitate the making of entries for the', a('LabelMaker Spreasheet', href = ' https://docs.google.com/spreadsheets/d/1ngMyWLLtBerwBpAPl713UGix9b-jHmzALFPLHiP7UY0/edit?usp=sharing', target = '_blank'), '.'),
			fluidRow(column(3, textInput(inputId = 'experiment_id', label = 'Experiment ID', value = "EXPID")),
			column(3, numericInput(inputId = 'n_cages', label = 'Number of Cages', value = 1, min = 1, max = 100, step = 1)),
			column(2, dateInput(inputId = 'date_selected', label = "Select Dates", format = 'mm/dd/yy', value = Sys.Date()-3)),
			column(2, actionButton(inputId = 'reset_dates', label = "Reset Dates", icon = icon('refresh')), verbatimTextOutput('sampling_dates_selected'))
			),
			fluidRow(column(3, selectizeInput(inputId = 'sample_type', label = 'Select Sample Type', choices = c('General' = ' ', 'Fecal Pellet' = '-FP', 'Duodenum' = '-D', 'Jejunum' = '-J', 'Ileum' = '-I', 'Cecum' = '-C', 'Proximal Colon' = '-PC', 'Colon' = '-Colon', 'IgA' = '-IgA', 'Lipocalin' = '-LCN'), multiple = T, selected = ' '))
			),
			hr(),
			fluidRow(column(12, h5("Total # of Samples/Labels:"), textOutput('total_number_of_samples'))),
			hr(),
			h4('Caging Scheme'),
			helpText('Select/deselect animals that are in each cage.'),
			fluidRow(column(12, uiOutput('cages_ui'))),
			hr(),
			h4('Output for LabelMaker Spreadsheet'),
			helpText('Copy the output below and paste it into the LabelMaker Spreadsheet.'),
			fluidRow(column(6, verbatimTextOutput('final_output'))),
			helpText(a("Open LabelMaker Spreadsheet in a new tab", href = 'https://docs.google.com/spreadsheets/d/1ngMyWLLtBerwBpAPl713UGix9b-jHmzALFPLHiP7UY0/edit?usp=sharing', target = "_blank"))
			)
			)