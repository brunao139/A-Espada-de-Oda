# A Espada de Oda — continuidade 0.1.6
Atualizado em 06/10/2026.

## GF5 e novas reações de impacto
- GF5 acrescentado ao combo terrestre: soco direto com o braço direito, 12 poses e permanência do braço estendido no final. Personagem calibrado em 176 unidades de altura; pivô alinhado aos pés.
- Cinco toques J/Z encadeiam GF1–GF5. É possível enfileirar o quinto toque durante a segunda metade do GF4. Segurar o botão não repete a sequência.
- Velocidade de todos os golpes do Youkai reduzida em 20% (duração 25% maior). Movimento, salto e gravidade comuns preservados; animação, rastro e dano compartilham o mesmo relógio.
- Cada hit faz o Ajogun piscar por 0,24 s e subir cerca de 6 unidades, com impulso vertical −170.
- GF5 arremessa o Ajogun para trás: impulso horizontal 440, vertical −350. Duas folhas novas, com 12 poses de voo e 12 de aterrissagem/recuperação. Alvo vivo se levanta; morto fica deitado e alinhado ao piso.
- GF5 gera tremor leve de câmera de 0,20 s, até 3 px por eixo, sem mover a interface nem deixar desvio residual.
- Ao acertar tudo, o combo causa seis impactos e derrota o Ajogun padrão de vida 6 no arremesso final.

Artes: assets/gf5/right_punch.png, assets/ajogun_launch/launch.png e landing.png. Prompts completos, parâmetros e reprodução em assets/gf5/GF5_E_ARREMESSO.md. Geradas pela ferramenta integrada de imagens. Recortes medidos em assets/animation_manifest.json; executar tools/measure_finisher.gd e tools/isolate_finisher_frames.gd somente para recalcular as novas folhas.

O projeto editável no repositório está em AEspadaDeOda/project.godot. Executável separado: A-Espada-de-Oda-Ajoguns-0.1.6.exe. Godot 4.7.2 stable / Compatibility. Esta atualização reúne no repositório os trabalhos locais até a versão 0.1.6.

## Validação 0.1.6
332 verificações do projeto passaram (286 anteriores e 46 novas), mais 18 verificações usando os recursos incorporados ao executável. Inicialização do executável Windows confirmada; recortes e poses conferidos em renderização gráfica.
O teste novo finisher_test.gd exercita a velocidade padrão 0,8, duração de todos os golpes, combo completo nos dois lados, inimigo com IA ativa, piscadas, impulsos, sobrevivência, morte, apoio no piso, paredes e tremor. Testes históricos com tempos fixos usam explicitamente a velocidade de referência 1,0; os novos testes e as suítes de Ajoguns/arte usam a velocidade padrão. Avaliação artística em movimento permanece aberta ao autor.

## Histórico da base 0.1.5

## Mudanças desta versão
Ajoguns redesenhados com contorno escuro forte, sombras definidas e proporções de sprite de ação, usando o atlas do Youkai como referência de estilo. A identidade de demônio cinza com chifres, garras e tecido marrom foi preservada.

Sete folhas novas, geradas pela ferramenta integrada de imagens:
- assets/ajogun_v2/walk.png: 12 poses de caminhada.
- assets/ajogun_v2/run.png: 12 poses de corrida.
- assets/ajogun_v2/idle_hurt.png: 4 poses de respiração e 12 de dano.
- assets/ajogun_v2/attack.png: 16 poses de ataque.
- assets/ajogun_v2/death.png: 16 poses de queda e morte.
- assets/youkai_hurt/ground.png: 12 poses de dano no chão.
- assets/youkai_hurt/air.png: 12 poses de dano no ar.
Total: 72 poses de Ajogun e 24 de Youkai.

O Ajogun agora troca entre respiração, caminhada e corrida. O ciclo locomotor acompanha a distância percorrida. As 16 poses do ataque estão distribuídas entre preparação, impacto e recuperação sem mudar as janelas de dano existentes.

## Correção de alinhamento ao chão
O ponto de apoio da morte agora é medido na região opaca de cada pose, em vez de usar a mesma coordenada de atlas em toda a linha. Isso mantém o corpo em contato com o piso durante a queda e a pose final, inclusive nas plataformas e ao espelhar o personagem. A pose final é totalmente deitada. Não normalizar cada pose de morte para a altura de um personagem em pé.

Os recortes e pivôs ficam em assets/animation_manifest.json, incluído explicitamente na exportação. A folha idle_hurt possui contato entre pontas dos chifres de uma linha e o espaço da anterior; recortes poligonais isolam os pixels sem fragmentos vizinhos. Não substituir por uma grade automática. Medição reproduzível: tools/measure_new_art.gd, seguida por tools/fix_hurt_overlap.gd.

## Youkai recebendo dano
Reação própria no chão ou no ar, escolhida no instante do impacto, com 12 desenhos ao longo de 0,40 s. No ar, o pivô mantém o centro do corpo e não alinha pés recolhidos a um chão fictício. O dano cancela ataques e mantém o curto recuo e a proteção temporária. Ao terminar, o personagem recupera sua animação normal. Vida, combos, salto e beiradas seguem a base 0.1.4.

## Arquivos centrais
scripts/ajogun_frames.gd lê os recortes e as texturas; scripts/ajogun.gd controla ritmo e transições; scripts/youkai_hurt_frames.gd monta as novas animações do herói; scripts/youkai.gd seleciona e reproduz a reação.

## Validação
286 verificações passaram: arte v2 37, Ajoguns 34, regressão 34, beiradas 29, golpes aéreos 54, GFF2 14, GF4 33, escala da espada 34 e cidade 17. A conferência gráfica inclui todas as poses, morte espelhada, corpo no piso e as reações do Youkai. A avaliação artística em movimento permanece aberta ao autor.

## Execução e continuidade
Godot 4.7.2 stable, Compatibility. Abra project.godot e pressione F5. Abertura e menu preservados. O preset usa os modelos de exportação padrão do Godot 4.7.2; instale-os no editor antes de exportar. A pasta .godot é cache.

O projeto foi desenvolvido nesta cópia local da versão 0.1.4. Esta atualização reúne no repositório os trabalhos locais até a versão 0.1.6.

Controles: A/D ou setas para correr; Espaço/W/↑ para pular e subir beiradas; S/↓ para soltar; J/Z para GF e GFA; K/X para espada; R para reiniciar; F1 para colisões.

O pacote Windows passou também por 10 verificações dos recursos incorporados: fase, 14 inimigos, novas folhas e metadados, combos, espada, morte, apoio do cadáver, dano terrestre/aéreo e reinício. Total: 296 verificações.
