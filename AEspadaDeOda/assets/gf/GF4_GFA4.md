# GF4 e GFA4 — chute giratório com salto

Implementação de 29/09/2026, baseada na main `aed3db54bdd005132cfc7490cf883dcd64ec66ed` (cidade simplificada), com integração dos arquivos locais de GFA e normalização de GFF encontrados na pasta de trabalho de 28/09. Essa pasta original foi preservada. Os arquivos foram inicialmente baixados do GitHub por um ZIP identificado pelo commit. Antes do versionamento, o histórico Git foi recuperado e as alterações foram comparadas com a main remota, preservando os arquivos locais.

## Referência pesquisada

- [Manual oficial da SEGA](https://manual.sega.jp/shinobi-art-of-vengeance/en/index.html): combinações de golpes leves/pesados, ataques aéreos, Dive Kick e Ninja Flip.
- [Entrevista Lizardcube/SEGA no PlayStation Blog](https://blog.playstation.com/?p=409075): intenção de criar combate rápido, fluido e com liberdade de encadeamento.
- [Apresentação de combate para PS4/PS5](https://blog.playstation.com/?p=405958): ataques de katana, projéteis, Cannon Punch, Ninpo e execuções.
- [Trailer oficial de combate da SEGA](https://www.youtube.com/watch?v=ahKG2_5QRLw): referência audiovisual para consulta. A pesquisa desta entrega confirmou o material textual; não mediu quadros ou tempos do vídeo.

Aplicação autoral: antecipação curta, rotação corporal desenhada em várias perspectivas, extensão da perna com impacto pontual e recuperação legível. Não se afirma que GF4 corresponde a um comando específico de Shinobi. Tempos, arte e mecânicas abaixo pertencem a A Espada de Oda.

## Jogar

No chão, quatro toques em J/Z encadeiam **GF1 → GF2 → GF3 → GF4**. O novo toque pode ser dado após 45% do golpe atual. Segurar não repete. Pausa de mais de 0,45 s ou troca para espada reinicia a sequência.

GF1 mantém soco + chute; GF2 mantém o giro anterior. Como as duas versões recuperadas não tinham GF3, foi acrescentada uma ligação de soco curto (0,24 s), reutilizando três poses já existentes do GF1. Essa é uma decisão de integração provisória, explícita, sem substituir a arte anterior. Pode ser revista conforme a preferência do autor.

**GF4:** 24 desenhos, 0,80 s, 30 poses/s. Impulso automático após 0,10 s, velocidade vertical inicial -545; física e colisão normais. Salto de aproximadamente 76 unidades na simulação a 60 Hz. Impacto nos quadros 13–15 (índices iniciados em zero), entre 0,4333 e 0,5333 s. Um dano por alvo. Caixa frontal 98×48 centrada em (±74, -106), relativa ao corpo. Tetos antecipam o pouso e encerram o impacto; a recuperação continua. Soltar o botão de pulo não corta esse impulso, e pressioná-lo durante a ação não gera salto duplo.

**GFA4:** substitui as quatro poses antigas por 16 poses aéreas (quadros 4–19 do atlas novo), 0,32 s, 50 poses/s. Impacto nos quadros 9–11, entre 0,180 e 0,240 s; mesma caixa e dano do GF4. Não aplica impulso extra. Mantém limite de quatro ataques por salto e cancelamento ao pousar. Começar o combo tarde ou em salto curto pode cortar a recuperação no chão.

O giro desenhado passa por vistas de costas, perfil e frente; a colisão corporal permanece vertical. A janela de dano é frontal, apenas na extensão final, não uma área circular que machuca atrás. O rastro da espada permanece exclusivo dos golpes fortes.

## Arte

Atlas: `gf4_jump_spin.png`, 1536×1024, RGBA com transparência. GF4 tem 24 poses, contra seis do GF1, oito do GF2 e três reutilizadas no GF3. GFA4 usa o mesmo movimento no ar sem antecipação/pouso terrestre.

`scripts/spin_kick_frames.gd` contém recortes explícitos e pivôs medidos por quadril. A grade nominal 6×4 NÃO deve ser cortada automaticamente: algumas botas e pernas atravessam as divisões nominais. Escala corporal fixa 0,78; apoio dos pés nas poses terrestres e pivô do quadril nas aéreas, sem aumentar/diminuir o corpo em cada quadro. O material existente usa alpha_cutoff 0,10.

Criado pela ferramenta integrada ImageGen, com `assets/gf/gf2_spin_kick.png` como referência de identidade. Não foi utilizado fallback CLI/API. Prompts exatos:

### Geração
Use case: stylized-concept. Production transparent PNG sprite atlas for a 2D action game. Reference image establishes EXACT original character YOUKAI identity and sprite rendering: golden sculpted armor, dark black/navy undersuit, golden helmet with orange V horns and cyan eyes, sheathed katana on back, no skin. Preserve proportions and detailed crisp hand-drawn pixel sprite aesthetic.
Create 24 DISTINCT chronological full-body animation drawings of a jumping spinning heel kick, a fluent martial arts finisher starting on the ground and ending on ground. EXACT GRID 6 columns x 4 rows, 3072x2048 canvas if possible, equal square cells. Each figure entirely within its own cell, generous transparent margins on all sides (at least 45px), no adjacent overlap, no labels, no grid lines, no background, no shadows, no glows. Same body scale in every cell: standing height 340px within 512px cell. Torso horizontal center at x=256. Reference hip at y=285 in every cell so airborne height is animated by game physics, not by moving drawing up across cells.
Read left to right, top to bottom:
1 right-facing guard, 2 knees bend anticipation, 3 deeper loaded crouch arms sweep left, 4 extend off ground lift left knee, 5 airborne chamber both knees, 6 begin rotation to back three-quarter.
7 back three-quarter coiled, 8 full back view turning with right knee folded, 9 back three-quarter other side left leg begins extending, 10 left-facing profile kicking heel sweeps LEFT, 11 front-left three-quarter heel rotates toward camera, 12 front view heel foreshortened toward camera.
13 front-right three-quarter kicking leg opens right, 14 right profile full horizontal LEFT-LEG heel kick to RIGHT with other knee tucked and torso leaning left, 15 slightly higher extended rightward heel, 16 follow-through fully extended rightward heel torso more rotated, 17 heel starts pulling inward, 18 rotating back three-quarter with knee recoiling.
19 tucked airborne recovery facing right, 20 right facing extend downward leg to land, 21 first right foot landing, 22 deep two-leg landing compression, 23 rising from landing, 24 guard right matching first pose.
Strong anatomy, exactly TWO arms TWO legs on each, no swords drawn. Do not just repeat a standing kick: poses 5 through 20 are clearly airborne, free leg TUCKED, no support foot planted. In-between drawings must smoothly articulate hips, shoulders, helmet perspective and limbs through full yaw rotation, not rotate the whole bitmap. Transparent RGBA alpha is essential.

### Transparência
Edit this exact game sprite sheet: remove ONLY the entire brown/olive/gold gradient background and every glow outside the 24 character silhouettes. Output GENUINE TRANSPARENT RGBA alpha, fully transparent pixels between sprites, not black and not painted checkerboard. Preserve ALL 24 poses exactly, preserve their original pixel positions, exact 6 columns x 4 rows layout, 1536x1024 canvas, character size, colors, armor detail, black suit and sheathed swords. Do not redraw or relocate any character, do not add shadows. This is a functional transparent sprite atlas, not a presentation poster. All space outside each outlined character silhouette must have alpha zero.

## Verificação

215 verificações passaram: regressão (34), GFA (54), GFF2 (14), escala da espada (34), beiradas (29), cidade (17) e novos giros (33). Cobertura de entradas reais, sequência, botão segurado, reinício, saltos, teto, dano em alvos físicos, espelhamento e todos os quadros dos novos ataques. A avaliação artística continua aberta ao autor.

Com Godot 4.7.2:
```text
godot --headless --editor --path AEspadaDeOda --import --quit
godot --headless --path AEspadaDeOda --script res://tests/spin_kick_test.gd
godot --path AEspadaDeOda --script res://tools/spin_kick_demo.gd
```

A demonstração usa entradas reais, em velocidade normal e a 45%, e permite captura por `-- --capture-dir=PASTA_EXISTENTE`. A cidade continua com 9.000 unidades, oito plataformas e tráfego apenas ao fundo; abertura, menus e correções locais da espada estão integrados. Ainda não há inimigos no protótipo; os testes criam alvos temporários com `receive_hit`.
