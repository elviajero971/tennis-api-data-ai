# app/services/decrypts/decrypt_match_datas.rb
require "net/http"
require "json"
require "openssl"
require "base64"

module Decrypts
  class DecryptMatchDatas
    def initialize(url:)
      @url = url
    end

    # Fetches the data from the URL and returns the decoded JSON.
    def decoded_data
      data = fetch_data
      decode(data)
    end

    private

    # Retrieves the JSON from the given URL.
    def fetch_data
      uri = URI(@url)
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    end

    # Decrypts the data using AES-128-CBC with a key/IV derived from lastModified.
    def decode(data)
      last_modified = data["lastModified"]
      cipher_text   = data["response"]

      # Generate the decryption key from lastModified (mimicking the JS logic)
      key_string = format_date(last_modified)
      key = key_string.encode("UTF-8")
      iv  = key_string.upcase.encode("UTF-8")

      cipher = OpenSSL::Cipher.new("AES-128-CBC")
      cipher.decrypt
      cipher.key = key
      cipher.iv  = iv
      cipher.padding = 1

      decoded_cipher = Base64.decode64(cipher_text)
      decrypted = cipher.update(decoded_cipher) + cipher.final

      JSON.parse(decrypted)
    rescue => e
      "Decryption failed: #{e.message}"
    end

    # Mimics the JavaScript date formatting to produce the decryption key.
    def format_date(last_modified)
      # Convert lastModified (milliseconds) to a Ruby Time object.
      t = Time.at(last_modified / 1000.0)

      # Adjust the time by the current timezone offset (in minutes).
      offset = -Time.now.utc_offset / 60
      t_adjusted = t + offset * 60

      # Get the day of the month (with a leading zero if needed)
      n = t_adjusted.day
      n_str = n < 10 ? "0#{n}" : n.to_s
      r = n_str.reverse.to_i

      # Get the year and its reversed form.
      i = t.year
      a = i.to_s.reverse.to_i

      # First part: interpret the timestamp as hex, convert to base36.
      part1 = last_modified.to_s.to_i(16).to_s(36)
      # Second part: multiply (year + reversed year) by (day + reversed day) and convert to base24.
      part2 = ((i + a) * (n + r)).to_s(24)

      o = part1 + part2
      # Ensure the string is exactly 14 characters (pad or trim).
      o = if o.length < 14
            o.ljust(14, "0")
          elsif o.length > 14
            o[0...14]
          else
            o
          end

      "#" + o + "$"
    end
  end
end
