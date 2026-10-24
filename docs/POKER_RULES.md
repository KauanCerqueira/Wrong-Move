# Contrato do motor, regras v1 para release 1.0.0

Baseline fechada: Texas Hold'em no-limit digital de torneio, 2–6 participantes, sem ante, rake, recompra ou entradas tardias. Regras de conduta física/penalidades não são funções do app. Fontes consultadas em 24/10/2026: [TDA 2026 v1.1](https://www.pokertda.com/view-poker-tda-rules/), [Hold'em PokerStars](https://www.pokerstars.com/poker/games/texas-holdem/) e [ranking WPF](https://worldpokerfederation.org/poker/how-to-play-poker/poker-hand-rankings/). As convenções digitais explícitas abaixo encerram as escolhas do produto.

## Convenções digitais

- CardId 0–51, sem duplicatas; deck justo, sem manipulação por dificuldade. Queimar antes de flop/turn/river, sem exigir animação.
- Fichas/contribuições inteiras não negativas; soma constante no torneio. Progresso é externo a essa soma.
- Guardar contribuição por street e total da mão separadamente. `raise_to` é total da street.
- Motor expõe ações legais, call, limites e direito de aumentar; UI/bots não recalculam regras.
- Oferecer check se legal, sem cobrar por passar. Fold não precisa aparecer quando check basta.
- All-in sem decisões restantes completa board; se há dois com fichas que ainda podem apostar, a rodada continua.
- Fold não revela cartas. Mostrar todas as mãos não-foldadas no showdown; no all-in, revelar quando não houver mais apostas antes de completar o board. Sem opção de muck e sem revelar cartas que teriam vindo após uma mão encerrada por fold.

## Pontos a conferir e fixar em fixtures

Com base na referência: o incremento completo define o raise mínimo; all-in curto não reabre automaticamente; aumentos curtos acumulados podem reabrir conforme o valor enfrentado por cada jogador. Em heads-up, botão/SB age primeiro pré-flop e depois do BB pós-flop. Cada pote separado tem elegíveis próprios, e fold não retira a contribuição. Empates comparam cinco cartas e kickers, nunca naipe.

Fichas indivisíveis de empate vão aos vencedores a partir da esquerda do botão. Usar dead button e a política operacional exata abaixo. Não há regras de canto deixadas para decisão de produto posterior.

Fixtures próprias mínimas:

1. Categorias, A2345, dois trios, três pares e board que joga sozinho.
2. Blinds 10/20, raise para 60: incremento 40, mínimo seguinte 100.
3. All-in para 80 após raise para 60: aumento curto, direito de reabertura por jogador; também testar múltiplos curtos cumulativos.
4. Contribuições 100, 250, 400 sem fold: potes 300 e 300, devolver excedente 150. Excedente não coberto não vira pote de um só jogador.
5. Folds com contribuição, empate em side pot, stack inferior a blind/call, BB com opção de check e passagem de três para dois.

## Presets

`P` inclui todas as contribuições da mão antes da ação; `C` é o call restante. Para raise de fração `f` do pote após call: `contribuicao_atual + C + floor(f × (P + C) + 0,5)`. Limitar ao mínimo/máximo legal do motor e ao direito de aumento. Se não há raise legal, desabilitar o preset. `Tudo` é contribuição atual + stack. Confirmar sempre o total efetivo da street.

## Distribuição e posições, política digital fechada

Assentos físicos fixos em sentido horário; jogador humano em 0 e bots em 1..N−1. Botão inicial sorteado uniformemente entre participantes com RNG de posições independente do deck. Distribuir uma carta por vez em duas voltas, começando no primeiro participante à esquerda do botão e terminando no botão se ocupado. Blinds antes de distribuir; preflop começa depois do BB (exceto heads-up, começa no botão/SB); pós-flop no primeiro não-foldado depois do botão.

Após liquidar a mão, eliminar stacks zero. Com três ou mais sobreviventes: novo BB é o primeiro sobrevivente após o BB anterior; SB é o BB anterior se sobreviveu, senão não há SB nessa mão. A âncora do novo botão é o assento anterior ao BB antigo no anel de participantes que receberam cartas na mão encerrada, mesmo que esse assento tenha acabado de ser eliminado; permitir botão morto. Registrar esse anel no estado, sem confundi-lo com assentos que estavam vazios antes da mão. Essa política preserva progressão dos blinds sem transformar lacunas físicas antigas em ausência permanente de SB.

Ao restarem dois: manter o próximo BB calculado a partir do BB anterior; o outro é botão/SB. Depois alternar. Se um só sobreviver, terminar antes de cobrar novos blinds. Fixture posições 0/1/2 com botão0/SB1/BB2: elimina0 → botão2/BB1; elimina1 → botão2/BB0; elimina2 → botão1/BB0. Todas as ordens de eliminação de 2–6 precisam ter fixtures.

## Apostas e término da street

- BB nominal do nível define a aposta inicial pré-flop e o incremento mínimo mesmo quando o BB só consegue postar parte. `call_cost = min(stack, max(0, current_bet − street_contribution))`.
- Street pós-flop inicia sem aposta; bet mínima = BB nominal, salvo all-in menor. Raise mínimo normal = current_bet + último incremento completo. Aumentos menores só são aceitos se consomem todo o stack e o participante tem direito de aumentar.
- Uma abertura pós-flop all-in abaixo da mínima não é completada simplesmente até o BB. Exemplo: BB20, primeira aposta all-in5; próximo raise mínimo total25. Confirmado em [discussão técnica oficial TDA](https://www.pokertda.com/forum/index.php?topic=842.0). Isso evita importar regra de limit para no-limit.
- Raise completo reabre a ação dos outros e atualiza incremento. Raise curto mantém o incremento; quem já enfrentou aposta só pode aumentar novamente se o total adicional enfrentado desde sua última ação alcança incremento completo. Quem não agiu, ou só deu check antes da primeira aposta, conserva seu direito inicial de raise.
- Fechar street quando todos os participantes não-foldados com fichas agiram e igualaram o valor exigido, ou estão all-in. BB conserva opção após limps; dois checks não encerram prematuramente uma mesa com mais participantes.
- Se só resta um capaz de apostar, permitir call/fold se deve responder a aposta existente; caso contrário, fechar apostas. Não permitir apostar num pote vazio de possíveis pagadores.
- Ao encerrar, retornar contribuição não coberta. Decompor potes pelos níveis de contribuição total, incluindo quem foldou como contribuinte e excluindo-o dos elegíveis. Cada pote é resolvido separadamente. Estado alcançável nunca tem pote sem elegível; detectar isso como falha de invariante, sem escolher vencedor arbitrário.
- Depois de cada ação, testar primeiro vitória por folds, depois ações pendentes, depois runout/showdown. Nunca cobrar blinds da próxima mão antes de liquidar a anterior.

## Comparação e eliminações

Representar ranking como categoria + sequência de valores relevantes lexicográfica: straight flush(high), quadra(rank,kicker), full house(trio,par), flush(cinco valores), sequência(high), trinca(rank,dois kickers), dois pares(alto,baixo,kicker), par(rank,três kickers), carta alta(cinco). A2345 tem high5; não há wrap QKA23. Usar zero, uma ou duas cartas privadas. Royal é straight flush com high14; naipe não desempata.

No showdown todos os não-foldados exibem as duas cartas; posições no histórico obedecem às revelações, incluindo all-ins. Potes divididos podem impedir eliminação. Empates não geram vencedor de torneio duplo. Se vários forem eliminados na mesma mão, ordem informativa por stack no início da mão, empate compartilhado; como não há prêmio por colocação, isso não altera saldo.

## Exemplos adicionais de aceite

| Estado | Resultado obrigatório |
|---|---|
| BB20 só tem7 no pré-flop, há três jogadores | Call nominal20 para quem tem fichas; mínimo raise40; devolver parcelas sem cobertura quando aplicável. |
| Pós-flop BB20, A check, B all-in5, C call5 | A pode call5 ou raise para pelo menos25; o check anterior não consome seu direito diante da primeira aposta. |
| A aposta100, B all-in150, C all-in200, D call200, volta A | A enfrenta100 adicionais e pode aumentar para pelo menos300. |
| A aposta100, B all-in150, C call150, D all-in200, volta A e depois C | A pode raise; se A apenas call200, C enfrenta só50 adicionais desde seu call150 e não pode raise. |
| Contribuições100/250/400/400, um dos participantes de400 foldou | Construir potes400/450/300 com elegíveis próprios, sem reembolsar apostas cobertas por causa do fold. |

Invalidar ação fora do turno, valor fracionário, raise não-all-in abaixo do mínimo ou comando com revisão antiga. Não ajustar silenciosamente ação inválida recebida do agente; pedir nova ação/fallback legal. Apenas presets visuais fazem clamp antes da confirmação explícita.
