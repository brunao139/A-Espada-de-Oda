# Direção e prompts — arte 0.1.5
Ferramenta: geração de imagens integrada, com fundo alfa transparente. Os PNGs originais gerados foram preservados. As referências foram o atlas do Youkai para estilo e o atlas Ajogun anterior para identidade; após gerar caminhada, ela também foi usada como referência de identidade dos demais movimentos.

## Direção comum Ajogun
Sprite de jogo de ação 2D, contornos pretos fortes, sombras de cel shading bem definidas, anatomia legível e realces pequenos, aproximando o tratamento visual do protagonista. Demônio musculoso de pele cinza prateada, chifres escuros enrolados, dentes, dedos longos com garras, torso descoberto, calças marrons rasgadas, faixa na cintura e tornozelos envolvidos em tecido. Vista lateral voltada à direita, com torso levemente em três quartos. Manter identidade, proporções e escala entre poses. Fundo transparente, sem letras, numeração, cenário, sombra de chão ou linhas de grade; corpo inteiro isolado com margens.

## Caminhada — walk.png
12 poses cronológicas em quatro colunas e três linhas. Ciclo em lugar, alternando contato, compressão, passagem e elevação de cada perna. Braços opostos às pernas, transferência de peso e movimento do tecido; intermediários distintos e retorno contínuo ao primeiro quadro. Quadril centralizado e pés na mesma linha de apoio por célula.

## Corrida — run.png
12 poses em quatro colunas e três linhas. Corrida de perseguição com inclinação do tronco, alternância de pernas, impulso, fase aérea, contato e compressão; braços alternados e tecido acompanhando o movimento. Ciclo contínuo, mesma escala e margens preservando extremidades.

## Garras — attack.png
16 poses em quatro colunas e quatro linhas. Preparação baixa, giro dos ombros, braço recolhido, antecipação, avanço e extensão das garras à direita na altura dos ombros, seguida de retração e recuperação da guarda. Pés apoiados; sem rastros ou efeitos desenhados; espaço amplo para a mão estendida.

## Queda e morte — death.png
16 poses em quatro colunas e quatro linhas. Recuo após impacto, joelhos cedendo, desequilíbrio, ajoelhar, mão buscando apoio, quadril e torso baixando, pernas estendendo para a esquerda e cabeça à direita. Quadros finais inteiramente deitados de lado, sem apoio dos braços ou posição sentada. Corpo assentado no mesmo chão local; sem sangue, sombra ou linha de piso. Não ampliar poses agachadas ou deitadas.

## Respiração e dano — idle_hurt.png
16 poses em quatro colunas e quatro linhas. Primeira linha: quatro poses de respiração discreta em guarda, peito e dedos se movendo. Três linhas seguintes: 12 poses contínuas de reação a dano no peito, recuo para a esquerda, joelhos flexionando, pequeno passo para trás, mão no torso e recuperação da guarda. Não é uma morte; manter pés apoiados e escala constante.

## Direção comum Youkai
Manter exatamente o personagem do atlas do protagonista: ninja atlético e compacto, armadura dourada sobre roupa azul-marinho/preta, capacete angular com hastes em V laranja/vermelhas, olhos ciano, botas e manoplas de armadura, espada embainhada diagonalmente nas costas. Mesmo contorno forte e sombras em blocos. Corpo inteiro voltado à direita, fundo transparente, sem redesenhar a armadura ou colocar armas nas mãos.

## Youkai no chão — ground.png
12 poses em quatro colunas e três linhas. Começar na guarda, receber impacto no peito vindo da direita, recuar o tronco à esquerda, girar ombros, recolher braços, flexionar joelhos, dar um pequeno passo para trás e recuperar a postura. Uma reação coerente com intermediários distintos, sem atacar. Pés na mesma linha de apoio.

## Youkai no ar — air.png
12 poses em quatro colunas e três linhas. Impacto vindo da direita durante o salto, recuo dos braços e ombros, torso arqueando, joelhos recolhendo e pernas acompanhando; depois recuperar equilíbrio e preparar as botas para pousar. Sem giro completo ou ataque. Centro corporal estável entre quadros; não alinhar os pés recolhidos ao chão.

Os resultados requereram recortes medidos, pois as grades geradas não são perfeitamente uniformes. Os recortes finais estão em assets/animation_manifest.json.
