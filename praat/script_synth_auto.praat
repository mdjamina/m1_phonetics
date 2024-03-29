clearinfo

select all
#pause
nocheck Remove

##########################

form command line calls
    sentence textGrid_filename ./input/Logatomes.TextGrid
    sentence sound_filename ./input/Logatomes.wav
    sentence dico_filename ./input/dico2.txt
	real play_sound 0
endform

writeInfoLine: ""
#appendInfoLine: "textGrid_filename: """, textGrid_filename$, """"
#appendInfoLine: "sound_filename: """, sound_filename$, """"
#appendInfoLine: "dico_filename: """, dico_filename$, """"

##########################
#lecture du fichier son des logatomes
sound = Read from file: sound_filename$

#select 'sound' 
frequency = Get sampling frequency


#lecture du fichier textGrid
@text_grid: textGrid_filename$



####################################
#chargement du dictionnaire
dico = Read Table from tab-separated file: dico_filename$

n_rows = Get number of rows
count = 0

dico2_filename$ =  dico_filename$ +  ".list.txt"
writeFileLine: dico2_filename$, "orthographe;phonetique" 


appendInfoLine: "Traitement en cours ..."

for i from 1 to n_rows
	#appendInfoLine: "------- --------"
	selectObject: "Table dico2"
	phonetique$ = Get value: i, "phonetique"
	orthographe$ = Get value: i, "orthographe"
	##appendInfoLine:" :  ",i , " - orthographe :",orthographe$ , " - phonetique :",phonetique$ 
	if (length(phonetique$) == 1)
		phonetique$ = "_"+phonetique$
	endif

	#recherche les diphones du mot dans le textGrid
	@check_logatomes: text_grid.diphone$#, phonetique$


	#si tout les diphones trouvés
	#creation de synthèse du mot courant
	if (check_logatomes.is_valid == 1)
		#appendInfoLine:" - ",orthographe$ , "  - ligne n°: ",i  , " - phonetique :",phonetique$ 
		count = count + 1

		appendFileLine: dico2_filename$, orthographe$ ,";", phonetique$ 

		select 'sound'
		sound_synthese = Create Sound from formula: "sineWithNoise", 1, 0, 0.1, frequency, "0"

		
		for index from 1 to length(phonetique$)-1
			diphone$ = mid$(phonetique$,index,2)
			#appendInfoLine: "diphone$:",diphone$, " - time_min=",text_grid.time_min [diphone$]," - time_max=",text_grid.time_max [diphone$]
			
			select 'sound'
			extract_sound = Extract part: text_grid.time_min [diphone$], text_grid.time_max [diphone$], "rectangular", 1, "no"

			select 'sound_synthese'

			id = selected ("Sound")
			#appendInfoLine: "sound_synthese id:",id
	
			plus 'extract_sound'
			sound_synthese = Concatenate

				#netoyage 
			selectObject: id
			Remove
			select 'extract_sound'
			Remove
		
		
		endfor

		select 'sound_synthese'
		Rename: "son synthese"

		if (play_sound == 1)
			appendInfoLine:" - ",orthographe$ , "  - ligne n°: ",i  , " - phonetique :",phonetique$ 
			Play

		endif
		output_sound$ = "./output/" + replace_regex$ (orthographe$,"\L","_",0 )+".wav"

		#appendInfoLine: "synthèse : ", output_sound$



		Save as WAV file: output_sound$
		#appendInfoLine: ""
		#appendInfoLine: "------- --------"
		#appendInfoLine: ""



	endif
	
	







endfor

appendInfoLine: "Total des mots trouvés: ", count
appendInfoLine: "Fichiers générés dans le dossier: ./output/"
appendInfoLine: "------fin---------"













###################################
# Partie déclaration des procédures
###################################

#Permet de vérifier si les diphones d'un mot sont disponible dans le fichier textgrid
# Paramètres:
# .list_diphone$# :  liste diphone (TextGrid)
# .str$ : le mot (phonetique)
procedure check_logatomes: .list_diphone$# .str$
	
	.is_valid = 0
	
	#nombre du phonemes
	nb_phonemes = length(.str$)
	
	#initialisation du nombre total des diphones dans un mot
	nb_diphone_total = 0

	#initialisation du nombre des diphones trouvés dans le TextGrid
	nb_diphone_trouve = 0

	
	
	if (nb_phonemes >0)
		index = 1
		#si le diphone est trouvé (d'un mot), on continue la boucle (optimisation) 
		diphone_trouve = 1
		
		#Pour chaque diphone dans le mot
		while ( index < nb_phonemes  and diphone_trouve = 1)
		
			diphone$ = mid$(.str$,index,2)
			
			nb_diphone_total = nb_diphone_total  + 1

			idx_lst = 1

			#si le diphone est trouvé (dans le TextGrid), on continue la boucle (optimisation)
			loga_trouve = 0

			diphone_trouve = 0

			while (idx_lst < size ( .list_diphone$#)+1 and loga_trouve == 0)
				
				p$ = .list_diphone$# [idx_lst] 
				#appendInfoLine: "idx_lst: ",idx_lst," -  p$: ",p$

				if ( diphone$ == p$ )
					
					#si le diphone est trouvé (dans le TextGrid), on continue la boucle (optimisation)
					loga_trouve = 1

					#si le diphone est trouvé (d'un mot), on continue la boucle (optimisation) 
					diphone_trouve = 1
					nb_diphone_trouve = nb_diphone_trouve + 1
				endif
				
				idx_lst = idx_lst + 1
			endwhile  

			index = index + 1
		endwhile
	
	
	if ( nb_diphone_total - nb_diphone_trouve == 0)
		.is_valid = 1
	endif
	
	endif
	
endproc



# Procédure permet le chargement du fichier .textGrid
# dans des tables 
# paramètres:
# .text_grid_file$ : chemin du fichier textGrid à charger
#
# output:
# .time_min : table contenant les informations sur le début de l'intervale pour chaque logatome (label)
# .time_max : table contenant les informations sur la fin de l'intervale pour chaque logatome (label)
procedure text_grid: .text_grid_file$

	select 'sound'
	point_process = To PointProcess (zeroes): 1, "yes", "no"

	#lecture du fichier
    textGrid = Read from file: .text_grid_file$

	select 'textGrid'

    #récupération du nombre des intervales présentent dans le fichiers
	nb_intervals = Get number of intervals: 1

	.labels$# = empty$#(nb_intervals)
	tmp_diphone$# = empty$#(nb_intervals)

	#printline nb_intervals 'nb_intervals'

    
	j=0
	for i from 1 to nb_intervals-1
		select 'textGrid'
		label$ = Get label of interval: 1, i
		x_min = Get start time of interval: 1, i
		x_max = Get end time of interval: 1, i
		

		if (label$ != "")
			
			#appendInfoLine: i, " - text#:", label$ ,  " - x_min# :",x_min, 	" -  x_max# :",x_max	
			i = i + 1
			j= j+1
			.labels$#[i]  = label$
			next_x_min = Get start time of interval: 1, i
			next_x_max = Get end time of interval: 1, i
		
			next_label$ = Get label of interval: 1, i

			#appendInfoLine: i, " - text#:", next_label$ ,  " - x_min# :",next_x_min, 	" -  x_max# :",next_x_max

			diphone$ = label$ + next_label$
			tmp_diphone$# [j] = diphone$

			midlle_time_min =  (x_min  + x_max)/2
			midlle_time_max = (next_x_min + next_x_max)/2

			select 'point_process'
			nearest_index = Get nearest index: midlle_time_min
			.time_min [diphone$] = Get time from index: nearest_index 
	
			nearest_index = Get nearest index: midlle_time_max
			.time_max [diphone$] = Get time from index: nearest_index 

			#appendInfoLine: "*** diphone$:",diphone$

		endif 

		#appendInfoLine: "--------------------------"

	endfor

	.diphone$# = empty$#(j)
	for idx from 1 to j
		.diphone$#[idx] = tmp_diphone$# [idx]
	endfor
	select 'point_process'
	Remove

endproc



