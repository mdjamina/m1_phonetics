clearinfo


select all
#pause
nocheck Remove

#déclaration du mot à synthétiser
##################creation msgbox
form mot à synthétiser?

text text la vieille porte le masque


endform


appendInfoLine: "text: ", text$

#######################

dico = Read Table from tab-separated file: "dico2.txt"


@transcript_phonetic: "vieille"

#detetection de la durée du mot pour l'intervalle
prosodie$ = transcript_phonetic.result$
prosodie_last_diphone$ = right$(prosodie$,3)
p1$ = mid$(prosodie_last_diphone$,1,1)
p2$ = mid$(prosodie_last_diphone$,2,1)

#appendInfoLine: prosodie_last_diphone$, " - ", p1$, " - ", p2$
@transcript_phonetic: text$

sentence$ = transcript_phonetic.result$

appendInfoLine: "phonetic: ", sentence$

##########################

sound = Read from file: "amina.wav"
textGrid = Read from file: "amina.textGrid"

select 'sound'
frequency = Get sampling frequency

#appendInfoLine: "frequency :",frequency 

sound_synthese = Create Sound from formula: "sineWithNoise", 1, 0, 0.1, frequency, "0"

select 'sound'
point_process = To PointProcess (zeroes): 1, "yes", "no"


###########################
select 'textGrid'

nb_intervals = Get number of intervals: 1

#printline nb_intervals 'nb_intervals'

nb_phonemes = length(sentence$)

for index from 1 to nb_phonemes-1

	diphone$ = mid$(sentence$,index,2)

	phoneme1$ = mid$(diphone$,1,1)
	phoneme2$ = mid$(diphone$,2,1)

	appendInfoLine: "-------------------------------------------"

	appendInfoLine: "diphone: ", diphone$	

	for interval from 1 to nb_intervals-1
		select 'textGrid'
		
		#phoneme 1
		label$ = Get label of interval: 1, interval		
		start_time = Get start time of interval: 1, interval
		end_time = Get end time of interval: 1, interval
	
		next_interval = interval+1
		#phoneme 2
		next_label$ = Get label of interval: 1, next_interval
		next_start_time = Get start time of interval: 1, next_interval 
		next_end_time = Get end time of interval: 1, next_interval

		if (label$ = phoneme1$ and next_label$ = phoneme2$)

			appendInfoLine: "label$: ", label$+next_label$	

		
			midlle_time =  (start_time + end_time)/2
			next_midlle_time = (end_time + next_end_time)/2


			#printline 1 - midlle_time='midlle_time:2' - next_midlle_time='next_midlle_time:2'

			select 'point_process'
			nearest_index = Get nearest index: midlle_time
			midlle_time = Get time from index: nearest_index 

			nearest_index = Get nearest index: next_midlle_time
			next_midlle_time = Get time from index: nearest_index 


			#appendInfoLine: "- midlle_time=",'midlle_time:2'," - next_midlle_time=",'next_midlle_time:2'
	
			select 'sound'
			extract_sound = Extract part: midlle_time, next_midlle_time, "rectangular", 1, "no"

			select 'sound_synthese'
			plus 'extract_sound'
			sound_synthese = Concatenate
			#todo récupération des infos temporelles posodie
			
			
			
			if (label$ = p1$ and next_label$ = p2$ )
				prosodie_time_end = Get total duration
				appendInfoLine: "Time duration", prosodie_time_end 

			endif
			
			
			 


		endif
	
	endfor
endfor
	
select 'sound_synthese'
Rename: "son synthese"

Play
Save as WAV file: "son_synthese.wav"

##################################


prosodie_time_start = 0
prosodie_time_end = 2
manipulation = To Manipulation: 0.01, 75, 600
extract_pitch = Extract pitch tier
Remove points between: prosodie_time_start , prosodie_time_end 
Add point: 0.5, 180
Add point: 1.5, 190
Add point: 2, 230
select 'manipulation'
plus 'extract_pitch'
Replace pitch tier


#manipulation = To Manipulation: 0.01, 75, 600
#extract_pitch  = Extract duration tier
#Remove points between: 0, 1



appendInfoLine: "fin"




#Scripting 5.5. Procedures
procedure transcript_phonetic: .str$
	# tokenization
	## ref Scripting 5.7. Vectors and matrices (8. String vectors)
	tokens$# = splitByWhitespace$#(.str$)

	.result$ = "_"

	select 'dico'
	for i from 1 to size (tokens$#)
		row_num = Search column: "orthographe", tokens$# [i]
		value$ = Get value: row_num , "phonetique"
		.result$ = .result$ + value$
		#appendInfoLine: tokens$# [i], " - ",row_num  
	endfor

	.result$ = .result$ + "_"
endproc




