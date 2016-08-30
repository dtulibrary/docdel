def zero_pad_integer(integer)
  integer.to_s.rjust(8, "0")
end

def random_order_number
  "E" + zero_pad_integer(Random.new.rand(99999999))
end

puts random_order_number
