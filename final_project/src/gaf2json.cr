# This script creates JSON files for each of the gaf.gz in annotation_sets that are much quicker to parse.
#  --<name>.set.json  - just the GO terms that have no modifiers, a JSON array
#  --<name>.tree.json - the GO terms in the GAF and all its ancestors

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

def set_from_gaf(gaf_path : String, go : SlimOntology)
  tree = Set.new [] of String

  Gzip::Reader.open(gaf_path) do |gzfile|
    csv = CSV.new(gzfile, separator:'\t')

    # Skip the two header lines
    csv.next
    csv.next

    while csv.next
      go_id = go.main_id_of csv.row[4]
      if ["", "0"].includes?(csv.row[3]) && !tree.includes?(go_id) # Ignore any annotations with modifier and any annotations that are already in the tree (if they are in their parents are in as well)
        if !go.is_obsolete?(go_id)
          tree << go_id
        end
      end
    end
  end

  return tree

end

def tree_from_gaf(gaf_path : String, go : SlimOntology)
  tree = Set.new [] of String

  Gzip::Reader.open(gaf_path) do |gzfile|
    csv = CSV.new(gzfile, separator:'\t')

    # Skip the two header lines
    csv.next
    csv.next

    while csv.next
      go_id = go.main_id_of csv.row[4]
      if ["", "0"].includes?(csv.row[3]) && !tree.includes?(go_id) # Ignore any annotations with modifier and any annotations that are already in the tree (if they are in their parents are in as well)
        if !go.is_obsolete?(go_id)
          tree << go_id
          tree.concat go.ancestors_of(go_id)
        end
      end
    end
  end

  return tree

end


def create_jsons(gaf_path : String, go : SlimOntology)
  STDERR.puts "Looking for set #{gaf_path}"
  if File.exists? gaf_path + ".set.json"
    STDERR.puts "  ..found!"
  else
    STDERR.puts "  ..not found, creating"
    tree = set_from_gaf(gaf_path, go)
    File.write(gaf_path + ".set.json", tree.to_json)
  end

  STDERR.puts "Looking for tree #{gaf_path}"
  if File.exists? gaf_path + ".tree.json"
    STDERR.puts "  ..found!"
  else
    STDERR.puts "  ..not found, creating"
    tree = tree_from_gaf(gaf_path, go)
    File.write(gaf_path + ".tree.json", tree.to_json)
  end
end

# Load ontology
go = Gzip::Reader.open("slimGO.json.gz") do |gzfile|
  SlimOntology.from_json(gzfile)
end

gafs = Dir.glob("annotation_sets/*.gaf.gz")

gafs.each_with_index do | g |
  STDERR.puts "Creating JSONS for GAF #{g}"
  create_jsons(g, go)
end
