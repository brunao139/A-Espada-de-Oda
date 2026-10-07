# GFA — golpes fracos no ar

**Atualização 29/09:** GFA4 foi substituído por 16 poses, 0,32 s, impacto 0,18–0,24 s, caixa 98×48 centrada em (±74,-106). O atlas anterior continua sendo usado por GFA1–3. Para detalhes atuais e novos prompts, consultar ../gf/GF4_GFA4.md. Os parâmetros antigos de GFA4 abaixo são apenas histórico.

GFA1: soco direto. GFA2: chute giratório. GFA3: soco cruzado. GFA4: chute giratório de finalização.

Pule e dê novos toques em J ou Z. A partir de 45% de cada movimento, um novo toque fica na fila para emendar o próximo. Segurar não repete. As quatro etapas duram 0,18 / 0,24 / 0,18 / 0,28 segundos. Uma pausa maior que 0,22 s após o término reinicia a sequência no GFA1, sem renovar o limite de quatro golpes por salto. O pouso cancela o ataque aéreo e sua fila, reinicia o limite e restaura o combo terrestre.

A gravidade da subida permanece normal. Durante a descida, somente enquanto GFA está ativo, usa-se 35% da gravidade para permitir a sequência. Não há impulso ascendente nem renovação infinita da suspensão. Salto curto ou ataque iniciado tarde pode não permitir os quatro golpes antes do chão.

Cada golpe causa 1 de dano por alvo durante a terceira pose (índice 2). Socos: janela 0,09–0,135 s, caixa 60×38, centro (±64, -117). Chutes: janelas 0,12–0,18 / 0,14–0,21 s, caixa 90×46, centro (±73, -101). Colisão do corpo não gira. Direção é travada durante cada ação. A espada permanece embainhada na nova arte.

`gfa_combo.png`: 1536×1024, RGBA com transparência real, quatro linhas de quatro poses, células de 384×256. Escala 0,65; pivô visual (10, -93), sem alinhamento variável pelos pés recolhidos. Usa o material existente com alpha_cutoff 0,10. As artes de chão foram preservadas.

GFFA é o nome reservado para golpes fortes aéreos. Esta entrega implementa somente a sequência GFA solicitada; K/X conserva o comportamento anterior enquanto GFFA não recebe sua sequência própria.

## Verificação

`godot --headless --path AEspadaDeOda --script res://tests/gfa_test.gd`

Os testes usam entradas de jogo, colisões reais, alvos à frente/atrás/abaixo e ambos os sentidos. Cobrem sequência completa, quinto toque, altura do salto, gravidade, pouso, pausa, botão segurado e restauração de GF-1. Regressão, GFF-2 e beiradas também foram verificados.

`godot --path AEspadaDeOda --script res://tools/gfa_demo.gd`

Mostra o combo em câmera lenta com entradas reais. Para salvar os quatro impactos, acrescente `-- --capture-dir=CAMINHO_ABSOLUTO_EXISTENTE`. O script encerra após a demonstração.

## Arte e prompts

Gerada com a ferramenta integrada ImageGen, usando `assets/gf/gf2_spin_kick.png` como referência de identidade e estilo. Não foi usada API paga por chave nem o fallback CLI. A aprovação artística final cabe ao autor.

Prompt de geração:

> Use case: stylized-concept. Create a production game sprite atlas for this EXACT golden armored ninja Youkai from the reference (reference only, do not modify existing atlas). Transparent RGBA background, no text, no grids. 1536x1024 canvas, exactly 4 columns and 4 rows, 16 separate full body poses, each entirely inside its equal 384x256 cell with generous 20px transparent gutters. Same character size in all cells, torso centered within cell, facing right except mid-spin back views. Gold armor, black undersuit, orange V helmet horns, cyan eyes, sheathed katana on back throughout. Match detailed crisp 2D sprite style of reference. ALL poses AIRBORNE, knees bent and feet lifted, no ground contact or shadows. Each row is a different four-frame attack. Row 1 GFA1 aerial straight punch: tucked guard, extend lead fist to right, full punch impact right, retract fist. Row 2 GFA2 aerial roundhouse kick: coil both knees, turn showing back, extend one leg horizontally to RIGHT with other knee folded, retract to airborne guard. Row 3 GFA3 aerial cross punch: wind up rear shoulder, twist torso, rear fist fully extended RIGHT in cross punch, recover knees tucked. Row 4 GFA4 airborne spinning heel kick finisher: tight tucked spin preparation, back view mid turn, long straight heel kick to RIGHT with torso leaning left and other leg bent, recover airborne guard. Clear distinct dynamic anatomy. Exactly one character per cell, all limbs and horns fully inside each cell. No sword drawing, no energy effects, no motion streaks, no background.

Prompt de acabamento (versão integrada):

> Edit this exact sprite sheet. Remove ONLY all black/brown/golden background glow, replace background with genuine fully transparent alpha (RGBA). Preserve every one of the 16 character poses, its pixel position, size, colors, golden armor, black clothing, sheathed sword, exact 4x4 grid composition and canvas 1536x1024. No shadows or glows outside sprites. This is a game atlas requiring isolated sprites, not a presentation illustration. Background must be transparent, not black or checkerboard painted pixels.
