require "csv"

header = ["GAF"]
counts = Hash(String,Array(Int32)).new

Dir.glob("*.count").each_with_index do |file, index|
  header << file.split(".").first
  csv = CSV.parse(File.open(file),separator=':')
  csv.each do |row|
    counts[row[0]] = [] of Int32 unless counts.has_key? row[0]
    counts[row[0]] << row[1].to_i
  end
end

CSV.build(STDOUT, separator='\t') do |csv|
  csv.row header
  counts.each do |k, v|
    csv.row [k] + v
  end
end
