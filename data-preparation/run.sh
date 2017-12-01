#!/bin/bash

# Extract Year > 1966 and only major MeSH terms
awk 'BEGIN{FS="|"; OFS="|"}{if ($2 >= 1966 && $4 == "Y") print $1,$2,$3}' ./data/xml2txt.txt > ./data/xml2txt_majr.txt

# Filter check tags
./data-preparation/scripts/filter_checktags.py ./data-preparation/scripts/check_tags.txt ./data/xml2txt_majr.txt > ./data/tmp1

# Filter unfrequent MeSH terms
./data-preparation/scripts/filter_nodes.py ./data/tmp1 > ./data/tmp2

# Compute frequency file
awk 'BEGIN{FS="|"}{print $3,$2}' ./data/tmp2 | sort | uniq -c | awk 'BEGIN{FS=" "}{print $2,$3,$1}' > ./data/freq.txt

# Create co-occurrence file
sh ./data-preparation/scripts/cooccurrence.sh  ## results je tmp3 file

# Filter co-occurrence file
./data-preparation/scripts/filter_edges.py ./data/tmp2 ./data/tmp3 > ./data/coc_data.txt

# Remove temporary files
rm ./data/tmp*
