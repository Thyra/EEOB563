require "csv"

tree = File.read("tree.newick")
CSV.each_row(File.open("taxa_name_mapping.csv")) do |row|
  from = row[0]
  to   = row[1]
  tree = tree.gsub(row[0], row[1])
end
#File.write("tree.newick", tree)
puts tree
