'''
#steps that can't be automated
#cs=$run_name"_capture_plates.tsv"
#micro $cs

#sp=$run_name"_sample_plates.tsv"
#micro $sp

run_dir=$run_name"_"$platform
output_file=$run_name"_samples.tsv"
data_dir=/work/bailey_share/raw_data/
run_dir=$data_dir$run_dir
'''

##begin snakefile
configfile: 'automated_demultiplexing.yaml'

output_folder=config['raw_data_dir']+'/'+config['run_name']+'_'+config['platform']

#can be automated - generation of sample sheet

rule all:
	input:
		#sample_sheet=output_folder+'/'+config['run_name']+'_samples.tsv'	
		demultiplexed_status='demultiplexing_finished.txt'

rule generate_sample_sheet:
	input:
		sample_plate=output_folder+'/'+config['run_name']+'_sample_plates.tsv',
		capture_plate=output_folder+'/'+config['run_name']+'_capture_plates.tsv',
		miptools_sif=config['miptools_sif']
	params:
		output_folder=output_folder,
		sample_sheet_name=config['run_name']+'_samples.tsv',
		sample_plate=config['run_name']+'_sample_plates.tsv',
		capture_plate=config['run_name']+'_capture_plates.tsv',
		platform=config['platform']
	output:
		sample_sheet=output_folder+'/'+config['run_name']+'_samples.tsv'
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
		sample_sheet=output_folder+'/'+config['run_name']+'_samples.tsv',
		miptools_sif=config['miptools_sif']
	params:
		output_folder=output_folder,
		bcl_dir=output_folder+'/'+config['run_name'],
#		sample_sheet_name='SampleSheet.csv',
		sample_sheet_name=config['run_name']+'_samples.tsv',
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

'''
#demux_qc
#run_dir=$run_name"_"$platform
#data_dir=/work/bailey_share/raw_data/
#run_dir=$data_dir$run_dir
#bcl_dir=$run_dir"/"$run_id
#fastq_dir=$run_dir"/fastq"
#resource_dir=/work/bailey_share/bin/MIPTools_20210430/base_resources
#container=/work/bailey_share/bin/MIPTools_20210430/miptools20210430b.sif
#cd $run_dir
#singularity run --app demux_qc -B $resource_dir:/opt/resources -B $fastq_dir:/opt/analysis -B $bcl_dir:/opt/data $container -p $platform

#run mipscripts
#python3 -m mipscripts 
#sequencing_folder=$run_name"_"$platform
#cd /tank/msmt_share/raw_data/$sequencing_folder/
#python3 -m mipscripts seqrun_stats --samplesheet /tank/msmt_share/raw_data/$sequencing_folder/$run_name"_samples.tsv"
'''
