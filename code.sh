
#!/bin/bash

# -e = exit on error; -x = output each line that is executed to log; -o pipefail = throw an error if there's an error in pipeline
set -e -x -o pipefail

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
mkdir -p $outdir

# Create reference sample bam directory names
male_dir = "$HOME/male"
female_dir = "$HOME/female"
mkdir -p $male_ref $female_ref
# Separate the male and female BAMs into respective directories
for file in ${refs_bams_path[@]}; do
	if [[ $file =~ .*_M_.* ]]; then mv $file $male_dir 
	elif [[ $file =~ .*_F_.* ]]; then mv $file $female_dir
    fi
done

# Convert all bams to numpy zip files
for file in $(find . -iname *.bam); do
	prefix=${file%%.bam}
	WisecondorX $file ${prefix}.npz --binsize $convert_binsize --retdist $convert_retdist --retthres $conver_retthresh
done

# Create references for Male and Female samples
WisecondorX newref male/*.npz reference_male.npz --gender 'M' --binsize $ref_binsize --refsize $ref_refsize
WisecondorX newref female/*.npz reference_female.npz --gender 'F' --binsize $ref_binsize --refsize $ref_refsizess

# Function to call Wisecondor X to predict CNVs
function run_wcx{
	# Args: (input_npz, reference.npz)
	WisecondorX predict $1 $2 ${outdir}/${1%%npz} \
		--minrefbins $min_ref_bins
		--maskrepeats $mask_repeats
		--alpha $alpha
		--beta $beta
		--blacklist $blacklist
		--bed
		--plot
}

# Function to run WisecondorX dependent on input sample gender
function wcx_gender_wrapper{
	# Args: (input_npz)
	input_npz=$1
	input_npz_gender=$(WisecondorX gender $input_npz | tr a-z A-Z)
	# If female, run command
	if [[ ${input_npz_gender:0:1} == "F" ]]; then
		run_wcx($input_npz, reference_female.npz)
	elif [[ ${input_npz_gender:0:1} == "M" ]]; then
		run_wcx{$input_npz, reference_male.npz}
	fi
}

# Run WisecondorX

# Upload output data
