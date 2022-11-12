import argparse
import os

import pandas as pd

def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', required=True, help='Path to multiqc_data directory.')
    parser.add_argument('-o', '--output', required=True, help='Output excel file.')
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_arguments()

    target_cols = [
        'Sample',
        'FastQC_mqc-generalstats-fastqc-total_sequences',
        'FastQC_mqc-generalstats-fastqc-avg_sequence_length',
        'FastQC_mqc-generalstats-fastqc-percent_gc'
    ]
    rename = {
        'FastQC_mqc-generalstats-fastqc-total_sequences': 'Number of total reads',
        'FastQC_mqc-generalstats-fastqc-avg_sequence_length': 'Average read length (bp)',
        'FastQC_mqc-generalstats-fastqc-percent_gc': 'GC (%)',
    }

    multiqc = pd.read_csv(os.path.join(args.input, 'multiqc_general_stats.txt'), sep='\t')
    multiqc[target_cols].rename(rename, axis=1).to_excel(args.output, index=False)