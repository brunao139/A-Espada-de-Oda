# GF5 e reação dos Ajoguns — 0.1.6

Criado em 06/10/2026 com a ferramenta integrada de geração de imagens (image_gen), usando as artes do próprio projeto como referência.

## Comportamento

- Todos os ataques do Youkai usam velocidade 0,8: 20% mais lentos, com duração 25% maior. Movimento e pulo comuns mantêm a velocidade.
- Cinco toques em J/Z encadeiam GF1–GF5 no chão. O quinto toque pode ser enfileirado durante a segunda metade do GF4. Pausa, troca de tipo ou dano recebido quebram a cadeia. Segurar não repete ataques.
- GF5 é um soco direto do braço direito. Possui 12 poses; a última fica estendida por 0,30 s. Altura calibrada em 176 unidades em cada pose, escala uniforme em X/Y, apoio medido nos pés. A lâmina permanece guardada.
- Janela lógica do GF5: 0,24–0,36 s; duração lógica 0,64 s; duração real 0,80 s. Caixa frontal 92×52, centro (±82, −108), dano 1 uma vez por alvo.
- GF5 inicia um tremor de 0,20 s e amplitude até 3 px por eixo, mesmo se errar. A câmera retorna exatamente ao deslocamento zero; a interface fica estável.
- Cada impacto no Ajogun reinicia uma piscada de 0,24 s alternando clarão branco e transparência. Impulso vertical −170 produz uma elevação de aproximadamente 6 px; não aumenta cumulativamente a velocidade a cada hit.
- O quinto golpe lança o alvo com velocidade (±440, −350). São 12 poses de voo e 12 de aterrissagem/recuperação. O alvo vivo se levanta; morto termina na quarta pose da aterrissagem, deitado. Colisão com piso e paredes continua ativa durante o voo.
- Um combo terrestre conectado causa seis impactos: dois em GF1 e um em cada GF2–GF5. Com vida padrão 6, o Ajogun morre no arremesso final. A contagem de derrotas ocorre uma única vez.

## Arquivos e reprodução

PNG originais preservados em assets/gf5/right_punch.png e assets/ajogun_launch/{launch,landing}.png. Metadados em assets/animation_manifest.json. tools/measure_finisher.gd mede as novas folhas sem substituir os registros antigos; tools/isolate_finisher_frames.gd identifica cada corpo conectado e valida margens livres nos recortes. Não substituir por recortes ingênuos de uma grade.

O teste tests/finisher_test.gd usa a velocidade padrão 0,8 e mede a duração de todos os ataques, o encadeamento por entradas reais, alvos vivos, o arremesso, apoio no piso e tremor. Os testes históricos que têm tempos fixos usam explicitamente 1,0 para conservar a referência temporal de suas verificações de física/recortes. tests/ajogun_test.gd e tests/art_v2_test.gd também rodam na velocidade padrão.

## Prompts utilizados

### gf5

Use case: stylized-concept. Production transparent sprite sheet for 2D side-scrolling game. Use reference image solely for exact character design and cel shaded thick outlined drawing style: Youkai, gold armor, dark undersuit, red-orange V horns and cyan eyes. Create exactly 12 full body poses, 4 columns by 3 rows, equal cells, generous transparent gutters, no text, no grid. Fixed camera, identical anatomical scale, feet baseline constant in every cell, same helmet-to-feet height in all poses. Character facing RIGHT, side/three-quarter side game view. Animation GF5: powerful straight punch with ANATOMICAL RIGHT ARM (near arm visible to camera), left fist stays guarding ribs. Row1: guard, right fist chambered, hip torque anticipation, start straight right punch. Row2: extension progressively, full horizontal right fist at chest height, full extension powerful planted stance, subtle forward shoulder follow through. Row3: four nearly identical fully EXTENDED right-arm poses for a strong finishing hold; NO arm retraction. Both feet remain grounded, no jump, no sword, no kick, no effects or trails, no shadows outside character. Maintain original compact hero proportions and same head and armor size across all 12 poses; never scale up the punch frames. Real transparent background.

### launch

Use case: stylized-concept. Production transparent sprite sheet for 2D side scrolling game. Reference exact Ajogun enemy identity and outlined cel-shaded game art: gray muscular demon, curled dark ram horns, claw hands, brown ragged pants and waistcloth, ankle wraps. Exactly 12 full body frames in equal 4 columns x3 rows, broad transparent gutters. No text/grid/shadows/effects. Same character scale and anatomy in every cell. Character faces RIGHT while being punched backward toward LEFT. Sequential airborne knockback poses: row1 chest impact recoil, arms opening, feet leave ground, back arch. Row2 flying BACKWARD LEFT, feet pointing right, torso leaning farther backward, arms flailing naturally; row3 descending into an almost horizontal supine fall, head toward LEFT and feet toward RIGHT, body preparing to hit ground on back. Last pose horizontal just above ground, back down. Preserve horn, face, limbs and costume consistency; no somersault, no copies or extra characters in each cell. Transparent background. Enough margin for entire horizontally stretched body.

### landing

Use case: stylized-concept. Production transparent sprite sheet for 2D side scrolling game. Exact Ajogun identity/style from reference: gray silver muscular demon, dark curled ram horns, brown ragged pants/waistcloth, ankle wraps, black outlines cel shading. Exactly 12 sequential full-body frames, 4 columns x3 rows, equal cells, ample transparent gutters, fixed anatomical scale, consistent ground baseline. No text, no grid, no ground, no shadows/effects. Animation landing on BACK after thrown backward toward LEFT, then getting up facing RIGHT. Row1 frames1-4: back impacts ground with HEAD LEFT and FEET RIGHT, legs rebound slightly, settles, fourth frame completely lying flat on his back motionless head LEFT feet RIGHT (usable death hold). Row2 frames5-8: rolls onto side, braces claw on ground, lifts torso, seated turning to face RIGHT. Row3 frames9-12: one knee grounded, crouches, rises, final standing combat guard facing RIGHT. Keep exact body proportions through foreshortening, body and horns not cropped. Transparent background.

### Revisão de isolamento: launch

undefined

### Revisão de isolamento: landing

undefined
