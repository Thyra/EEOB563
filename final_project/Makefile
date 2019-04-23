distance_matrix.txt: build_distance_matrix json_files
	./build_distance_matrix > distance_matrix.txt

json_files: obo_jsons gaf2json $(wildcard annotation_sets/*.gaf.gz)
	./gaf2json

obo_jsons: resources/go.obo.gz src/obo_parser.py src/create_obo_jsons.py
	gunzip resources/go.obo.gz
	python src/create_obo_jsons.py
	pigz -11 slimGO.json
	pigz -11 go_names.json
	pigz -11 resources/go.obo

gaf2json: src/gaf2json.cr
	crystal build --release --no-debug src/gaf2json.cr

build_distance_matrix: src/build_distance_matrix.cr
	crystal build --release --no-debug src/build_distance_matrix.cr

unique_terms: src/unique_terms.cr
	crystal build --release --no-debug src/unique_terms.cr
