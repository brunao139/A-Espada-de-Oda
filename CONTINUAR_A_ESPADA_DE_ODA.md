# A Espada de Oda — resumo para continuar em outro chat

Atualizado em 26/09/2026. Versão do projeto: **0.1.3**, agora com introdução. Este documento registra o estado do trabalho; confirme os arquivos antes de alterar qualquer coisa.

## Nova introdução — 26/09/2026

- Repositório: https://github.com/brunao139/A-Espada-de-Oda. Use a cópia Git atualizada para continuar; o pacote ZIP original de transferência é anterior à introdução.
- O usuário esclareceu que a abertura deve ser um **vídeo pré-renderizado dentro do executável**, não uma animação em tempo real. `scenes/intro.tscn` reproduz `assets/intro/intro.ogv` com VideoStreamPlayer. O arquivo tem 13 segundos, 1280×720, 30 FPS, sem áudio. Não necessita internet, arquivo externo ou player instalado.
- No vídeo, Youkai corre da direita para a esquerda no Japão, um clarão ciano cobre a troca para o futuro, ele continua no mesmo sentido e salta da borda esquerda de um prédio. O título provisório aparece com a frase “Aperte qualquer botão para iniciar”. No fim, `title_frame.png` mantém o último quadro aguardando entrada.
- Qualquer tecla, botão do controle, clique ou toque inicia a fase, inclusive durante a abertura. A transição aguarda a soltura do comando inicial para evitar ataque ou salto involuntário na fase. Movimento do mouse, analógico e repetição automática de tecla não iniciam.
- `scripts/intro.gd` controla apenas reprodução, espera por entrada e troca de cena. A montagem cinematográfica fica em `tools/intro_source.tscn` e `tools/intro_source.gd`, para futuras renderizações. Essa montagem não roda durante a abertura e é excluída da exportação. Nenhum arquivo de movimento, combate ou correção da espada foi modificado.
- Os cenários novos estão em `assets/intro/japan.png` e `future.png`. Foram gerados em pixel art a partir da direção visual das duas referências do usuário. `assets/intro/INTRO.md` registra os prompts e a fonte Press Start 2P, distribuída com licença OFL.
- Para substituir pelo logo futuro, altere `_build_title()` em `tools/intro_source.gd` e gere novamente o vídeo e seu quadro final; o procedimento está em `assets/intro/INTRO.md`.
- `tests/intro_test.gd` executa `video_intro_test.gd`: 14 verificações de reprodução real, fim do vídeo, entrada e reinício, mais 2 capturas opcionais. `tests/intro_source_test.gd` preserva as verificações da montagem cinematográfica editável. Os 34 testes anteriores de movimento/combate foram preservados. A aprovação artística permanece a cargo do usuário.

## Visão do jogo

Jogo 2D de ação e plataforma inspirado na agilidade dos jogos de ninja clássicos e em Ninja Gaiden Ragebound, baseado no mangá autoral do usuário, A Espada de Oda. Protagonista: Youkai. A aparência atual usa armadura dourada, roupa escura, capacete com hastes em V e olhos ciano. As ilustrações originais do usuário estão na pasta Referencias do pacote; há também uma versão azul/prateada do personagem.

A cidade futurista segue a referência fornecida: lua turquesa, prédios azuis, iluminação ciano e céu violeta. Existe uma área jogável de teste com plataformas, câmera e paralaxe. Ainda não há inimigos, vida, objetivos, som ou condição de vitória. Não tratar este protótipo como uma fase finalizada.

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
5. **GFF-2:** corte ascendente com oito poses novas de giro dos punhos, preparação da lâmina e corte de baixo para cima. A primeira pose usa exatamente a mesma textura e posição final de GFF-1, para continuidade. Não é simplesmente GFF-1 reproduzido ao contrário.

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
- `assets/gff/gff2_rising_cut.png`: novas poses do corte ascendente.
- `assets/cidade_futurista.png`: fundo da cidade.
- `assets/ANIMACOES_013.md`, `DIRECAO_DE_ARTE.md` e `CORRECAO_ESPADA.md`: decisões de arte, prompts e correções anteriores.
- `tests/regression.gd` e `tests/smoke_test.gd`: verificações automáticas.
- `export_presets.cfg`: exportação Windows x86_64 com recursos embutidos no executável.

## Cuidados para não reintroduzir bugs

- Houve um bug no golpe forte: efeito cortado e fragmento de outro quadro. Foram utilizados sprites dedicados, margens de recorte e rastro separado. Não voltar ao recorte ingênuo de uma grade uniforme.
- As artes de GF-2 e GFF-2 têm margens personalizadas e alinhamento por quadro. O recorte superior/inferior do GFF-2 evita cortar a ponta da espada e capturar a linha vizinha.
- O material das novas poses usa limiar de transparência 0,10 para preservar a lâmina ciano semitransparente. O material antigo usa 0,80. Aumentar indiscriminadamente esse limiar pode amputar a espada.
- Manter a conexão exata entre a última pose de GFF-1 e a primeira de GFF-2. Não substituir o golpe ascendente por quadros invertidos do descendente.
- Sincronizar janela de dano, rastro e animação quando mudar a velocidade de um ataque.
- Rotacionar o visual no pulo, não a colisão do personagem.

## Base para inimigos futuros

Mundo na camada 1; personagem na camada 2; alvos futuros na camada 3, valor de máscara 4. O método esperado no alvo é `receive_hit(damage, direction)`. Golpes fracos causam 1 por impacto; espada causa 3. Um alvo só é atingido uma vez por janela; GF-1 tem duas janelas independentes.

## Verificação e exportação

A versão foi validada com execução gráfica e 34 verificações automáticas de movimento, colisão, recortes e combos. Para repetir depois da importação:

```text
godot --headless --path <pasta-AEspadaDeOda> --script res://tests/smoke_test.gd
godot --headless --path <pasta-AEspadaDeOda> --script res://tests/intro_test.gd
```

Aqui `godot` representa o executável do Godot instalado no novo computador. Para importar pela linha de comando:

```text
godot --headless --editor --path <pasta-AEspadaDeOda> --import --quit
```

Para gerar outro executável, instale os modelos de exportação correspondentes à versão do Godot e use o preset Windows Desktop. Escolha uma pasta de saída existente. Os modelos de exportação e o próprio editor não fazem parte do pacote.

## Continuidade no novo chat

Abra a pasta extraída no Codex para permitir trabalho direto nos arquivos locais. Em um chat comum do ChatGPT, anexe este resumo e os arquivos necessários; escrever um caminho do seu computador não concede acesso a ele. Não conte com a recuperação automática de todos os detalhes de conversas anteriores.

O pacote é uma fotografia da versão 0.1.3, não sincroniza alterações futuras. Ao terminar uma sessão, atualize o resumo e copie o projeto atualizado antes de trocar de máquina. Evite editar duas cópias diferentes ao mesmo tempo.
