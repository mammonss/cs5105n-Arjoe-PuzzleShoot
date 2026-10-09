# PuzzleShoot

This is my Game Development project for CS-5105N.

## Game Idea

PuzzleShoot is a 2D puzzle shooter game where the player controls a character and solves puzzles by using projectiles. The game will focus on combining puzzle-solving and shooting mechanics.

## Genre

2D Puzzle Shooter

## Project Status

Week 1 – Initial project setup and Godot & Git configuration.

Week 2 – Added player movement using CharacterBody2D, keyboard controls, projectile shooting, target collision, and basic game feel.

Week 3 – Added two levels with TileMap layouts, hazards, targets, clear goals, and a transition from Level 1 to Level 2. The level layouts use clear colors and shapes to distinguish the goal, targets, and hazards.

Week 4 – Added idle and move animations using AnimationPlayer, a shooting particle effect, and a small AI-assisted background tile asset. The tile concept was made from the prompt: “Create a simple dark sci-fi tile for a friendly 2D puzzle shooter, with clear grid lines and a bright teal and gold center symbol.” I cleaned up the concept into an editable SVG and integrated it as `assets/ai_background_tile.svg`. Tool used: ChatGPT for AI-assisted asset planning and SVG refinement.

Week 5 – Added a HUD showing score, health, and level, a Start / Continue / Quit main menu, a save button, and sound effects for shooting and taking damage. Background music was removed to keep the game focused on sound effects. Added a larger text option for accessibility and used a high contrast palette. A peer playtest still needs to be completed; after testing, record one observation and the change made below.

Week 6 – Added an enemy with a finite state machine: patrol, chase, and attack. The enemy checks the player's distance, moves toward the player when detected, and attacks when close. The first draft was AI-assisted and then adapted into the project script. The behavior should be tested and adjusted during play.

Week 7 – Added JSON save/load for score, health, and current level, a Continue option, camera shake on damage, tweened visual feedback, and a lightweight scene/object setup. The Godot Profiler should be used during a play session to confirm performance and record one measured optimization. A second five-minute peer playtest still needs to be completed.

## Controls

- W, A, S, D – Move
- Space – Shoot
- P – Pause or resume
- Use the on-screen Save button to save progress.
- Use Continue from the main menu to load saved progress.

## How to Run

1. Download and extract the project folder.
2. Open Godot 4.x.
3. Select Import and choose the `project.godot` file in this folder.
4. Open the project and press F6 or F5 to run it.
5. Reach the green goal to advance to the next level.

## Main Features

- Player movement and projectile shooting
- Two levels with a gradual increase in difficulty
- TileMapLayer based level layouts
- Targets, hazards, goals, and enemy AI
- Idle and move animations
- Shooting particles and screen shake
- HUD, main menu, and sound effects
- Large text accessibility option
- Save and Continue functionality

## Inclusive Design Reflection

I used clear shapes, readable text, and different colors to help players recognize targets, hazards, and goals. The game avoids using harmful stereotypes to represent characters or groups.

## Playtest Notes

- First five-minute peer playtest (Week 5): Complete this after watching someone play without helping. Record one thing they struggled with and the change made.
- Second five-minute peer playtest (Week 7): Complete this after the first polish pass. Record one observation and the improvement made.
- Performance check: Open Godot's Profiler while playing, identify the largest cost, and record one optimization based on what you observe.

## AI Assistance and Assets

- AI-assisted asset prompt: “Create a simple dark sci-fi tile for a friendly 2D puzzle shooter, with clear grid lines and a bright teal and gold center symbol.”
- The SVG asset in `assets/ai_background_tile.svg` is included as an editable art concept. Review and modify it so you can explain the final asset.
- AI-assisted code: the enemy finite state machine and save/load pattern were drafted with assistance and adapted into the project. Read the scripts and make sure you understand the behavior before submitting.
- Sound effects are simple generated tones included in the project; the background sound is generated at runtime.


