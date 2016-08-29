### ExomeDepth_csv_gene_filter.py
### Author: Rebecca Haines (rebecca.haines@nuh.nhs.uk)
### Date: 2016/08/27
### Version: v1
###
### use: python ExomeDepth_csv_gene_filter.py /path/to/csvfiles genename

import csv
import sys
import os
import glob

# file path to directory containing the ExomeDepth output csv files
path = sys.argv[1]

def csv_filter_gene(input_csv, gene_name):
    '''
    To filter ExomeDepth output .csv files to only include variants in genes of 
    interest. 
    '''
    # generate output file name
    outfile = input_csv + gene_name + "filtered.csv"

    with open(input_csv,'r') as inf, open (outfile,'w') as outf:
        writer = csv.writer(outf, delimiter=',')            
        for row in csv.reader(inf, delimiter=','):
            # check for empty file (no calls)
            if len(row) <=1:
                continue
            # write the header row to the output
            if row[0] == 'start.p':
                writer.writerow(row)
            # write the variant to the output if it has been annotated with the
            # gene name.
            if gene_name in row[12]:
                writer.writerow(row)

# loop over all .csv files
for infile in glob.glob(os.path.join(path, '*Annotation.csv')):
    print "Generating annotations for: " + infile
    csv_filter_gene(infile,sys.argv[2])