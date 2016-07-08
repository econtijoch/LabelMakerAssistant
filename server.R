require(shiny)
require(stringr)
require(googlesheets)
suppressPackageStartupMessages(require(dplyr))

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
						column(2, style = 'border-style: solid;border-color:black', checkboxGroupInput(inputId = paste0('cage_', i, '_animals_selected'), label = paste0("Animals in Cage # ", i), choices = animal_ids, selected = animal_ids, inline = F), hr(), selectInput(inputId = paste0('cage_', i, '_sex'), label = paste0("Cage # ", i, " Animal Sex"), choices = c("Female", "Male")), hr(), textInput(inputId = paste0('cage_', i, '_condition'), label = paste0("Cage # ", i, " Condition"), value = paste0('Condition_', i)))
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
						if (input$sample_type[k] == " ") {
							if (!is.null(input_list()[[paste0('cage_', i, '_animals_selected')]])) {
						animals_list[[paste0(i,"_",k)]] <- paste(i, input_list()[[paste0('cage_', i, '_animals_selected')]], sep = "")
					}
					} else {
						if (!is.null(input_list()[[paste0('cage_', i, '_animals_selected')]])) {
						animals_list[[paste0(i,"_",k)]] <- paste(i, input_list()[[paste0('cage_', i, '_animals_selected')]], input$sample_type[k], sep = "")
					}
					}
					}
				}
				return(unlist(animals_list))
			})
			
			
			labelmaker_table <- reactive({
				if (!is.null(date_list$dates) && !is.null(input$sample_type)) {
				output_list <- list("Experiment_ID\tSample_ID\tDate\tBarcodeID\n")
				unique_dates <- unique(unlist(date_list$dates))
				for (i in 1:length(unique(unlist(date_list$dates)))) {
					for (j in 1:length(animals_total())) {
						
						expid <- input$experiment_id
						sampleid <- str_pad(animals_total()[j], width = 15 - nchar(expid), pad = "0", side = 'left')
						date <- format(as.Date(unique(unlist(sort(date_list$dates))), origin = "1970-01-01"), "%m%d%y")[i]
						random_string <- paste(sample(c(LETTERS, letters, 0:9), replace = T,size = 5), collapse = "")
						
						barcodeid <- paste(expid, sampleid, date, random_string,  sep = "|")
						
						output_list[[paste0(i,"_",j)]] <- paste(paste(input$experiment_id, animals_total()[j], format(as.Date(unique(unlist(sort(date_list$dates))), origin="1970-01-01"), "%m/%d/%Y")[i], barcodeid, sep = '\t'), '\n', sep = "")

					}
				}
				final <- unlist(output_list)
				cat(final, file = 'temp.txt')
				
				table <- read.delim('temp.txt', header = T)
				table$Experiment_ID <- input$experiment_id
				output <- list(table, output_list)
				return(output)
			}
			})
					
				output$labelmaker_output <- renderTable({labelmaker_table()[[1]]}, include.rownames = F)
				

				observeEvent(input$add_to_master, {
					success <- list()
					for (i in 1:nrow(labelmaker_table()[[1]])) {
						success[[i]] <- capture.output({ss %>% gs_add_row(ws = "Master List 2", input = labelmaker_table()[[1]][i,])}, type = 'message')
					}
					unlisted_success <- unlist(success)
					number_appended <- sum(unlisted_success == 'Row successfully appended.')
					session$sendCustomMessage(type = 'testmessage', message = paste(number_appended, 'rows were added to LabelMaker Spreadsheet Master List 2 tab.'))
				})
				
				labels_file <- reactive({
					table <- labelmaker_table()[[1]]
					output <- data.frame(a = table$Sample_ID, b = table$Experiment_ID, c = table$Sample_ID, d = gsub("/", "|", as.character(table$Date)), e = table$BarcodeID)
					
				})
				
				output$download_labels_file <- downloadHandler(

				    # This function returns a string which tells the client
				    # browser what name to use when saving the file.
				    filename = function() {
						"Labels.csv"
					  },

				    # This function should write data to a file given to it by
				    # the argument 'file'.
				    content = function(file) {
				      # Write to a file specified by the 'file' argument
				      write.table(labels_file(), file, quote = FALSE, row.names = FALSE, col.names = FALSE, sep = ",", eol = '\r\n')
				    }
				  )
				
				
				mapping_table <- reactive({

					if (!is.null(date_list$dates) && !is.null(input$sample_type)) {
					output_list <- list("Experiment_ID\tSample_ID\tDate\tBarcodeID\tCage\tAnimal\tSample_Type\tMaleFemale\tCondition\n")
					unique_dates <- unique(unlist(date_list$dates))
					for (i in 1:length(unique(unlist(date_list$dates)))) {
						for (j in 1:length(animals_total())) {
							
							expid <- input$experiment_id
							sampleid <- str_pad(animals_total()[j], width = 15 - nchar(expid), pad = "0", side = 'left')
							date <- format(as.Date(unique(unlist(sort(date_list$dates))), origin = "1970-01-01"), "%m%d%y")[i]
							random_string <- paste(sample(c(LETTERS, letters, 0:9), replace = T,size = 5), collapse = "")
							
							if (grepl("-", animals_total()[j])) {
								animal <- unlist(strsplit(animals_total()[j], "-"))[1]
								sample_type <- unlist(strsplit(animals_total()[j], "-"))[2]
							} else {
								animal <- animals_total()[j]
								sample_type <- "General"
							}
							
							cage <- unique(na.omit(as.numeric(unlist(strsplit(unlist(animal), "[^0-9]+")))))
							
							malefemale <- input_list()[[paste0('cage_', cage, '_sex')]]
							
							condition <- input_list()[[paste0('cage_', cage, '_condition')]]
							
							output_list[[paste0(i,"_",j)]] <- paste(paste(input$experiment_id, animals_total()[j], format(as.Date(unique(unlist(sort(date_list$dates))), origin="1970-01-01"), "%m/%d/%Y")[i], " ", cage, animal, sample_type, malefemale, condition,  sep = '\t'), '\r\n', sep = "")
						
						
						}
					}
					final <- unlist(output_list)
					cat(final, file = 'temp2.txt')
					
					table <- read.delim('temp2.txt', header = T)
					table$BarcodeID <- labelmaker_table()[[1]]$BarcodeID
					table$Experiment_ID <- input$experiment_id
					output <- list(table, output_list)
					return(output)
				}
				})
				
				output$mapping_output <- renderTable({mapping_table()[[1]]}, include.rownames = F)

				
				output$download_mapping <- downloadHandler(

				    # This function returns a string which tells the client
				    # browser what name to use when saving the file.
				    filename = function() {
						  paste(input$experiment_id, "mapping.csv", sep = "_")
					  },

				    # This function should write data to a file given to it by
				    # the argument 'file'.
				    content = function(file) {
				      # Write to a file specified by the 'file' argument
				      write.table(mapping_table()[[1]], file,
				        row.names = FALSE, quote = FALSE, sep = ",", eol = "\r\n")
				    }
				  )
				
				
				output$total_number_of_samples <- renderText({
					length(animals_total())*length(unique(unlist(date_list$dates)))
				})
		}
	)