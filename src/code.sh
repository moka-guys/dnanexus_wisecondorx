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
# wisecondorx 1.1.0 is compatible with 1.16.2 but later versions of wisecondorx are compatible with newer numpy
conda install -f -y -c conda-forge -c bioconda wisecondorx=1.1.0 numpy=1.16.2

# Set the binsize for the `Wisecondor convert` command. 
# All converted BAM files must use a binsize that is a multiple of the input resolution. Here we 
# use a default of 1/20th.
convert_binsize=$((resolution/20))

#### Create reference files

# Download reference bams
dx download -r ${project_for_newref}:/wisecondorx_reference/


# delete self and downsampled self from reference bams - this depends entirely on first 4 characters of filename ## hack by Wook
cd wisecondorx_reference
ls
bam_name=$input_bam_prefix
bam_start=${bam_name:0:4}
find . -maxdepth 1 -type f -name ${bam_start}\* -exec rm {} \;
cd ..

###WOUT
# Convert all bams to numpy zip files
for file in wisecondorx_reference/*.bam; do
	prefix=${file%%.bam}
	WisecondorX convert $file ${prefix}.npz --binsize $convert_binsize #--retdist $convert_retdist --retthres $convert_retthresh
done

###  Create reference
WisecondorX newref wisecondorx_reference/*.npz wisecondorx_reference/combined_ref.npz --cpus 8 --binsize $resolution
###WOUT END

##### Predict CNVs
# Create output directory
outdir=out/wisecondorx/wisecondorx_${resolution}/${input_bam_prefix}/
mkdir -p $outdir

# Convert input bam to numpy zip file for wisecondorx
mv $input_bam_index_path $(dirname $input_bam_path)
WisecondorX convert $input_bam_path ${input_bam_prefix}.npz --binsize $convert_binsize #--retdist --retthres --gender --gonmapr

# Run WisecondorX
wcx_command ${input_bam_prefix}.npz wisecondorx_reference/combined_ref.npz
#####

# Upload output data
mv wisecondorx_reference/combined_ref.npz $outdir/combined_ref.npz
mv ${input_bam_prefix}.npz $outdir/${input_bam_prefix}.npz
dx-upload-all-outputs
