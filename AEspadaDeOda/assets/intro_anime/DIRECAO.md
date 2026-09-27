# Abertura anime — versão montada em 27/09/2026

Vídeo de 30 segundos, 1280×720, 30 FPS, com áudio estéreo. Produção local sem Runway: ilustrações anime geradas a partir da referência autoral, ciclo de corrida por poses, movimento de câmera e efeitos compostos. É animação limitada/montagem cinematográfica; não é animação integral quadro a quadro de estúdio. O título é tipográfico provisório, aguardando o logo oficial.

## Montagem

| Tempo | Conteúdo |
|---|---|
| 0–4,4 s | Corrida da direita para a esquerda nos telhados feudais à noite. |
| 4,4–6,2 s | Plano aproximado das pernas, telhas, partículas e passos. |
| 6,2–9,4 s | Fenda temporal e reconstrução do cenário em faixas luminosas. |
| 9,4–11,4 s | Corrida na cidade neon sob chuva. |
| 11,4–16,8 s | Salto entre dois prédios, retenção do tempo no ápice e corte no pouso. |
| 16,8–22,8 s | Preparação da espada, aura dourada, aproximação e detalhe dos olhos. |
| 22,8–24,8 s | Golpe em direção à lente, fresta diagonal e clarão branco. |
| 24,8–30 s | Revelação do fundo e título; ao terminar entra o menu funcional. |

START abre a área jogável existente. OPTIONS oferece volume geral e tela cheia, salvos em `user://settings.cfg`. EXIT encerra o jogo. Qualquer tecla, botão de controle, clique ou toque pode pular o filme para o menu; a transição aguarda soltar a entrada para não ativar START por acidente. Mouse em movimento, eixo analógico e repetição de tecla não pulam.

## Arquivos

- `opening.ogv`: filme com vídeo Theora e áudio Vorbis; integrado ao executável, sem internet ou player externo.
- `../../tools/anime_source.gd` e `.tscn`: montagem determinística para renderização offline.
- `../../tools/compose_anime.py`: composição instrumental original e efeitos, com semente fixa.
- PNGs nesta pasta: artes-fonte; a corrida usa apenas a primeira linha do atlas, voltada à esquerda. A segunda linha foi gerada espelhada e não é usada.
- `menu_background.png`, `Cinzel.ttf`: recursos da interface.
- `PROMPTS.md` e `PROMPTS_SEQUENCIA.md`: prompts usados para gerar as artes.
- A montagem anterior 16-bit permanece nos arquivos `tools/intro_source.*`, `assets/intro/` e no histórico Git; excluída do novo executável.

## Regenerar

Com Godot 4.7.2, FFmpeg com libtheora/libvorbis/libx264 e Python com numpy/scipy/tinysoundfont:

1. Importe o projeto: `godot --headless --editor --path AEspadaDeOda --import --quit`.
2. Renderize: `godot --path AEspadaDeOda res://tools/anime_source.tscn --write-movie anime-master.avi --fixed-fps 30 --quit-after 900 --disable-vsync --audio-driver Dummy`.
3. Obtenha GeneralUser GS 2.0.3 no [repositório do autor](https://github.com/mrbumpy409/GeneralUser-GS), respeitando a licença incluída. O SoundFont é ferramenta de produção, não necessário para jogar.
4. Gere a trilha: `python AEspadaDeOda/tools/compose_anime.py --soundfont GeneralUser-GS.sf2 --output anime-soundtrack.wav`.
5. Converta: `ffmpeg -i anime-master.avi -i anime-soundtrack.wav -map 0:v:0 -map 1:a:0 -t 30 -af loudnorm=I=-17:TP=-1.5:LRA=11 -ar 44100 -c:v libtheora -q:v 8 -g 64 -pix_fmt yuv420p -c:a libvorbis -q:a 5 AEspadaDeOda/assets/intro_anime/opening.ogv`.
6. Para MP4, use `-c:v libx264 -crf 18 -preset medium -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart` no lugar dos codecs OGV.
7. Reimporte e execute `tests/video_intro_test.gd`, `tests/menu_test.gd` e `tests/regression.gd`. A verificação de vídeo requer cerca de 35 segundos e ambiente gráfico para inspecionar a decodificação.
8. Exporte com o preset Windows Desktop e modelos 4.7.2.

Ajustes de arte/câmera exigem nova renderização do vídeo. Para colocar o logo, altere o título no final de `anime_source.gd` e o `ProvisionalTitle` em `scripts/main_menu.gd`, mantendo a composição consistente.

## Créditos

Personagem e universo: referência autoral fornecida pelo usuário. Artes produzidas com geração de imagem e revisão de enquadramento. Trilha instrumental original programada para esta sequência; timbres renderizados com GeneralUser GS de S. Christian Collins, licença em `GeneralUser-GS-LICENSE.txt`. Efeitos de passos, chuva, portal e impacto sintetizados. Fonte Cinzel: Natanael Gama, SIL OFL, licença `Cinzel-OFL.txt`.

Os arquivos de movimento, combos, pulo e correções da espada não foram alterados. Aprovação artística permanece a cargo do usuário.
