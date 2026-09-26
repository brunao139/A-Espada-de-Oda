# Direção de arte e geração dos recursos

Os dois PNGs foram criados com a ferramenta integrada de geração de imagens, usando as referências enviadas nesta conversa. Os arquivos originais do usuário não foram alterados.

## Youkai

Arquivo: `youkai_atlas.png`. Atlas com transparência, 6 colunas × 5 linhas, 30 poses. Referências: `A ESPADA DE ODA_001.png`, `YOUKAI MANBRA BEAT 1.png` e `YOUKAI.png`. A versão dourada foi adotada como visual inicial. A animação é uma primeira adaptação para jogo; os quadros podem receber refinamento artístico posterior.

Prompt utilizado:

Use case: stylized-concept. Asset type: production 2D game sprite animation atlas.
Create ONE transparent PNG sprite sheet for the original manga protagonist YOUKAI, based on the three provided reference images. References 2 and 3 establish the GOLD armor palette, reference 1 supports armor structure. Faithfully preserve his black undersuit, sculpted gold armor, gold shin/forearm guards, black domed helmet, long orange-gold V-shaped antenna horns, dark full face mask and cyan glowing eyes. Athletic adult male tokusatsu armored swordsman, no skin. Gold tsuba, pale cyan katana blade.
EXACT GRID: 6 equal columns by 5 equal rows, landscape 1536x1280 pixels. Every cell 256x256. Exactly 30 full-body poses, one per cell. All face RIGHT, fixed side-view camera, consistent scale, head-to-foot standing body height about 160px, feet baseline y=226 within each cell. Whole body and sword always within its cell with 12px empty margins, NO overlap between cells. Center torso horizontally at x=112 in every cell. Transparent empty background alpha, no floor, no cast shadows, NO labels, text, grid lines, checkerboard, border, logo.
Style: beautiful polished hand-pixeled 2D action game sprite art, crisp pixel clusters, strong dark outlines and gold highlights, limited colors, readable anatomy. Not a photo, not a 3D render. Character should have real articulated expressive movement.
ROW 1: six-frame breathing idle loop, martial arts ready stance, sword sheathed on back, minimal rhythmic torso/arm motion.
ROW 2: six-frame RUN cycle: extended stride, contact, compressed passing, opposite extended stride, opposite contact, passing. Strong alternating legs and arm pump, forward lean, sheathed sword.
ROW 3: six jump states left to right: anticipation crouch, takeoff extending legs, rising with tucked knees, apex tucked legs, falling extending legs, landing compression.
ROW 4: six martial arts combo poses: fist wind-up, straight punch full extension, punch retract, high kick wind-up, high side kick full extension, kick recovery. Sword remains sheathed, empty fists for kung-fu.
ROW 5: six POWERFUL KATANA ATTACK poses: draw and windup, blade raised behind head, overhead strike begins, full diagonal forward cut with elegant cyan crescent slash, low blade follow-through, return toward guard. Blade is clearly visible, no extra swords. Every frame full body; preserve identity and fixed registration across all 30 cells.
This is a functional animation atlas to slice into 30 uniform cells, NOT a poster or character collage.

## Cidade

Arquivo: `cidade_futurista.png`. Fundo panorâmico inspirado na imagem `a299a124aedcc7a7c4f0c06ba9d478f6.jpg`. As silhuetas intermediárias e plataformas são desenhadas pelo Godot em camadas separadas.

Prompt utilizado:

Use case: stylized-concept. Asset type: background layer for a 2D side-scrolling action game, A Espada de Oda. Use the supplied image only as visual reference for palette, atmospheric city towers, luminous cyan moon and cyberpunk mood.
Generate a beautiful LANDSCAPE 16:9 wide composition, 1792x1024 or similar. Futuristic Japanese-inspired megacity high above ground at twilight. Tall slender blue and teal skyscrapers, antennae, layered silhouettes in cyan atmospheric haze, tiny cyan horizontal window lights and a few violet lights, huge softly glowing turquoise moon toward upper right, sky lavender at top fading blue cyan below. Dark navy tall buildings framing left and right edges with more open atmospheric center. Restrained polished pixel-art painted background for a modern 2D action platformer, carefully grouped colors and architectural silhouettes, crisp details with soft distance haze. Wide side-on view, sense of huge vertical scale. IMPORTANT: entire image is distant background; NO playable floor, NO foreground railing, NO bridge or platform across the bottom, NO characters, NO text or logos. Lower quarter has distant tower bases with teal mist and dark blue shapes; leave room visually for a separately rendered dark foreground platform. The character will be a small golden armored swordsman and must read clearly against the desaturated middle-distance blue buildings. No dominant gold/orange. No interface. No transparent background.

