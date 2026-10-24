# Bots e dicas, baseline 1.0.0

Agentes locais, sem LLM ou solver obrigatório. Força 0–8, três estilos visíveis, configuração determinística e testes. `release-baseline.json` fixa amostras e ruído; algoritmo abaixo é baseline executável, não promessa GTO.

## Informação e aleatoriedade

Cada bot recebe cópia de suas duas cartas, board, stacks, posição, contribuições públicas, últimos valores e ações legais. Não recebe Deck, seed de distribuição, mãos dos outros, histórico privado ou save. Bots não trocam suas cartas. Dica recebe exatamente a perspectiva pública do jogador mais suas próprias cartas. Separar RNG de decisão, estimativa, deck e gerador; persistir estados necessários sem expô-los na UI.

Equidade por Monte Carlo: remover apenas cartas conhecidas da observação, amostrar sem reposição mãos possíveis dos oponentes e board restante, dividir empates proporcionalmente. Pré-flop e pós-flop usam o mesmo limite de informação. Para comparar candidatos, usar as mesmas amostras da decisão; não consultar o deck real nem o resultado futuro.

## Política inicial de decisão

1. Enumerar fold quando permitido, check ou call e até quatro alvos legais de bet/raise: mínimo, meio pote, pote e all-in; remover duplicatas e aumentos proibidos.
2. Calcular equidade `e` contra os adversários não-foldados da observação. Perfil cauteloso aplica margem −0,05, equilibrado 0 e agressivo +0,05; limitar resultado a [0,1].
3. Se existe call `C`, calcular limiar `C/(P+C)`, onde P já inclui contribuições na mão. Limite de tolerância para pagar: cauteloso exige margem +0,04, equilibrado +0,02, agressivo 0. Fold só quando equidade ajustada+ruído ficar abaixo desse limiar e não existe check.
4. Com check disponível, usar check como fallback; considerar bet/raise por valor quando equidade ajustada supera `1/N + 0,15`, N = participantes vivos na mão. Escolher meio pote, pote ou all-in conforme excedente acima do limiar: <0,10, <0,25 ou ≥0,25; limitar ao stack e ao mínimo legal.
5. Blefe só com raise legal e observação de chance plausível de fold: frequências-base 0,02/0,05/0,10 para cauteloso/equilibrado/agressivo, divididas pelo número de adversários. Normal de força 0–2 não adapta; força ≥3 pode multiplicar por 0,5–1,5 conforme frequência pública de folds, apenas depois de 20 oportunidades observadas. Não usar cartas que foram foldadas para inferir resultados reais.
6. Ruído de decisão uniforme simétrico conforme força, sorteado uma vez. Não introduzir erro escolhendo ação ilegal. All-in curto é legal mesmo sem raise completo; call all-in respeita limites e direito de ação.

Esta heurística é deliberadamente simples: não usar a expressão IA competitiva/GTO como alegação de desempenho perfeito. Se a força maior não demonstrar vantagem no teste pareado, ajustar margens/blefes/ranges sem mudar baralho e registrar o balance_version.

Hardcore usa forças3–8, Normal0–5 por tier. Estilos se repetem sem personagens. Cálculo em frames/worker usa cópia imutável e quantidade FIXA de amostras da baseline, não amostragem interrompida por tempo de parede; feedback até120 ms após conclusão. Mesmo input/RNG sempre usa o mesmo número de amostras. Gates exigem concluir até500 ms no hardware-alvo; se falhar no desenvolvimento, otimizar ou reduzir contagens da baseline por força e repetir comparativos.

Em falha excepcional de cálculo ou estouro do orçamento em runtime, não escolher uma ação diferente a partir de uma amostra parcial: retornar BOT_BUDGET_EXCEEDED, pausar a sessão e permitir repetir a mesma decisão/seed, sem consumir tempo humano nem alterar cartas. Deadline é erro operacional, não ramo estratégico. Resultado tardio de revisão antiga é descartado. A matriz de release não pode registrar esse erro nos ensaios de desempenho. Não criar fallback dependente de relógio que quebre o determinismo.

## Dica paga

Uma compra por decision_id do jogador no Normal. Oferecer após 8 s de tempo ativo nessa decisão; pausar não zera contagem. Preço mostrado antes; abrir só após confirmação. Usar política equilibrada, força 5, sem ruído nem blefe aleatório para obter recomendação estável. Não exibir percentuais de equidade no release.

Explicações por caso: check, `Você pode ver como a rodada segue sem colocar mais fichas agora.`; call, `O valor para acompanhar parece razoável para a força estimada da sua mão.`; raise, `Sua mão parece forte para pressionar. O valor sugerido ainda arrisca suas fichas.`; fold, `A aposta parece cara para a força estimada desta mão.` Acrescentar `É uma estimativa, não uma garantia.` Empates de escolha favorecem check/call, não ação mais cara.

Débito e conteúdo persistidos juntos. Saldo insuficiente não cobra e não bloqueia jogada. Falha de cálculo ou persistência não entrega débito parcial. Conteúdo comprado reabre sem custo até nova decisão; uma nova ação/turno invalida o contexto anterior, não a revisão meramente visual ou checkpoint de relógio.

## Testes de aceite

Toda ação em 10.000 observações aleatórias é legal; teste metamórfico troca ocultos reais preservando decisão com mesma observação/RNG. Comparar forças extremas em 2.000 duelos pareados por seeds e posição, com estilos iguais: força 5 Normal versus força 0 deve ter taxa de vitória pelo menos 55%; força 8 Hardcore versus força 5 pelo menos 52%. Ajustar política até passar, sem alterar cartas ou dar informação extra. Não exigir que toda diferença de nível produza aumento estatisticamente significativo.
