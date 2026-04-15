# murderface-pets

[![License](https://img.shields.io/github/license/fruitmob/murderface-pets)](LICENSE)
[![Release](https://img.shields.io/github/v/release/fruitmob/murderface-pets)](https://github.com/fruitmob/murderface-pets/releases)
[![GitHub Stars](https://img.shields.io/github/stars/fruitmob/murderface-pets)](https://github.com/fruitmob/murderface-pets)

A natural companion pet system for FiveM (QBox/QBX framework). Pets act like real pets — they follow you, defend you, react to their environment, and interact with other pets, all without constant menu management.

## Features

### Natural Companion AI
- **Auto-idle**: Pet sits when you stop, wanders and sniffs around, plays random anims, then cycles back
- **Speed-matching follow**: Pets walk when you walk, jog when you jog, sprint when you sprint
- **Sprint ahead**: Dog runs out in front when you sprint, falls back behind when you slow down
- **Move rate override**: Physically faster movement (1.0x idle to 1.8x catch-up) via `SetPedMoveRateOverride`
- **Auto-defend**: Pet attacks anyone who hurts you — no toggle needed, scales by level
- **Gunshot reactions**: Small pets cower, large pets bark and go alert
- **Ambient vocalizations**: Random barks, whines, and mood changes while following
- **Stranger alert**: Barks at NPCs who get too close
- **Sprint excitement**: Barks happily when you start running
- **Water reactions**: Excited bark entering water, shake off leaving

### Multi-Pet Support
- Up to 2 active pets simultaneously
- Lateral spacing — pets walk side by side, not stacked
- Sibling interactions — your own pets sniff and bark at each other during idle
- Independent follow offsets (left/right of player)

### 26 Breeds
8 large dogs, 3 small dogs, 2 cats, 3 wild/exotic, 2 small animals, 2 primates, plus 10 addon breeds (requires addon ped streaming resource). Police K9 available for law enforcement jobs.

### XP & Progression (Levels 0-50)
- 10 XP sources: passive, hunting, petting, tricks, feeding, watering, K9 search, healing, guarding, tracking, defending
- Level-gated unlocks: hunting (3), guard mode (5), speed tiers (10/25), specializations (20)
- 5 level titles: Puppy, Trained, Veteran, Elite, Legendary
- Milestone celebrations at levels 10, 25, 50

### 3 Specializations (Level 20)
- **Guardian**: 1.5x guard radius, +50 combat ability
- **Tracker**: Detect and highlight nearby peds within 50m
- **Companion**: 2x stress relief, 2x regen, 1.25x XP

### Combat Systems
- **Guard mode**: Pet guards a position and attacks intruders
- **Aggro/defense**: Auto-attacks threats to owner (always-on for dogs/wild)
- **Hunting**: Hunt and Hunt & Grab with corpse carry
- **K9 search**: Person and vehicle search for illegal items (police jobs)

### Prop-Based Leash System
- 3 color variants (Black, Yellow, Green)
- Physical leash prop attached between player hand and pet neck
- Script-side distance enforcement
- Network synced — other players see the leash
- Auto-detaches on despawn, death, vehicle enter

### Pet Carry
- Pick up small/medium pets with carry animation
- Auto-drops on vehicle enter, combat, logout

### 10 Emotes (`/petemote`)
happy, angry, sad, bark, sit, sleep, dance, paw, lay, fetch (throws a ball!)

### Stray Taming
- Wild animals at config-driven spawn points
- Trust-building through feeding (persisted in DB)
- Rare coat variants on tamed strays

### Breeding & Doghouse
- Placeable doghouse prop with rest bonus aura
- Same-model, opposite-gender, level 10+ breeding
- 24h cooldown per parent, offspring metadata pre-generated

### Built-In Pet Shop (`/petshop`)
- Admin places display dogs at kennel locations in-game
- Players walk up and buy via ox_target
- DB-persisted, proximity-spawned display dogs
- Works standalone — no dependency on external shop resources

### Swimming
- Pets swim instead of drowning (`SetPedDiesInWater` + config flag 65)

### Smart Vehicle Handling
- Auto-board when owner enters vehicle
- Auto-exit to left side with ground detection when owner exits
- Skip invisible vehicles (skateboard BMX fix)
- Dead pets don't board

## Dependencies

- [qbx_core](https://github.com/Qbox-project/qbx_core) (QBox framework)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [oxmysql](https://github.com/overextended/oxmysql)

### Optional
- Addon ped streaming resource for extra breeds (Doberman, Cane Corso, English Bulldog, Sphynx Cat, etc.)
- Police K9 ped streaming resource for the Police K9 breed

## Installation

1. Place `murderface-pets` in your resources folder
2. Add `ensure murderface-pets` to your server.cfg (after ox dependencies)
3. Add pet items to your ox_inventory `items.lua` (see item definitions below)
4. Add ace permission for admin commands:
   ```
   add_ace group.admin murderface-pets.petshop allow
   ```
5. Restart server — DB tables auto-create on first start

## Database Tables (auto-created)

- `murderface_pets` — pet data backup
- `murderface_stray_trust` — stray taming progress
- `murderface_doghouses` — placed doghouse positions
- `murderface_breeding` — breeding records
- `murderface_petshop_displays` — admin-placed shop display dogs

## Configuration

All settings are in `config.lua`:
- Pet definitions, prices, and traits
- XP rates and progression gates
- Guard, aggro, and combat settings
- Ambient behavior tuning (vocalize chance, idle thresholds, reactions)
- Movement rate multipliers
- Leash settings
- Pet carry settings
- K9 illegal items list
- Stray spawn points
- Breeding rules
- Notification system (ox_lib or rtx_notify)

### Owner Reactions
Pets respond naturally to what you're doing — no commands needed:
- **Owner sits down** — pet walks over and lays at your feet
- **Owner eats/drinks** — dog whines and begs for food
- **Owner goes AFK** (2 min) — pet sleeps nearby, barks when you return
- **Owner dies** — pet sits by your body and whines

## Commands

| Command | Permission | Description |
|---------|-----------|-------------|
| `/sit` | Everyone | Pet sits for a few seconds then resumes following |
| `/come` | Everyone | Pet stops waiting and follows you |
| `/stay` | Everyone | Pet stays at current position |
| `/heel` | Everyone | Pet follows closely at your side |
| `/speak` | Everyone | Pet barks on command |
| `/lay` | Everyone | Pet lays down |
| `/paw` | Everyone | Paw shake trick (level-gated) |
| `/petname` | Everyone | Show current pet's name and level |
| `/petemote <name>` | Everyone | Play a pet emote |
| `/petshop` | Admin | Open breed picker, place display dogs |
| `/petshop remove` | Admin | Remove nearest display dog |

## Keybind

| Key | Action |
|-----|--------|
| `]` (RBRACKET) | Open pet companion menu |

### 2. Add items to ox_inventory

Open `ox_inventory/data/items.lua` and paste the following block inside the `return { }` table. Pet items use `stack = false` because each pet carries unique metadata (name, level, XP, health, coat, etc). Supply items stack normally.

```lua
	-- ========================================
	--  murderface-pets: Pet Items
	--  consume = 0: usable but not consumed on use
	--  server.export: links to murderface-pets resource handler
	-- ========================================

	['murderface_husky'] = {
		label = 'Husky',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'A loyal Husky companion',
		server = { export = 'murderface-pets.murderface_husky' },
	},

	['murderface_shepherd'] = {
		label = 'German Shepherd',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'A brave German Shepherd companion',
		server = { export = 'murderface-pets.murderface_shepherd' },
	},

	['murderface_rottweiler'] = {
		label = 'Rottweiler',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'A powerful Rottweiler companion',
		server = { export = 'murderface-pets.murderface_rottweiler' },
	},

	['murderface_retriever'] = {
		label = 'Golden Retriever',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'A friendly Golden Retriever companion',
		server = { export = 'murderface-pets.murderface_retriever' },
	},

	['murderface_chop'] = {
		label = 'Chop',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'A tough old dog with character',
		server = { export = 'murderface-pets.murderface_chop' },
	},

	['murderface_westy'] = {
		label = 'Westie',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'A spirited West Highland Terrier companion',
		server = { export = 'murderface-pets.murderface_westy' },
	},

	['murderface_pug'] = {
		label = 'Pug',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'An adorable Pug companion',
		server = { export = 'murderface-pets.murderface_pug' },
	},

	['murderface_poodle'] = {
		label = 'Poodle',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'An elegant Poodle companion',
		server = { export = 'murderface-pets.murderface_poodle' },
	},

	['murderface_cat'] = {
		label = 'House Cat',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'An independent feline companion',
		server = { export = 'murderface-pets.murderface_cat' },
	},

	['murderface_panther'] = {
		label = 'Black Panther',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'A sleek and dangerous Black Panther',
		server = { export = 'murderface-pets.murderface_panther' },
	},

	['murderface_mtlion'] = {
		label = 'Mountain Lion',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'A fierce Mountain Lion companion',
		server = { export = 'murderface-pets.murderface_mtlion' },
	},

	['murderface_coyote'] = {
		label = 'Coyote',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'A cunning Coyote companion',
		server = { export = 'murderface-pets.murderface_coyote' },
	},

	['murderface_hen'] = {
		label = 'Chicken',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'A trusty Chicken companion',
		server = { export = 'murderface-pets.murderface_hen' },
	},

	['murderface_rabbit'] = {
		label = 'Rabbit',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'A fluffy Rabbit companion',
		server = { export = 'murderface-pets.murderface_rabbit' },
	},

	['murderface_chimp'] = {
		label = 'Chimpanzee',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'A clever Chimpanzee companion (build 3258+)',
		server = { export = 'murderface-pets.murderface_chimp' },
	},

	['murderface_rhesus'] = {
		label = 'Rhesus Monkey',
		weight = 100,
		stack = false,
		consume = 0,
		description = 'A mischievous Rhesus Monkey companion (build 3258+)',
		server = { export = 'murderface-pets.murderface_rhesus' },
	},

	-- ========================================
	--  murderface-pets: Supply Items
	--  consume = 0: usable but not consumed (resource handles removal)
	-- ========================================

	['murderface_food'] = {
		label = 'Pet Food',
		weight = 200,
		consume = 0,
		description = 'Nutritious food for your pet',
		server = { export = 'murderface-pets.murderface_food' },
	},

	['murderface_firstaid'] = {
		label = 'Pet First Aid',
		weight = 300,
		consume = 0,
		description = 'Heals or revives your pet (use via 3rd eye)',
		server = { export = 'murderface-pets.murderface_firstaid' },
	},

	['murderface_waterbottle'] = {
		label = 'Water Bottle',
		weight = 500,
		consume = 0,
		description = 'Refillable water bottle for your pet',
		server = { export = 'murderface-pets.murderface_waterbottle' },
	},

	['murderface_collar'] = {
		label = 'Pet Collar',
		weight = 100,
		consume = 0,
		description = 'Transfer pet ownership to another player',
		server = { export = 'murderface-pets.murderface_collar' },
	},

	['murderface_nametag'] = {
		label = 'Pet Nametag',
		weight = 50,
		consume = 0,
		description = 'Rename your pet companion',
		server = { export = 'murderface-pets.murderface_nametag' },
	},

	['murderface_groomingkit'] = {
		label = 'Grooming Kit',
		weight = 400,
		consume = 0,
		description = 'Change your pet\'s coat and appearance',
		server = { export = 'murderface-pets.murderface_groomingkit' },
	},

	['murderface_doghouse'] = {
		label = 'Dog House',
		weight = 5000,
		consume = 0,
		description = 'A placeable dog house for pet breeding and resting',
		server = { export = 'murderface-pets.murderface_doghouse' },
	},
```

## License

[MIT](LICENSE)
