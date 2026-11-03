with open("scripts/santelmo.gd", "r", encoding="utf-8") as f:
    content = f.read()

old_tex_def = 'const SANTELMO_TEX = preload("res://assets/enemies/santelmo_spritesheet.png")'
new_tex_def = """static var _santelmo_tex: Texture2D = null

static func get_santelmo_texture() -> Texture2D:
\tif _santelmo_tex != null:
\t\treturn _santelmo_tex
\tif ResourceLoader.exists("res://assets/enemies/santelmo_spritesheet.png"):
\t\tvar res = load("res://assets/enemies/santelmo_spritesheet.png")
\t\tif res is Texture2D:
\t\t\t_santelmo_tex = res
\t\t\treturn res
\tvar global_p: String = ProjectSettings.globalize_path("res://assets/enemies/santelmo_spritesheet.png")
\tif FileAccess.file_exists(global_p):
\t\tvar img := Image.new()
\t\tif img.load(global_p) == OK:
\t\t\t_santelmo_tex = ImageTexture.create_from_image(img)
\t\t\treturn _santelmo_tex
\treturn null"""

assert old_tex_def in content, "old_tex_def not found"
content = content.replace(old_tex_def, new_tex_def, 1)

old_tex_assign = "sprite.texture = SANTELMO_TEX"
new_tex_assign = "sprite.texture = get_santelmo_texture()"
assert old_tex_assign in content, "old_tex_assign not found"
content = content.replace(old_tex_assign, new_tex_assign, 1)

old_vfx_call = "VFX_SCRIPT.spawn_blood_splash(get_parent(), global_position, false, Vector2(1.2, 1.2))"
new_vfx_call = "VFX_SCRIPT.spawn_blood_slash(get_parent(), global_position, false, Vector2(1.2, 1.2))"
assert old_vfx_call in content, "old_vfx_call not found"
content = content.replace(old_vfx_call, new_vfx_call, 1)

with open("scripts/santelmo.gd", "w", encoding="utf-8") as f:
    f.write(content)

print("scripts/santelmo.gd successfully updated!")
