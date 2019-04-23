# This script finds GO terms that are unique to one set of species when compared to another.
# Usage:
#  unique_terms sp1.tree.json sp2.set.json
#   This will print out all terms in the sp1 tree (including ancestors) that are not present in the sp2 set (not including ancestors)
#   The tree.json and set.json files can be generated from the GAFs with gaf2json
# more complex cases:
#  unique_terms union:sp1.tree.json,sp2.tree.json intersection:sp3.tree.json,sp4.tree.json
#   This will print out all terms that are in either sp1 or sp2 but NOT common to SP3 and SP4

require "json"
require "gzip"

abort("Wrong number of arguments!") unless ARGV.size == 2

set1, set2 = ARGV[0..1].map do |argument|
  if argument.includes?(":") # There is a union or intersection
    operation, files = argument.split(":")
    set = Set.new [] of String
    if operation == "union"
      files.split(",").each do |filename|
        set = set | Set.new(Array(String).from_json(File.read(filename)))
      end
    elsif operation == "intersection"
      filenames = files.split(",")
      set = Set.new(Array(String).from_json(File.read(filenames.first)))
      filenames[1..filenames.size-1].each do |filename|
        set = set & Set.new(Array(String).from_json(File.read(filename)))
      end
    else
      abort("Invalid operation '#{operation}'")
    end
    set
  else
    Set.new(Array(String).from_json(File.read(argument)))
  end
end

go_names = Gzip::Reader.open("go_names.json.gz") do |gzfile|
  Hash(String,String).from_json(gzfile)
end

unique_terms = set1.not_nil! - set2.not_nil!
unique_terms.each do |t|
  if go_names[t]?
    puts("#{t} - #{go_names[t]}")
  else
    puts(t)
  end
end

