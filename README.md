# A Espada de Oda

Protótipo 2D de ação e plataforma baseado no mangá autoral A Espada de Oda, com Youkai como protagonista. Versão **0.1.3**, desenvolvida em **Godot 4.7.2**, com GDScript e renderização Compatibility.

## Abrir o projeto

1. Instale o Git e o Godot 4.7.2, edição padrão.
2. Clone este repositório:

   ```sh
   git clone https://github.com/brunao139/A-Espada-de-Oda.git
   ```

3. No Godot, importe `AEspadaDeOda/project.godot`.
4. Aguarde a importação das imagens e pressione **F5**.

O jogo começa com um **vídeo anime pré-renderizado de 30 segundos com trilha e efeitos**, incluído no executável. Youkai atravessa o Japão feudal e uma cidade futurista, salta entre prédios e desfere um golpe em direção à câmera. A produção usa animação limitada com ilustrações, poses, câmera e efeitos, feita localmente sem Runway.

Ao terminar, surge um menu funcional: **START** abre a área jogável, **OPTIONS** ajusta volume e tela cheia, **EXIT** encerra. Qualquer tecla, botão de controle, clique ou toque pula a abertura para o menu; solte o comando para concluir a transição. O título é provisório e poderá receber o logo oficial depois.

O editor, os modelos de exportação e os executáveis do jogo não fazem parte do repositório. A pasta `.godot` será recriada automaticamente. Os arquivos `.uid` e `.import` são versionados e devem ser preservados.

## Controles

| Teclas | Ação |
|---|---|
| A/D ou setas laterais | Correr |
| Espaço, W ou seta para cima | Pular; segurar aumenta a altura |
| Espaço, W ou ↑ na beirada | Subir; solte o pulo anterior e aperte novamente |
| S ou ↓ | Soltar a beirada; segurar impede agarrar |
| J ou Z | GF-1; novo toque emenda GF-2 |
| K ou X | GFF-1; novo toque emenda GFF-2 |
| R | Reiniciar o trecho |
| F1 | Mostrar colisões e alcance dos golpes |

Youkai agarra automaticamente quinas à sua frente durante a descida do salto, desde que haja espaço para ficar pendurado. Uma plataforma sinalizada no fim do trecho permite testar o movimento. A subida respeita colisões e tetos; plataformas móveis não são suportadas. Detalhes em [BEIRADAS.md](AEspadaDeOda/assets/ledge/BEIRADAS.md).

O protótipo tem plataformas, câmera e cidade com paralaxe. Ainda não há inimigos, vida, objetivos, áudio de gameplay ou condição de vitória.

## Trabalhar em outras máquinas

Antes de começar, execute `git pull --ff-only` na pasta do repositório. Ao terminar:

```sh
git status
git add .
git commit -m "Descreva a melhoria realizada"
git push
```

Configure seu nome e e-mail no Git antes do primeiro commit. Envie as alterações antes de trocar de máquina. Se houver alterações locais ou divergência entre versões, resolva-as antes de continuar; não sobrescreva trabalho pendente.

Para colaborar, cada pessoa pode criar uma branch com `git switch -c nome-da-melhoria`, enviar com `git push -u origin nome-da-melhoria` e abrir um pull request. Colaboradores precisam de acesso de escrita para enviar branches diretamente; quem não tiver esse acesso pode usar um fork, se permitido pela visibilidade do repositório.

## Continuidade e preservação

Leia [CONTINUAR_A_ESPADA_DE_ODA.md](CONTINUAR_A_ESPADA_DE_ODA.md) antes de alterar as mecânicas. Preserve o pulo com dois giros, GF-1/GF-2, GFF-1/GFF-2, a conexão entre as poses dos cortes e as correções de recorte, transparência e rastro da espada.

- `AEspadaDeOda/scenes/`: personagem e área de teste.
- `AEspadaDeOda/scripts/`: movimento, combate, interface e efeitos.
- `AEspadaDeOda/assets/`: artes utilizadas no jogo e documentação visual.
- `AEspadaDeOda/tests/`: testes de regressão e verificação.
- AEspadaDeOda/scenes/intro.tscn e scripts/intro.gd: reprodução do vídeo e transição para o menu.
- AEspadaDeOda/scenes/main_menu.tscn e scripts/main_menu.gd: START, OPTIONS e EXIT.
- AEspadaDeOda/assets/intro_anime/opening.ogv: filme final com áudio embutido.
- AEspadaDeOda/tools/anime_source.tscn: montagem editável; compose_anime.py: trilha original e efeitos.
- AEspadaDeOda/assets/intro_anime/DIRECAO.md: montagem, regeneração, prompts e créditos/licenças.
- AEspadaDeOda/assets/intro/ e tools/intro_source.*: versão 16-bit anterior, preservada e excluída do executável.
- `Referencias/`: referências visuais para continuar o trabalho artístico.

Atualize o documento de continuidade quando o estado do jogo mudar. O histórico do Git registra as alterações de cada versão.

## Verificar e exportar

Com o executável do Godot disponível como `godot` no terminal:

```sh
godot --headless --editor --path AEspadaDeOda --import --quit
godot --headless --path AEspadaDeOda --script res://tests/smoke_test.gd
godot --headless --path AEspadaDeOda --script res://tests/ledge_test.gd
godot --path AEspadaDeOda --script res://tests/intro_test.gd
godot --path AEspadaDeOda --script res://tests/menu_test.gd
```

Para exportar, instale os modelos de exportação da mesma versão do Godot e use o preset **Windows Desktop**. Crie a pasta `Windows` na raiz do repositório antes de usar o caminho de saída padrão. Builds não são versionadas; podem ser distribuídas separadamente por GitHub Releases.

## Atualização GFF-2 frontal — 28/09/2026

O segundo golpe forte agora projeta a katana para a frente, com 16 poses novas mais a ligação com GFF-1 (17 quadros, 0,68 s). Use K ou X duas vezes para emendar. Dano e rastro acompanham a extensão horizontal, nos dois sentidos. Detalhes em AEspadaDeOda/assets/gff/GFF2_FRONTAL.md.


## Cidade expandida — 29/09/2026

Fase três vezes mais longa (9.000 unidades), com Acesso Oda, distrito Neon e Porto/Terminal 09. Após simplificação visual, oito plataformas no total (quatro originais e quatro adicionais), carros e motos pequenos somente ao fundo, trem, letreiros, chuva e equipamentos animados. Os veículos grandes em primeiro plano foram removidos. Os veículos são ambientação.

Detalhes em AEspadaDeOda/assets/city/CIDADE.md. Para integrar os golpes aéreos ainda salvos no outro computador, leia INTEGRAR_COMBOS_AEREOS.md antes de atualizar.
