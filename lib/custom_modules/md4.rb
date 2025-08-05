# rubocop:disable Performance/CollectionLiteralInLoop
# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/CyclomaticComplexity
# frozen_string_literal: true

# Source: https://rosettacode.org/wiki/MD4#Ruby

module CustomModules
  class Md4
    def self.hexdigest(buffer, abcd = nil, length = nil)
      # functions
      mask = (1 << 32) - 1
      f = proc { |x, y, z| (x & y) | (x.^(mask) & z) }
      g = proc { |x, y, z| (x & y) | (x & z) | (y & z) }
      h = proc { |x, y, z| x ^ y ^ z }
      r = proc { |v, s| (v << s).&(mask) | (v.&(mask) >> (32 - s)) }

      # initial hash
      abcd ||= [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]
      a, b, c, d = abcd

      input = buffer.clone
      length ||= input.size
      bit_len = length << 3
      input << 0x80
      input << 0 while (input.size % 64) != 56
      input += [bit_len & mask, bit_len >> 32].pack('V2').bytes

      raise 'failed to pad to correct length' if input.size % 64 != 0

      loop do
        block = input.shift(64)
        break if block.empty?

        x = block.pack('C*').unpack('V16')

        # Process this block.
        aa = a
        bb = b
        cc = c
        dd = d

        [0, 4, 8, 12].each do |i|
          a = r[a + f[b, c, d] + x[i], 3]
          i += 1
          d = r[d + f[a, b, c] + x[i], 7]
          i += 1
          c = r[c + f[d, a, b] + x[i], 11]
          i += 1
          b = r[b + f[c, d, a] + x[i], 19]
        end

        [0, 1, 2, 3].each do |i|
          a = r[a + g[b, c, d] + x[i] + 0x5a827999, 3]
          i += 4
          d = r[d + g[a, b, c] + x[i] + 0x5a827999, 5]
          i += 4
          c = r[c + g[d, a, b] + x[i] + 0x5a827999, 9]
          i += 4
          b = r[b + g[c, d, a] + x[i] + 0x5a827999, 13]
        end

        [0, 2, 1, 3].each do |i|
          a = r[a + h[b, c, d] + x[i] + 0x6ed9eba1,  3]
          i += 8
          d = r[d + h[a, b, c] + x[i] + 0x6ed9eba1, 9]
          i -= 4
          c = r[c + h[d, a, b] + x[i] + 0x6ed9eba1, 11]
          i += 8
          b = r[b + h[c, d, a] + x[i] + 0x6ed9eba1, 15]
        end

        a = (a + aa) & mask
        b = (b + bb) & mask
        c = (c + cc) & mask
        d = (d + dd) & mask
      end

      [a, b, c, d].pack('V4').unpack1('H*')
    end
  end
end
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/BlockLength
# rubocop:enable Performance/CollectionLiteralInLoop
