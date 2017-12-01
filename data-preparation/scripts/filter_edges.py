#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
from collections import defaultdict

threshold = 7.879

file1 = sys.argv[1] #r'database10.txt'
file2 = sys.argv[2] #r'results.txt'

# Count distinct PMIDs for each year (year2pmid)
# Count frequency of DOIs for each year (doi2year)
year2pmid = dict()
doi2year = defaultdict(int)
with open(file1, 'r') as f1:
    for line in f1:
        pmid, year, doi = line.strip().split('|')
        year2pmid.setdefault(year, [])
        year2pmid[year].append(pmid)
        doi2year[(doi, year)] += 1

# Reshape dictionary
for keys, values in year2pmid.items():
    year2pmid[keys] = len(set(values))

with open(file2) as f2:
    for line in f2:
        doi1, doi2, year, freq = line.strip().split(' ')
        # Number of papers containing particular DOI in given year
        n1 = int(doi2year[(doi1, year)])
        n2 = int(doi2year[(doi2, year)])
        # Number of all papers present in time interval
        n = int(year2pmid[year])
        expected = n1 * n2 / n
        stat = int(freq) / expected
        if stat >= threshold:
            print(doi1, doi2, year, freq)
