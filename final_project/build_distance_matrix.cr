# This script goes through the annotation sets and uses the slimGO created by the python script
# and then it calculates pairwise distances for all combinations of GAF files.
require "json"
require "csv"
require "gzip"

class SlimOntology
  JSON.mapping(
    parents: Hash(String, Array(String)),
    main_id: Hash(String, String),
    obsolete: Array(String)
  )

  def ancestors_of(go_id)
    ancestors = Set.new [] of String
    if !@parents.keys.includes? go_id
      puts "WARNING: not in Ontology: #{go_id}"
      return ancestors
    end
    @parents[go_id].each do |p|
      ancestors.add(p)
      ancestors.concat(ancestors_of(p))
    end
    return ancestors
  end

  def is_obsolete?(go_id)
    return @obsolete.includes?(go_id)
  end

  def main_id_of(go_id)
    return @main_id.keys.includes?(go_id) ? @main_id[go_id] : go_id
  end

end


def gaf_distance(s1 : Set(String), s2 : Set(String))
  # Returns the distance between the two annotation sets
  # Currently primitive Jaccard distance
  return 1.0 - (s1 & s2).size.to_f / (s1 | s2).size # length of intersect/length of union
end
# puts gaf_distance(Set.new(['a','b','e']), Set.new(['b','c','d','e'])) # -- should be 0.6

def tree_from_gaf(gaf_path : String, go : SlimOntology)
  tree = Set.new [] of String

  Gzip::Reader.open(gaf_path) do |gzfile|
    csv = CSV.new(gzfile, separator:'\t')

    # Skip the two header lines
    csv.next
    csv.next

    while csv.next
      if ["", "0"].includes?(csv.row[3]) && !tree.includes? csv.row[4] # Ignore any annotations with modifier and any annotations that are already in the tree (if they are in their parents are in as well)
        go_id = go.main_id_of csv.row[4]
        if !go.is_obsolete?(go_id)
          tree << go_id
          tree.concat go.ancestors_of(go_id)
        end
      end
    end
  end

  return tree

end


def load_or_create_tree(gaf_path : String, go : SlimOntology)
  puts "Looking for tree #{gaf_path}"
  if File.exists? gaf_path + ".tree.json"
    puts "  ..found!"
    return Set.new(Array(String).from_json(File.read(gaf_path + ".tree.json")))
  else
    puts "  ..not found, creating"
    tree = tree_from_gaf(gaf_path, go)
    File.write(gaf_path + ".tree.json", tree.to_json)
    return tree
  end
end



# Load ontology
go = Gzip::Reader.open("slimGO.json.gz") do |gzfile|
  SlimOntology.from_json(gzfile)
end

distances = Hash(String, Hash(String, Float64)).new

gafs = Dir.glob("annotation_sets/*.gaf.gz")

gafs[0..-2].each_with_index do | g1, i1 |
  # Load first genome
  puts "Loading GAF #{g1}"
  tree1 = load_or_create_tree(g1, go)
  n1 = File.basename(g1).split(".")[0..-3].join(".")
  gafs[i1+1..-1].each do | g2 |
    # Load second genome and compare
    puts "Loading GAF #{g2}"
    tree2 = load_or_create_tree(g2, go)
    n2 = File.basename(g2).split(".")[0..-3].join(".")
    distances[n1] = Hash(String, Float64).new unless distances.keys.includes? n1
    distances[n1][n2] = gaf_distance(tree1, tree2) 
  end
end

# Print distance matrix
puts("   #{gafs.size}")
gafs.each do | g1 |
  n1 = File.basename(g1).split(".")[0..-3].join(".")
  print(n1[0..9].ljust(12)) # names can only be 10 chars long and then need to be followed by 2 spaces for the neighbor program to work
  gafs.each do | g2 |
    n2 = File.basename(g2).split(".")[0..-3].join(".")
    if n1 == n2
      print("0.000000 ")
    elsif distances.keys.includes?(n1) && distances[n1].keys.includes? n2
      print("#{distances[n1][n2].round(6).to_s.ljust(8,'0')} ")
    else
      print("#{distances[n2][n1].round(6).to_s.ljust(8,'0')} ")
    end
  end
  print "\n"
end
