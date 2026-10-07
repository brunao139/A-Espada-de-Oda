# A Espada de Oda — versão 0.1.6

Projeto Godot 4.7.2, edição padrão, renderização Compatibility. Abra project.godot, aguarde a importação e pressione F5. Uma tecla pula a abertura anime; START abre a cidade. OPTIONS ajusta volume e tela cheia.

A cidade tem 9.000 unidades, oito plataformas, tráfego decorativo ao fundo e 14 Ajoguns. O personagem e os inimigos têm vida e reações de dano. Derrote os Ajoguns para liberar a ponte ou pressione R para reiniciar.

| Controle | Ação |
|---|---|
| A/D ou ←/→ | Correr |
| Espaço, W ou ↑ | Pular; segurar aumenta a altura; subir quando pendurado |
| S ou ↓ | Soltar a beirada |
| J ou Z no chão | GF1 → GF2 → GF3 → GF4 → GF5, com novos toques |
| J ou Z no ar | GFA1 → GFA2 → GFA3 → GFA4 |
| K ou X | GFF1 descendente → GFF2 frontal |
| R | Reiniciar o trecho |
| F1 | Mostrar colisão e alcance |

Novos toques após 45% do golpe enfileiram a continuação; segurar não repete. O GF5 é um soco direito que mantém o braço estendido no final, arremessa o Ajogun e provoca tremor leve na câmera. Todos os golpes estão 20% mais lentos. A velocidade de corrida e a física do salto normal foram preservadas. O quinto toque pode ser enfileirado durante o giro do GF4.

Os Ajoguns piscam e sobem levemente ao receber cada impacto. Um combo terrestre completo causa seis impactos e derrota o inimigo padrão no arremesso final. O corpo termina apoiado no chão. Inimigos que sobrevivem ao arremesso se levantam.

O salto normal mantém dois giros; ataques aéreos são limitados a quatro por voo. Corpo, plataformas, teto e beiradas conservam colisão. As artes usam recortes medidos e pivôs próprios; preserve assets/animation_manifest.json e os arquivos .uid e .import.

332 verificações do projeto e 18 verificações dos recursos do executável passaram na preparação desta versão. Exemplo de teste:

```text
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/finisher_test.gd
```

Documentação: [continuidade](../CONTINUAR_A_ESPADA_DE_ODA.md), [GF5 e arremesso](assets/gf5/GF5_E_ARREMESSO.md), [GF4 e GFA4](assets/gf/GF4_GFA4.md). Para exportar, instale os modelos Godot 4.7.2 e use o preset Windows Desktop. Crie a pasta Windows na raiz do repositório para usar o destino padrão.
