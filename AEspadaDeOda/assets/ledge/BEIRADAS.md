# Beiradas — 28/09/2026

Youkai agarra automaticamente uma quina à sua frente durante a descida do salto. É preciso estar no ar, com as mãos próximas do topo e espaço para o corpo ficar pendurado. A corrida e a subida inicial do salto não são interrompidas. Funciona nos dois lados de plataformas sólidas estáticas, inclusive na passarela fina StepTwo.

- Espaço, W ou ↑: subir após agarrar. Se o botão já estava segurado no salto, solte e aperte novamente.
- S ou ↓: soltar; há um intervalo de 0,32 s antes de poder agarrar novamente. Manter para baixo impede agarrar.
- Ataques ficam indisponíveis enquanto pendurado/subindo e não entram na fila. Um golpe que já estava ativo não é cancelado para agarrar.

A subida leva 0,64 s. O controlador verifica apoio, espaço para os pés, corpo e percurso antes e durante o movimento. A cápsula de colisão permanece ativa. Tetos impedem a subida; se o apoio desaparecer, mover ou surgir uma obstrução durante a subida, o personagem é solto. Plataformas móveis e superfícies inclinadas não fazem parte desta implementação.

Agarres muito baixos, sem espaço entre a plataforma e o chão para pendurar o corpo, são rejeitados. As plataformas originais foram preservadas. Uma plataforma sólida sinalizada como TESTE DE BEIRADA foi adicionada no fim do trecho, entre x=2170 e x=2410, topo y=330, para demonstrar a mecânica com um salto a partir do chão.

## Implementação

- scripts/ledge_controller.gd: detecção por raios de topo/lateral, varredura da altura das mãos, estados hang/climb, subida em dois trechos com colisão, pivôs de animação.
- scripts/youkai.gd: pontos de integração no ciclo de física, bloqueio de ataque ao pendurar e indicação de estado. Física do salto, giros, duração/janelas dos golpes e recortes anteriores foram preservados.
- assets/ledge/youkai_ledge.png: oito poses originais, grade 4×2. Frames 0–1 pendurados, 2–5 puxada, 6 agachado, 7 em pé. Recorte e alinhamento das mãos feitos no Godot, usando limiar alfa 0,10 somente neste atlas.
- scripts/hud.gd: comandos contextuais ao pendurar.
- tests/ledge_test.gd: 29 verificações de física/entrada, ambos os lados, contato, queda rápida, ataque, tetos, obstáculos, perda do apoio e percurso real desde o chão.
- tests/regression.gd: os 34 testes anteriores de movimento, combos e espada.
- tools/ledge_demo.tscn: demonstração por entradas reais, com posicionamento inicial definido. Não altera a posição do personagem durante a execução.

## Verificação

Execute no Godot 4.7.2 após importar o projeto:

    godot --headless --path AEspadaDeOda --script res://tests/ledge_test.gd
    godot --headless --path AEspadaDeOda --script res://tests/regression.gd

Para gerar o vídeo de demonstração:

    godot --path AEspadaDeOda res://tools/ledge_demo.tscn --write-movie ledge-demo.avi --fixed-fps 30 --quit-after 180 --disable-vsync --audio-driver Dummy

## Arte

Atlas produzido com a ferramenta integrada de geração de imagens, usando assets/youkai_atlas.png como referência de identidade e estilo. A folha original não foi modificada. Prompt:

Create a production sprite sheet for this exact gold-armored Youkai ninja character from the reference gameplay atlas. This is a NEW companion asset, do not alter the supplied atlas. Match the existing small 2D hand-pixel/detailed retro videogame sprite style, squat athletic body, orange V helmet crest, cyan eyes, dark undersuit, golden armor, sword safely sheathed on back. Exactly 8 full-body poses in a strict evenly spaced grid 4 columns x 2 rows. All face RIGHT, strict side profile facing an invisible wall to their right. Transparent background, NO platform or scenery, NO floor, NO lines, labels or numbers. Generous transparent gutters, no overlapping cells or cropped hands/feet/sword. Each cell same dimensions and character scale. Sequence row-major: 1) hanging still by BOTH hands, arms extended above head and FORWARD to right, fingers curled over an invisible ledge, torso and both legs dangling below and left of hands, knees slightly bent, head below hands; 2) same hanging pose slight leg sway; 3) beginning pull-up, elbows bending and chest rises toward hands; 4) chin/chest above fixed gripping hands, elbows deeply bent; 5) mantle, shoulders over palms, left knee brought up toward ledge level; 6) one knee planted on invisible top, crouched pushing torso forward and up; 7) low crouch safely atop invisible platform, both feet on same baseline, hands releasing; 8) standing ready at same proportions as reference idle. Hands should clearly reach forward right and stay in contact during poses 1-6. No weapon drawn, no effects. Clear readable black outline, gold highlights, consistent anatomy exactly two arms two legs. Use most of each cell while preserving gutters. Needed for a platformer ledge grab and climb animation. Wide landscape sheet.
