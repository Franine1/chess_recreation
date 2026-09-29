class_name Position
extends Resource





var board_position: BitMap

enum piece {
	EMPTY,
	PAWN,
	KNIGHT,
	BISHOP,
	ROOK,
	CASTLE_ROOK,
	QUEEN,
	KING
}

func _init() -> void:
	board_position = BitMap.new()
	board_position.create(Vector2i(16,16))
	reset_board()
	
	

static func get_empty() -> BitMap:
	var ans = BitMap.new()
	ans.create(Vector2i(2,2))
	
	return ans

static func get_en_passant() -> BitMap:
	var ans = BitMap.new()
	ans.create(Vector2i(2,2))
	
	ans.set_bit(1,1,true)
	
	return ans

static func get_pawn(is_white: bool = true) -> BitMap:
	var ans = BitMap.new()
	ans.create(Vector2i(2,2))
	ans.set_bit(0,0, true)
	ans.set_bit(1,1, is_white)
	
	return ans

static func get_knight(is_white: bool = true) -> BitMap:
	var ans = BitMap.new()
	ans.create(Vector2i(2,2))
	ans.set_bit(1,0, true)
	ans.set_bit(1,1, is_white)
	
	return ans

static func get_bishop(is_white: bool = true) -> BitMap:
	var ans = BitMap.new()
	ans.create(Vector2i(2,2))
	ans.set_bit(0,0, true)
	ans.set_bit(1,0, true)
	ans.set_bit(1,1, is_white)
	
	return ans

static func get_rook(is_white: bool = true) -> BitMap:
	var ans = BitMap.new()
	ans.create(Vector2i(2,2))
	ans.set_bit(0,1, true)
	ans.set_bit(1,1, is_white)
	
	return ans
	
static func get_castleable_rook(is_white: bool = true) -> BitMap:
	var ans = BitMap.new()
	ans.create(Vector2i(2,2))
	ans.set_bit(0,0, true)
	ans.set_bit(0,1, true)
	ans.set_bit(1,1, is_white)
	
	return ans

	
static func get_queen(is_white: bool = true) -> BitMap:
	var ans = BitMap.new()
	ans.create(Vector2i(2,2))
	ans.set_bit(1,0, true)
	ans.set_bit(0,1, true)
	ans.set_bit(1,1, is_white)
	
	return ans
	
static func get_king(is_white: bool = true) -> BitMap:
	var ans = BitMap.new()
	ans.create(Vector2i(2,2))
	ans.set_bit(0,0,true)
	ans.set_bit(1,0, true)
	ans.set_bit(0,1, true)
	ans.set_bit(1,1, is_white)
	
	return ans

static func get_piece(p: piece, is_white: bool = true) -> BitMap:
	var ans = BitMap.new()
	ans.create(Vector2i(2,2))
	var index = int(p)
	var bit_pos: Array[Vector2] = [Vector2(0,0),Vector2(1,0),Vector2(0,1)]
	
	for vector in bit_pos:
		var remainder = index % 2
		ans.set_bitv(vector,(remainder > 0))
		index -= remainder
		index /= 2
		if index == 0:
			break
	
	return ans

static func pieceof(bits: BitMap) -> piece:
	
	var bit_pos: Array[Vector2] = [Vector2(0,0),Vector2(1,0),Vector2(0,1)]
	
	var index = 0
	var scale = 1
	
	for vector in bit_pos:
		if bits.get_bitv(vector):
			index += scale
		scale *= 2
	
	return piece.values()[index]
	

static func colorof(bits: BitMap) -> bool:
	return bits.get_bitv(Vector2(1,1))

static func is_empty(bits: BitMap, ignore_passant: bool = true) -> bool:
	return piece.EMPTY == pieceof(bits) and (ignore_passant or !colorof(bits))
	
static func is_passant(bits: BitMap) -> bool:
	return piece.EMPTY == pieceof(bits) and colorof(bits)
	

static func is_pawn(bits: BitMap) -> bool:
	return piece.PAWN == pieceof(bits)

static func is_knight(bits: BitMap) -> bool:
	return piece.KNIGHT == pieceof(bits)

static func is_bishop(bits: BitMap) -> bool:
	return piece.BISHOP == pieceof(bits)

static func is_rook(bits: BitMap, ignore_castleable: bool = true) -> bool:
	return piece.ROOK == pieceof(bits) or (piece.CASTLE_ROOK == pieceof(bits) and ignore_castleable)

static func is_castleable_rook(bits: BitMap) -> bool:
	return piece.CASTLE_ROOK == pieceof(bits)

static func is_queen(bits: BitMap) -> bool:
	return piece.QUEEN == pieceof(bits)

static func is_king(bits: BitMap) -> bool:
	return piece.KING == pieceof(bits)

func clear_board() -> void:
	board_position.set_bit_rect(Rect2i(Vector2i(0,0),board_position.get_size()),false)


func reset_board() -> void:
	clear_board()
	set_piece_at_ra([Rect2i(0,1,8,1),Rect2i(0,6,8,1)],get_pawn(true))
	set_piece_at_a([Vector2i(0,0),Vector2i(0,7),Vector2i(7,0),Vector2i(7,7)],get_castleable_rook(true))
	set_piece_at_a([Vector2i(1,0),Vector2i(1,7),Vector2i(6,0),Vector2i(6,7)],get_knight(true))
	set_piece_at_a([Vector2i(2,0),Vector2i(2,7),Vector2i(5,0),Vector2i(5,7)],get_bishop(true))
	set_piece_at_a([Vector2i(3,0),Vector2i(3,7)],get_queen(true))
	set_piece_at_a([Vector2i(4,0),Vector2i(4,7)],get_king(true))
	set_color_at_r(Rect2i(0,0,8,2),false)




func set_piece_at(pos: Vector2i, input: BitMap) -> void:
	var offsets: Array[Vector2i] = [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]
	
	for vector in offsets:
		board_position.set_bitv((pos*2)+vector,input.get_bitv(vector))

func set_color_at(pos: Vector2i, is_white: bool) -> void:
	board_position.set_bitv((pos*2)+Vector2i(1,1),is_white)

func change_piece_at(pos: Vector2i, p: piece) -> void:
	change_piece_at_b(pos,get_piece(p))

func change_piece_at_b(pos: Vector2i, input: BitMap) -> void:
	var offsets: Array[Vector2i] = [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1)]
	
	for vector in offsets:
		board_position.set_bitv((pos*2)+vector,input.get_bitv(vector))

func get_piece_at(pos: Vector2i) -> BitMap:
	var offsets: Array[Vector2i] = [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]
	var ans: BitMap = BitMap.new()
	ans.create(Vector2i(2,2))
	
	for vector in offsets:
		ans.set_bitv(vector,board_position.get_bitv((pos*2)+vector))
	
	return ans

func set_piece_at_a(pos: Array[Vector2i], input: BitMap) -> void:
	for pos2 in pos:
		set_piece_at(pos2,input)

func set_piece_at_r(pos: Rect2i, input: BitMap) -> void:
	for i in pos.size.x:
		for j in pos.size.y:
			set_piece_at(pos.position + Vector2i(i,j),input)
			

func set_piece_at_ra(pos: Array[Rect2i], input: BitMap) -> void:
	for rect in pos:
		for i in rect.size.x:
			for j in rect.size.y:
				set_piece_at(rect.position + Vector2i(i,j),input)
			

func set_color_at_a(pos: Array[Vector2i], is_white: bool) -> void:
	for pos2 in pos:
		set_color_at(pos2,is_white)

func set_color_at_r(pos: Rect2i, is_white: bool) -> void:
	for i in pos.size.x:
		for j in pos.size.y:
			set_color_at(pos.position + Vector2i(i,j),is_white)

func set_color_at_ra(pos: Array[Rect2i], is_white: bool) -> void:
	for rect in pos:
		for i in rect.size.x:
			for j in rect.size.y:
				set_color_at(rect.position + Vector2i(i,j),is_white)

func change_piece_at_a(pos: Array[Vector2i], p: piece) -> void:
	for pos2 in pos:
		change_piece_at(pos2,p)

func change_piece_at_r(pos: Rect2i, p: piece) -> void:
	for i in pos.size.x:
		for j in pos.size.y:
			change_piece_at(pos.position + Vector2i(i,j),p)

func change_piece_at_ra(pos: Array[Rect2i], p: piece) -> void:
	for rect in pos:
		for i in rect.size.x:
			for j in rect.size.y:
				change_piece_at(rect.position + Vector2i(i,j),p)
