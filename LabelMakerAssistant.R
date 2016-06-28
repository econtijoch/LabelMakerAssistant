#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


	require(shiny)
	
	shinyApp(
		ui = fluidPage( 
			# Application title
			titlePanel("LabelMaker Assistant"),
			helpText('Use this tool to help facilitate the making of entries for the', a('LabelMaker Spreasheet', href = ' https://docs.google.com/spreadsheets/d/1ngMyWLLtBerwBpAPl713UGix9b-jHmzALFPLHiP7UY0/edit?usp=sharing', target = '_blank'), '.'),
			fluidRow(column(3, textInput(inputId = 'experiment_id', label = 'Experiment ID', value = "EXPID")),
			column(3, numericInput(inputId = 'n_cages', label = 'Number of Cages', value = 1, min = 1, max = 100, step = 1)),
			column(2, dateInput(inputId = 'date_selected', label = "Select Dates", format = 'mm/dd/yy', value = Sys.Date()-3)),
			column(2, actionButton(inputId = 'reset_dates', label = "Reset Dates", icon = icon('refresh')), verbatimTextOutput('sampling_dates_selected'))
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
			fluidRow(column(4, verbatimTextOutput('final_output'))),
			helpText(a("Open LabelMaker Spreadsheet in a new tab", href = 'https://docs.google.com/spreadsheets/d/1ngMyWLLtBerwBpAPl713UGix9b-jHmzALFPLHiP7UY0/edit?usp=sharing', target = "_blank"))
			),
			
			
		server = function(input, output, session) {

			animal_ids <- c('a', 'b', 'c', 'd', 'e')
			
			output$select_sampling_dates <- renderUI({
				selectizeInput(inputId = 'sampling_dates', label = 'Dates to Sample', choices = format(seq(input$date_range[1], input$date_range[2], by = 1), format = "%m/%d/%Y"), multiple = T)
			})

			date_list <- reactiveValues(dates=NULL)
			
			observe({
				input$date_selected
				isolate({
					if (input$date_selected != Sys.Date()-3) {
					date_list$dates[[as.character(length(date_list$dates)+1)]] <- input$date_selected
				}
				})
			})
			
			observeEvent(input$reset_dates, {
				date_list$dates <- NULL
			})

			output$sampling_dates_selected <- renderPrint({
				if (!is.null(date_list$dates)) {
				dates <- format(as.Date(unlist(sort(date_list$dates))), "%m/%d/%Y")
				cat('Dates Selected\n')
				cat(paste(dates, '\n', sep = ""), sep = "")
			}
			})

			cage_reactive_output <- reactive({
				lapply(1:input$n_cages, function(i) {
					output[[paste0('cage_',i)]] <- renderUI({
						column(2, offset = -1, style = 'border-style: solid;border-color:black',checkboxGroupInput(inputId = paste0('cage_', i, '_animals_selected'), label = paste0("Animals in Cage # ", i), choices = animal_ids, selected = animal_ids, inline = F))
					})	
				})
			})
			output$cages_ui <- renderUI({cage_reactive_output()})
			
			
			input_list <- reactive({
				test <- reactiveValuesToList(input)
				return(test)
			})
			
			animals_total <- reactive({
				animals_list <- list()
				for (i in 1:input$n_cages) {
					animals_list[[i]] <- paste(i, input_list()[[paste0('cage_', i, '_animals_selected')]], sep = "")
				}
				return(unlist(animals_list))
			})
			
					
				output$final_output <- renderText({
					if (!is.null(date_list$dates)) {
					output_list <- list("EXP_ID\tSmpl_ID\tDate\n")
					for (i in 1:length(date_list$dates)) {
						for (j in 1:length(animals_total())) {
							output_list[[paste0(i,j)]] <- paste(paste(input$experiment_id, animals_total()[j], format(as.Date(unlist(sort(date_list$dates))), "%m/%d/%Y")[i], sep = '\t'), '\n', sep = "")
						}
					}
					unlist(output_list)
				}
				})
				
				output$total_number_of_samples <- renderText({
					length(animals_total())*length(unlist(date_list$dates))
				})
		}
	)