# WiseCondorX
This app is incomplete. 

090818
Problem1. Zero division error when using one reference file. The app seems reasonable, so running with lots of input may work.

Problem2. Newer version of wcx could be installed (after using bioconda for dependencies), however reference npz has changed and it isn't in bioconda - cannot install dependencies in a tarball from conda

Best bet is to run improved app with all inputs and see. MAKE REF TAR FIRST, build app, test.


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