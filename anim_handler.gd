extends Control

signal animation_finished(anim_name: StringName)

@export_range(0.0, 100.0, 1.0) var value = 80:
    set(new):
        value = new
        calc_progress_value()

var top_pixel = 0
var bottom_pixel = 0
var reg_height = 0
var offset = Vector2.ZERO:
    set(new):
        offset = new
        %Bar.position = new

func play_anim(anim_name: StringName):
    %Sprites.play(anim_name)

func calc_progress_value():
    var progress_height = bottom_pixel - top_pixel
    var split_in_bottle = progress_height * (1 - (value / 100.0))
    var abs_pos = top_pixel + split_in_bottle
    %Bar.value = (1 - (abs_pos / reg_height)) * 100

func _on_animated_sprite_2d_frame_changed() -> void:
    var tex: Texture2D = %Sprites.sprite_frames.get_frame_texture(
        %Sprites.animation,
        %Sprites.frame,
    )

    if tex == null:
        %Bar.texture_under = null
        %Bar.texture_over = null
        %Bar.texture_progress = null
        return

    var atlas = AtlasTexture.new()
    atlas.atlas = tex

    reg_height = tex.get_height() / 3.0
    var reg_width = tex.get_width()
    var textures: Array[AtlasTexture] = []
    textures.resize(3)

    for i in 3:
        var start = Vector2i(0, reg_height * i)
        var reg_size = Vector2i(reg_width, reg_height)
        atlas.region = Rect2i(start, reg_size)
        textures[i] = atlas.duplicate()
        var is_progress_layer = i == 1
        if is_progress_layer:
            get_bounds(atlas)

    %Bar.texture_under = textures[0]
    %Bar.texture_over = textures[2]
    %Bar.texture_progress = textures[1]

    calc_progress_value()

func get_bounds(atlas_tex: AtlasTexture):
    var width = atlas_tex.get_width()
    var height = atlas_tex.get_height()

    var img = atlas_tex.atlas.get_image()
    var region_rect = atlas_tex.region

    top_pixel = height
    bottom_pixel = 0

    for y in range(height):
        for x in range(width):
            var atlas_x = region_rect.position.x + x
            var atlas_y = region_rect.position.y + y
            var color = img.get_pixel(atlas_x, atlas_y)
            if color.a > 0:
                top_pixel = min(top_pixel, y)
                bottom_pixel = max(bottom_pixel, y)


func _on_sprites_animation_finished() -> void:
    animation_finished.emit(%Sprites.animation)
