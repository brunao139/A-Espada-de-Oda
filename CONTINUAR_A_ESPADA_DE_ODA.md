# A Espada de Oda — resumo para continuar em outro chat

Atualizado em 28/09/2026. Versão do projeto: **0.1.3**, agora com introdução. Este documento registra o estado do trabalho; confirme os arquivos antes de alterar qualquer coisa.

## GFF-2 frontal — 28/09/2026

- Pedido atual substitui explicitamente o corte ascendente por uma estocada de espada para a frente.
- 16 poses novas em assets/gff/gff2_forward_a.png e gff2_forward_b.png; mais a pose inicial idêntica ao final do GFF-1: 17 quadros em 0,68 s (25 quadros por segundo).
- scripts/gff2_frames.gd define recortes medidos, escala e pivô da bota da frente. As divisões não coincidem com uma grade uniforme; não substituir pelos recortes automáticos antigos.
- Dano entre 0,24 e 0,44 s; caixa frontal 144 × 64, centro (±106, -98). Dano 3, uma vez por alvo. Rastro horizontal acompanha a estocada.
- GFF-1 mantém velocidade 1,2×, final baixo e ligação exata. GF-1/GF-2, dois giros no salto e beiradas permanecem.
- tests/gff2_test.gd cobre alvos reais à frente, atrás e acima, ambos os lados, todos os quadros e término do dano. tools/gff2_demo.tscn demonstra o combo e uma repetição lenta.
- Arte e prompts: assets/gff/GFF2_FRONTAL.md. Atlas ascendente antigo preservado como histórico, sem uso no GFF-2 atual.
- A nova abertura por IA está em espera a pedido do usuário, sem gastos; conservar a abertura anime já integrada.

## Movimento de beirada — 28/09/2026

- Nova mecânica: agarrar quina automaticamente durante a descida do salto, ficar pendurado e subir com Espaço/W/↑. Soltar com S/↓. Se o pulo já estava segurado ao agarrar, é necessário soltar e apertar novamente para subir.
- Funciona nos dois lados de plataformas sólidas estáticas com espaço para o corpo pendurar. Subida dura 0,64 s; a cápsula continua ativa. Verifica topo, espaço para os pés, teto e percurso. Segurar para baixo e um intervalo após soltar evitam reagarrar imediatamente.
- O pulo normal ainda completa dois giros. Golpes ativos não são cancelados por agarrar; enquanto pendurado/subindo não se ataca nem se enfileira combo. As correções de espada e as sequências GF/GFF permanecem.
- scripts/ledge_controller.gd, assets/ledge/youkai_ledge.png (oito poses) e assets/ledge/BEIRADAS.md documentam a implementação e o prompt. youkai.gd contém os pontos de integração; hud.gd mostra as instruções.
- Plataforma TESTE DE BEIRADA adicionada no fim da fase: x=2170–2410, topo y=330. As plataformas originais foram mantidas. Plataformas muito baixas podem não ter espaço para pendurar o corpo; StepTwo e a nova plataforma permitem testar.
- tests/ledge_test.gd: 29 verificações; tests/regression.gd: 34 verificações anteriores. Ambos passaram. tools/ledge_demo.tscn grava uma demonstração com entradas reais.
- Plataformas móveis/inclinadas não são suportadas nesta primeira implementação. Abertura anime e menu permanecem.

## Nova abertura anime — 27/09/2026

- O usuário descartou Runway. A versão atual é um vídeo pré-renderizado de 30 segundos, 1280×720, 30 FPS, com áudio estéreo. Produção local com ilustrações anime, poses de corrida, câmera e efeitos: animação limitada/montagem cinematográfica, não animação integral de estúdio.
- Youkai corre da direita para a esquerda no Japão feudal noturno, atravessa um portal, continua na cidade futurista chuvosa, salta entre prédios em câmera lenta, prepara a espada com aura e desfere um golpe na direção da lente. O clarão revela o título provisório; o logo oficial não foi fornecido.
- scenes/intro.tscn reproduz assets/intro_anime/opening.ogv (Theora/Vorbis), incluído no executável. Sem internet ou player externo. Ao terminar abre scenes/main_menu.tscn.
- Qualquer tecla, botão de controle, clique ou toque pula para o menu, aguardando soltar a entrada. Movimento do mouse, eixo analógico e repetição de tecla não pulam.
- Menu real: START abre movement_lab.tscn; OPTIONS ajusta volume e tela cheia, persistidos em user://settings.cfg; EXIT fecha o jogo.
- Fontes de produção: tools/anime_source.gd/.tscn, tools/compose_anime.py, PNGs e prompts em assets/intro_anime/. Trilha instrumental original programada e renderizada com timbres GeneralUser GS. Licenças da fonte Cinzel e dos timbres incluídas. Procedimento completo: assets/intro_anime/DIRECAO.md.
- A montagem não roda durante o jogo. O executável exclui ferramentas, artes usadas apenas na renderização e a abertura anterior. Os arquivos anteriores permanecem no projeto e no histórico Git.
- Nenhum arquivo de movimento, combate, pulo ou correção da espada foi alterado. A área jogável continua sendo protótipo.
- tests/video_intro_test.gd cobre filme completo, decodificação, menu, START, reinício e pular por teclado/controle/mouse; tests/menu_test.gd verifica opções e EXIT; tests/regression.gd preserva os 34 testes de gameplay. Aprovação artística permanece a cargo do usuário.

## Visão do jogo

Jogo 2D de ação e plataforma inspirado na agilidade dos jogos de ninja clássicos e em Ninja Gaiden Ragebound, baseado no mangá autoral do usuário, A Espada de Oda. Protagonista: Youkai. A aparência atual usa armadura dourada, roupa escura, capacete com hastes em V e olhos ciano. As ilustrações originais do usuário estão na pasta Referencias do pacote; há também uma versão azul/prateada do personagem.

A cidade futurista segue a referência fornecida: lua turquesa, prédios azuis, iluminação ciano e céu violeta. Existe uma área jogável de teste com plataformas, câmera e paralaxe. Ainda não há inimigos, vida, objetivos, áudio de gameplay ou condição de vitória. Não tratar este protótipo como uma fase finalizada.

## Versão e abertura

- Desenvolvido e testado com **Godot 4.7.2 stable**, versão padrão, usando GDScript e renderização Compatibility.
- O projeto editável está em `AEspadaDeOda/project.godot`. Importe esse arquivo no Godot, espere a importação das imagens e pressione F5.
- Cena inicial: `res://scenes/intro.tscn`. Primeira fase: `res://scenes/movement_lab.tscn`.
- O pacote não precisa dos caminhos antigos do computador para executar o jogo. Todos os recursos usados pelo jogo estão dentro da pasta do projeto.
- O antigo `JOGAR.cmd` contém um caminho específico da máquina anterior. Ele foi excluído do pacote de transferência: use o editor e F5.
- A pasta `.godot` é cache: foi excluída e será recriada. Preserve `.uid` e `.import`, que acompanham os arquivos-fonte.
- O executável Windows existente é `AEspadaDeOda-0.1.3.exe`, separado deste pacote. Serve para jogar, mas não substitui os arquivos editáveis.

## Controles

| Tecla | Ação |
|---|---|
| A/D ou setas esquerda/direita | Correr |
| Espaço, W ou seta para cima | Pular; segurar aumenta a altura, soltar cedo encurta |
| Espaço, W ou ↑ na beirada | Subir; solte o pulo anterior e aperte novamente |
| S ou ↓ | Soltar a beirada; segurar impede agarrar |
| J ou Z | GF-1; novo toque emenda GF-2 |
| K ou X | GFF-1; novo toque emenda GFF-2 |
| R | Reiniciar o trecho |
| F1 | Mostrar colisão e alcance dos golpes |

## Últimos pedidos e implementação

O usuário pediu mais agilidade e movimentos naturais. A versão 0.1.3 implementa:

1. **Pulo:** dois giros no ar, mantendo a física, altura e tempo de voo. Rotação ao redor do centro do corpo recolhido; colisão permanece vertical. Adaptação ao salto curto e restauração da orientação no pouso. Ataques aéreos interrompem o giro e orientam o personagem.
2. **GF-1:** sequência já existente de soco e chute de kung-fu. Um toque executa os dois movimentos, com duas janelas distintas de impacto.
3. **GF-2:** oito poses novas para chute giratório com a perna esquerda, apoio da direita, rotação com vista de costas, extensão, recolhimento e retorno à guarda. Vem após GF-1.
4. **GFF-1:** corte de cima para baixo acelerado exatamente 1,2×. Duração de 0,56 / 1,2 segundos. Termina na pose baixa e pode mantê-la por até 0,5 segundo, parado, aguardando continuação.
5. **GFF-2:** estocada frontal com 16 poses novas de preparação, extensão e recuperação (atualização de 28/09). A primeira pose usa exatamente a mesma textura e posição final de GFF-1, para continuidade.

Um segundo toque do mesmo tipo de ataque, após aproximadamente 45% do primeiro movimento, pode ficar na fila e emendar o segundo. Segurar o botão não repete automaticamente. Pausa ou troca de tipo reinicia a sequência. No chão, ataques desaceleram o personagem. Durante os cortes de espada não se inicia outro salto.

O usuário ainda deve avaliar o resultado visual e indicar o próximo ajuste. Não assumir aprovação artística definitiva apenas porque os testes passaram.

## Estrutura

- `scenes/youkai.tscn`: personagem CharacterBody2D, colisão, visual e área ofensiva.
- `scenes/movement_lab.tscn`: área de teste, plataformas, câmera, fundo e interface.
- `scripts/youkai.gd`: movimento, construção das animações, recortes, combos e janelas de impacto.
- `scripts/sword_trail.gd`: efeito separado do rastro da espada.
- `scripts/sword_sprite.gdshader`: tratamento de transparência das artes de ataque.
- `scripts/lab.gd`: câmera, reinício e desenho das passarelas.
- `scripts/city_backdrop.gd`: cidade e paralaxe.
- `scripts/hud.gd`: controles e indicação de GF/GFF.
- `assets/youkai_atlas.png`: locomoção e GF-1.
- `assets/youkai_sword_v2.png`: corte descendente.
- `assets/gf/gf2_spin_kick.png`: novas poses do chute giratório.
- `assets/gff/gff2_rising_cut.png`: atlas ascendente anterior; substituído por gff2_forward_a.png e gff2_forward_b.png.
- `assets/cidade_futurista.png`: fundo da cidade.
- `assets/ANIMACOES_013.md`, `DIRECAO_DE_ARTE.md` e `CORRECAO_ESPADA.md`: decisões de arte, prompts e correções anteriores.
- `tests/regression.gd` e `tests/smoke_test.gd`: verificações automáticas.
- `export_presets.cfg`: exportação Windows x86_64 com recursos embutidos no executável.

## Cuidados para não reintroduzir bugs

- Houve um bug no golpe forte: efeito cortado e fragmento de outro quadro. Foram utilizados sprites dedicados, margens de recorte e rastro separado. Não voltar ao recorte ingênuo de uma grade uniforme.
- As artes de GF-2 e GFF-2 têm margens personalizadas e alinhamento por quadro. O GFF-2 frontal tem recortes explícitos em gff2_frames.gd para preservar espada e evitar fragmentos vizinhos.
- O material das novas poses usa limiar de transparência 0,10 para preservar a lâmina ciano semitransparente. O material antigo usa 0,80. Aumentar indiscriminadamente esse limiar pode amputar a espada.
- Manter a conexão exata entre a última pose de GFF-1 e a primeira de GFF-2. O novo golpe frontal usa arte própria, não quadros invertidos do descendente.
- Sincronizar janela de dano, rastro e animação quando mudar a velocidade de um ataque.
- Rotacionar o visual no pulo, não a colisão do personagem.

## Base para inimigos futuros

Mundo na camada 1; personagem na camada 2; alvos futuros na camada 3, valor de máscara 4. O método esperado no alvo é `receive_hit(damage, direction)`. Golpes fracos causam 1 por impacto; espada causa 3. Um alvo só é atingido uma vez por janela; GF-1 tem duas janelas independentes.

## Verificação e exportação

A versão foi validada com execução gráfica e 34 verificações automáticas de movimento, colisão, recortes e combos. Para repetir depois da importação:

```text
godot --headless --path <pasta-AEspadaDeOda> --script res://tests/smoke_test.gd
godot --headless --path <pasta-AEspadaDeOda> --script res://tests/ledge_test.gd
godot --path <pasta-AEspadaDeOda> --script res://tests/intro_test.gd
godot --path <pasta-AEspadaDeOda> --script res://tests/menu_test.gd
```

Aqui `godot` representa o executável do Godot instalado no novo computador. Para importar pela linha de comando:

```text
godot --headless --editor --path <pasta-AEspadaDeOda> --import --quit
```

Para gerar outro executável, instale os modelos de exportação correspondentes à versão do Godot e use o preset Windows Desktop. Escolha uma pasta de saída existente. Os modelos de exportação e o próprio editor não fazem parte do pacote.

## Continuidade no novo chat

Abra a pasta extraída no Codex para permitir trabalho direto nos arquivos locais. Em um chat comum do ChatGPT, anexe este resumo e os arquivos necessários; escrever um caminho do seu computador não concede acesso a ele. Não conte com a recuperação automática de todos os detalhes de conversas anteriores.

O pacote é uma fotografia da versão 0.1.3, não sincroniza alterações futuras. Ao terminar uma sessão, atualize o resumo e copie o projeto atualizado antes de trocar de máquina. Evite editar duas cópias diferentes ao mesmo tempo.
