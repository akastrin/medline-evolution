# Filter rows with major MeSH heading and year greater than 1966
awk '{FS="|"}{if ($4 == "Y" && $2 >= 1966) print $0}' xml2txt.txt > xml2txt_majr.txt

# Prepare co-occurrence file
awk -F "|" '{print $1,$3,$2}' ../data/xml2txt_majr.txt > out1
sort -k1n,1 -k2,2 -k3n,3 out1 > out2
join -1 1 -2 1 out2 out2 > out3
awk -F " " '{print $2,$4,$5}' out3 > out4
sort -k1,1 -k2,2 -k3n,3 out4 > out5
uniq -c out5 > out6
awk '{OFS="|"}{print $2,$3,$4,$1}' out6 > ../data/mesh_coc.txt
rm out*
