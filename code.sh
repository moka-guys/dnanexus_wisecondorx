
#!/bin/bash

# -e = exit on error; -x = output each line that is executed to log; -o pipefail = throw an error if there's an error in pipeline
set -e -x -o pipefail

function wcx_command{
	# Call Wisecondor X to predict CNVs
	# Args: (input.npz, reference.npz)
	WisecondorX predict $1 $2 ${outdir}/${1%%npz} \
		--minrefbins $min_ref_bins
		--maskrepeats $mask_repeats
		--alpha $alpha
		--beta $beta
		--blacklist $blacklist
		--bed
		--plot
}

function wcx_gender{
	# Function to check gender of WisecondorX .npz file
	# Args: input.npz
	local gender=$(WisecondorX gender $1)
	echo "$gender"
}

function wcx_wrapper{
	# Run WisecondorX dependent on input sample gender
	# Args: input.npz
	input_npz=$1
	# If female, run command
	if [[ wcx_gender($input_npz) =~ "female" ]]; then
		wcx_command($input_npz, "reference_female.npz")
	elif [[ wcx_gender($input_npz) =~ "male" ]]; then
		wcx_command($input_npz, "reference_male.npz")
	fi
}

# Download input data
# Download BAM files for reference ; refs - array of healthy male and female bams, identified by '_M_' or '_F_' in filename
# Download BAM file for sample ; test_bams - input BAM file. Must be aligned to same reference genome as reference sample bams
dx download-all-inputs

# Install conda. Set to beginning of path variable for python calls
bash Miniconda2-latest-Linux-x86_64.sh -b -p $HOME/miniconda
source miniconda/bin/activate

# Install WisecondorX
conda install -f -y -c conda-forge -c bioconda wisecondorx

# Create output directory
outdir=out/wisecondorx
mkdir -p $outdir

# Convert all bams to numpy zip files
for file in $(find . -iname *.bam); do
	prefix=${file%%.bam}
	WisecondorX $file ${prefix}.npz --binsize $convert_binsize --retdist $convert_retdist --retthres $conver_retthresh
done

# Create reference directories
male_dir = "$HOME/male"
female_dir = "$HOME/female"
mkdir -p $male_ref $female_ref
# Separate the male and female reference sample npz files into respective directories
for file in ${refs_bams_path}/*.npz; do
	if [[ wcx_gender($file) =~ "male" ]]; then mv $file $male_dir 
	elif [[ wcx_gender($file) =~ "female" ]]; then mv $file $female_dir
    fi
done

# Create references for Male and Female samples
WisecondorX newref male/*.npz reference_male.npz --gender 'M' --binsize $ref_binsize --refsize $ref_refsize
WisecondorX newref female/*.npz reference_female.npz --gender 'F' --binsize $ref_binsize --refsize $ref_refsizess

# Run WisecondorX
run_wcx_gender_wrapper(${input_bam_path})

# Upload output data
dx-upload-all-outputs