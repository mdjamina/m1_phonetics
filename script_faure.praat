clearinfo

select all
#pause
nocheck Remove

##################creation msgbox
form mot à synthétiser?

text text 

endform



dictionnaire = Read Table from tab-separated file: "dico1.txt"

######################

#text$ = "par"


##########################################


#déclaration du mot à synthétiser


num_ligne_mot = Search column: "orthographe", text$

mot$ = Get value: num_ligne_mot, "phonetique"

printline text: 'text$' => 'mot$'

##########################
file_wav = Read from file: "faure.wav"
file_grid = Read from file: "faure.TextGrid"


son_sythese = Create Sound from formula: "sineWithNoise", 1, 0, 0.1, 44100, "0"


###########################
#select 'file_wav '
point_process = To PointProcess (zeroes): 1, "yes", "no"


###########################
select 'file_grid'

nb_intervals = Get number of intervals: 1

printline nb_intervals 'nb_intervals'


##############################

nb_phonemes = length(mot$)

for index from 1 to nb_phonemes-1

	diphone$ = mid$(mot$,index,2)

	phoneme1$ = mid$(diphone$,1,1)
	phoneme2$ = mid$(diphone$,2,1)

	for interval from 1 to nb_intervals-1
		select 'file_grid'
		start_interval = Get start time of interval: 1, interval
		end_interval = Get end time of interval: 1, interval
		label$ = Get label of interval: 1, interval
	
		next_interval = interval+1
		next_start_interval = Get start time of interval: 1, next_interval 
		next_end_interval = Get end time of interval: 1, next_interval 

		next_label$ = Get label of interval: 1, next_interval

		if (label$ = phoneme1$ and next_label$ = phoneme2$)

			printline label: 'label$' - next_label: 'next_label$'
		
			mid_interval =  (start_interval + end_interval)/2
			select 'point_process'

			nearest_index = Get nearest index: mid_interval
			time_index = Get time from index: nearest_index 

			mid_next_interval = (end_interval + next_end_interval)/2

			nearest_index_next = Get nearest index: mid_interval_next
			time_index_next = Get time from index: nearest_index_next


			printline mid:'mid_interval:2' et mid_next:'mid_next_interval:2'
			printline time_index:'time_index:2' et time_index_next:'time_index_next:2'
	
			#printline start_interval: 'start_interval:2'
			#printline end_interval: 'end_interval:2'
		
			#printline next_start_interval: 'next_start_interval:2'
			#printline next_end_interval: 'next_end_interval:2'

			select 'file_wav'

			extrait_son = Extract part: time_index, time_index_next, "rectangular", 1, "no"

			select 'son_sythese'
			plus 'extrait_son'
			son_sythese = Concatenate


		endif
	
	endfor
endfor
	printline interval 'interval'
	
select 'son_sythese'
Rename: "son synthese"
##################################







