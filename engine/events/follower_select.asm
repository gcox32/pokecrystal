; Choosing the overworld follower from the field party menu (see StartMenu_Pokemon)

DEF FOLLOWER_MARKER_TILE EQU $72 ; unused "『" from FontBattleExtra
DEF FOLLOWER_MARKER_PAL  EQU 3   ; HP_RED from PalPacket_PartyMenu: red top, cream bottom

SetPartyMonAsFollower:
; Make wCurPartyMon the overworld follower, if it's able to follow
	ld a, [wCurPartySpecies]
	cp EGG
	jr z, .cant_follow
	ld a, MON_HP
	call GetPartyParamLocation
	ld a, [hli]
	or [hl]
	jr z, .cant_follow
	ld a, [wCurPartyMon]
	ld [wFollowerChoice], a
	ld a, [wCurPartySpecies]
	call PlayMonCry
	ret

.cant_follow
	ld de, SFX_WRONG
	call WaitPlaySFX
	ret

PlacePartyMenuFollowerInfo:
; Mark the current follower in the party list and show the SELECT hint
	ld de, FollowerMarkerGFX
	ld hl, vTiles2 tile FOLLOWER_MARKER_TILE
	lb bc, BANK(FollowerMarkerGFX), 1
	call Get2bpp

	ld a, [wPartyCount]
	and a
	ret z

	farcall GetFollowerMon

; Clear the previous marker's palette
	push de
	hlcoord 3, 2, wAttrmap
	ld bc, 2 * SCREEN_WIDTH
	ld e, PARTY_LENGTH
.clear_attrs
	ld [hl], 0
	add hl, bc
	dec e
	jr nz, .clear_attrs
	pop de

	ld a, [wPartyCount]
	cp d
	jr c, .apply_attrs ; no mon can follow
	ld a, d
	dec a
	push af
	hlcoord 3, 2
	ld bc, 2 * SCREEN_WIDTH
	call AddNTimes
	ld [hl], FOLLOWER_MARKER_TILE
	pop af
	hlcoord 3, 2, wAttrmap
	ld bc, 2 * SCREEN_WIDTH
	call AddNTimes
	ld [hl], FOLLOWER_MARKER_PAL

.apply_attrs
	ld b, SCGB_PARTY_MENU
	call GetSGBLayout
	ld a, [wPartyMenuActionText]
	and a ; PARTYMENUACTION_CHOOSE_POKEMON
	ret nz

	ld a, [wOptions]
	push af
	set NO_TEXT_SCROLL, a
	ld [wOptions], a
	hlcoord 1, 15
	ld de, .ChooseAMonString
	call PlaceString
	hlcoord 1, 16
	ld bc, SCREEN_WIDTH - 2
	ld a, ' '
	call ByteFill
	hlcoord 1, 16
	ld de, .SelectFollowString
	call PlaceString
	pop af
	ld [wOptions], a
	ret

.ChooseAMonString:
	db "Choose a #MON.@"

.SelectFollowString:
	db "SELECT: Follow@"

FollowerMarkerGFX:
; the battle HUD's normal Poké Ball
INCBIN "gfx/battle/balls.2bpp", 0, TILE_SIZE
