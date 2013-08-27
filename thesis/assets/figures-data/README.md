Generating pdf figures by gnuplot
==============
* Set the following terminal:
`set term epslatex size 6,3 standalone color colortext 10`
Note: if you use gnuplot 'save' command, modify the saved file and manually add the above line. Additionally, set the proper output.
* The output file has to have the same as the gnuplot input file.
* Run `./generate-pdf-figure.sh GNUPLOT-FILE-WITHOUT-EXTENSION`
* Example:
`./generate-pdf-figure.sh chapter-1/public-cloud-services-market-size`

