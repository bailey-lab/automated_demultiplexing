'''
#steps that can't be automated
#cs=$run_name"_capture_plates.tsv"
#micro $cs

#sp=$run_name"_sample_plates.tsv"
#micro $sp
'''

##begin snakefile
configfile: 'automated_demultiplexing.yaml'

output_folder=config['raw_data_dir']+'/'+config['run_date']+'_'+config['platform']

#can be automated - generation of sample sheet

rule all:
	input:
		#sample_sheet=output_folder+'/'+config['run_name']+'_samples.tsv'	
#		demultiplexed_status='demultiplexing_finished.txt'
#		demux_qc='demux_qc_finished.txt'
		output_folder+'/'+config['run_date']+'_samples_readcnt.tsv'


rule generate_sample_sheet:
	input:
		sample_plate=output_folder+'/'+config['run_date']+'_sample_plates.tsv',
		capture_plate=output_folder+'/'+config['run_date']+'_capture_plates.tsv',
		miptools_sif=config['miptools_sif']
	params:
		output_folder=output_folder,
		sample_sheet_name=config['run_date']+'_samples.tsv',
		sample_plate=config['run_date']+'_sample_plates.tsv',
		capture_plate=config['run_date']+'_capture_plates.tsv',
		platform=config['platform']
	output:
		sample_sheet=output_folder+'/'+config['run_date']+'_samples.tsv'
	shell:
		'''
		singularity exec -B {params.output_folder}:/opt/analysis \
		{input.miptools_sif} python /opt/src/sample_sheet_prep.py -c \
		{params.capture_plate} -s {params.sample_plate} -p {params.platform} \
		-o {params.sample_sheet_name}
		'''

#demultiplexing
rule demultiplex_samples:
	input:
		sample_sheet=output_folder+'/'+config['run_date']+'_samples.tsv',
		miptools_sif=config['miptools_sif']
	params:
		output_folder=output_folder,
		bcl_dir=output_folder+'/'+config['run_id'],
		sample_sheet_name=config['sample_sheet_name'],
		extra=config['extra']
	output:
		demultiplexed_status='demultiplexing_finished.txt'
	shell:
		'''
		singularity run --app demux -B {params.output_folder}:/opt/analysis \
		-B {params.bcl_dir}:/opt/data {input.miptools_sif} \
		-s {params.sample_sheet_name} {params.extra}
		touch demultiplexing_finished.txt
		'''

rule get_stats:
	input:
		miptools_sif=config['miptools_sif'],
		demultiplexed_status='demultiplexing_finished.txt'
	params:
		fastq_dir=output_folder+'/fastq',
		bcl_dir=output_folder+'/'+config['run_id'],
		platform=config['platform']
	output:
		demux_qc='demux_qc_finished.txt'
	shell:
		'''
		singularity run --app demux_qc -B {params.fastq_dir}:/opt/analysis -B {params.bcl_dir}:/opt/data {input.miptools_sif} -p {params.platform}
		touch demux_qc_finished.txt
		'''

rule run_mipscripts:
	input:
		demux_qc='demux_qc_finished.txt'
	params:
		sample_sheet=output_folder+'/'+config['run_date']+'_samples.tsv'
	output:
		output_folder+'/'+config['run_date']+'_samples_readcnt.tsv'
	shell:
		'''
		pip install mipscripts
		python3 -m mipscripts seqrun_stats --samplesheet {params.sample_sheet}		
		'''
