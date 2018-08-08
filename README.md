# WiseCondorX
This app is incomplete. 

02/07/18
WisecondorX requires reference BAM files from 'healthy' individuals to create the reference sample for CNV calling. 
These will be generated in-house to ensure data generation is equal for test samples.

## Todo
* Add BAM index files to input spec (takes too long to index)
* Complete readme.

* The following parameters require adding to the dxapp.json file to become optional inputs:
convert_retdist
convert_binsize
convert_retthresh
ref_binsize
ref_refsize
minrefbins
maskrepeats
alpha
beta
blacklist

* Test on nexus