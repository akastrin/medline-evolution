all: set-parmissions data-preparation community-detection community-evolution

set-permissions:
	chmod +x ./data-preparation/scripts/filter_checktags.py
	chmod +x ./data-preparation/scripts/filter_nodes.py
	chmod +x ./data-preparation/scripts/filter_edges.py
	chmod +x ./data-preparation/scripts/cooccurrence.sh
	chmod +x ./data-preparation/run.sh

data-preparation:
	sh ./data-preparation/run.sh

community-detection:
	Rscript ./computation/community-detection/main.R

community-evolution:
	matlab -nosplash -nodesktop -r "try; cd ./computation/community-evolution; main; catch; end; exit";

create-db:
	Rscript ./data-preparation/scripts/prepare-db.R



clear:
	rm ./data/adj-mats/*.*
	rm ./data/clu-tabs/*.*
	rm ./data/num-comms/*.*
	rm ./data/other/*.*
	rm ./data/str-comms/*.*
	rm ./data/temp-max-like/*.*
	rm ./data/temp-users/*.*
	rm ./temp-users-comm-nums/*.*
