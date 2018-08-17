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

function wcx_gender {
	# Function to check gender of WisecondorX .npz file
	# Args: input.npz
	local gender=$(WisecondorX gender $1)
	echo "$gender"
}

function wcx_run {
	# Run WisecondorX dependent on input sample gender
	# Args: input.npz
	input_npz=$1
	# Run with appropriate reference for gender
	if [[ $(wcx_gender $input_npz) =~ "female" ]]; then
		$(wcx_command $input_npz reference_female.npz)
	elif [[ $(wcx_gender $input_npz) =~ "male" ]]; then
		$(wcx_command $input_npz reference_male.npz)
	fi
} 

# Download input data
# Download BAM files for reference ; ref_bams - array of healthy male and female bams, identified by '_M_' or '_F_' in filename
# Download BAM file for sample ; input_bam - input BAM file. Must be aligned to same reference genome as reference sample bams
dx-download-all-inputs

# Install conda. Set to beginning of path variable for python calls
gzip -d Miniconda2-latest-Linux-x86_64.sh.gz
bash Miniconda2-latest-Linux-x86_64.sh -b -p $HOME/miniconda
export PATH="$HOME/miniconda/bin:$PATH"

# Install WisecondorX
conda install -y -c bioconda wisecondorx=0.1

# Create output directory
outdir=out/wisecondorx
mkdir -p $outdir

# Convert input bam to numpy zip file for wisecondorx
mv $input_bam_index $(dirname $input_bam_path)
WisecondorX convert $input_bam_path ${input_bam_prefix}.npz

# Run WisecondorX
wcx_run ${input_bam_prefix}.npz

# Upload output data
dx-upload-all-outputs
