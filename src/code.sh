#!/bin/bash

# -e = exit on error; -x = output each line that is executed to log; -o pipefail = throw an error if there's an error in pipeline
set -e -x -o pipefail

function wcx_command {
	# Call Wisecondor X to predict CNVs
	# Args: (input.npz, reference.npz)
    WisecondorX predict $1 $2 ${outdir}/${1%%.npz} --bed --plot\
		# --minrefbins $min_ref_bins
		# --maskrepeats $mask_repeats
		# --alpha $alpha
		# --beta $beta
		# --blacklist $blacklist
		# --bed
		# --plot
}

function wcx_run {
	# Run WisecondorX dependent on input sample gender
	# Args: input.npz
	input_npz=$1
	local gender=$(WisecondorX gender $input_npz)
	# Run with appropriate reference for gender
	if [[ $gender =~ "female" ]]; then
		$(wcx_command $input_npz reference_female.npz)
	elif [[ $gender =~ "male" ]]; then
		$(wcx_command $input_npz reference_male.npz)
	fi
}

# Download input data
# project_for_newref -- project containing wisecondorx_reference directory with reference BAMs
# resolution -- Resolution of windows/bins in bp. Set as --binsize parameter on the `newref` command
# input_bam -- input bam file for samples to test
# input_bam_index -- input bam index file for samples to test
# reference_male_prefix -- string prefix of files to use as male reference
# reference_female_prefix -- string prefix of files to use as female reference
dx-download-all-inputs

# Install conda. Set to beginning of path variable for python calls
gzip -d Miniconda2-latest-Linux-x86_64.sh.gz
bash Miniconda2-latest-Linux-x86_64.sh -b -p $HOME/miniconda
export PATH="$HOME/miniconda/bin:$PATH"

# Install WisecondorX
conda install -f -y -c conda-forge -c bioconda wisecondorx=0.2.0

# Set the binsize for the `Wisecondor convert` command. 
# All converted BAM files must use a binsize that is a multiple of the input resolution. Here we 
# use a default of 1/20th.
convert_binsize=$((resolution/20))

###### Create reference files

# Download reference bams
dx download -r ${project_for_newref}:/wisecondorx_reference/

# Convert all bams to numpy zip files
for file in wisecondorx_reference/*.bam; do
	prefix=${file%%.bam}
	WisecondorX convert $file ${prefix}.npz --binsize $convert_binsize #--retdist $convert_retdist --retthres $convert_retthresh
done

# Create male and female sample holding directories
male_dir="$HOME/male"
female_dir="$HOME/female"
mkdir -p $male_dir $female_dir

# Separate the male and female reference sample npz files into respective directories
# for file in wisecondorx_reference/*.npz; do
# 	if [[ $(WisecondorX gender $file) =~ "male" ]]; then mv $file $male_dir 
# 	elif [[ $(WisecondorX gender $file) =~ "female" ]]; then mv $file $female_dir
#   	fi
# done

## QUICKFIX: Currently, available reference BAMs are all male. Use prefix input parameter to separate
mv wisecondorx_reference/${reference_male_prefix}*.npz $male_dir
mv wisecondorx_reference/${reference_female_prefix}*.npz $female_dir

# Create references for Male and Female samples
WisecondorX newref ${male_dir}/*.npz reference_male.npz --cpus 4 --binsize $resolution ## --refsize $ref_refsize
WisecondorX newref ${female_dir}/*.npz reference_female.npz --cpus 4 --binsize $resolution ## --refsize $ref_refsizes
#####

##### Predict CNVs
# Create output directory
outdir=out/wisecondorx/Results/wisecondorx_${resolution}
mkdir -p $outdir

# Convert input bam to numpy zip file for wisecondorx
mv $input_bam_index_path $(dirname $input_bam_path)
WisecondorX convert $input_bam_path ${input_bam_prefix}.npz --binsize $convert_binsize #--retdist --retthres --gender --gonmapr

# Run WisecondorX
wcx_run ${input_bam_prefix}.npz
#####

# Upload output data
dx-upload-all-outputs
