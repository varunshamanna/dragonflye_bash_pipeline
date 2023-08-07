#!/bin/bash

display_help() {
  echo -e "Usage bash dragonflye_pipeline.sh \n \
  -l <Nanopore_reads_folder> \n \
  -s <illumina_reads_folder> \n \
  -ids <text_file_of_sample_ids> \n \
  -o <output_folder>"
}

#default params
cpus='32'
ram='120'
gsize='5.5M'
Racon_polish_steps='4'
Medaka_polish_steps='1'
Medaka_model=r941_min_sup_g507
Polypolish_steps='1'
Pilon_steps='0'

#print the default params


# Function to display error messages
function error_exit {
    echo "Error: $1"
    exit 1
}

# Store the user inputs in variables
while getopts "hs:l:i:o:" opt; do
  case $opt in
    h)
      display_help
      exit 0
      ;;
    s)
      illumina_reads_dir="$OPTARG"
      ;;
    l)
      nanopore_reads_dir="$OPTARG"
      ;;  
    i)
      sample_ids="$OPTARG"
      ;;
    o)
      output_folder="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      display_help
      exit 1
      ;;
  esac
done


#Print the default parameters used!!
echo -e "\n Using default parameters: \n \
      Genome size = \033[1m\033[32m"$gsize"\033[0m \n \
      CPUs = \033[1m\033[32m"$cpus"\033[0m \n \
      RAM = \033[1m\033[32m"$ram"\033[0m \n \
      Number of polishing rounds to conduct with Racon = \033[1m\033[32m"$Racon_polish_steps"\033[0m \n \
      Number of polishing rounds to conduct with Medaka = \033[1m\033[32m"$Medaka_polish_steps"\033[0m \n \
      Medaka Model = \033[1m\033[32m"$Medaka_model"\033[0m \n \
      Number of polishing rounds to conduct with Polypolish = \033[1m\033[32m"$Polypolish_steps"\033[0m \n \
      Number of polishing rounds to conduct with Pilon = \033[1m\033[32m"$Pilon_steps"\033[0m \n
     "

echo -e "If you want to change any of the default params edit the dragonflye_pipeline.sh \n"
sleep 5

# Check if the provided directories exist
if [ ! -d "$illumina_reads_dir" ]; then
    error_exit "Illumina reads directory not found: $illumina_reads_dir"
fi

if [ ! -d "$nanopore_reads_dir" ]; then
    error_exit "Nanopore reads directory not found: $nanopore_reads_dir"
fi


# Create the output dsirectory for Dragonflye
output_dir="$output_folder"
mkdir -p "$output_dir" || error_exit "Failed to create the output directory: $output_dir"

# Run Dragonflye assembly for each ID in sample id file
for id in `cat "$sample_ids"`; do
    # Assume the nanopore and Illumina fastq files follow a specific naming convention, adjust as per your files
    nanopore_fastq="$nanopore_reads_dir/"$id".fastq.gz"
    forward_fastq="$illumina_reads_dir/"$id"_1.fastq.gz"
    reverse_fastq="$illumina_reads_dir/"$id"_2.fastq.gz"
    echo -e "Running Dragonflye on Sample \033[1m\033[32m"$id"\033[0m \n"
    echo -e "Using nanopore read \033[1m\033[32m"$nanopore_fastq"\033[0m"
    echo -e "Using illumina reads \033[1m\033[32m"$forward_fastq"\033[0m & \033[1m\033[32m"$reverse_fastq"\033[0m \n"
    sleep 5
    mkdir "$output_dir"/"$id"
    echo -e "Saving output to \033[1m\033[32m"$output_dir"/"$id"\033[0m \n"
    sleep 3
  #run dragonflye  
	dragonflye \
    		--gsize "$gsize" \
    		--R1 "$forward_fastq" \
		    --R2 "$reverse_fastq" \
    		--reads "$nanopore_fastq" \
    		--cpus "$cpus" \
		    --ram "$ram" \
		    --prefix "$id" \
		    --racon 4 \
		    --medaka 1 \
		    --model "$Medaka_model" \
        --polypolish "$Polypolish_steps" \
        --pilon "$Pilon_steps" \
    		--outdir "$output_dir"/"$id" \
		    --force \
    		|| error_exit "Dragonflye assembly failed for sample id "$id" : Please look into dragonflye.log in "$output_dir"/"$id""
    echo -e "\n \n The final assembly file is "$output_dir"/"$id"/"$id".fa"
done

echo "\n \n Pipeline completed successfully!"
