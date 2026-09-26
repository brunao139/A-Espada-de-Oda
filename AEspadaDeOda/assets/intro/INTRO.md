# Abertura — versão 0.1.3

Criada em 26/09/2026. Referência de linguagem: aberturas 16-bit de Super Nintendo e Mega Drive, especialmente jogos das Tartarugas Ninja. As artes são próprias desta abertura; não foram copiados personagens, logos ou recursos desses jogos.

`japan.png` e `future.png` foram gerados com a ferramenta integrada de geração de imagens, em modo padrão, para compor cenários laterais em pixel art. As imagens fornecidas pelo usuário orientaram arquitetura, cores e atmosfera. A imagem futurista vertical foi reinterpretada em panorama horizontal. As referências originais não são dependências de execução.

A abertura entregue é um vídeo pré-renderizado, não uma cena animada em tempo real. `intro.ogv` é reproduzido por VideoStreamPlayer e fica embutido no executável Windows. `title_frame.png` é o último quadro decodificado do vídeo, mantido após o fim enquanto o jogador não inicia a fase. Não há áudio.

A montagem de produção em `tools/intro_source.tscn` reutiliza o atlas e o alinhamento do personagem, e desenha telhados, silhuetas, poeira, paralaxe, linhas de CRT e uma única transição luminosa gradual. A pasta `tools` é excluída da exportação.

## Gerar novamente

Formato final: Ogg Theora, 1280×720, 30 FPS, 13 segundos, qualidade 8, GOP 64, YUV420p. O arquivo atual tem 15.130.288 bytes. Ogg Theora é o formato de vídeo nativo do Godot: https://docs.godotengine.org/en/stable/tutorials/animation/playing_videos.html.

Com Godot e FFmpeg no PATH, execute a partir da raiz do repositório. Crie antes uma pasta de trabalho externa ao projeto para o AVI intermediário.

```sh
godot --path AEspadaDeOda --scene res://tools/intro_source.tscn --write-movie /caminho/intro-master.avi --fixed-fps 30 --quit-after 390 --disable-vsync --audio-driver Dummy
ffmpeg -i /caminho/intro-master.avi -an -c:v libtheora -q:v 8 -g:v 64 -pix_fmt yuv420p AEspadaDeOda/assets/intro/intro.ogv
ffmpeg -sseof -0.04 -i AEspadaDeOda/assets/intro/intro.ogv -frames:v 1 AEspadaDeOda/assets/intro/title_frame.png
```

Uma cópia MP4 para assistir fora do jogo pode ser gerada com `-an -c:v libx264 -crf 18 -pix_fmt yuv420p -movflags +faststart`. O jogo utiliza o OGV, e não o MP4. AVI intermediário e builds ficam fora do Git.

## Prompts finais

### japan.png

Use case: stylized-concept. Create a production background image for a 16-bit side-scrolling ninja game intro. Reference the Japanese temple sunset image attached earlier for mood and architecture; the futuristic image is NOT reference for this asset. Wide 16:9 landscape panorama, 1536x864 if possible. Original Japanese feudal town at sunset, layered pagodas with curved dark teal tile roofs, red timber, golden warm windows, peach orange sky, pale gold sun, distant misty mountains. Authentic beautiful SNES / Mega Drive pixel art with crisp chunky pixel clusters and limited palette, no smooth painting, no blur. Side-on horizontal game background with readable silhouettes and strong depth. Buildings fill lower two thirds, sky upper third. No characters, no foreground playable platform (drawn separately in game), no writing, no logo, no watermark. Composition remains clear behind a running gold-armored hero along the bottom quarter. A polished 1990s arcade opening atmosphere, dramatic and atmospheric.

### future.png

Use case: stylized-concept. Generate original production game background, wide 16:9 landscape panorama. 16-bit SNES / Mega Drive pixel art opening for a ninja action platformer. Reference the attached futuristic portrait city for mood only: a deep canyon of blue-violet skyscrapers, salmon pink sky stripes, dense tiny lit windows, balconies, silhouetted cables, futuristic Japanese urban atmosphere. Recompose as WIDE landscape side-view background, not portrait. Strong depth: dusty purple distant towers behind dark indigo middle-distance towers, sparse cyan and rose lit windows and signage with abstract pixels (no readable words), overhead cables. Crisp hand-placed-looking large pixel clusters, restrained palette, clean silhouettes, no smooth digital painting. Lower quarter dark building masses, upper half generous sky opening toward the center to let a title remain legible. No hero, no people, no foreground playable platform (added by code), no text, no title, no watermark. Polished atmospheric 1990s arcade cinematic backdrop. Whole image opaque.

## Fonte

Press Start 2P, de CodeMan38, distribuída sob SIL Open Font License 1.1. Fonte original: https://github.com/google/fonts/tree/main/ofl/pressstart2p. A licença completa acompanha este diretório em `OFL.txt`.

## Ajustes futuros

- Linha do tempo: constantes no início de `tools/intro_source.gd`.
- Logo: substituir o Label `GameTitle` em `_build_title()` da montagem de produção por uma textura e renderizar novamente quando a arte original estiver disponível.
- A fase jogável e a cidade de teste mantêm seus recursos e lógica anteriores.
