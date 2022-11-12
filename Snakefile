import os
import pandas as pd

def sort_data_directory(
    d,
    pe_suffixes=[
        ('_1.fastq.gz', '_2.fastq.gz'),
        ('.read1.fastq.gz', '.read2.fastq.gz'),
        ('.read1.trimmed.fastq.gz', '.read2.trimmed.fastq.gz'),
    ]
):
    l = os.listdir(d)
    
    # Account for non-gzipped files, too.
    for suffix1, suffix2 in pe_suffixes:
        if suffix1.endswith('.gz') and suffix2.endswith('.gz'):
            pe_suffixes.append((suffix1[:-3], suffix2[:-3]))
    
    # Only consider these single-read suffixes.
    se_suffixes = ['.fastq.gz', '.fastq']
    
    pe_dict = {} # sample_name -> (read1_file, read2_file)
    
    # Look for paired-end suffixes to find paired-end read pairs.
    for read1_suffix, read2_suffix in pe_suffixes:
        sample_names = []
        for f in l:
            if f.endswith(read1_suffix):
                sample_names.append(f[:-len(read1_suffix)])
            
            if f.endswith(read2_suffix) and f[:-len(read2_suffix)] not in sample_names:
                sample_names.append(f[:-len(read2_suffix)])
        
        files_to_remove = []
        for sample_name in sample_names:
            read1_file = sample_name + read1_suffix
            read2_file = sample_name + read2_suffix
            
            if read1_file not in l:
                raise OSError(f'Could not find {read1_file}')
            if read2_file not in l:
                raise OSError(f'Could not find {read2_file}, leaving {read1_file} unpaired.')
            
            pe_dict[sample_name] = (read1_file, read2_file)
            
            files_to_remove.append(read1_file)
            files_to_remove.append(read2_file)
        
        for f in files_to_remove:
            l.remove(f)
    
    se_dict = {} # sample_name -> read_file
    for suffix in se_suffixes:
        for f in l:
            if f.endswith(suffix):
                sample_name = f[:-len(suffix)]
                se_dict[sample_name] = f
    
    return se_dict, pe_dict

configfile: 'config.yaml'
data_dir = config['data_dir']

se_reads, pe_reads = sort_data_directory(data_dir)

print(f'There are {len(se_reads)} single-reads.')
print(f'There are {len(pe_reads)} paired-end reads.')
proc = input('Proceed? [y/n]: ')
if proc != 'y':
    print('Terminating.')
    sys.exit(1)

read_files = []
for sample, read in se_reads.items():
    read_files.append(read)
for sample, (read1, read2) in pe_reads.items():
    read_files.extend([read1, read2])

prefixes = [f[:-9] for f in read_files]

FASTQC = expand('result/{prefix}_fastqc.zip', prefix=prefixes)
MULTIQC = 'result/multiqc_report.html'

ALL = []
ALL.append(MULTIQC)

rule all:
    input: ALL

rule fastqc:
    input:
        os.path.join(data_dir, '{prefix}.fastq.gz')
    output:
        html='result/{prefix}_fastqc.html',
        zip='result/{prefix}_fastqc.zip',
    threads: 1
    wrapper:
        'http://dohlee-bio.info:9193/fastqc'

rule multiqc:
    input:
        expand('result/{prefix}_fastqc.html', prefix=prefixes)
    output:
        'result/multiqc_report.html'
    shell:
        'multiqc .'