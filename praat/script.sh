#!/bin/bash
#-------------------------------------------------------
# pour lancer ce script:
# bash script.sh <fichier Logatomes textGrid> <fichier Logatomes wav> <dictionnaire>
#-------------------------------------------------------


TEXTGRID=$1

if [[ $TEXTGRID == "" ]]
then
    TEXTGRID="./input/Logatomes.TextGrid"
fi


SOUND=$2

if [[ $SOUND == "" ]]
then
    SOUND="./input/Logatomes.wav"
fi


DICO=$3

if [[ $DICO == "" ]]
then
    DICO="./input/dico2.txt"
fi


#Vidange des répertoires
if [ "$(ls -A ./output)" ] 
then 
   rm ./output/*.wav  
fi

#praat --run script_synth_auto.praat "./input/Logatomes.TextGrid" "./input/Logatomes.wav" "./input/dico2.txt" 

#praat --run script_synth_auto.praat "./input/faure.TextGrid" "./input/faure.wav" "./input/dico2.txt" 





praat --run script_synth_auto.praat $TEXTGRID $SOUND $DICO