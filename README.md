# Pokémon Crystal — Following Pokémon

A hack of Pokémon Crystal, built on the [pret/pokecrystal][pret] disassembly. The first healthy Pokémon in your party walks behind you on the overworld, the way it does in HeartGold and SoulSilver. You can turn around and talk to it, and it reacts to where you are.

To set up the repository and build the ROM, see [INSTALL.md](INSTALL.md). Run `make` to build `pokecrystal.gbc`.


## Following Pokémon

### The follower engine

The core is in `engine/events/follower.asm` and `engine/overworld/`.

- **Your lead Pokémon follows you.** It walks one step behind you, follows you through warps and across map connections, and turns to face you when you talk to it.
- **Poké Ball transitions.** The follower goes back into its ball, and comes back out, with an animated overworld Poké Ball and a ball emote (`EMOTE_POKE_BALL`).
- **Shiny followers.** Overworld sprites use the same palette as the Pokémon's party icon, and shiny Pokémon get their shiny colors.
- **Every species has a sprite,** with separate sprites for each Unown form. They are in `gfx/following/` and indexed by `gfx/following_sprite_pointers.asm`.

### Talking to your follower

Press A while facing your follower and it reacts. Reactions come from `FollowerInteractionTable`. Each row can match on any combination of:

| Condition  | Example                                         |
|------------|-------------------------------------------------|
| Species    | Slowpoke in Slowpoke Well                       |
| Type       | Ice types in the Ice Path, Ghost types in Lavender Town |
| Landmark   | Starters on the routes near where they were received |
| Specific map | Clefairy in Goldenrod Gym, Electrode in the Rocket Hideout |
| Time of day | Morning, day or night (no reactions use this yet) |
| Status     | Sleeping, poisoned, burned, frozen or paralyzed Pokémon |
| Event flag | Slowpoke before and after the Rockets leave the well |

The first row that matches is used, and if nothing matches, the default reaction is the last row. There are dozens of location-specific reactions across Johto and Kanto, including legendary Pokémon at their home locations (Ho-Oh at Tin Tower, Lugia in the Whirl Islands, the legendary beasts at the Burned Tower).

### Scripting the follower

New event script commands let map scripts control the follower during cutscenes:

| Command                  | Effect                                              |
|--------------------------|-----------------------------------------------------|
| `freezefollower` / `unfreezefollower` | Stop the follower from moving, or let it move again |
| `stowfollower`           | Return the follower to its Poké Ball (animated)     |
| `silentstowfollower`     | Hide the follower with no animation                 |
| `appearfollower`         | Bring the follower back out                         |
| `appearfolloweronestep`  | Bring the follower back out after the player's next step |
| `getfollowerdirection`   | Get the follower's direction relative to the player |
| `savefollowercoords`     | Save the follower's current position                |
| `followcry`              | Play the follower's cry                             |

The follower can be addressed in movement scripts as object `FOLLOWER`. Its state is stored in `VAR_FOLLOWERSTATE`. There is also a new NPC-only movement command, `jump_in_place`. Story maps such as Elm's Lab, Cherrygrove City and the Pokémon Center have been updated to use these commands.


## Overworld engine changes

These changes make the follower possible. Some of them are useful on their own.

- **Dynamic sprite reload.** Overworld sprites are loaded into VRAM as needed instead of being chosen in advance for each map group, which frees up VRAM for the follower. `data/maps/outdoor_sprites.asm` has been removed.
- **GDMA transfers.** FIQ's general-purpose DMA routine is used for faster VRAM copies.
- **Party menu icons** now use the overworld follower sprites, with the colors from each Pokémon's party menu palette (`data/pokemon/menu_mon_pals.asm`).
- **Bug fixes.** Surfing directly across a map connection now loads the new map, `ReadObjectEvents` no longer overflows into `wObjectMasks`, and the follower no longer turns invisible after a warp.


## Debug build

`make crystal_debug` builds a version for testing:

- Hold **A + B** while walking to walk through walls.
- The radio in the player's room gives a fully unlocked save: Pokégear with all cards, the Pokédex, all 16 badges, every Fly point and useful items.
- Some intro text is skipped, and the Pokémon Center link rooms are open from the start.


## Gameplay tweaks

- New move: **Silver Wind** (Bug, 60 power, 100 accuracy). Like Ancient Power, it has a chance to raise all of the user's stats.
- **Defense Curl** now raises Speed as well as Defense.
- Some level-up learnsets have changed, and wild Pokémon locations in Johto and Kanto have been reworked.


## Credits

- [pret][pret] — the original pokecrystal disassembly
- **vulcandth** — the Following Pokémon port and integration, interactions and map scripts
- **AtmaBuster** — Leaf Follow code from *Crystal Leaf*
- **FrenchOrange** and **LJSTAR** — additional Unown following sprites
- **Fredrik Ljungdahl (FIQ)** — GDMA transfer routine and dynamic sprite reload
- **Major Agnostic** — menu Pokémon palettes, based on the [Polished Crystal][polished] / Rangi tutorial

[pret]: https://github.com/pret/pokecrystal
[polished]: https://github.com/Rangi42/polishedcrystal
