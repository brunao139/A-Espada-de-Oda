# Animações 0.1.3 — GF e GFF

Os novos PNGs foram criados com a ferramenta integrada de geração de imagens, usando os atlas anteriores de Youkai como referência. Os recortes, pivôs, escala e limiares de transparência foram revisados no Godot.

- GF-1: soco + chute, quadros da quarta linha de `youkai_atlas.png`.
- GF-2: oito poses novas em `gf/gf2_spin_kick.png`, com preparação, giro pelo apoio direito, chute com a perna esquerda, recolhimento e retorno à guarda.
- GFF-1: `youkai_sword_v2.png`, velocidade 1,2×. A pose final é a guarda baixa, mantida durante a janela de continuação.
- GFF-2: uma pose de ligação idêntica ao final de GFF-1 + oito poses novas em `gff/gff2_rising_cut.png`, com giro do punho, carregamento baixo, corte diagonal ascendente e recuperação. Não reutiliza o corte descendente ao contrário.
- Salto: dois giros completos em torno do centro do corpo; física, altura e duração do salto preservadas.

## Prompt GF-2

Use case: stylized-concept. Asset type: game animation sheet for GF-2, left-leg spinning kick. Reference image identifies YOUKAI's exact gold armor, black undersuit, orange V-horn helmet, cyan eyes and pixel art.
Generate 8 NEW full-body animation drawings in EXACTLY 4 columns x 2 rows, 2048x1024 image. Each cell 512x512. Real transparent alpha background. No opaque background, no glow, no shadow, no particles, no trails, no text or grid. Within EVERY cell leave at least 75 pixels fully empty around every body part. Same character body height about 240 pixels, torso center at x=240, feet baseline y=410. All art safely inside cell. Whole figure visible.
Animate a NATURAL 360-degree standing spinning LEFT LEG martial arts kick, aimed to screen-right. Katana stays SHEATHED throughout, empty hands. RIGHT foot is the support/pivot, LEFT leg is the attacking leg. These are anatomical views changing as the whole torso rotates, not a flat sprite rotated on screen.
Ordered frames:
1 ready guard facing right, both feet grounded, hands up.
2 shift weight to RIGHT foot, left knee chambers, shoulders start turning away.
3 rear three-quarter view during pivot on right foot, left leg bent ready to swing.
4 clear BACK view, shoulders and hips rotating together, LEFT knee raised, right leg supports body.
5 rear-side three-quarter turning toward right, LEFT leg extends in a sweeping roundhouse.
6 full left-leg roundhouse kick toward screen-right, hip rotated through, right foot supporting, arms counterbalance.
7 finish body rotation back toward original right-facing guard, retract left knee.
8 place left foot down, return EXACT same ready guard and feet position as frame 1.
Maintain believable limb continuity, one head, two arms, two legs. Dark crisp pixel outlines and strong clustered gold highlights matching reference. No sword drawn, no energy. The differences between frames 2-7 MUST show actual body rotation with back and profile views. This is a technical animation atlas, NOT a collection of repeated front-facing side kicks.

## Prompt GFF-2

Use case: stylized-concept. Asset type: GFF-2 original rising katana cut animation atlas for YOUKAI. Match gold armored character, black undersuit, orange V horns, cyan eyes, crisp pixel art in reference.
Create 8 NEW distinct full-body poses, exact 4 columns x 2 rows, 2048x1024 pixels, cells512x512. Real transparent alpha, absolutely NO background, NO lighting halo, NO shadow, NO energy trail/particles, NO labels/grid. Each figure height around240px. Feet baseline y410 within EACH cell, torso center x220. At least60px fully empty transparent space between every pose and every edge. Entire sword must fit inside its own cell.
The move is a NATURAL reverse-grip-angle adjustment followed by a rising DIAGONAL CUT, low screen-right to high screen-right, using the SHARP EDGE leading upward, NOT striking with the blunt spine. Keep both hands on handle; katana has a visible bright cyan sharpened bevel edge and dark blue blunt spine. ROTATE THE WRISTS/forearms to turn the blade about its long axis during the windup before cutting upward. Do NOT merely play an overhead downward strike backwards.
Frame order:
1 Start from the LOW finishing position of a previous downward cut: deep forward lunge toward right, sword extended low-right with point slightly downward, both hands low in front of hips. This matches reference sheet bottom-middle stance.
2 Same feet and hips, elbows draw hilt toward low right hip; wrists begin rolling the grip so the blade turns edge-up. Blade stays low.
3 Load reverse cut: knees flex, shoulders coil left/back, hands low beside hip, sword tip points diagonally DOWN-RIGHT, bright cutting bevel now faces UP, dark blunt spine faces down.
4 Initiate rising cut: extend knees and hips, rotate torso toward right, hands rise from hip, blade travels through low-right 20-degree angle, sharp edge leads upward.
5 Mid-swing rising diagonal slash: arms project forward-right at chest height, sword tip rises diagonally upper-right, hips unwind, edge leading UP.
6 Finish rising stroke: hands above right shoulder, sword almost vertical extending upper-right above head, torso upright, body has followed through naturally.
7 Controlled recovery: wrists settle, elbows lower, blade returns to right-side ready position while feet return toward guard.
8 Stable original ready sword guard, right-facing, feet planted.
Keep footing and proportions consistent, same ONE sword, blade never passes through torso. Hand/wrist roll and blade edge reversal must be clearly visible in frames 2 and3. These need NEW bridging poses, especially LOW loaded posture, diagonal mid-swing, and HIGH follow-through. Do not repeat six poses from reference. Keep strong readable pixel silhouette and full sword with generous padding.

