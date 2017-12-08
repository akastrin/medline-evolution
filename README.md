# Software requirements

We encourage you to use Linux system. In addition, the following software requirements should be meet:
- Python 3
- R
- MATLAB (we didn't tested our software on Octave, but probably it would work out of the box)

# Run computation and analysis code

# Input data

First we need to map MEDLINE distribution to major MeSH terms. In other words, we need the file with the structure

```
10895639|1966|D003766
11526831|1966|D008954
11526833|1966|D013696
11526835|1966|D008957
11526835|1966|D009154
```
where the first field is MEDLINE PMID identifier of the citation, second field is year of the citations, and the last field refers to major MeSH term identifier. We need to save this file as `xml2txt-majr.txt` into the `data` directory.

In addition, we need `doi2name.txt` file which maps MeSH identifiers to MeSH names. Both fields are separated by vertical bar. The file should be saved into the `data` directory.

Last, we need `freq.txt` file in which first field refers to MeSH identifier, second field to year of occurrence and the last field to number of occurrence. The file should be saved into the `data` directory.

Main co-occurrence input file `coc-data.txt` is automatically build from `xml2txt-majr.txt` file using the custom BASH script and is saved into `data` directory.

# Web application

After you successfully build the data you could start the Web application to further explore the content of the MEDLINE communities. Please navigate to `flask-app` directory and run

```python
python3 app.py
```
command. After starting the Web server, open your browser and navigate to the address `http://localhost:5000` to open the Web application.
