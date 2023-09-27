# automated_demultiplexing
This program creates a sample sheet, demultiplexes bcl files into fastq files,
and generates run statistics. The program expects a date_platform folder
containing:
  - a correctly formatted sample plate named (your_date)_capture_plates.tsv
  - a correctly formatted capture plate named (your_date)_sample_plates.tsv
  - a folder of bcl files named with the run ID

## Installation:
Follow installation instructions from here:

https://github.com/bailey-lab/wrangler_by_sample#installation

except swap out the web address of wrangler_by_sample.git for
automate_demultiplexing.git, and swap out wrangler_by_sample.yaml for
automate_demultiplexing.yaml

## Usage:
snakemake -s automate_demultiplexing.smk --cores 4
