# A Espada de Oda

Versão 0.1.3: salto com dois giros ágeis mantendo a mesma física; GF-1 (soco + chute) seguido por GF-2 (chute giratório esquerdo); GFF-1 descendente acelerado em 1,2× seguido por GFF-2 ascendente com novas poses de giro da lâmina. O preset de exportação gera `../Windows/AEspadaDeOda-0.1.3.exe`; o executável não está incluído no repositório.

Protótipo jogável em Godot 4.7.2, baseado no mangá autoral do usuário. Youkai usa armadura dourada, capacete com hastes em V, olhos ciano e espada. A primeira área é uma cidade futurista com lua turquesa, prédios em azul e luzes ciano, conforme a referência fornecida.

## Jogar

Abra `project.godot` no Godot, aguarde a importação dos recursos e pressione **F5**. Clique na janela do jogo para dar foco ao teclado. **F8** encerra uma execução iniciada pelo editor.

F5 começa pela reprodução do vídeo pré-renderizado `assets/intro/intro.ogv`, em `scenes/intro.tscn`: Japão ao pôr do sol, viagem no tempo, cidade futurista, salto e título provisório. O vídeo de 13 segundos fica embutido no executável e termina na tela de título, aguardando entrada. Qualquer tecla, botão do controle ou clique inicia a fase após soltar o comando, inclusive durante o vídeo. A fase continua em `scenes/movement_lab.tscn`; R reinicia apenas a fase. A abertura não possui áudio nesta versão.

| Controle | Ação |
|---|---|
| A/D ou ←/→ | Correr para os dois lados |
| Espaço, W ou ↑ | Pular com dois giros; segurar sobe mais, soltar cedo produz salto curto |
| J ou Z | GF-1: soco + chute. Pressione novamente para emendar GF-2, chute giratório com a perna esquerda |
| K ou X | GFF-1: corte descendente. Pressione novamente para emendar GFF-2, giro da lâmina e corte ascendente |
| R | Reiniciar o trecho |
| F1 | Mostrar colisão do corpo e alcance ativo dos golpes |

Os golpes também funcionam no ar e interrompem o giro para orientar Youkai. No chão, Youkai desacelera durante os ataques. Ambos os cortes de espada impedem iniciar um salto até o fim do golpe. Pressione J/Z ou K/X novamente a partir da metade do primeiro movimento para emendar o segundo. A espada aceita continuação até meio segundo após o corte; Youkai mantém a posição baixa nesse intervalo se estiver parado. Movimento, salto ou expiração da janela liberam a pose. Uma pausa maior ou troca de tipo de golpe reinicia a sequência. Cada comando inicia uma seção: o GF-1 sozinho já inclui o soco e o chute; segurar a tecla não repete ataques.

## O que está implementado

- Corrida com aceleração e frenagem, salto variável, pequena tolerância ao sair de uma borda e registro antecipado do botão de salto antes do pouso.
- Onze estados visuais: guarda, corrida, subida, ápice, queda, pouso, giro duplo, GF-1, GF-2, GFF-1 e GFF-2.
- Dois giros em torno do centro do corpo, com duração adaptada ao salto curto. A colisão permanece vertical e o pouso restaura a orientação. Altura e tempo total no ar não foram aumentados.
- GF-2 utiliza oito poses novas, com vista de costas durante a rotação e retorno à guarda.
- GFF-2 utiliza oito poses novas e uma pose inicial compartilhada com o final de GFF-1. O personagem gira os punhos e carrega a espada antes do corte ascendente.
- O GFF-1 tem duração de 0,56 / 1,2 segundos. A janela de impacto e o rastro acompanham a aceleração.
- Colisões com piso, plataformas e limites laterais; câmera acompanha o movimento horizontal.
- Preparação, janela ativa e recuperação dos ataques. A colisão ofensiva é habilitada apenas durante a janela ativa.
- Cidade com paralaxe: o fundo distante se desloca mais devagar que as silhuetas próximas e as passarelas.

Este trecho tem 3.000 unidades de largura e serve para experimentar os controles e a direção visual. Ainda não há inimigos, vida, objetivos, sons ou condição de vitória. As plataformas constituem um primeiro arranjo para testar saltos, não uma fase finalizada.

## Estrutura e alterações

- `scenes/movement_lab.tscn`: cena principal com a cidade, plataformas, câmera e interface.
- `scenes/youkai.tscn`: personagem reutilizável.
- `scripts/youkai.gd`: controles, física, animações e ataques. No Inspetor do Youkai, ajuste **Run Speed**, **Jump Speed**, **Gravity**, **Acceleration** e **Braking**.
- `scripts/lab.gd`: câmera, reinício e desenho das passarelas.
- `scripts/city_backdrop.gd`: imagem da cidade e camadas de paralaxe.
- `scripts/hud.gd`: interface e indicação dos controles.
- `assets/youkai_atlas.png`: poses de locomoção e GF-1. As animações são montadas ao executar a cena.
- `assets/gf/gf2_spin_kick.png`: oito poses do chute giratório.
- `assets/gff/gff2_rising_cut.png`: oito poses novas do corte ascendente.
- `assets/ANIMACOES_013.md`: organização GF/GFF, referências e prompts das novas artes.
- `assets/cidade_futurista.png`: fundo da cidade.
- `assets/DIRECAO_DE_ARTE.md`: referências e prompts usados na geração integrada das imagens.
- `tests/smoke_test.gd`: verificações automáticas do movimento e combate.

Para mover plataformas, abra a cena principal e edite os corpos dentro de **Geometry**. O desenho das passarelas acompanha as formas de colisão ao executar. Como parte dos visuais é montada por código, use **F5** para ver a aparência completa.

## Preparação para inimigos

Mundo usa camada de colisão 1; Youkai, camada 2; alvos futuros, camada 3 (valor 4). Um alvo com o método `receive_hit(damage, direction)` recebe 1 de dano por impacto leve ou 3 por corte de espada. GF-1 possui duas janelas separadas, soco e chute, cada uma com no máximo um impacto por alvo. GF-2 e cada corte de espada têm uma janela de impacto. Ainda não há inimigos nesta versão.

## Verificação

Validado no Godot 4.7.2 instalado localmente: execução gráfica, inspeção visual dos novos quadros e 34 verificações automáticas, incluindo bordas dos sprites, giro duplo, duração do salto, GF-1 com dois impactos, encadeamento GF-2, velocidade 1,2×, ligação de poses GFF e colisões. Para repetir: execute o Godot com `--headless --path <pasta-do-projeto> --script res://tests/smoke_test.gd`.

A pasta `.godot` é cache gerado pelo editor. O protótipo anterior `PrimeiroJogo2D` foi preservado separadamente.
