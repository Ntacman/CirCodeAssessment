require_relative 'csv_etl.rb'
require 'csv'
etl = CsvEtl.new

CSV.open("output.csv", "w+") do |csv|
  csv << etl.transformed_rows.first.keys
  etl.transformed_rows.each do |row|
    csv << row.values
  end
end

File.open("report.txt", 'w') do |f|
  etl.skipped_rows.each do |row|
    f.write("#{row['first_name']} #{row['last_name']} was skipped due to the following reason: #{row['reason']}")
  end    
end
