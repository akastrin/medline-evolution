#!/bin/bash

awk -F "|" '{print $1,$3,$2}' ./data/tmp2 > ./data/out1
sort -k1n,1 -k2,2 -k3n,3 ./data/out1 > ./data/out2
join -1 1 -2 1 ./data/out2 ./data/out2 > ./data/out3
awk -F " " '{print $2,$4,$5}' ./data/out3 > ./data/out4
sort -k1,1 -k2,2 -k3n,3 ./data/out4 > ./data/out5
uniq -c ./data/out5 > ./data/out6
awk '{print $2,$3,$4,$1}' ./data/out6 > ./data/tmp3
rm ./data/out*
