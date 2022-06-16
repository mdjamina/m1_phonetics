clearinfo

select all
#pause
nocheck Remove

##########################

#chargement du dictionnaire
dico = Read Table from tab-separated file: "./input/dico2.txt"

n_rows = Get number of rows

for i from 1 to 12
	value$ = Get value: i, "phonetique"
	appendInfoLine:"n_rows : ",i , " - value :",value$ 

endfor
	






#lecture du fichier son des logatomes
sound = Read from file: "./input/Logatomes.wav"

select 'sound' 
frequency = Get sampling frequency

appendInfoLine: "frequency :",frequency 

#lecture du fichier textGrid
@text_grid: "./input/Logatomes.TextGrid"


for i from 1 to size (text_grid.diphone$#)
	appendInfoLine:"n_rows : ",i , " - value :",text_grid.diphone$# [i] 
endfor






appendInfoLine: "------fin---------"













###################################
# Partie déclaration des procédures
###################################


# Procédure premet le chargement du fichier .textGrid
# dans des tables 
# paramètres:
# .text_grid_file$ : chemin du fichier textGrid à charger
#
# output:
# .time_min : table contenant les information sur le début de l'intervale pour chaque logatome (label)
# .time_max : table contenant les information sur la fin de l'intervale pour chaque logatome (label)
procedure text_grid: .text_grid_file$

	select 'sound'
	point_process = To PointProcess (zeroes): 1, "yes", "no"

	#lecture du fichier
    textGrid = Read from file: .text_grid_file$

	select 'textGrid'

    #récupération du nombre des intervales présentent dans le fichiers
	nb_intervals = Get number of intervals: 1

	.labels$# = empty$#(nb_intervals)
	.diphone$# = empty$#(nb_intervals)

	printline nb_intervals 'nb_intervals'

    #
	j=0
	for i from 1 to nb_intervals-1
		select 'textGrid'
		label$ = Get label of interval: 1, i
		x_min = Get start time of interval: 1, i
		x_max = Get end time of interval: 1, i
		

		if (label$ != "")
			
			appendInfoLine: i, " - text#:", label$ ,  " - x_min# :",x_min, 	" -  x_max# :",x_max	
			i = i + 1
			j= j+1
			.labels$#[i]  = label$
			next_x_min = Get start time of interval: 1, i
			next_x_max = Get end time of interval: 1, i
		
			next_label$ = Get label of interval: 1, i

			appendInfoLine: i, " - text#:", next_label$ ,  " - x_min# :",next_x_min, 	" -  x_max# :",next_x_max

			diphone$ = label$ + next_label$
			.diphone$# [j] = diphone$

			midlle_time_min =  (x_min  + x_max)/2
			midlle_time_max = (next_x_min + next_x_max)/2

			select 'point_process'
			nearest_index = Get nearest index: midlle_time_min
			.time_min [diphone$] = Get time from index: nearest_index 
	
			nearest_index = Get nearest index: midlle_time_max
			.time_max [diphone$] = Get time from index: nearest_index 

			appendInfoLine: "diphone$:",diphone$

		endif 

		appendInfoLine: "--------------------------"

	endfor
	select 'point_process'
	Remove

endproc

