# This script builds an HTML document displaying the unique GO terms for all pairwise comparisons
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

# Load ontology
go = Gzip::Reader.open("slimGO.json.gz") do |gzfile|
  SlimOntology.from_json(gzfile)
end

taxa_names = Hash(String, String).new
CSV.each_row(File.open("taxa_name_mapping.csv")) do |row|
  taxa_names[row[0]] = row[1]
end

def nice_name(name, taxa_names)
  n1 = File.basename(name).split(".")[0..-3].join(".")[0..9]
  return taxa_names[n1]? || n1
end

# doesnt include ancestors
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

gafs = Dir.glob("annotation_sets/*.gaf.gz")

File.open("unique_go_terms_including_ancestors.html", "w") do |html|
  html.puts("<table rules=\"all\">")
  # Print table header
  html.puts("  <tr>")
  html.puts("    <th>unique GO terms/when compared to</th>")
  gafs.each {|g| html.puts "    <th>#{nice_name(g, taxa_names)}</th>"}
  html.puts("  </tr>")

  # Print each row
  gafs.each do |g1|
    html.puts("  <tr>")
    html.puts("    <th>#{nice_name(g1, taxa_names)}</th>")
    s1 = Set.new(Array(String).from_json(File.read(g1 + ".tree.json")))
    gafs.each do |g2|
      if g1 == g2
        html.puts("    <td>-</td>")
      else
        s2 = Set.new(Array(String).from_json(File.read(g2 + ".tree.json")))
        unique_terms = s1 - s2
        html.puts("    <td>#{unique_terms.join("<br />")}</td>")
      end
    end
    html.puts("  </tr>")
  end

  html.puts("</table>")
end

File.open("unique_go_terms.html", "w") do |html|
  html.puts("<table rules=\"all\">")
  # Print table header
  html.puts("  <tr>")
  html.puts("    <th>unique GO terms/when compared to</th>")
  gafs.each {|g| html.puts "    <th>#{nice_name(g, taxa_names)}</th>"}
  html.puts("  </tr>")

  # Print each row
  gafs.each do |g1|
    html.puts("  <tr>")
    html.puts("    <th>#{nice_name(g1, taxa_names)}</th>")
    puts "Row #{g1}..."
    s1 = set_from_gaf(g1, go)
    gafs.each do |g2|
      if g1 == g2
        html.puts("    <td>-</td>")
      else
        s2 = set_from_gaf(g2, go)
        unique_terms = s1 - s2
        html.puts("    <td>#{unique_terms.join("<br />")}</td>")
      end
    end
    html.puts("  </tr>")
  end

  html.puts("</table>")
end

