require 'rbtree'

input = IO.foreach('../data/17.txt').map(&:strip).map{ _1.chars.map(&:to_i)}

class Node
  attr_accessor :x, :y, :direction, :depth
  def initialize(x, y, direction, depth)
    @x = x
    @y = y
    @direction = direction
    @depth = depth
  end

  def to_a = [@x, @y, @direction, @depth]
  
  def eql?(other)
    other.class == self.class && other.to_a == self.to_a
  end

  def hash = to_a.hash
end

class Solver
  attr_accessor :input, :min_depth, :max_depth, :queue, :best

  @@up = 0
  @@left = 1
  @@down = 2
  @@right = 3
  @@dx = [-1, 0, 1, 0]
  @@dy = [0, -1, 0, 1]

  def initialize(input, min_depth, max_depth)
    @input = input
    @min_depth = min_depth
    @max_depth = max_depth
    @queue = MultiRBTree.new
    @best = {}
  end

  def try_explore(target, base_cost)
    if target.x >= 0 && target.x < @input.size && target.y >= 0 && target.y < @input[0].size && target.depth <= @max_depth

      cost = base_cost + @input[target.x][target.y]
      current_cost = best[target]
      if current_cost == nil || cost < current_cost
        queue[cost] = target
        best[target] = cost
      end  
    end
  end

  def go!
    try_explore(Node.new(0, 1, @@right, 1), 0)
    try_explore(Node.new(1, 0, @@down, 1), 0)
      
    until @queue.empty?
      cost, node = @queue.shift
      next if cost > @best[node]
      return cost if node.x == @input.size-1 && node.y == @input[0].size-1 && node.depth >= @min_depth

      try_explore(Node.new(
        node.x + @@dx[node.direction], 
        node.y + @@dy[node.direction],
        node.direction,
        node.depth + 1
        ), cost)

      if node.depth >= @min_depth
        if node.direction == @@left || node.direction == @@right
          try_explore(Node.new(node.x-1, node.y, @@up, 1), cost)
          try_explore(Node.new(node.x+1, node.y, @@down, 1), cost)
        else
          try_explore(Node.new(node.x, node.y-1, @@left, 1), cost)
          try_explore(Node.new(node.x, node.y+1, @@right, 1), cost)  
        end
      end
    end

    return nil
  end

end

# part 1
p Solver.new(input, 1, 3).go!

# part 2
p Solver.new(input, 4, 10).go!
