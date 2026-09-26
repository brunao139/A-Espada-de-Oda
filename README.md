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

O jogo começa com um **vídeo pré-renderizado de 13 segundos**, incluído no executável: Youkai corre pelo Japão, atravessa uma transição de luz para uma cidade futurista e salta de um prédio antes da tela de título. Ao terminar, o último quadro permanece aguardando o jogador. Pressione qualquer tecla, botão do controle ou clique para iniciar a primeira fase; também é possível iniciar durante o vídeo. Solte o botão para concluir a transição. O título é provisório e poderá receber o logo original depois. O vídeo ainda não tem áudio.

O editor, os modelos de exportação e os executáveis do jogo não fazem parte do repositório. A pasta `.godot` será recriada automaticamente. Os arquivos `.uid` e `.import` são versionados e devem ser preservados.

## Controles

| Teclas | Ação |
|---|---|
| A/D ou setas laterais | Correr |
| Espaço, W ou seta para cima | Pular; segurar aumenta a altura |
| J ou Z | GF-1; novo toque emenda GF-2 |
| K ou X | GFF-1; novo toque emenda GFF-2 |
| R | Reiniciar o trecho |
| F1 | Mostrar colisões e alcance dos golpes |

O protótipo tem plataformas, câmera e cidade com paralaxe. Ainda não há inimigos, vida, objetivos, som ou condição de vitória.

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
- `AEspadaDeOda/scenes/intro.tscn` e `scripts/intro.gd`: reprodução do vídeo e entrada na fase, separadas da física e combate.
- `AEspadaDeOda/assets/intro/intro.ogv`: vídeo final embutido na exportação; `title_frame.png` mantém a tela final.
- `AEspadaDeOda/tools/intro_source.tscn`: montagem editável usada para renderizar o vídeo; não é executada nem incluída no build.
- `AEspadaDeOda/assets/intro/`: cenários em pixel art, fonte e licença; veja `INTRO.md` nessa pasta para regenerar o vídeo.
- `Referencias/`: referências visuais para continuar o trabalho artístico.

Atualize o documento de continuidade quando o estado do jogo mudar. O histórico do Git registra as alterações de cada versão.

## Verificar e exportar

Com o executável do Godot disponível como `godot` no terminal:

```sh
godot --headless --editor --path AEspadaDeOda --import --quit
godot --headless --path AEspadaDeOda --script res://tests/smoke_test.gd
godot --headless --path AEspadaDeOda --script res://tests/intro_test.gd
```

Para exportar, instale os modelos de exportação da mesma versão do Godot e use o preset **Windows Desktop**. Crie a pasta `Windows` na raiz do repositório antes de usar o caminho de saída padrão. Builds não são versionadas; podem ser distribuídas separadamente por GitHub Releases.
