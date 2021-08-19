require 'csv'

class CsvEtl
  attr_accessor :original_csv
  attr_accessor :skipped_rows
  attr_accessor :valid_rows
  attr_accessor :transformed_rows
  
  def initialize
    @original_csv = CSV.read(
      './input.csv',
      headers: true,
      converters: ->(field) { field&.strip },
      header_converters: ->(header) { header&.gsub("\xEF\xBB\xBF", "") }
    ).map(&:to_h)
    
    @skipped_rows = []
    @valid_rows = []
    @transformed_rows = []

    @original_csv.each_with_index do |row, index|
      validate_row(row, index)
    end

    #puts "skipped rows: #{skipped_rows.count}"
    #@skipped_rows.each { |row| puts row.inspect }

    #puts "Transforming rows..."
    @valid_rows.each do |row|
      row['phone_number'] = process_phone_number(row['phone_number'])
      row['dob'] = process_date(row['dob'])
      row['effective_date'] = process_date(row['effective_date'])
      row['expiry_date'] = process_date(row['expiry_date'])
      transformed_rows << row
      next
    end
  end

  def process_date(date_string)
    return if (date_string.nil? || date_string.empty?)
    date_string.gsub!('-', '/') # normalize date string by replacing dashes with a slash
    begin
      parsed_date = Date.parse(date_string, true)
    rescue => e
      parsed_date = Date.strptime(date_string, '%m/%d/%Y')
      if parsed_date.cwyear <= 100
        parsed_date = Date.strptime(date_string, '%m/%d/%y')
      end
    end
    parsed_date.strftime('%Y-%m-%d')
  end

  def process_phone_number(phone_number)
    return if (phone_number.nil? || phone_number.empty?)
    characters_to_remove = {
      '-' => '',
      '(' => '',
      ')' => '',
      ' ' => '',
    }
    phone_number = phone_number.gsub(/\D/, characters_to_remove)
    if phone_number.chars.count == 10
      return phone_number.prepend('+1')
    else
      return phone_number.prepend('+')
    end
  end

  def validate_row(row, index)
    case
    when (row['first_name'].nil? || row['first_name'].empty?)
      row['reason'] = 'first name missing'
      @skipped_rows << row
    when (row['last_name'].nil? || row['last_name'].empty?)
      row['reason'] = 'last name missing'
      @skipped_rows << row
    when (row['dob'].nil? || row['dob'].empty?)
      row['reason'] = 'dob missing'
      @skipped_rows << row
    when (row['member_id'].nil? || row['member_id'].empty?)
      row['reason'] = 'member id missing'
      @skipped_rows << row
    when (row['effective_date'].nil? || row['effective_date'].empty?)
      row['reason'] = 'effective date missing'
      @skipped_rows << row
    else
      @valid_rows << row
    end
  end
end
