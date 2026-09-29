# Cidade expandida com visual simplificado — 29/09/2026

A fase passa de 3.000 para 9.000 unidades horizontais, mantendo o início e os obstáculos originais. Três trechos: Acesso Oda, Neon e Porto/Terminal 09. A revisão solicitada pelo autor reduz as plataformas de 18 para oito: quatro originais e quatro adicionais, baixas e espaçadas (NeonLanding, NeonSteps, PortArrival e TerminalPad). O piso contínuo permite recuperar quedas sem reiniciar. Foram removidas dez plataformas da expansão e seus suportes visuais.

## Vida e direção de arte
- Quatro sprites originais: carro esportivo, táxi, moto esportiva com piloto e moto de entrega com piloto.
- Dez veículos pequenos em circulação apenas no fundo, nos dois sentidos, com velocidades, escalas e oscilações diferentes. As motos inclinam suavemente. São elementos de ambientação, sem colisão ou pilotagem.
- Fundo em paralaxe com cobertura contínua até o final da fase, torres, janelas iluminadas, balizas, trem de quatro vagões, chuva fina e partículas.
- Fachadas com dutos, antenas, cabos, letreiros de neon com varredura, luminárias e corrimãos. Plataformas altas recebem painéis e ventiladores giratórios. Guindaste no porto.
- Tráfego em primeiro plano removido completamente: não há mais os quatro veículos grandes nem o nó NearTraffic. A área de jogo fica livre dessa camada móvel.
- Cyan no acesso, magenta no distrito Neon e âmbar no porto. Detalhes do mundo são limitados ao trecho visível para reduzir desenho fora da câmera.
- Não foram adicionados inimigos, objetivos, veículos pilotáveis ou áudio de tráfego.

## Arquivos
- scenes/movement_lab.tscn: geometria, câmera e nós de ambiente.
- scripts/lab.gd: limites derivados do piso e acabamento das superfícies.
- scripts/city_backdrop.gd: fundo, tráfego distante e trem.
- scripts/city_environment.gd: fachadas, letreiros e instalações.
- assets/city/hover_traffic.png: atlas de quatro veículos, transparência real, criado com a ferramenta integrada de geração de imagens.

## Validação
92 verificações passaram: regressão 34, beiradas 29, GFF-2 12 e cenário 17.
O teste de cenário percorre a expansão de x=2860 até x>=8900 por entradas de corrida e salto, valida o topo de cada nova plataforma, a parede final, câmera e movimento do tráfego. Também confirma oito plataformas e ausência da camada de tráfego próximo.
tools/city_demo.tscn mostra os três trechos com cortes de câmera; a mudança de distrito no vídeo é uma apresentação, não teletransporte disponível no jogo.
tools/city_capture.gd produz as capturas da apresentação.

## Integração com os combos aéreos
Base desta melhoria: commit 0a3a1d1. Nenhuma mudança em youkai.gd, gff2_frames.gd, sword_trail.gd, ledge_controller.gd, hud.gd ou scenes/youkai.tscn.
Os golpes aéreos feitos no outro computador ainda não estavam no GitHub. Preservar e fazer commit desse trabalho local antes de integrar a main. Ver INTEGRAR_COMBOS_AEREOS.md na raiz.

## Prompt dos veículos
Use case: stylized-concept. Asset type: game sprite atlas, 4 flying cyberpunk vehicles for a 2D side scrolling pixel-art samurai game. Input reference defines the cyan/indigo neon city palette only, NOT a background to include.
Produce exact TWO columns TWO rows, square1536x1536, genuinely TRANSPARENT background. Eachcell768x768. Exactly FOUR separate complete vehicle sprites, no extra objects. Vehicles centered in eachcell, total width maximum520px, height maximum300px, huge clear transparent gutters at least100pixels on everyedge. Each flies horizontally to SCREEN RIGHT in consistent near-side view (slight threequarter visible top). Highly crafted crisp pixel-art, clean dark outlines, faceted highlights, legible at100–180pxwidth. NO labels, no text, no grid, no backdrop, no floor/shadow, no bakedcheckerboard. No full-canvas atmosphere. Keep engine exhaust short and within cell.
Top-left: sleek pearl-teal flying sports CAR, clear enclosed cockpit and windshield, two seats suggested through glass, headlights on right, red taillights on left, no roadwheels; two distinct small anti-gravity pods under chassis and short cyan jetplume towardleft.
Top-right: gold and darknavy flying city TAXI CAR, sturdy enclosed passenger cabin, windshield, tiny blank glowing taxi roofsign, compact orange underside thrusters and redtaillights. Not a spaceship, must visibly read as a floating CAR.
Bottom-left: magenta-black flying MOTORCYCLE with a helmeted rider leaning forward gripping two handlebars, two legs straddling narrow saddle, elongated motorcycle nose right, exposed chassis, two small circular anti-gravity thrusters replacing wheels. Small cyan plumeleft. Rider fully visible, neutraldark biker outfit, no weapons.
Bottom-right: cyan-white flying MOTORCYCLE with different helmeted courier rider sitting moreupright, hands onhandlebars, bothbootsattachedfootrests, compact luggagebox behindsaddle onleft, forward fairingright, two anti-gravity rings replacingwheels, shortwarm exhaust.
Keep vehicle silhouettes distinct, cars recognizablycars, bikesrecognizablyriddenbikes. Fronts alwaysright. Transparent alpha with emptyspace for cropping and animation inGodot.
