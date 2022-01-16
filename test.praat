writeInfoLine: "test"

text$ = "veuille porte le mask ffp2"



while length(text$) > 0
	pos = index(text$, " ")
	mot$ = left$(text$,pos-1)
	text$ = right$(text$,length(text$)-pos)

	if pos  = 0
		mot$=text$
		text$=""
	endif

	appendInfoLine: "pos: ", pos, " - mots:|", mot$, "| - text: ", text$ 

endwhile

appendInfoLine:"fin"

