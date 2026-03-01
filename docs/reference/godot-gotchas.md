# Godot Gotchas

Non-obvious things that will bite you. Patterns live in CLAUDE.md.

---

## UID Collisions (Critical)

Godot auto-generates `.uid` files for `.gd` and `.tscn` files. If they share the same UID you get "No loader found for resource" errors.

**Never manually create `.uid` files.** Let Godot generate them:
1. Write `.gd` and `.tscn` files
2. Run `godot --headless --editor --quit` to generate UIDs
3. Commit the generated `.uid` files

**Do commit `.uid` files — do not add them to `.gitignore`.**

To fix a collision: delete `.godot/` cache, reopen project, commit regenerated UIDs.

---

## @onready Runs After _init()

```gdscript
@onready var label = $Label  # Available in _ready(), NOT _init()
```

---

## Resource Instances Share Data

```gdscript
var a = load("res://task.tres")
var b = load("res://task.tres")
a.progress = 50
print(b.progress)  # Also 50 — same instance!

# Fix:
var b = a.duplicate()
```

---

## Setter Order Matters

```gdscript
var money := 0:
    set(value):
        money = value          # Update BEFORE emitting
        money_changed.emit(money)
```

---

## Cache Node References

```gdscript
# ✅ Cache once
@onready var label = $Label

# ❌ Don't traverse in _process
func _process(delta):
    $Label.text = "..."  # Searches tree every frame
```

---

## Signals Need Listeners

A signal emitted with no connections fails silently. If state isn't updating, check the connection exists in `_ready()`.
