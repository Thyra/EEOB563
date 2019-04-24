while read term; do
  echo $term
  zgrep -c "$term" *.gaf.gz > go_counts/$term.count
done < go_counts/terms
