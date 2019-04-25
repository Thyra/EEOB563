crystal_binaries: bin/gaf2json bin/build_distance_matrix bin/unique_terms bin/rename_taxa bin/binary_table bin/binary2phylip

bin/%: src/%.cr
	crystal build --release --no-debug $< -o $@
