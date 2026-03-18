class_name ProjectileUtil

## Shared projectile spawning logic used by WeaponController, PinballLauncher, etc.
## Instantiates a PackedScene, propagates standard properties, and adds to the scene tree.

static func spawn(
	scene: PackedScene,
	tree: SceneTree,
	origin: Vector2,
	direction: Vector2,
	config: Dictionary = {}
) -> Node:
	if scene == null:
		return null

	var proj := scene.instantiate()
	proj.position = origin

	if "dir" in proj:
		proj.dir = direction.normalized() if direction != Vector2.ZERO else Vector2.DOWN

	if config.has("speed") and "speed" in proj:
		proj.speed = config["speed"]
	if config.has("atk") and "atk" in proj:
		proj.atk = config["atk"]
	if config.has("damage") and "damage" in proj:
		proj.damage = config["damage"]
	if config.has("instigator") and "instigator" in proj:
		proj.instigator = config["instigator"]

	if config.has("team") and proj.has_method("set_team"):
		proj.set_team(config["team"])

	if config.has("exclude_body") and "exclude_body" in proj:
		proj.exclude_body = config["exclude_body"]

	tree.root.add_child(proj)
	return proj
