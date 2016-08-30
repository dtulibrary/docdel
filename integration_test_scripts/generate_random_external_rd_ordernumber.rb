def zero_pad_integer(integer)
  integer.to_s.rjust(6, "0")
end

def random_order_number
  zero_pad_integer(Random.new.rand(999999))
end

puts random_order_number
