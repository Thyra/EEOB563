# This script builds a binary table of whether each GO term is present in a specific annotation.
# Uses JSON files as its input

require "json"
require "csv"

annotations = Hash(String, Array(String)).new
ARGV.each do |f|
  annotations[f] = Array(String).from_json(File.open(f))
end

columns = annotations.values.flatten.uniq

CSV.build(STDOUT) do |csv|
  csv.row ["Taxon"] + columns
  ARGV.each do |f|
    name = File.basename(f).split(".")[0..-5].join(".")
    csv.row [name] + columns.map {|t| annotations[f].includes?(t) ? 1 : 0 }
  end
end
