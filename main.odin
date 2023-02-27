package main

import "core:fmt"
import "core:math"
import ry "vendor:raylib"

MAP_SIZE: int : 8
TITLE :: "raycasting"
WIDTH :: 960
HEIGHT :: 8 * TILE_SIZE
TILE_SIZE :: 64
MAX_WIDTH :: (WIDTH / 2) / TILE_SIZE
MAX_HEIGHT :: (HEIGHT) / TILE_SIZE
FSP :: 60
MAX_RAYS :: 1
FOV :: ry.PI / 3
HALF_FOV :: FOV / 2

_map: [MAP_SIZE][MAP_SIZE]i32 = {
	{1, 1, 1, 1, 1, 1, 1, 1},
	{1, 0, 1, 0, 0, 0, 0, 1},
	{1, 0, 1, 0, 0, 0, 1, 1},
	{1, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 1, 1, 1, 1},
	{1, 0, 0, 0, 1, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 1},
	{1, 1, 1, 1, 1, 1, 1, 1},
}

Tile :: struct {
	color: ry.Color,
	pos:   ry.Rectangle,
}


Player :: struct {
	speed: f32,
	r:     f32,
	tmp:   ry.Vector2,
	pos:   ry.Vector2,
	color: ry.Color,
	angle: f32,
}

main :: proc() {


	p: Player = Player {
		speed = 10.0,
		r = 5.0,
		pos = ry.Vector2{WIDTH / 4, HEIGHT / 2},
		color = {a = 255, r = 255, g = 0, b = 0},
		angle = ry.PI,
	}

	ry.InitWindow(WIDTH, HEIGHT, TITLE)

	ry.SetTargetFPS(FSP)

	for (!ry.WindowShouldClose()) {

		ry.BeginDrawing()
		defer ry.EndDrawing()

		ry.ClearBackground(ry.RAYWHITE)

		draw_map()
		move_player(&p)
		draw_player(p)

	}

	ry.CloseWindow()

}

draw_map :: proc() {

	for c in 0 ..< len(_map) {
		for l in 0 ..< len(_map[c]) {
			if _map[c][l] == 1 {
				ry.DrawRectangle(
					i32(l * TILE_SIZE),
					i32(c * TILE_SIZE),
					i32(TILE_SIZE - 2),
					i32(TILE_SIZE - 2),
					ry.Color{0, 0, 0, 255},
				)
			} else {
				ry.DrawRectangle(
					i32(l * TILE_SIZE),
					i32(c * TILE_SIZE),
					i32(TILE_SIZE - 2),
					i32(TILE_SIZE - 2),
					ry.Color{100, 100, 100, 255},
				)
			}
		}
	}

}

move_player :: proc(p: ^Player) {

	key: ry.KeyboardKey = ry.GetKeyPressed()

	caseY: f32 = math.floor_f32((p^.pos.x / f32((TILE_SIZE * MAP_SIZE))) * f32(MAP_SIZE))
	caseX: f32 = math.floor_f32((p^.pos.y / f32((TILE_SIZE * MAP_SIZE)) * f32(MAP_SIZE)))

	fmt.println(int(caseY), " ", int(caseX), " ", _map[int(caseY)][int(caseX)])


	if key == ry.KeyboardKey.RIGHT {
		p^.angle += 0.1
	}

	if key == ry.KeyboardKey.LEFT {
		p^.angle -= 0.1
	}

	if (_map[int(caseY)][int(caseX)] == 0) {

		p^.tmp.x = p^.pos.x
		p^.tmp.y = p^.pos.y

		if key == ry.KeyboardKey.UP {
			p^.pos.x += p.speed * math.sin_f32(p.angle)
			p^.pos.y += p.speed * math.cos_f32(p.angle)
		}

		if key == ry.KeyboardKey.DOWN {
			p.pos.x -= p.speed * math.sin_f32(p.angle)
			p.pos.y -= p.speed * math.cos_f32(p.angle)
		}
	} else {
		p.pos = p.tmp
	}

}

draw_raycasting :: proc(p: Player) {

	depth: f32 = 0
	rays: [MAX_RAYS]f32

	for r in 0 ..= MAX_RAYS {

		loop_depth: for {


		}

	}
}

draw_player :: proc(p: Player) {
	ry.DrawCircle(i32(p.pos.x), i32(p.pos.y), p.r, p.color)
	ry.DrawLineV(
		p.pos,
		ry.Vector2{p.pos.x + math.sin_f32(p.angle) * 20, p.pos.y + math.cos_f32(p.angle) * 20},
		ry.RED,
	)
	ry.DrawLineV(
		p.pos,
		ry.Vector2{
			p.pos.x + math.sin_f32(p.angle + HALF_FOV) * 20,
			p.pos.y + math.cos_f32(p.angle + HALF_FOV) * 20,
		},
		ry.RED,
	)
	ry.DrawLineV(
		p.pos,
		ry.Vector2{
			p.pos.x + math.sin_f32(p.angle - HALF_FOV) * 20,
			p.pos.y + math.cos_f32(p.angle - HALF_FOV) * 20,
		},
		ry.RED,
	)
}
