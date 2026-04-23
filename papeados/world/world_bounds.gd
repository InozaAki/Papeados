extends Node2D

@export var arena_width := 800
@export var arena_height := 600
@export var boundary_thickness := 20

@export var arena_texture : Texture2D

func _ready() -> void:
	create_walls()

'''
Construye los cuatro límites físicos de la arena (suelo, techo y laterales)
usando dimensiones y grosor configurables.
'''
func create_walls():
	# Floor
	create_wall(
		Vector2(0, arena_height / 2),
		Vector2(arena_width + boundary_thickness, boundary_thickness)
	)

	# Top
	create_wall(
		Vector2(0, -arena_height / 2),
		Vector2(arena_width + boundary_thickness, boundary_thickness)
	)

	# Left
	create_wall(
		Vector2(-arena_width / 2, 0),
		Vector2(boundary_thickness, arena_height)
	)

	# Right
	create_wall(
		Vector2(arena_width / 2, 0),
		Vector2(boundary_thickness, arena_height)
	)

func create_wall(pos: Vector2, size: Vector2) -> void:
	var wall := StaticBody2D.new()
	var collision_shape := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.extents = size / 2
	collision_shape.shape = shape
	wall.position = pos
	wall.add_child(collision_shape)
	add_child(wall)


	var visual = Panel.new()
	var sb = StyleBoxTexture.new()

	sb.texture = arena_texture

	visual.add_theme_stylebox_override("panel", sb)

	visual.size = size 
	visual.position = -size / 2
	wall.add_child(visual)
