def run(x, y)
	a=[1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,13,1,19,1,10,19,23,1,6,23,27,1,5,27,31,1,10,31,35,2,10,35,39,1,39,5,43,2,43,6,47,2,9,47,51,1,51,5,55,1,5,55,59,2,10,59,63,1,5,63,67,1,67,10,71,2,6,71,75,2,6,75,79,1,5,79,83,2,6,83,87,2,13,87,91,1,91,6,95,2,13,95,99,1,99,5,103,2,103,10,107,1,9,107,111,1,111,6,115,1,115,2,119,1,119,10,0,99,2,14,0,0]
	a[1] = x
	a[2] = y
	i = 0
	while a[i] != 99
		case a[i]
		when 1
			a[a[i+3]]=a[a[i+1]]+a[a[i+2]]
		when 2
			a[a[i+3]]=a[a[i+1]]*a[a[i+2]]
		end
		i+=4
	end
	a[0]
end

def compute(x, y)
	874653 + 384000 * x + y
end

def etupmoc(r) # inverse of compute!
	(r - 874653).divmod(384000)
end

# figure these out by trial and error!
# [0, i] => 874653 + i
# [i, 0] => (874 + (384 * i)) * 1000 + 653
# [i, j] => (874 + (384 * i)) * 1000 + 653 + j
#        = 874653 + 384000i + j

# part 1
puts run(12, 2)

# part 2
x,y = etupmoc(19690720)
puts x * 100 + y