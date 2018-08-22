# WisecondorX predict v1.0
[CenterForMedicalGeneticsGhent/WisecondorX v0.2.0](https://github.com/CenterForMedicalGeneticsGhent/WisecondorX/releases/tag/v0.2.0)

## What does this app do?
Predict Copy Number Variations (CNVs) from Whole Genome Sequence (WGS) data.

## What are typical use cases for this app?
WisecondorX predicts CNVs from NGS samples. For this prediction, a specific reference file made from sequences of healthy individuals is required for comparison. This app takes alignment files for a WGS sample and predicts CNVs.

## What inputs are required for this app to run?
* Input sample alignment file (`*.bam`)
* Input sample alignment index file (`*.bam.bai`)
* WisecondorX reference for male samples (`reference_male.npz`)
* WisecondorX reference for female samples (`reference_female.npz`)

## What does this app output?
Outputs are found in the Results/wisecondorx/ directory. The following results are returned by the app:

Output file or directory| Name
---|:---
CNV plots for each chromosome | \*plots/
CNV abberations | \*_aberrtions.bed
Chromosome bin regions | \*_bins.bed
Chromosome statistics | \*_chr_statistics.txt
Chromosome segments | *_segments.bed

## How does this app work?
This app determines the gender of the input sample alignment using `WisecondorX gender`. The gender-appropriate reference file is passed, along with the alignment, to `WisecondorX predict` for detecting CNVs.


*Developed by Viapath Genome Informatics*
