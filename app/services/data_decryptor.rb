require 'openssl'
require 'base64'
require 'json'
require 'net/http'
require 'uri'

class DataDecryptor
  def initialize(url)
    @url = url
  end

  def fetch_and_decrypt
    json_data = fetch_data
    return unless json_data

    last_modified = json_data['lastModified']
    response = json_data['response']

    decrypt(last_modified, response)
  end

  private

  def fetch_data
    uri = URI.parse(@url)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      puts "Failed to fetch data from URL: #{response.code} #{response.message}"
      nil
    end
  rescue StandardError => e
    puts "Error fetching data: #{e.message}"
    nil
  end

  def decrypt(last_modified, response)
    key = generate_key(last_modified)
    iv = key.upcase

    decipher = OpenSSL::Cipher.new('AES-128-CBC')
    decipher.decrypt
    decipher.key = key
    decipher.iv = iv

    decrypted_data = decipher.update(Base64.decode64(response)) + decipher.final
    JSON.parse(decrypted_data)
  rescue OpenSSL::Cipher::CipherError => e
    puts "Decryption failed: #{e.message}"
    nil
  rescue JSON::ParserError => e
    puts "Failed to parse decrypted data: #{e.message}"
    nil
  end

  def generate_key(last_modified)
    date = Time.at(last_modified / 1000.0)
    timezone_offset = date.utc_offset / 60
    adjusted_time = date + timezone_offset * 60
    day = adjusted_time.day

    reversed_day = day.to_s.rjust(2, '0').reverse.to_i
    year = adjusted_time.year
    reversed_year = year.to_s.reverse.to_i

    time_hex = last_modified.to_s(16)
    combined_factor = (year + reversed_year) * (day + reversed_day)
    key = time_hex.to_i(16).to_s(36) + combined_factor.to_s(24)

    # Ensure key length is exactly 14 characters, then format it
    key = key.ljust(14, '0')[0, 14]
    "##{key}$".ljust(16, '0')[0, 16]
  end
end