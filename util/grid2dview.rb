class Grid2DView

  class Orientation
    attr_accessor  :vec, :height, :width, :get, :set, :row_elements

    # homemade 2x2 matrix multiplication
    def self.mm(a, b)
      [
        b[0]*a[0] + b[2]*a[1],
        b[1]*a[0] + b[3]*a[1],
        b[0]*a[2] + b[2]*a[3],
        b[1]*a[2] + b[3]*a[3]
      ]
    end
  end

  @@orientation_0    = Orientation.new
  @@orientation_90   = Orientation.new
  @@orientation_180  = Orientation.new
  @@orientation_270  = Orientation.new
  @@orientation_0R   = Orientation.new
  @@orientation_90R  = Orientation.new
  @@orientation_180R = Orientation.new
  @@orientation_270R = Orientation.new

  
  @@orientation_0.vec    = [1, 0, 0, 1]
  @@orientation_90.vec   = [0, -1, 1, 0]
  @@orientation_180.vec  = [-1, 0, 0, -1]
  @@orientation_270.vec  = [0, 1, -1, 0]
  @@orientation_0R.vec   = [1, 0, 0, -1]
  @@orientation_90R.vec  = [0, 1, 1, 0]
  @@orientation_180R.vec = [-1, 0, 0, 1]
  @@orientation_270R.vec = [0, -1, -1, 0]

  @@orientation_map = [@@orientation_0, @@orientation_90, @@orientation_180, @@orientation_270, @@orientation_0R, @@orientation_90R, @@orientation_180R, @@orientation_270R].map{|o| [o.vec, o]}.to_h

  @@orientation_0.height    = ->(rows) {rows.size}
  @@orientation_90.height   = ->(rows) {rows[0].size}
  @@orientation_180.height  = ->(rows) {rows.size}
  @@orientation_270.height  = ->(rows) {rows[0].size}
  @@orientation_0R.height   = ->(rows) {rows[0].size}
  @@orientation_90R.height  = ->(rows) {rows.size}
  @@orientation_180R.height = ->(rows) {rows[0].size}
  @@orientation_270R.height = ->(rows) {rows.size}
  
  @@orientation_0.width    = ->(rows) {rows[0].size}
  @@orientation_90.width   = ->(rows) {rows.size}
  @@orientation_180.width  = ->(rows) {rows[0].size}
  @@orientation_270.width  = ->(rows) {rows.size}
  @@orientation_0R.width   = ->(rows) {rows.size}
  @@orientation_90R.width  = ->(rows) {rows[0].size}
  @@orientation_180R.width = ->(rows) {rows.size}
  @@orientation_270R.width = ->(rows) {rows[0].size}

  @@orientation_0.get    = ->(rows, r, c) {rows[r][c]}
  @@orientation_90.get   = ->(rows, r, c) {rows[rows.size-1-c][r]}
  @@orientation_180.get  = ->(rows, r, c) {rows[rows.size-1-r][rows[0].size-1-c]}
  @@orientation_270.get  = ->(rows, r, c) {rows[c][rows[0].size-1-r]}
  @@orientation_0R.get   = ->(rows, r, c) {rows[c][r]}
  @@orientation_90R.get  = ->(rows, r, c) {rows[rows.size-1-r][c]}
  @@orientation_180R.get = ->(rows, r, c) {rows[rows.size-1-c][rows[0].size-1-r]}
  @@orientation_270R.get = ->(rows, r, c) {rows[r][rows[0].size-1-c]}

  @@orientation_0.set    = ->(rows, r, c, v) {rows[r][c] = v}
  @@orientation_90.set   = ->(rows, r, c, v) {rows[rows.size-1-c][r] = v}
  @@orientation_180.set  = ->(rows, r, c, v) {rows[rows.size-1-r][rows[0].size-1-c] = v}
  @@orientation_270.set  = ->(rows, r, c, v) {rows[c][rows[0].size-1-r] = v}
  @@orientation_0R.set   = ->(rows, r, c, v) {rows[c][r] = v}
  @@orientation_90R.set  = ->(rows, r, c, v) {rows[rows.size-1-r][c] = v}
  @@orientation_180R.set = ->(rows, r, c, v) {rows[rows.size-1-c][rows[0].size-1-r] = v}
  @@orientation_270R.set = ->(rows, r, c, v) {rows[r][rows[0].size-1-c] = v}

  @@orientation_0.row_elements    = ->(rows, r, &block) {rows[r].each(&block)}
  @@orientation_90.row_elements   = ->(rows, r, &block) {rows.size.times{|i| block.call(rows[rows.size-1-i][r]) }}
  @@orientation_180.row_elements  = ->(rows, r, &block) {rows[rows.size-1-r].reverse_each(&block)}
  @@orientation_270.row_elements  = ->(rows, r, &block) {rows.size.times{|i| block.call(rows[i][rows[0].size-1-r]) }}
  @@orientation_0R.row_elements   = ->(rows, r, &block) {rows.size.times{|i| block.call(rows[i][r]) }}
  @@orientation_90R.row_elements  = ->(rows, r, &block) {rows[rows.size-1-r].each(&block)}
  @@orientation_180R.row_elements = ->(rows, r, &block) {rows.size.times{|i| block.call(rows[rows.size-1-i][rows[0].size-1-r]) }}
  @@orientation_270R.row_elements = ->(rows, r, &block) {rows[r].reverse_each(&block)}

  attr_accessor  :rows, :orientation

  def initialize(rows)
    @rows = rows
    @orientation = @@orientation_0
  end

  def rotate90!
    @orientation = @@orientation_map[Orientation.mm(@orientation.vec, @@orientation_90.vec)]
  end

  def rotate180!
    @orientation = @@orientation_map[Orientation.mm(@orientation.vec, @@orientation_180.vec)]
  end

  def rotate270!
    @orientation = @@orientation_map[Orientation.mm(@orientation.vec, @@orientation_270.vec)]
  end

  def flip_horizontal!
    @orientation = @@orientation_map[Orientation.mm(@orientation.vec, @@orientation_270R.vec)]
  end

  def flip_vertical!
    @orientation = @@orientation_map[Orientation.mm(@orientation.vec, @@orientation_90R.vec)]
  end

  def flip_diagonal!
    @orientation = @@orientation_map[Orientation.mm(@orientation.vec, @@orientation_0R.vec)]
  end

  def flip_antidiagonal!
    @orientation = @@orientation_map[Orientation.mm(@orientation.vec, @@orientation_180R.vec)]
  end


  def height
    @orientation.height.call(@rows)
  end

  def width
    @orientation.width.call(@rows)
  end

  def get(r, c)
    @orientation.get.call(@rows, r, c)
  end

  def set(r, c, v)
    @orientation.set.call(@rows, r, c, v)
  end

  def row_elements(r, &block)
    @orientation.row_elements.call(@rows, r, &block)
  end

  def to_a
    height.times.map{|i| 
      r = []
      row_elements(i){|e| r << e}
      r
    }.to_a
  end

end
