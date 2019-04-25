# This script converts the binary table to PHYLIP format for parsimony analysis.
require "csv"

n_rows = 0
n_columns = 0
output = String.build do |str|
  csv = CSV.new(ARGF, headers: true)
  while csv.next # THis skips the first row (headers)
    str << csv[0][0..9].ljust(12) # names can only be 10 chars long and then need to be followed by 2 spaces for the neighbor program to work
    str << csv.row.to_a[1..csv.row.size-1].join("")
    str << "\n"
    n_columns = csv.row.size - 1 if n_columns == 0
    n_rows += 1
  end
end

puts("     #{n_rows}   #{n_columns}") # The space between the two may depend on number of digits in n_rows
puts output
