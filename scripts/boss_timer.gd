extends Node2D

onready var world = get_parent().get_parent()

var best_flash = false
var best_delay = 0

var show_badge = false
var badge_frame = 0
var badge_time = 60
var badge_delay = 0
var set_badge = 0
var flash_cnt = 0
var sound = false

func _process(delta):
	
	if best_flash:
		best_delay += 1
		
		if best_delay > 7:
			if !$text_b.is_visible_in_tree():
				$text_b.show()
			else:
				$text_b.hide()
			best_delay = 0
	
	if show_badge:
		
		if badge_time > 1:
			
			sound = true
			
			if !$badge.is_visible_in_tree():
				$badge.show()
			
			badge_delay += 1
			
			if badge_delay > 1:
				badge_frame += 1
				
				if badge_frame > 4:
					badge_frame = 0
			
			badge_time -= 1
		else:
			
			if sound:
				world.sound('bling')
				sound = false
			
			badge_delay += 1
			
			if badge_delay > 3 and flash_cnt < 8:
				if !$badge.is_visible_in_tree():
					$badge.show()
				else:
					$badge.hide()
				flash_cnt += 1
				badge_delay = 0
			
			if flash_cnt > 8:
				$badge.show()
			
			badge_frame = set_badge
		
		$badge.frame = badge_frame

func init():
	best_flash = false
	best_delay = 0
	show_badge = false
	badge_frame = 0
	badge_time = 60
	badge_delay = 0
	set_badge = 0
	flash_cnt = 0
	sound = false
	$text_b.hide()
	$badge.hide()
