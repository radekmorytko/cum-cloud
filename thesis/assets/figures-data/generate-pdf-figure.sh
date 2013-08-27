#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Wrong number of arguments! The only argument should be  " \
    "the name of the gnuplot input file  (with .gnu extension). " \
    "Output must have the same name as the input file."
  exit 1
fi

DIRECTORY=`echo "$1" | sed 's/\(.*\)\/\(.*\)$/\1/'` 
BARE_FILE=`echo "$1" | sed 's/\(.*\)\/\(.*\)$/\2/'` 
DESTINATION_DIR=../figures/$DIRECTORY
CURRENT_DIR=`pwd`
GNUPLOT_FILE=$BARE_FILE.gnu
EPS_FILE=$BARE_FILE-inc.eps
TEX_FILE=$BARE_FILE.tex

function cleanup {
  rm -rf *.log *.aux *.eps *-inc.pdf *.tex
}

cd $DIRECTORY

if [ ! -f $GNUPLOT_FILE ]; then 
  echo "File $GNUPLOT_FILE not found!" 
  cd $CURRENT_DIR
  exit 1
fi

# this command should create a 'eps' file
gnuplot $GNUPLOT_FILE

if [ ! -f $EPS_FILE ]; then 
  echo "File $EPS_FILE not found!"
  cleanup
  cd $CURRENT_DIR
  exit 1
fi

epstopdf $EPS_FILE
pdflatex $TEX_FILE

cleanup
cd $CURRENT_DIR

mv $1.pdf $DESTINATION_DIR

