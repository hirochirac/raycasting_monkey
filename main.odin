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
MAX_DEPTH :: 200
FSP :: 60
FOV :: ry.PI / 3
HALF_FOV :: FOV / 2
CASTED_RAYS :: 260
STEP_ANGLE :: FOV / CASTED_RAYS

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
		draw_raycasting(p)
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

	if key == ry.KeyboardKey.RIGHT {
		p^.angle += 0.1
	}

	if key == ry.KeyboardKey.LEFT {
		p^.angle -= 0.1
	}

	if key == ry.KeyboardKey.UP {
		move(1, p)
	}

	if key == ry.KeyboardKey.DOWN {
		move(-1, p)
	}

}

move :: proc(dir: f32, p: ^Player) {

	tmpx := p^.pos.x - (p^.speed * math.sin_f32(p^.angle) * dir)
	col := int(math.floor_f32(p^.pos.y / TILE_SIZE))
	row := int(math.floor_f32(tmpx / TILE_SIZE))
	if _map[col][row] == 0 {
		p^.pos.x = tmpx
	}

	tmpy := p^.pos.y + (p^.speed * math.cos_f32(p^.angle) * dir)
	col = int(math.floor_f32(tmpy / TILE_SIZE))
	row = int(math.floor_f32(p^.pos.x / TILE_SIZE))
	if _map[col][row] == 0 {
		p^.pos.y = tmpy
	}


}

draw_raycasting :: proc(p: Player) {

	case_x: f32 = 0.0
	case_y: f32 = 0.0
	start_angle: f32 = p.angle - HALF_FOV
	endPos: ry.Vector2 = {}

	for c in 0 ..= CASTED_RAYS {

		for depth in 0 ..= MAX_DEPTH {
			endPos.x = p.pos.x - math.sin_f32(start_angle) * f32(depth)
			endPos.y = p.pos.y + math.cos_f32(start_angle) * f32(depth)

			case_y = math.floor_f32(endPos.x / TILE_SIZE)
			case_x = math.floor_f32((endPos.y / TILE_SIZE))

			ry.DrawLineV(p.pos, endPos, ry.Color{255, 255, 0, 255})

			if _map[int(case_x)][int(case_y)] == 1 {
				ry.DrawRectangle(
					i32(case_y) * TILE_SIZE,
					i32(case_x) * TILE_SIZE,
					TILE_SIZE - 1,
					TILE_SIZE - 1,
					ry.Color{0, 0, 255, 255},
				)
				break
			}


		}
		start_angle += STEP_ANGLE
	}
}

draw_player :: proc(p: Player) {
	ry.DrawCircle(i32(p.pos.x), i32(p.pos.y), p.r, p.color)
	ry.DrawLineV(
		p.pos,
		ry.Vector2{p.pos.x - math.sin_f32(p.angle) * 20, p.pos.y + math.cos_f32(p.angle) * 20},
		ry.RED,
	)
	ry.DrawLineV(
		p.pos,
		ry.Vector2{
			p.pos.x - math.sin_f32(p.angle + HALF_FOV) * 20,
			p.pos.y + math.cos_f32(p.angle + HALF_FOV) * 20,
		},
		ry.RED,
	)
	ry.DrawLineV(
		p.pos,
		ry.Vector2{
			p.pos.x - math.sin_f32(p.angle - HALF_FOV) * 20,
			p.pos.y + math.cos_f32(p.angle - HALF_FOV) * 20,
		},
		ry.RED,
	)
}
