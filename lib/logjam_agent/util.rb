module LogjamAgent
  module Util
    # copied from amqp protocol gem (slightly modified)
    BIG_ENDIAN = ([1].pack("s") == "\x00\x01")

    UINT64 = "Q"

    # we assume we're running on MRI ruby
    FIXNUM_MAX = 2 ** (1.size * 8 - 2) - 1

    if BIG_ENDIAN

      def pack_uint64_big_endian(uint64)
        [uint64].pack(UINT64)
      end

      def unpack_uint64_big_endian(string)
        string.unpack(UINT64)
      end

    else

      def pack_uint64_big_endian(uint64)
        [uint64].pack(UINT64).bytes.map(&:chr).reverse.join
      end

      def unpack_uint64_big_endian(string)
        string.bytes.map(&:chr).reverse.join.unpack(UINT64)[0]
      end

    end

    def zclock_time(t = Time.now)
      t.tv_sec*1000 + t.tv_usec/1000
    end

    def next_fixnum(i)
      (i+=1) > FIXNUM_MAX ? 0 : i
    end

    def pack_info(n)
      info = pack_uint64_big_endian(zclock_time)
      info << pack_uint64_big_endian(n)
    end

    def unpack_info(info)
      zclock = unpack_uint64_big_endian(info[0..7])
      secs = zclock / 1000
      msecs = zclock % 1000
      sent = Time.at(secs) + 1000.0/msecs
      sequence = unpack_uint64_big_endian(info[8..15])
      [sent, sequence]
    end
  end
end