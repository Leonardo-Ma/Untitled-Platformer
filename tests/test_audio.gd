extends Node


func _ready() -> void:
	# Wait one frame to ensure all systems are initialized
	await get_tree().process_frame
	_run_all_tests()


# Optional: Run tests on demand via console command
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_home"):  # Home key
		print("\n🔄 Re-running audio system tests...")
		_run_all_tests()


func _run_all_tests() -> void:
	print("\n========== AUDIO SYSTEM VERIFICATION ==========")

	_test_soundmanager_autoload()
	_test_subsystems_exist()
	_test_audio_buses()
	_test_soundpool_categories()
	_test_music_system()
	_test_combat_system()
	_test_volume_controls()

	print("========== ALL TESTS PASSED! ==========\n")


# ============== INDIVIDUAL TESTS ==============
func _test_soundmanager_autoload() -> void:
	assert(
		SoundManager != null,
		"SoundManager autoload not found! Add SoundManager.gd to Project Settings → Autoload",
	)

	assert(
		SoundManager.has_signal("ready"),
		"SoundManager exists but may not be properly initialized",
	)

	print("✅ Test 1: SoundManager autoload exists")


func _test_subsystems_exist() -> void:
	# Check SoundPool
	assert(
		SoundManager.pool != null,
		"SoundManager.pool is null - SoundPool not created",
	)
	assert(
		SoundManager.pool is SoundPool,
		"SoundManager.pool is not a SoundPool instance",
	)

	# Check MusicController
	assert(
		SoundManager.music != null,
		"SoundManager.music is null - MusicController not created",
	)
	assert(
		SoundManager.music is MusicController,
		"SoundManager.music is not a MusicController instance",
	)

	# Check CombatPrioritySoundController
	assert(
		SoundManager.combat != null,
		"SoundManager.combat is null - CombatPrioritySoundController not created",
	)
	assert(
		SoundManager.combat is CombatPrioritySoundController,
		"SoundManager.combat is not a CombatPrioritySoundController instance",
	)

	print("✅ Test 2: All subsystems exist and are correct types")


func _test_audio_buses() -> void:
	var required_buses = ["Master", "Music", "SFX", "Ambient", "UI", "Voice"]

	var bus_indices := {}

	# Build lookup from AudioServer
	for i in range(AudioServer.get_bus_count()):
		var name = AudioServer.get_bus_name(i)
		bus_indices[name] = i

	# Validate existence + mute state
	for bus_name in required_buses:
		assert(
			bus_name in bus_indices,
			"Audio bus '%s' not found! Check your AudioBusLayout (uid://plxel2xf671u)" % bus_name,
		)

		var idx = bus_indices[bus_name]

		assert(
			not AudioServer.is_bus_mute(idx),
			"Audio bus '%s' is muted. Fix it in the layout." % bus_name,
		)

	# Validate routing (Music -> Master)
	var music_idx = bus_indices["Music"]
	var send = AudioServer.get_bus_send(music_idx)

	assert(
		send == "Master",
		"Music bus should send to Master bus.",
	)

	print("✅ Test 3: All audio buses properly configured")


func _test_soundpool_categories() -> void:
	var pool = SoundManager.pool

	# Check category limits exist
	var expected_categories = [
		SoundManager.SoundCategory.MUSIC,
		SoundManager.SoundCategory.SFX,
		SoundManager.SoundCategory.AMBIENT,
		SoundManager.SoundCategory.UI,
		SoundManager.SoundCategory.VOICE,
	]

	for category in expected_categories:
		assert(
			pool.CATEGORY_LIMITS.has(category),
			"SoundPool missing CATEGORY_LIMITS for category %d" % category,
		)

		var limit = pool.CATEGORY_LIMITS[category]
		assert(
			limit > 0,
			"Category %d has invalid limit: %d" % [category, limit],
		)

	# Verify player pools were created
	assert(
		not pool._pools.is_empty(),
		"SoundPool._pools is empty - pools not initialized",
	)

	assert(
		not pool._active_players.is_empty(),
		"SoundPool._active_players is empty - tracking not initialized",
	)

	print("✅ Test 4: SoundPool categories properly configured")


func _test_music_system() -> void:
	var music = SoundManager.music

	# Check music state enum exists
	assert(
		MusicController.MusicState != null,
		"MusicController.MusicState enum not accessible",
	)

	# Check music library has entries (even if empty)
	assert(
		music.music_library != null,
		"MusicController.music_library is null",
	)

	# Verify music player was created
	assert(
		music._current_player != null,
		"MusicController._current_player not created",
	)
	assert(
		music._current_player.bus == "Music",
		"Music player not assigned to Music bus",
	)

	# Test volume control
	var test_volume = -15.0
	music.set_volume(test_volume)
	var actual_volume = music._current_player.volume_db
	assert(
		abs(actual_volume - test_volume) < 0.1,
		"Music volume not updating properly",
	)

	# Reset volume to default
	music.set_volume(-10.0)

	print("✅ Test 5: MusicController functional")


func _test_combat_system() -> void:
	var combat = SoundManager.combat

	# Check priority enum exists
	assert(
		CombatPrioritySoundController.Priority != null,
		"CombatPrioritySoundController.Priority enum not accessible",
	)

	# Check priority values
	assert(
		CombatPrioritySoundController.Priority.LOW == 0,
		"Priority.LOW should be 0",
	)
	assert(
		CombatPrioritySoundController.Priority.ULTIMATE == 4,
		"Priority.ULTIMATE should be 4",
	)

	# Verify initialize was called
	assert(
		combat._sound_pool != null,
		"CombatPrioritySoundController not initialized with SoundPool reference",
	)

	# Check active sounds array exists
	assert(
		combat._active_sounds != null,
		"CombatPrioritySoundController._active_sounds not initialized",
	)

	# Test max active sounds setting
	assert(
		combat._max_active_sounds > 0,
		"CombatPrioritySoundController._max_active_sounds not set",
	)

	print("✅ Test 6: CombatPrioritySoundController functional")


func _test_volume_controls() -> void:
	# Test get/set for each category
	var categories = [
		{"enum": SoundManager.SoundCategory.MUSIC, "bus": "Music"},
		{"enum": SoundManager.SoundCategory.SFX, "bus": "SFX"},
		{"enum": SoundManager.SoundCategory.AMBIENT, "bus": "Ambient"},
		{"enum": SoundManager.SoundCategory.UI, "bus": "UI"},
		{"enum": SoundManager.SoundCategory.VOICE, "bus": "Voice"},
	]

	for cat in categories:
		var original_volume = SoundManager.get_category_volume(cat.enum)
		var test_volume = -20.0

		SoundManager.set_category_volume(cat.enum, test_volume)
		var new_volume = SoundManager.get_category_volume(cat.enum)

		assert(
			abs(new_volume - test_volume) < 0.1,
			"Volume control broken for category %s" % cat.bus,
		)

		# Restore original volume
		SoundManager.set_category_volume(cat.enum, original_volume)

	# Test mute/unmute
	SoundManager.mute_all()
	var master_idx = AudioServer.get_bus_index("Master")
	assert(
		AudioServer.is_bus_mute(master_idx),
		"mute_all() didn't mute Master bus",
	)

	SoundManager.unmute_all()
	assert(
		not AudioServer.is_bus_mute(master_idx),
		"unmute_all() didn't unmute Master bus",
	)

	print("✅ Test 7: Volume controls working correctly")
