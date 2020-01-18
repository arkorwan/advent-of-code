# We don't need to track every card in the deck, just need to track the one card we're interested in.
# All operations can be defined as some combination of add and multiply modulo number of cards
# 'CUT(n)' is addition by n.
# 'DEAL WITH INCREMENT(n)' is multiplication by n.
# 'REVERSE' is mutiplication by -1, then add -1.
# All these are easy enough to implement for part 1. Just track the position by doing the operation according to the input.

# For part 2, we need to do the repeat the input operations some 10^14 times. Clearly we cannot do one operation at a time.
# So instead of applying each operation right away, we can do better by composing the operations (think functional!)
# so that the whole instruction set is compressed into one operation.
# We can write each position as mx + a, where x is the starting position.
# 'CUT(n)' is the transformation [mx + a] => [mx + a + n], so m => m and a => a + n
# 'DEAL WITH INCREMENT(n)' is the transformation [mx + a] => [mnx + an], so m => mn and a => an
# 'REVERSE' is the transformation [mx + a] => [-mx - a - 1], so m => -m and a => -a-1
# Start from initial conditions m = 1 and a = 0 we can compose the whole instruction.

# Still, we need to keep compressing. We still cannot do 10^14 operations.
# Suppose the composed instruction has m = M and a = A
# If we do this 1 time, we get Mx + A
# 2 times -> (M^2)x + MA + A
# 3 times -> (M^3)x + (M^2)A + MA + A
# n times -> (M^n)x + SUM(i <= 0 to n-1)[(M^i)A]
#          = (M^n)x + [(M^n - 1) / (M - 1)]A    ... (by geometric sum)
# This is cool. We can compute modular exponentiation M^n and multiplicative inverse 1/(M-1) efficiently in log(N) time.

# But... wait a second. Part 2 actually ask a inverse question to part 1. It's not asking what position a particular card ends up,
# but what card ends up in this particaular position.
# Luckily, we can also easily find the inverse to our M and A.
# If   x1 is M(x0) + A
# then x0 is (x1 - A)/M
# so M => M' and A => -AM' where M' is the multiplicative inverse of M.


def step(a, m, d, ins)
	s = ins.split
	if s[1] == 'into'
		[(d -a -1) % d, (d - m) % d]
	elsif s[0] == 'cut'
		[(a - s[-1].to_i + d) % d, m]
	else
		n = s[-1].to_i
		[(a * n) % d, (m * n) % d]
	end
end

def f(d, ins_list)
	a = 0
	m = 1
	ins_list.each{|line| a, m = step(a, m, d, line)}
	[a, m]
end

def modpow(base, power, mod)
	result = 1
	while power > 0
		result = (result * base) % mod if power & 1 == 1
		base = (base * base) % mod
		power >>= 1;
	end
	result
end

def modinv(a, m) # compute a^-1 mod m if possible
	return m if m == 1
	m0, inv, x0 = m, 1, 0
	while a > 1
		inv -= (a / m) * x0
		a, m = m, a % m
		inv, x0 = x0, inv
	end
	inv += m0 if inv < 0
	inv
end

ins = IO.read('in22.txt').split("\n")

# part 1

d = 10007
pos = 2019

a, m = f(d, ins)
p (pos * m + a) % d

# part 2

d = 119315717514047
rounds = 101741582076661
pos = 2020

a, m = f(d, ins)

# inverse!
m = modinv(m, d)
a = d - ((m * a) % d)

mp = modpow(m, rounds, d)
p (mp * pos + a * (mp - 1) * modinv(m-1, d)) % d


