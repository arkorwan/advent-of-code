layers = IO.read('in08.txt').chars.map(&:to_i).each_slice(25 * 6).to_a

# part 1
l=layers.map{|x|x.group_by{|y|y}.transform_values{|v|v.size}}.min_by{|l|l[0]}
p l[1]*l[2]

# part 2
img=layers.reduce{|l1,l2|l1.zip(l2).map{|x,y|x==2?y:x}}
img.each_slice(25){|r| puts r.join.tr("01"," #")}