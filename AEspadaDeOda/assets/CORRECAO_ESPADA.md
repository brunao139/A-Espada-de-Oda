

## Correção 0.1.1 — golpe forte

Arquivo: `youkai_sword_v2.png`. Seis poses dedicadas, geradas com a ferramenta integrada. O Godot usa recortes individuais com margens, alinhamento dos pés e descarte do halo semitransparente. O rastro ciano é desenhado separadamente por `scripts/sword_trail.gd`, sem depender do tamanho de um quadro.

Prompt inicial:

Edit reference: the attached sprite atlas establishes the exact original gold armored character YOUKAI. Create a NEW dedicated sword-attack animation atlas, replacing only the sword action for this character; do not reproduce the other rows.
Transparent PNG, EXACT 3 columns x 2 rows, 1536x1024 pixels (512x512 each). Exactly six isolated poses ordered left-to-right then top-to-bottom.
Preserve the reference sprite's gold armor, black undersuit, angular black helmet with orange V horns, cyan eyes, proportions, crisp pixel-art clusters, dark outline, shading and right-facing side-on view.
Each cell has EXTENSIVE empty transparent padding: at least 60 pixels on all four sides. Character height roughly 250 pixels. Torso centered x=235 within each cell, feet fixed baseline y=420 within every cell. Same scale in all six. Whole sword must be inside its own cell with at least 60px padding. Never overlap cell boundaries. No labels, no grid, no background, no shadows, no extra parts.
Six coherent poses for one powerful katana cut: 1 draw sword and prepare; 2 raise blade behind/above head; 3 begin overhead cut; 4 cut diagonally forward with blade extending right; 5 low forward follow-through; 6 recover back to upright ready stance. Same katana with pale cyan blade, gold guard, dark grip.
CRITICAL: NO glowing slash trail, NO crescent energy, NO particles or detached effects anywhere. Show only one complete character holding one solid sword in each cell. The cyan energy trail will be drawn separately by the game engine. Never crop any blade or limb. Reuse the identity faithfully; this is a functional production animation sprite sheet with generous transparent gutters.

Refinamento:

Remove background and all glows; enforce transparent padded 3x2 sword atlas, 70px clear margins, standing body 230px, feet y400, center x220.

