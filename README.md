# Code Monkey

A darkly comedic turn-based game where you're a developer trapped in corporate hell, secretly building a startup on company time. Each day, pick one action. Ship quality work or cut corners. Escape with $5,000 before bugs make work impossible or your boss catches you hustling.

---

## Running the Game

1. Open the project in **Godot 4.5**
2. Press **F5**

Main scene: `scenes/game_ui.tscn`

---

## Development

**Check for errors (headless):**
```bash
make check
```

**Run tests:**
```bash
make test
```

Both default to `/Applications/Godot.app/Contents/MacOS/Godot`. Override if your install differs:
```bash
make check GODOT=/path/to/godot
```

**Installing GUT (required for tests):**

`addons/` is gitignored — install GUT manually:
1. Download `gut_v*.zip` from the [GUT releases page](https://github.com/bitwes/Gut/releases) or the Godot Asset Library
2. Extract and place the `gut` folder into `addons/` (create `addons/` if it doesn't exist)
3. In Godot: Project → Project Settings → Plugins → enable GUT

---

## How to Play

Each day pick one action:

- **WORK** — go do job monkey
- **HUSTLE** — earn $$$ toward your escape (don't get caught)
- **SHIP IT** — ship your buggy code and repeat

**Win** by saving $5,000 before you get fired

---

## Docs

- **[docs/GDD.md](docs/GDD.md)** — full game design
- **[docs/BALANCE.md](docs/BALANCE.md)** — all the numbers
- **[docs/DECISIONS.md](docs/DECISIONS.md)** — design decisions
- **[docs/INDEX.md](docs/INDEX.md)** — everything else
- **[docs/PLAN.md](docs/PLAN.md)** — build plan and implementation notes