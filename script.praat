clearinfo

select all
#pause
nocheck Remove

##########################


dico = Read Table from tab-separated file: "dico2.txt"

sound = Read from file: "Logatomes.wav"

select 'sound' 
frequency = Get sampling frequency

appendInfoLine: "frequency :",frequency 

@text_grid: "Logatomes.textGrid"


########################### 

text$ = "la vieille porte le masque et amina l'apporte"

appendInfoLine: "text: ", text$

@transcript_phonetic: text$, 1

sentence$ = transcript_phonetic.result$

appendInfoLine: "sentence$: ", sentence$

@transcript_phonetic: "vieille", 0

prosodie$ = transcript_phonetic.result$

index_prosodie_min = index (sentence$, prosodie$)
index_prosodie_max = index_prosodie_min + length(prosodie$)-2

appendInfoLine: "prosodie$: ", prosodie$, " - index:", index_prosodie_min  ,"|",index_prosodie_max 



select 'sound'
sound_synthese = Create Sound from formula: "sineWithNoise", 1, 0, 0.1, frequency, "0"

nb_phonemes = length(sentence$)

for index from 1 to nb_phonemes-1
	diphone$ = mid$(sentence$,index,2)
	appendInfoLine: "diphone$:",diphone$, " - time_min=",text_grid.time_min [diphone$]," - time_max=",text_grid.time_max [diphone$]



	select 'sound'
	extract_sound = Extract part: text_grid.time_min [diphone$], text_grid.time_max [diphone$], "rectangular", 1, "no"

	select 'sound_synthese'

	id = selected ("Sound")
	#appendInfoLine: "sound_synthese id:",id
	
	plus 'extract_sound'
	sound_synthese = Concatenate

	if (index = index_prosodie_min) 
		appendInfoLine: "------------------", diphone$
		prosodie_time_start = Get total duration
		
		delta = text_grid.time_max [diphone$] - text_grid.time_min [diphone$]

		prosodie_time_start = prosodie_time_start - delta 
		
		appendInfoLine: "Time duration", prosodie_time_start
	endif

	if (index = index_prosodie_max)
		appendInfoLine: "------------------", diphone$
		prosodie_time_end = Get total duration
		appendInfoLine: "Time duration", prosodie_time_end 

	endif

	#netoyage 
	selectObject: id
	Remove
	select 'extract_sound'
	Remove
	

endfor



select 'sound_synthese'
Rename: "son synthese"

Play
Save as WAV file: "son_synthese.wav"



##################################
#modification prosodique 

#prosodie_time_start = 0
#prosodie_time_end = 2

step = (prosodie_time_end - prosodie_time_start) / 3
manipulation = To Manipulation: 0.01, 75, 600
extract_pitch = Extract pitch tier
Remove points between: prosodie_time_start , prosodie_time_end 

pt = prosodie_time_start
Add point: pt , 180
pt = pt +step
Add point: pt, 190
pt = pt +step
Add point: pt, 230

select 'manipulation'
plus 'extract_pitch'
Replace pitch tier


#manipulation = To Manipulation: 0.01, 75, 600
#extract_pitch  = Extract duration tier
#Remove points between: 0, 1



appendInfoLine: "fin"

###########################





#Scripting 5.5. Procedures
procedure transcript_phonetic: .str$, .addpause
	pause$ = "_"	
	if .addpause=0
		pause$ = ""
	endif

	# tokenization
	## ref Scripting 5.7. Vectors and matrices (8. String vectors)
	.tokens$# = splitByWhitespace$#(.str$)

	

	.result$ = pause$

	select 'dico'
	for i from 1 to size (.tokens$#)
		row_num = Search column: "orthographe", .tokens$# [i]
		value$ = Get value: row_num , "phonetique"
		.result$ = .result$ + value$
		#appendInfoLine: .tokens$# [i], " - ",row_num  
	endfor

	.result$ = .result$ + pause$
endproc



procedure text_grid: .text_grid_file$

	select 'sound'
	point_process = To PointProcess (zeroes): 1, "yes", "no"

	textGrid = Read from file: .text_grid_file$

	select 'textGrid'

	nb_intervals = Get number of intervals: 1

	#printline nb_intervals 'nb_intervals'

	for i from 1 to nb_intervals-1
		select 'textGrid'
		label$ = Get label of interval: 1, i
		x_min = Get start time of interval: 1, i
		x_max = Get end time of interval: 1, i

		if (label$ != "")
			#appendInfoLine: i, " - text#:", label$ ,  " - x_min# :",x_min, 	" -  x_max# :",x_max	
			i = i + 1
			next_x_min = Get start time of interval: 1, i
			next_x_max = Get end time of interval: 1, i
		
			next_label$ = Get label of interval: 1, i

			#appendInfoLine: i, " - text#:", next_label$ ,  " - x_min# :",next_x_min, 	" -  x_max# :",next_x_max

			diphone$ = label$ + next_label$

			midlle_time_min =  (x_min  + x_max)/2
			midlle_time_max = (next_x_min + next_x_max)/2

			select 'point_process'
			nearest_index = Get nearest index: midlle_time_min
			.time_min [diphone$] = Get time from index: nearest_index 
	
			nearest_index = Get nearest index: midlle_time_max
			.time_max [diphone$] = Get time from index: nearest_index 

			#appendInfoLine: "diphone$:",diphone$, " - midlle_time_min=",time_min [diphone$]," - midlle_time_max=",time_max [diphone$]

		endif 

		#appendInfoLine: "--------------------------"

	endfor
	select 'point_process'
	Remove

endproc

