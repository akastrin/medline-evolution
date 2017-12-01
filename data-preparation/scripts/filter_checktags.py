#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys

file1 = sys.argv[1]
file2 = sys.argv[2]
checktags = []

with open(file1) as my_file:
    for line in my_file:
        name, doi = line.strip().split('|')
        checktags.append(doi)

with open(file2) as my_file:
    for line in my_file:
        pmid, year, doi = line.strip().split("|")
        if doi not in checktags:
            print(pmid, year, doi, sep='|')
