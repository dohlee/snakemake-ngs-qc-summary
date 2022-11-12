# snakemake-ngs-qc-summary

Just specify a directory containing FASTQ files to the pipelie, and a QC summary excel file for those runs will be created.

## Quickstart

1. `fastqc` and `multiqc` must be installed. Also a `Python` environment with `pandas` is needed.

2. Specify the FASTQ directory as `data_dir` in `config.yaml`. Currently, only a single & unnested directory is allowed.
```yaml
data_dir : [FASTQ_DIRECTORY]
```

3. Run below. Adjust `NUM_CORES` according to your computing environment.

```shell
$ snakemake -j[NUM_CORES]
```

## Summarized attributes

- Number of total reads
- Average read length (bp)
- GC (%)

## Todo

- [ ] Allow multiple FASTQ directories to be specified.
- [ ] Recursively search for FASTQ files inside the specified directories.
- [ ] Any further attributes?