#!/bin/bash

# -e = exit on error; -x = output each line that is executed to log; -o pipefail = throw an error if there's an error in pipeline
set -e -x -o pipefail

# Download input data
dx-download-all-inputs

# Install conda. Set to beginning of path variable for python calls
gzip -d Miniconda2-latest-Linux-x86_64.sh.gz
bash Miniconda2-latest-Linux-x86_64.sh -b -p $HOME/miniconda
export PATH="$HOME/miniconda/bin:$PATH"

# Install WisecondorX
# wisecondorx 1.1.0 is compatible with 1.16.2 but later versions of wisecondorx are compatible with newer numpy
conda install -f -y -c conda-forge -c bioconda wisecondorx=1.1.0 numpy=1.16.2

# Set the binsize for the `Wisecondor convert` command. 
# All converted BAM files must use a binsize that is a multiple of the input resolution. Here we use a default of 1/20th based on the defaults.
convert_binsize=$((resolution/20))

# create dir to hold ref or ctrls
mkdir -p ./wisecondorx_reference/
echo "reference provided = $reference_provided"
echo "controls provided = $controls_provided"
# if ref = true, download
if [ "$reference_provided" == "true" ]; then
	mv ~/in/reference_file/$reference_file ~/wisecondorx_reference/ref.npz
fi
# if ctrls = true and ref = false, download
if [ "$reference_provided" == "false" ] && [ "$controls_provided" == "true" ]; then
	find ~/in/controls/ -type f -print0 | xargs -0 mv -t ~/wisecondorx_reference
	# delete self and downsampled self from reference bams - this depends entirely on first 4 characters of filename
	cd wisecondorx_reference
	bam_name=$input_bam_prefix
	bam_start=${bam_name:0:4}
	find . -maxdepth 1 -type f -name ${bam_start}\* -exec rm {} \;
	ls
	cd ..
	# Convert all bams to numpy zip files
	for file in wisecondorx_reference/*.bam; do
		prefix=${file%%.bam}
		WisecondorX convert $file ${prefix}.npz --binsize $convert_binsize
	done
	###  Create reference
	WisecondorX newref wisecondorx_reference/*.npz wisecondorx_reference/ref.npz --cpus 8 --binsize $resolution
fi

# Create output directory
outdir=out/wisecondorx/wisecondorx_${resolution}/${input_bam_prefix}
mkdir -p $outdir

# Convert input bam to numpy zip file for wisecondorx
mv $input_bam_index_path $(dirname $input_bam_path)
WisecondorX convert $input_bam_path ${input_bam_prefix}.npz --binsize $convert_binsize

# Run WisecondorX predict function
WisecondorX predict ${input_bam_prefix}.npz wisecondorx_reference/ref.npz ${outdir}/${1%%.npz} --bed --plot

# Upload output data
mv wisecondorx_reference/ref.npz $outdir/ref.npz
mv ${input_bam_prefix}.npz $outdir/${input_bam_prefix}.npz
dx-upload-all-outputs
