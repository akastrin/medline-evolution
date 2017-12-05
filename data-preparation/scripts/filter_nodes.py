#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
from collections import defaultdict

file1 = sys.argv[1]
threshold = 3

doi2year = defaultdict(int)
with open(file1, 'r') as f1:
    for line in f1:
        pmid, year, doi = line.strip().split('|')
        doi2year[(doi, year)] += 1

with open(file1) as f2:
    for line in f2:
        pmid, year, doi = line.strip().split('|')
        if int(doi2year[(doi, year)]) >= threshold:
        	print(pmid, year, doi, sep="|")
