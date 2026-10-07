# Integrar os combos aéreos do outro computador

**Situação em 07/10/2026:** a atualização para 0.1.6 reúne a cidade expandida, GFA1–GFA4, GF1–GF5 e os Ajoguns. A orientação abaixo é histórica. A base integrada foi validada com testes de movimento, combate, beiradas, cenário e inimigos; não é necessário repetir a integração dos mesmos arquivos. Antes de trazer qualquer outra cópia ainda não enviada, preserve seus commits e compare as diferenças.

O autor informou em 29/09/2026 que os novos golpes no ar existem apenas no outro computador. A ampliação da cidade foi feita separadamente, a partir de 0a3a1d1.

Ao retomar naquele computador:
1. Ler o arquivo de continuidade local e conferir git status antes de modificar arquivos.
2. Preservar os assets e scripts dos golpes aéreos. Fazer um commit local com esse trabalho, incluindo arquivos novos necessários.
3. Buscar a main do GitHub e integrar as duas linhas de trabalho por merge. Se houver conflitos, manter os combos aéreos e a cidade expandida.
4. Conferir especialmente movement_lab.tscn e lab.gd caso a versão local também os tenha alterado. A fase nova tem 9.000 unidades, oito plataformas no total (quatro adicionais), CityDetails e tráfego pequeno somente no fundo. NearTraffic e dez plataformas da expansão foram removidos a pedido do autor para reduzir a poluição visual. A geometria inicial permanece.
5. Não substituir os arquivos de combate locais por versões antigas do GitHub. Esta melhoria de cenário não modificou o controlador do Youkai, HUD, espada ou beiradas.
6. Importar o projeto no Godot, executar os testes do cenário e as regressões de combate/pulo/beirada. Atualizar testes quando os novos golpes aéreos alterarem intencionalmente o comportamento esperado.
7. Testar os ataques no ar, exportar e enviar o resultado combinado ao GitHub.

A nova abertura continua em espera, sem gastos.
