
def count(last_digit, remains, has_dup)

	a = Array.new(10, 0)
	b = Array.new(10, 0)
	if has_dup
		a[last_digit] = 1
	else 
		b[last_digit] = 1
	end
	remains.times{
		k1 = 0
		k2 = b[0]
		bc = b.clone
		1.upto(9){|d|
			k1 += a[d]
			a[d] = k1 + bc[d]
			b[d] = k2
			k2 += bc[d]
		}
	}
	a.sum

end

def count_up_to(m)
	n = m + 1
	s = 0
	has_dup = false
	last_digit = nil
	digits = n.to_s.size - 1
	n.to_s.each_char{|c|
		d = c.to_i 
		break if last_digit && last_digit > d && d > 0
		(last_digit || 0).upto(d-1){|i| s += count(i, digits, has_dup || (i > 0 && last_digit == i))}

		has_dup = d > 0 && last_digit == d
		last_digit = d
		digits -= 1
	}
	s
end

# part 1 in log(n)

p count_up_to(892942) -count_up_to(357253 - 1)

# part 2

s = 0
357253.upto(892942){|i|
	digits = i.to_s.chars
	s += 1 if digits == digits.sort && digits.group_by{|x| x}.map{|k,v| v.size}.include?(2)
}

p s