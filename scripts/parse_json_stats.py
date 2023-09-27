import json
stats_json=snakemake.params.stats_json
output_file=open(snakemake.output.parsed_json_stats, 'w')

stats_dict=json.load(open(stats_json))
read_length=stats_dict['ReadInfosForLanes'][0]['ReadInfos'][0]['NumCycles']
overall_yield=stats_dict['ConversionResults'][0]['Yield']
overall_reads=overall_yield/(read_length*2)
undetermined_reads=stats_dict['ConversionResults'][0]['Undetermined']['NumberReads']
undetermined_yield=stats_dict['ConversionResults'][0]['Undetermined']['Yield']
demux_results=stats_dict['ConversionResults'][0]['DemuxResults']
mapped_reads, mapped_yield=0,0
sample_list=[]
for sample_dict in demux_results:
	sample_list.append([round(sample_dict['NumberReads']/overall_reads, 4), sample_dict['SampleName'], sample_dict['NumberReads'], sample_dict['Yield']])
	mapped_reads+=sample_dict['NumberReads']
	mapped_yield+=sample_dict['Yield']

output_file.write(f'undetermined read_count\t{undetermined_reads}\n')
output_file.write(f'mapped read_count\t{mapped_reads}\n')
output_file.write(f'overall read_count\t{overall_reads}\n\n')
output_file.write(f'undetermined yield\t{undetermined_yield}\n')
output_file.write(f'mapped yield\t{mapped_yield}\n')
output_file.write(f'overall yield\t{overall_yield}\n\n')
output_file.write(f'undetermined_proportion\t{round(undetermined_reads/overall_reads, 4)}\n')
output_file.write(f'mapped_proportion\t{round(mapped_reads/overall_reads, 4)}\n\n')
output_file.write(f'sample_name\tnumber_of_reads\tyield\tfraction_of_all_reads\n')
for line in sorted(sample_list, reverse=True):
	rearranged_line=line[1:4]+[line[0]]
	string_line=map(str, rearranged_line)
	reformatted_line='\t'.join(list(string_line))
	output_file.write(reformatted_line+'\n')
