Source is 'Chart2.svg' from the reference 'https://www.eia.gov/todayinenergy/detail.php?id=42915' (see paper)
from this individual images are taken for each plot.
Then the data points are extracted using web plot digitizer (https://apps.automeris.io/wpd4/) and saved by file->save project
The projects files are then loaded by LoadWebPlotDigitizerProject or LoadSet methods of LoadCurve (LoadSet will look at all files matching a pattern and attempt to load them using LoadWebPlotDigitizerProject)

