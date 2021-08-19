require 'test/unit'
require_relative './csv_etl.rb'

class EtlTest < Test::Unit::TestCase
  def test_jason_bateman_fails_validation
    etl = CsvEtl.new
    assert_equal(1, etl.skipped_rows.count)
    assert_equal('Jason', etl.skipped_rows.first['first_name'])
  end

  def test_numbers_are_e164_compliant
    etl = CsvEtl.new
    assert_not_nil(etl.transformed_rows)
    assert_block do
      etl.transformed_rows.all? do |row|
        return true if (row['phone_number'].nil? || row['phone_number'].empty?)
        row['phone_number'].start_with?('+')
      end
    end
  end

  def test_dates_are_valid
    etl = CsvEtl.new
    assert_not_nil(etl.transformed_rows)
    etl.transformed_rows.each do |row|
      case row['first_name']
      when 'Brent'
        assert_equal('1988-01-01', row['dob'])
        assert_equal('2019-09-30', row['effective_date'])
        assert_equal('2000-09-30', row['expiry_date'])
      when 'Antonio'
        assert_equal('1966-02-02', row['dob'])
        assert_equal('2019-09-30', row['effective_date'])
        assert_equal('2000-09-30', row['expiry_date'])
      when 'Jason'
        assert_equal('1988-02-12', row['dob'])
        assert_equal('2019-09-30', row['effective_date'])
      end
    end
  end

  def test_all_names_are_stripped
    etl = CsvEtl.new
    assert_block do
      etl.original_csv.all? { |row| !(row['first_name'] =~ /^\s+|\s+$/) }
      etl.original_csv.all? { |row| !(row['last_name'] =~ /^\s+|\s+$/) }
    end
  end

end

