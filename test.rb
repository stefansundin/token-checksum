#!/usr/bin/env ruby
require "rack"
require "active_support"
require "zlib"

CHECKSUM_SALT = "AemVTMy0L8NkbebfUMeK92OvVHUomf8IP2Dw6z2Y"

class Base62
  PRIMITIVES = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] +\
  ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"] +\
  ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
  PRIMITIVES_SIZE = 62

  def self.encode(int, min_length: 0)
    return "".rjust(min_length, PRIMITIVES[0]) if int <= 0

    result = ""
    while int > 0
      result = PRIMITIVES[int % PRIMITIVES_SIZE] + result
      int /= PRIMITIVES_SIZE
    end

    result.rjust(min_length, PRIMITIVES[0])
  end
end

module SecurityUtils
  def self.secure_compare(a, b)
    unless a.is_a?(String) && b.is_a?(String)
      raise ArgumentError, "both arguments must be String values"
    end
    Rack::Utils.secure_compare(a, b)
  end
end

def checksum(token)
  crc_value = Zlib.crc32(CHECKSUM_SALT + token)
  Base62.encode(crc_value, min_length: 6)
end

def valid_checksum?(token)
  return false unless token.present?

  provided_checksum = token[-6..-1]
  return false unless provided_checksum.present?

  # This is the token without the prefix
  checksum_string = token.split("_", 2).last
  # This is the token without the checksum
  checksum_string = checksum_string[0..-7]
  return false unless checksum_string.present?

  calculated_checksum = checksum(checksum_string)

  SecurityUtils.secure_compare(calculated_checksum, provided_checksum)
end

def test(token)
  puts "Testing #{token} => #{valid_checksum?(token)}"
end

puts "Tokens I generated on GitHub:"
test("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")
test("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")
test("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")
test("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")

puts
puts "Fake tokens that I made myself:"
test("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")
test("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")
test("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")
test("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")
