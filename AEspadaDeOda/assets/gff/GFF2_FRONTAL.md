# GFF-2 frontal — 28/09/2026

Substitui o corte ascendente pelo ataque com a katana projetada para a frente, conforme pedido do autor.

- 16 desenhos novos, distribuídos em gff2_forward_a.png (preparação/extensão) e gff2_forward_b.png (impacto/recuperação).
- Primeiro quadro reaproveita exatamente a textura, material, escala e posição do final de GFF-1: total de 17 quadros.
- Duração 0,68 s; avanço de quadros a 25 por segundo. Antes eram oito poses novas mais ligação em 0,58 s.
- Janela de dano: 0,24–0,44 s. Caixa 144 × 64 em (±106, -98), dano 3 por alvo, um impacto por execução.
- Rastro frontal separado do atlas. Sua ponta acompanha a coordenada da lâmina medida em cada desenho, com espelhamento automático pelo nó Visual.
- GFF-1 continua a 1,2× e mantém a pose baixa durante a janela de combo. GF-1/GF-2, pulo com dois giros e beiradas não mudaram.

## Arte e recortes
Ferramenta integrada de geração de imagens, sem OpenArt e sem créditos externos.
Referências: atlas originais de locomoção e espada do jogo. Dois estudos em grade 4 × 4 foram descartados por falta de espaço entre as lâminas; os PNGs finais usam duas colunas e quatro linhas, com divisões e pivôs explícitos em scripts/gff2_frames.gd.
A grade nominal não deve ser usada automaticamente: o corte entre colunas foi medido para não capturar uma lâmina vizinha. Material mantém alpha_cutoff 0,10, preservando o ciano da espada.
As imagens geradas não foram retocadas por código; as coordenadas de recorte, bota e ponta foram medidas e aplicadas pelo Godot.
O atlas ascendente antigo permanece como fonte histórica, excluído do novo executável.

## Validação
34 verificações de regressão, 29 de beiradas e 12 de GFF-2 frontal passaram.
O teste frontal usa alvos físicos em ambos os sentidos, à frente, atrás e acima; confere dano único, quadros completos e fim do ataque.
Revisão visual com tools/gff2_contact_sheet.gd e demonstração de entradas reais em tools/gff2_demo.tscn.
A demonstração inclui velocidade normal em ambos os sentidos e uma repetição a 40% da velocidade. O jogo permanece na velocidade normal.

## Prompt da primeira metade

Create a NEW clean game sprite atlas, TRANSPARENT BACKGROUND. EXACTLY TWO columns by FOUR rows, eight poses total. Portrait canvas1024x2048, each cell512x512. Use supplied reference for Youkai design and pixel style only; DO NOT retain its4x4 layout.
Every pose must be SMALL in its cell: full character AND sword combined width at most330px, height240px. 85px empty transparent gap at left and right of EVERY cell; 100px top gap, feet at y400. All sword tips completely visible. NO glow, NO particles, NO labels or grid. Hard clean alpha silhouette. Only ONE cyan-edged katana, entire blade and helmet and feet visible.
Gold armored samurai, dark undersuit, orange V helmet, cyan eyes. Same original stocky pixel proportions. Facing SCREEN RIGHT in all poses, fixed three-quarter side view. Full body on every frame.
This is FIRST HALF of a continuous forward sword thrust, eight successive poses in row-major reading order:
1 very low deep lunge with both hands extended low and blade pointing down-right20degrees, matching first pose of reference.
2 elbows begin bending, lift sword point slightly, hips still low.
3 elbows draw back, katana nearly horizontal right at waist.
4 hands near waist, knees flexed, load thrust, blade horizontal.
5 push from rear leg, both hands drive a little forward, blade horizontal pointing RIGHT.
6 arms extend25percent, shoulders and torso lean forward-right.
7 arms extend50percent, front knee bends, sword thrust aims directly right at enemy torso.
8 arms extend75percent, strong forward lean, back leg pushing.
Natural believable anatomy, consistent body scale, same feet baseline. Do not make a rising cut or swing overhead. The sword thrust points right horizontally. Clean unconnected eight figures surrounded by LOTS of transparent air.

## Prompt da segunda metade

Create the SECOND HALF of this pixel-art game sword-thrust animation. Use image1 for exact gold Youkai character, pixel style and scale; use image2 only as reference for movement recovery ideas. Output exactly TWO COLUMNS by FOUR ROWS: 8 full-body right-facing poses on real transparent alpha. Portrait1024x2048,512x512cells. Maintain generous empty space between ALL poses, especially swordtips: combined character+sword MAXIMUM WIDTH330px inside each512pxcell. Feet baseliney415, no part within60pxofanyedge. Both hands on ONE katana, black scabbard on back, gold armor, black undersuit, orangeVhelmet, cyaneyes. Short cyan katana remains completely visible and always right ofbody. No background, groundshadow, grid, text, particles, haze or swordtrail.
These are frames9..16 of ONE FORWARD HORIZONTAL THRUST at enemy chest, row-major:
9 maximum extension continuing image1 bottom-right pose: low forward lunge, arms extended firmly toward screenRIGHT, katana straight horizontal right; head and shoulders lean into thrust.
10 settle into full extension, slight weight shift forward, head2pixelslower, both feetgrounded.
11 beginretraction, elbows bend a little, hilt moves back toward chest while blade stays horizontalright.
12 retract halfway, torso begins to rise, forwardknee lessbent, katana horizontalright.
13 finishretraction, handleclose to waist, uprightshoulders, blade only10degreesdownright.
14 handsrelaxnearwaist, feetsettle, blade20degreesdownright.
15 returnright-facingreadyguard, kneesstillsoft, armslower, sword25degreesdownright.
16 stableoriginalright-facingguard, samegoldhero, quietneutralstance, handsholdkatanaatwaistblade25degreesdownright.
Eight truly distinct poses with gradual changes. Do not reproduce FIRST HALF positions. Match original pixelgame bodyproportions, size, palette, and samefaceorientation throughout. Do NOT rotate camera, blade upward or attack left. Clean complete sprites ready for atlas cropping, fully transparent EMPTY gutters.
