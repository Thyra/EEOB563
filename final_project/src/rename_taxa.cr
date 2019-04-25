require "csv"

unless ARGV.size == 2
  abort("Wrong number of arguments (2 required).
   Usage: rename_taxa [tree.newick] [name-map.csv]
   ")
end

tree = File.read(ARGV[0])
CSV.each_row(File.open(ARGV[1])) do |row|
  tree = tree.gsub(row[0], row[1])
end
puts tree
