# dragonflye_bash_pipeline
This is a bash script to run dragonflye as a pipeline.

The pipeline assumes that you have conda installed and working and you have installed dragonflye by following the instruction at: https://github.com/rpetit3/dragonflye and activated the environment before running.

The pipeline will take 4 mandatory inputs from the user.
-l Folder containing long reads (Nanopore)
-s Folder containing short reads (Illumina)
-i A text file with sample ids for the pipeline has to be run
-o output folder name

Other parameters used for the dragonflye are hardcoded in the dragonflye_pipeline.sh
Please edit the file for your requirement.
