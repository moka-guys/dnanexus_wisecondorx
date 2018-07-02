# WisecondorX

# Functional Requirements
- Analyse patient sample for CNVs

# Technical Requirements
- Package as DNA nexus app
- Expose arguments for configuration
- Create reference sample with appropriate gender parameter*

# App stages
1. Convert bam to .npz
2. Create reference
3. Predict CNVs

* CNV analysis in WisecondorX requires comparisons between a 'reference' sample and a 'test' sample. The reference sample must be generated from \*.bam files of healthy individuals using the `WisecondorX newref` command. Seperate references containing all male and all female samples are required.

# Design
DNA nexus app can should be run from the command line as:
dxrun wisecondorx input_bam reference_bams

input_bam	directory containing the sample bam file
ref_bams 	directory containing reference bam files
binsize		the size per bin in bp. The reference bin size should be a multiple of this value.

Optional args (stage):
--binsize	Size per bin in bp, the reference bin size should be a multiple of this value (default: x=5000 (5kb))
--retdist	Max amount of bp's between reads to consider them part of the same tower (default: x=4)
--retthres	Threshold for a group of reads to be considered a tower. These will be removed (default: x=4)

The application will:
1. Convert all bams to .npz (including reference bams with .npz output in a separate directory)
2. Create a new reference from the reference_bam.npz files. This can be done in a loop to create reference files with multiple different reference bin sizes (kb).
3. Predict CNVs
