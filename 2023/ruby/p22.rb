require 'set'

input = IO.foreach('../data/22.txt').map(&:strip)

class Brick
  attr_accessor :id, :top_z, :bottom_z, :xy_pos, :supported_by

  def initialize(pos, id)
    @id = id
    @bottom_z = [pos[2], pos[5]].min
    @top_z = [pos[2], pos[5]].max
    
    @xy_pos = pos[0].upto(pos[3]).flat_map{|x|
      pos[1].upto(pos[4]).map{|y| [x, y] }
    } 
  end

end

bricks = input.each_with_index.map{|line, i|
  pos = line.split(/[~,]/).map(&:to_i)
  Brick.new(pos, i)
}

floor_brick = Brick.new([0, 0, 0, 0, 0, 0], -1) # the entire floor as a fake brick
top_brick_for_pos = {}
cannot_remove = Set.new

bricks.sort_by{ _1.bottom_z}.each{|b|

  bricks_under = b.xy_pos.map{ top_brick_for_pos[_1] || floor_brick }
  top_z = bricks_under.map{_1.top_z}.max

  # fall down
  diff = b.bottom_z - (top_z+1)
  b.bottom_z -= diff
  b.top_z -= diff

  supporting_bricks = [] # small enough that it's faster than Set
  b.xy_pos.each{|k|
    if top_brick_for_pos[k] && top_brick_for_pos[k].top_z == top_z
      supporting_bricks << top_brick_for_pos[k].id
    end
    top_brick_for_pos[k] = b
  }
  supporting_bricks.uniq!
  cannot_remove << supporting_bricks[0] if supporting_bricks.size == 1
  b.supported_by = supporting_bricks
}

# part 1
p bricks.size - cannot_remove.size

# part 2
bricks = bricks.sort_by{ _1.bottom_z }
p 0.upto(bricks.size-1).map{|i|
  fallen = Set.new
  fallen << bricks[i].id
  (i+1).upto(bricks.size-1){|j|
    if (!bricks[j].supported_by.empty?) && bricks[j].supported_by.all?{|q| fallen.include?(q)}
      fallen << bricks[j].id
    end
  }
  fallen.size - 1 #excluding the disintegrating brick
}.sum
