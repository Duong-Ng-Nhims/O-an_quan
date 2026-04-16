extends Node2D
	
var is_ai_mode: bool = false
var ai_difficulty: String = "easy"

var stone_scene=preload("res://stone.tscn")
var mandarine_stone_scene = preload("res://mandarine_stone.tscn")
var game_over_scene = preload("res://game_over.tscn")
var ai_avt = preload("res://Assets/da620eafdcd3dfa0d8c8266927f8d6a3.png")
@onready var holes = $board_manager/holes.get_children()
@onready var mandarineHoles = $board_manager/mandarineHoles.get_children()
@onready var stones_container = $board_manager/stonesContainer
@onready var p1 = $P1
@onready var p2 = $P2
@onready var score_label_1 = $scoreLabel1
@onready var score_label_2 = $scoreLabel2
@onready var p1_marker = $board_manager/basketP1/stonePoint1
@onready var p2_marker = $board_manager/basketP2/stonePoint2

var score1: int = 0
var score2: int = 0
var current_turn = 1
var is_busy: bool = false
var all_slot = []

func _on_btn_home_pressed() -> void:
	Sounds.Click_Sound()
	get_tree().change_scene_to_file("res://main.tscn")
	
func _ready():
	#Sounds.play_bgm("res://Sound/Nhac.nen.trong.tro.choi.mp3")
	Sounds.play_bgm2()
	is_ai_mode = GameData.is_ai_mode
	ai_difficulty = GameData.ai_difficulty
	
	if is_ai_mode:
		doi_avartar()
		
	setup_all_slot()
	setup_board()
	
	await get_tree().process_frame
	
	for h in holes:
		update_stone_number(h)
	for m in mandarineHoles:
		update_stone_number(m)
		
	permition_to_double_click()
	bat_dau_luot(1)
	
	for hole in holes:
		if hole.has_signal("directional_selected"):
			if not hole.directional_selected.is_connected(_on_hole_selected):
				hole.directional_selected.connect(_on_hole_selected.bind(hole))
		
func doi_avartar():
	$P2.set_avt(ai_avt)

func setup_all_slot():
	all_slot.clear()
	for i in range(5):
		all_slot.append(holes[i])
	all_slot.append(mandarineHoles[1])
	for i in range(5,10):
		all_slot.append(holes[i])
	all_slot.append(mandarineHoles[0])
	
func setup_board():
	clear_all_stones()
	
	for hole in holes:
		for i in range(5):
			add_stone_to_hole(hole, stone_scene)
			
	for m_hole in mandarineHoles:
		add_stone_to_hole(m_hole, mandarine_stone_scene, true)
			
func add_stone_to_hole(hole_node, scene_to_use, is_mandarine=false):
	var stone = scene_to_use.instantiate()
	var range_x = 20
	var range_y = 20 if not is_mandarine else 45
	var offset = Vector2(randf_range(-range_x, range_x), randf_range(-range_y, range_y))
	stone.global_position = hole_node.global_position + offset
	stones_container.add_child(stone)
	
func clear_all_stones():
	for child in stones_container.get_children():
		child.queue_free()

func bat_dau_luot(player_id):
	current_turn = player_id
	is_busy = true
	await get_tree().process_frame
	await get_tree().process_frame
	if player_het_soi(player_id):
		lay_soi_tu_gio(player_id)
		await get_tree().process_frame
		for h in holes: update_stone_number(h)
	
	if is_ai_mode and player_id == 2:
		is_busy = true
		permition_to_double_click()
		thuc_hien_nuoc_di_ai()
	else:
		is_busy = false
		permition_to_double_click()
		
	if player_id == 1:
		p1.set_active(true)
		p1.reset_timer()
		p2.set_active(false)
		p2.stop_timer()
	else:
		p2.set_active(true)
		p2.reset_timer()
		p1.set_active(false)
		p1.stop_timer()

func ket_thuc_luot():
	bat_dau_luot(2 if current_turn == 1 else 1)

func player_het_soi(player_id) -> bool:
	var start_idx = 0 if player_id == 1 else 5
	var end_idx = 4 if player_id == 1 else 9
	for i in range(start_idx, end_idx+1):
		var hole = holes[i]
		for stone in stones_container.get_children():
			if not stone.is_queued_for_deletion() and stone.global_position.distance_to(hole.global_position)<30:
				return false
	return true
	
func lay_soi_tu_gio(player_id):
	if player_id == 1:
		score1 -= 5
	else:
		score2 -= 5
	cap_nhat_diem()
	
	var start_idx = 0 if player_id == 1 else 5
	var end_idx = 4 if player_id == 1 else 9
	for i in range(start_idx, end_idx+1):
		var  target_hole = holes[i]
		them_mot_vien_soi(target_hole)
	xoa_bot_soi_trong_gio(player_id, 5)

func _on_p_1_het_gio() -> void:
	print("player 1 timeout")
	bat_dau_luot(2)


func _on_p_2_het_gio() -> void:
	print("player 2 timeout")
	bat_dau_luot(1)
	
func rai_soi(start_hole, direction):
	var current_idx = all_slot.find(start_hole)
	var so_soi_rai = get_stone_in_hole(start_hole)
	await clear_stones_in_hole(start_hole)
	
	while so_soi_rai > 0:
		while so_soi_rai > 0:
			current_idx = (current_idx + direction + all_slot.size()) % all_slot.size()
			var target_hole = all_slot[current_idx]
			them_mot_vien_soi(target_hole)
			so_soi_rai -= 1
			await get_tree().create_timer(0.5).timeout
		
		var next_idx = (current_idx + direction + all_slot.size()) % all_slot.size()
		var next_hole = all_slot[next_idx]
		var stone_next_hole = get_stone_in_hole(next_hole)
	
		if next_hole in mandarineHoles:
			ket_thuc_luot()
			return
	
		if stone_next_hole > 0:
			so_soi_rai = stone_next_hole
			await clear_stones_in_hole(next_hole)
			current_idx = next_idx
			await get_tree().create_timer(0.5).timeout
			
		else:
			var eat_idx = (next_idx + direction + all_slot.size()) % all_slot.size()
			await an_quan(eat_idx, direction)
			ket_thuc_luot()
			return
	ket_thuc_luot()
	
func get_stone_in_hole(hole_node):
	var count = 0
	for stone in stones_container.get_children():
		if not stone.is_queued_for_deletion() and stone.global_position.distance_to(hole_node.global_position) < 28:
			count += 1
	return count

func get_hole_value(hole_node):
	var total_value = 0
	var stones = stones_container.get_children().filter(func(s):
		return not s.is_queued_for_deletion() and s.global_position.distance_to(hole_node.global_position) < 30
	)
	
	for s in stones:
		if "mandarine" in s.name.to_lower():
			total_value += 10 
		else:
			total_value += 1  
	return total_value
	
func update_stone_number(hole_node):
	var count = get_stone_in_hole(hole_node)
	if hole_node.has_node("stoneCountLabel"):
		var label = hole_node.get_node("stoneCountLabel")
		label.text = str(count)
		label.visible = (count > 0)
	
func them_mot_vien_soi(hole_node, is_mandarine_stone = false):
	var scene_to_use = mandarine_stone_scene if is_mandarine_stone else stone_scene
	var stone = scene_to_use.instantiate()
	var offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
	stone.global_position = hole_node.global_position + offset
	stones_container.add_child(stone)
	update_stone_number(hole_node)
	
func clear_stones_in_hole(hole_node):
	for stone in stones_container.get_children():
		if stone.global_position.distance_to(hole_node.global_position) < 30:
			stone.queue_free()
	await  get_tree().process_frame
	update_stone_number(hole_node)
			
func an_quan(eat_idx, direction):
	var target_hole = all_slot[eat_idx]
	var points_earned = get_hole_value(target_hole)
	if points_earned > 0:
		if current_turn == 1:
			score1 += points_earned
		else:
			score2 += points_earned
		var stone_count = get_stone_in_hole(target_hole)
			
		bo_vao_gio(current_turn, stone_count, target_hole in mandarineHoles)
			
		await clear_stones_in_hole(target_hole)
		update_stone_number(target_hole)
		
		cap_nhat_diem()
		kiem_tra_ket_thuc()
		var next_empty_idx = (eat_idx + direction + all_slot.size()) % all_slot.size()
		var next_eat_idx = (next_empty_idx + direction + all_slot.size()) % all_slot.size()
		
		if get_stone_in_hole(all_slot[next_empty_idx]) == 0:
			if get_stone_in_hole(all_slot[next_eat_idx]) > 0:
				await get_tree().create_timer(0.5).timeout
				await an_quan(next_eat_idx, direction)
			
func cap_nhat_diem():
	score_label_1.text = "Player 1 score: "+ str(score1)
	score_label_2.text = "Player 2 score: "+ str(score2)

func _on_hole_selected(direction: int, hole_node: Area2D):
	if is_busy: 
		return
		
	if is_ai_mode and current_turn == 2:
		return
		
	if not is_my_turn_hole(hole_node):
		return
		
	if get_stone_in_hole(hole_node) == 0:
		return

	if current_turn == 1: p1.stop_timer()
	else: p2.stop_timer()

	var real_direction = direction
	var idx = holes.find(hole_node)
	if idx >= 5 and idx <=9:
		real_direction = direction * -1
	is_busy = true
	clear_all_arrows() 
	await rai_soi(hole_node, real_direction)
	
func clear_all_arrows():
	for h in holes:
		h.arrow.hide()
	for m in mandarineHoles:
		m.arrow.hide()

func is_my_turn_hole(hole_node) -> bool:
	var idx = holes.find(hole_node)
	if current_turn == 1:
		return idx >= 0 and idx <= 4 
	else:
		return idx >= 5 and idx <= 9 

func permition_to_double_click():
	for i in range(holes.size()):
		var hole_node = holes[i]
		if holes.is_empty(): return
		if current_turn == 1:
			hole_node.can_click = (i >= 0 and i <= 4)
		else:
			hole_node.can_click = (i >= 5 and i <= 9)
		
		if not hole_node.can_click:
			hole_node.arrow.hide()
	
	for m_hole in mandarineHoles:
		m_hole.can_click = false
		m_hole.get_node("Arrow").hide()

func them_mot_vien_vao_gio(marker_node, scene_to_use):
	if scene_to_use == null:
		print("Loi")
		return
	var stone = scene_to_use.instantiate()
	var range_random = 50
	var offset = Vector2(randf_range(-range_random, range_random), randf_range(-range_random, range_random))
	stone.global_position = marker_node.global_position + offset
	stones_container.add_child(stone)
	
func xoa_bot_soi_trong_gio(player_id, so_luong):
	var target_marker = p1_marker if player_id == 1 else p2_marker
	var deleted_count = 0
	var all_stones = stones_container.get_children()
	all_stones.reverse()
	for stone in all_stones:
		if deleted_count >= so_luong: break
		if stone.global_position.distance_to(target_marker.global_position) < 60:
			stone.queue_free()
			deleted_count +=1

func bo_vao_gio(player_id: int, so_luong: int, quan:bool = false):
	var target_marker = p1_marker if player_id == 1 else p2_marker
	if quan:
		for i in range(5):
			them_mot_vien_vao_gio(target_marker, stone_scene)
		if so_luong > 1:
			for i in range(so_luong - 1):
				them_mot_vien_vao_gio(target_marker, stone_scene)
	else:
		var limit_display = min(so_luong, 10)
		for i in range(limit_display):
			them_mot_vien_vao_gio(target_marker, stone_scene)

func kiem_tra_ket_thuc():
	var quan_het_soi = true
	for m in mandarineHoles:
		if get_stone_in_hole(m) > 0: 
			quan_het_soi = false 
			break
	if quan_het_soi:
		is_busy = true
		thu_dan_con_lai()
		hien_thi_man_hinh_ket_thuc()

func thu_dan_con_lai():
	for i in range(all_slot.size()):
		var hole = all_slot[i]
		
		var stone_in_hole = stones_container.get_children().filter(func(s):
			return not s.is_queued_for_deletion() and s.global_position.distance_to(hole.global_position) < 30)
		var points_in_this_hole = 0
		for s in stone_in_hole:
			if "mandarine" in s.name.to_lower():
				points_in_this_hole += 10
			else:
				points_in_this_hole += 1
			s.queue_free()
		if i >= 0 and i <= 4:
			score1 += points_in_this_hole
		elif  i >= 6 and i <= 10:
			score2 += points_in_this_hole
	cap_nhat_diem()
	
func hien_thi_man_hinh_ket_thuc():
	p1.stop_timer()
	p2.stop_timer()
	
	var end_screen = game_over_scene.instantiate()
	add_child(end_screen)
	
	var winner_text = ""
	if score1 > score2:
		winner_text = "<Player 1 won>"
	elif score2 > score1:
		winner_text = "<Player 2 won>"
	else:
		winner_text = "Draw!"
	
	var lbl_winner = end_screen.find_child("winnerLabel", true, false)
	var lbl_score = end_screen.find_child("scoreLabel", true, false)
	var btn_replay = end_screen.find_child("btn_replay", true, false)
	var btn_home = end_screen.find_child("btn_home", true, false)
	if lbl_winner:
		lbl_winner.text = winner_text
	else: 
		print("khong tim thay node winnerLabel")
	if lbl_score:
		lbl_score.text = "P1: %d	|	P2: %d" %[score1, score2]
	if btn_replay:
		btn_replay.pressed.connect(self._on_btn_replay_pressed)
	if btn_home:
		btn_home.pressed.connect(self._on_btn_home_pressed)

func get_current_state():
	var state = {
		"slots": [],
		"score1": score1,
		"score2": score2
	}
	for slot in all_slot:
		state.slots.append(get_stone_in_hole(slot))
	return state

func evaluate_state(slots: Array, s1: int, s2: int) -> float:
	# 1. Trọng số chênh lệch điểm số (Nhân 10 để làm nền tảng)
	var score = (s2 - s1) * 10.0
	
	# 2. Đánh giá tình trạng hố Quan của AI (Hố số 11)
	if slots[11] == 0:
		score -= 100.0 # Phạt cực nặng nếu để mất Quan nhà
	else:
		# AI sẽ ưu tiên giữ sỏi ở Quan hoặc tích thêm sỏi vào đó
		score += slots[11] * 3.0
	
	# 3. Đánh giá tình trạng hố Quan đối thủ (Hố số 5)
	if slots[5] == 0:
		score += 50.0 # Thưởng điểm nếu đã ăn được Quan đối phương
	
	# 4. Kiểm tra khả năng "Hết sỏi trên sân" của AI (Hố 6-10)
	var ai_side_stones = 0
	for i in range(6, 11):
		ai_side_stones += slots[i]
		
	if ai_side_stones == 0:
		score -= 60.0 # Phạt nặng vì nước đi này buộc AI phải bỏ 5 điểm ra rải lại
	elif ai_side_stones < 5:
		score -= 20.0 # Cảnh báo nếu số sỏi trên sân quá ít
		
	# 5. Khuyến khích giữ sỏi trên sân nhà để tạo ra nhiều lựa chọn
	score += ai_side_stones * 1.5
	
	return score

func simulate_move(slots: Array, score1: int, score2: int, start_idx: int, direction: int, player_id: int) -> Array:
	# Chỉ sao chép mảng số (rất nhanh) thay vì duplicate toàn bộ Object
	var new_slots = slots.duplicate()
	var current_score1 = score1
	var current_score2 = score2
	
	var stones = new_slots[start_idx]
	new_slots[start_idx] = 0
	var curr = start_idx
	
	while stones > 0:
		# Rải sỏi
		while stones > 0:
			curr = (curr + direction + 12) % 12
			new_slots[curr] += 1
			stones -= 1
		
		# Kiểm tra ô tiếp theo
		var next = (curr + direction + 12) % 12
		
		# Gặp ô Quan (5, 11) thì phải dừng lại ngay
		if next == 5 or next == 11:
			break 
			
		if new_slots[next] == 0:
			# Logic ăn quân liên hoàn
			var eat_pos = (next + direction + 12) % 12
			while new_slots[next] == 0 and new_slots[eat_pos] > 0:
				var points = new_slots[eat_pos]
				# Cộng điểm thưởng cho viên Quan
				if eat_pos == 5 or eat_pos == 11:
					points += 10
				
				if player_id == 2: current_score2 += points
				else: current_score1 += points
				
				new_slots[eat_pos] = 0 # Xóa sỏi ở ô vừa ăn
				
				# Nhảy cách 1 ô để kiểm tra ăn liên hoàn
				next = (eat_pos + direction + 12) % 12
				eat_pos = (next + direction + 12) % 12
			break
		else:
			# Bốc sỏi ở ô tiếp theo lên rải tiếp
			stones = new_slots[next]
			new_slots[next] = 0
			curr = next
			
	# Trả về kết quả dưới dạng mảng để hàm minimax dễ xử lý
	return [new_slots, current_score1, current_score2]
	
func minimax(slots: Array, s1: int, s2: int, depth: int, alpha: float, beta: float, is_maxing: bool) -> float:
	if depth == 0:
		return evaluate_state(slots, s1, s2)
	
	if is_maxing:
		var max_eval = -1000000.0
		var moves = get_valid_moves(slots, 2)
		for move in moves:
			var result = simulate_move(slots, s1, s2, move.idx, move.dir, 2)
			var eval = minimax(result[0], result[1], result[2], depth - 1, alpha, beta, false)
			max_eval = max(max_eval, eval)
			alpha = max(alpha, eval)
			if beta <= alpha: break
		return max_eval
	else:
		var min_eval = 1000000.0
		for move in get_valid_moves(slots, 1):
			var result = simulate_move(slots, s1, s2, move.idx, move.dir, 1)
			var eval = minimax(result[0], result[1], result[2], depth - 1, alpha, beta, true)
			min_eval = min(min_eval, eval)
			beta = min(beta, eval)
			if beta <= alpha: break
		return min_eval
func get_valid_moves(slots_array: Array, player_id: int):
	var moves = []
	var indices = range(0,5) if player_id == 1 else range(6,11)
	for i in indices:
		if slots_array[i] > 0: 
			moves.append({"idx": i, "dir": 1})
			moves.append({"idx": i, "dir": -1})
	return moves
	
func thuc_hien_nuoc_di_ai():
	is_busy = true
	await  get_tree().create_timer(1.0).timeout
	
	var state = get_current_state()
	var moves = get_valid_moves(state.slots, 2)
	var best_move = moves[0]
	if moves.is_empty():
		ket_thuc_luot()
		return
	
	if ai_difficulty == "easy":
		best_move = moves.pick_random()
	else:
		var best_val = -999999
		var depth = 7 if ai_difficulty == "medium" else 9
		var use_pruning = (ai_difficulty == "hard")
		
		for move in moves:
			var alpha = -10000 if use_pruning else -999999
			var beta = 10000 if use_pruning else 999999
			var result = simulate_move(state.slots, state.score1, state.score2, move.idx, move.dir, 2)
			var val = minimax(result[0], result[1], result[2], depth-1, alpha, beta, false)
			
			if val > best_val:
				best_val = val
				best_move = move
	if best_move:
		p2.stop_timer()
		var hole_node = all_slot[best_move.idx]
		var real_dir = best_move.dir
		if best_move.idx >= 6 and best_move.idx <= 10:
			real_dir = best_move.dir * -1
			
		clear_all_arrows()
		await rai_soi(hole_node, real_dir)
			
func _on_btn_replay_pressed() -> void:
	Sounds.Click_Sound()
	get_tree().reload_current_scene()


func _on_btn_setting_pressed() -> void:
	Sounds.Click_Sound()
	pass # Replace with function body.


func _on_btn_pause_pressed() -> void:
	Sounds.Click_Sound()
	pass # Replace with function body.


func _on_btn_sounds_pressed() -> void:
	pass # Replace with function body.
