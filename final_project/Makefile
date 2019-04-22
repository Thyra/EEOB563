distance_matrix.txt: build_distance_matrix json_files
	./build_distance_matrix > distance_matrix.txt

json_files: slimGO.json.gz gaf2json $(wildcard annotation_sets/*.gaf.gz)
	./gaf2json

slimGO.json.gz: go.obo.gz obo_parser.py create_slim_ontology.py
	python create_slim_ontology.py
	pigz -11 slimGO.json

gaf2json: gaf2json.cr
	crystal build --release gaf2json.cr

build_distance_matrix: build_distance_matrix.cr
	crystal build --release build_distance_matrix.cr
