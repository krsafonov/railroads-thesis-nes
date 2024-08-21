# Railroads and their lagged impact on the economy
## Thesis Code

This repository includes the thesis and the parts of my code which I used. Three main parts include data collection (downloading, scraping, processing, cleaning), matlab model optimization, and final step regressions.

Structure:
- [Data Processing](data%20collection):
This folder contains main data collection and data processing Python scripts.
	- [Hisorical line collection](data%20collection/collect_historical_lines.ipynb): the main data collection and data processing file.

   	There is no historical railroad network available so I build it myself. The main assumption is that the most railroad networks built in 19th century in Russia are still present today.
   
	I first get and scrape resources (wikidata, openstreetmap, alta) with information about coordinates of today's railroad stations. The data is not high-quality: many errors, some coordinates being completely off, many stations are not geolocated at all. Thus, this script serves to semi-automize the data cleaning task: I wrote the function to calcalute haversine distance between stations and compare it with the distance that coordinates imply. The script tries to find the most accurate coordinates from 3 sources: wikidata, openstreetmap, alta, as well as correctly reorder stations in the sequence. Also, the script highlights the completely off and missing coordinates (here, I also differentiate missing coordinates by importance: the start of the station line and the end of the station line are of utmost importance, while some coordinates in between are less important for the project). Anyway, after this script I double-checked everything myself paying the most attention to algorithmically selected completely-off and missing coordinates. 

	The historical railroad network is then constructed by referring to the handbook (link: https://istmat.org/node/42966): if my constructe network is present in the handbook, I assign the construction date to it till 1897. Note that the process can be done only manually because the handbook has only names of the railroad lines, and many current and historical names, of course, do not coincide.


	- [Maps and graphs Visualization](data%20collection/maps%20and%20graphs.ipynb): the script I wrote to visualize the actual railroad network in 1897. Also, there I created the adjacency matrix for the graph, and did some data preparation for MATLAB (matlab/data.json).
	- [Web scraper](data%20collection/web_scraper.ipynb) parses Alta source as an additional source for geolocating.
- [MATLAB](matlab):
	This part contains the matlab script of network optimization and the toolbox I used (to be extended a bit).
- [QGIS](qgis):
	The QGIS project visualizes the collected historical network.
- [Regressions](regressions.R):
	Main specifications of regressions I used.
