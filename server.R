require(shiny)

shinyServer(function(input, output, session) {

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
				dates <- format(as.Date(unique(unlist(sort(date_list$dates))), origin="1970-01-01"), "%m/%d/%Y")
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
					for (k in 1:length(input$sample_type)) {
						animals_list[[paste0(i,"_",k)]] <- paste(i, input_list()[[paste0('cage_', i, '_animals_selected')]], input$sample_type[k], sep = "")
					}
				}
				return(unlist(animals_list))
			})
			
					
				output$final_output <- renderText({
					if (!is.null(date_list$dates) && !is.null(input$sample_type)) {
					output_list <- list("EXP_ID\tSmpl_ID\tDate\n")
					unique_dates <- unique(unlist(date_list$dates))
					for (i in 1:length(unique(unlist(date_list$dates)))) {
						for (j in 1:length(animals_total())) {
							output_list[[paste0(i,"_",j)]] <- paste(paste(input$experiment_id, animals_total()[j], format(as.Date(unique(unlist(sort(date_list$dates))), origin="1970-01-01"), "%m/%d/%Y")[i], sep = '\t'), '\n', sep = "")
						}
					}
					unlist(output_list)
				}
				})
				
				output$total_number_of_samples <- renderText({
					length(animals_total())*length(unique(unlist(date_list$dates)))
				})
		}
	)