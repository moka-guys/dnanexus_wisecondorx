# WiseCondorX

## About
Wisecondor detects copy number variants from low-coverage NGS (WGS). Different regions on the genome vary in read frequency characteristics from one sample to another. While between-sample comparison suffers from this, within-sample comparison does not: regions with equal characteristics will behave alike within a test sample, as all regions are subject to the same experimental procedures. Wisecondor performs within-sample comparisons, removing the need to account for read frequency variations over different samples.

## Method
Previous popular methods apply GC-correction and segment the signal, but the segmentation scheme for detecting break points can be sensitive and problematic with larger aberrations. We adopt a similar window-based approach but avoid the need to segment the read-depth signal. To identify target bins, the whole genome is divided into bins of a user-defined size. Target bins in the test sample are identified, for which a set of 'reference bins' from *a different* chromosome are determined, for every target bin. The bins with the smallest *squared Euclidean distance between GC-normalized read frequencies* are selected as reference bins. Significance testing for variant calls is accomplished using a z score method. 	

In the WiseCondor1.0 paper, Straver et al (2013) state that "gender-specific chromosomes were omitted because the amounts of reads that map to the X and Y chromosomes are too strongly correlated with the percentage of fetal DNA in the sample as well as the fetus’ gender. If more reference samples would be available, detection of subchromosomal disorders on chromomes X could become possible. Detection of aberrations on the Y chromosome appears to be more problematic owing to its small size and repetitive sequence, leading to mappability difficulties." 

## WiseCondor X
Hiujsdends-van Amsterdam et al (2018) made alterations to the WiseCondor program including reduced bin size and a sliding window z-score approach. WiseCondorX adds further improvements, with the addition of gender chromosomes. For WiseCondorX, reference (control) samples must always be present to match to test cases. 

Inputs for wisecondor must be **reference bams** and **test sample bam**. Each reference bam should be obtained from **healthy individuals**. Reference bams should be separated by gender with 50-200 samples per gender. These bams are are used to create a gender-specific reference sample against which the test sample (of the same gender) is assesed.

## References
Center for Medical Genetics Ghent. 2018. WisecondorX Readme. https://github.com/CenterForMedicalGeneticsGhent/WisecondorX/blob/master/README.md

Straver, R., Sistermans, E.A., Holstege, H., Visser, A., Oudejans, C.B. and Reinders, M.J., 2013. WISECONDOR: detection of fetal aberrations from shallow sequencing maternal plasma based on a within-sample comparison scheme. Nucleic acids research, 42(5), pp.e31-e31.

Huijsdens–van Amsterdam, K., Straver, R., van Maarle, M.C., Knegt, A.C., Van Opstal, D., Sleutels, F., Smeets, D. and Sistermans, E.A., 2018. Mosaic maternal 10qter deletions are associated with FRA10B expansions and may cause false-positive noninvasive prenatal screening results. Genetics in Medicine.