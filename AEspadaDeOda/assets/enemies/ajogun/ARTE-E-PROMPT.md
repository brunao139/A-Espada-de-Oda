# Ajogun — caminhada, versão visual 1

Oito poses de caminhada para avaliação do autor. Arte gerada pela ferramenta integrada ImageGen; referência de identidade fornecida pelo autor e referência de estilo do atlas GF2 do Youkai. Arquivo: ajogun-caminhada-v1.png. Esta é uma proposta de sprites, ainda sem integração de inimigo, IA ou colisões no jogo. Os recortes e pivôs deverão ser medidos antes da integração; não assumir divisões de grade exatas.

## Prompt de geração

Use case: stylized-concept. Create a production sprite sheet of AJOGUN walking for the 2D side-scrolling action game A Espada de Oda.
REFERENCE 1 defines AJOGUN's identity. Faithfully adapt the tall lean muscular ash-gray demon, striated silver-gray skin, sinister narrow toothy face, enormous dark charcoal/violet ram horns curling down and forward, pointed ears, elongated clawed hands and clawed bare feet. Preserve dark brown/maroon sash with long torn trailing fabric, loose dark gray harem pants, subtle dull gold ankle bands. Both horns belong to the same head; silhouette must be readable in side view. No armor, no weapons, no new anatomy. Golden thin magic wrist rings can be subtle small accents that stay close to hands, no large orbiting effects.
REFERENCE 2 is ONLY the rendering style reference for the existing game's character sprites: crisp detailed 2D hand-drawn pixel-art-influenced game sprites, dark clean outline, sculptural limited-color shading and readable silhouette. Do NOT transfer gold armor, helmet, sword or hero identity to Ajogun.
Deliver ONE transparent RGBA PNG atlas, 1536x1024, exactly FOUR columns by TWO rows, EIGHT distinct full-body poses. Equal 384x512 cells. Every sprite entirely inside its cell, transparent margin minimum 35px including all horns, claws, cloth. Same model proportions and scale in all frames, height from highest horn to floor about 390px. Fixed feet ground baseline at local y=465, pelvis roughly x=192. Fixed side-on camera, Ajogun faces and walks RIGHT in ALL frames, in-place animation suitable for slicing. Show a slow predatory deliberate WALK, NOT running, floating or attacking: slight forward lean, bent elbows, hands hanging threateningly with relaxed claws, restrained counter-swing of arms, subtle vertical body bob, trailing sash sways continuously. One foot always supports weight.
Eight evenly spaced chronological gait phases, read left to right top to bottom:
1 left foot forward heel contact, right foot behind toe contact;
2 down/recoil weight over forward left foot, knees bend;
3 left leg supports, right foot passes under hips raised off floor;
4 up/high point on left support, right knee swings forward;
5 right foot forward heel contact, left foot behind toe contact;
6 down/recoil weight over forward right foot;
7 right leg supports, left foot passes under hips raised;
8 up/high point on right support, left knee advances to loop seamlessly into frame1.
Clearly distinct alternating legs and opposite arm swings. Preserve consistent horn shape, face, pants and sash across all eight. Frame8 must connect to frame1, not duplicate it.
Background entirely alpha zero; no scenery, cast shadows, graphic symbols, lettering, numbers, cell borders, gradients, painted checkerboard, or watermark. No title or the word from the reference. This is a game animation atlas, not an illustration collage.
