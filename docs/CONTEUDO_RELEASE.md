# Conteúdo fechado para 1.0.0

Decisões do assistente sob delegação do autor. Textos abaixo são baseline pt-BR; ajustes de espaço são permitidos mantendo significado e termos técnicos.

## Navegação e mensagens

| Contexto | Texto/ação |
|---|---|
| Início | `Normal`, `Hardcore`, `Aprender a jogar`, `Configurações` |
| Aviso Hardcore | `Já pegou o jeito? Aqui os bots são mais fortes e você tem tempo para agir.` / `Jogar Hardcore` |
| Mapa | `Mesa {table_index}`, `{participants} participantes`, `Seu saldo`, `Continuar torneio`; participants vem da configuração2–6, não do índice |
| Bloqueio | `Vença a mesa anterior para liberar esta.` |
| Compra | `Desbloquear por {x} fichas` / `O acesso é permanente. Jogar novamente é grátis.` |
| Sem saldo | `Faltam {x} fichas. Você pode ganhar mais nas mesas já liberadas.` |
| Ações | `Desistir (fold)`, `Passar (check)`, `Pagar {x} (call)`, `Apostar {x} (bet)`, `Aumentar para {x} (raise)`, `Apostar tudo (all-in)` |
| Sua vez | `Sua vez` / `Para continuar: {x}`; com call all-in mostrar `Pagar {x} (all-in)` |
| Dica | `Quer uma dica?` / `Ver dica por {x} fichas` / `Ela ajuda a pensar, mas não garante vitória.` |
| Dica sem saldo | `Seu saldo não cobre a dica. Você pode continuar jogando normalmente.` |
| Vitória por fold | `Você levou o pote: os outros desistiram.` |
| Showdown | `{vencedor} levou {x} com {mão}.` / `Empate: pote dividido.`; side pots listados separadamente |
| Torneio | `Mesa vencida!`, `Vitória: +{x}`, `Primeira vitória: +{bônus}` / `Dessa vez não deu. Tentar de novo é grátis.` |
| Pausa | `Continuar`, `Regras`, `Salvar e sair`, `Abandonar torneio` |
| Abandono | `Abandonar este torneio? Conta como derrota. A mesa continua liberada.` / `Continuar jogando` / `Abandonar` |
| Save falhou | `Não conseguimos salvar. Sua última gravação está preservada.` / `Tentar novamente`; bloquear novos comandos econômicos até resolver |
| Backup recuperado | `Recuperamos sua última gravação válida.` |
| Save futuro | `Esta gravação é de uma versão mais nova. Atualize o jogo para continuar.` |
| Saves inválidos | `Não foi possível abrir o progresso. Nada foi apagado.` / `Tentar novamente` / `Iniciar novo progresso` com confirmação dupla explícita |
| Sobre | `Pôquer offline com fichas fictícias. Sem compras ou anúncios. O progresso fica neste aparelho; desinstalar ou apagar os dados remove a gravação.` |

## Glossário gratuito

- **Mão**: cartas e apostas de uma rodada completa, até o pote ser entregue.
- **Pote (pot)**: fichas colocadas em disputa nesta mão.
- **Suas fichas (stack)**: quanto você ainda pode apostar neste torneio.
- **Cartas da mesa (board)**: cartas comunitárias usadas por todos.
- **Posição do botão (dealer/button)**: marca que orienta a distribuição e a ordem de ação; muda entre mãos.
- **Apostas obrigatórias (blinds)**: small blind e big blind, cobrados antes das decisões; não são taxa da campanha.
- **Passar (check)**: continuar sem colocar mais fichas quando não há aposta para pagar.
- **Pagar (call)**: colocar o necessário para acompanhar, até o limite das suas fichas.
- **Apostar (bet)**: abrir uma aposta na rodada; **aumentar (raise)** é elevar uma aposta existente.
- **Desistir (fold)**: sair desta mão, sem recuperar o que já colocou no pote.
- **Apostar tudo (all-in)**: colocar todas as fichas restantes; você continua disputando os potes que cobriu.
- **Desempate (kicker)**: carta usada para decidir entre combinações da mesma categoria.
- **Mostrar as cartas (showdown)**: comparar as melhores mãos dos participantes que restaram.
- **Pote separado (side pot)**: disputa entre quem colocou fichas além do valor coberto por outro participante.

Ranking: sequência do mesmo naipe (straight flush), quadra, full house, flush, sequência, trinca, dois pares, um par, carta alta. Royal flush aparece como straight flush mais alto, não categoria extra. Exemplos e desempates conforme POKER_RULES.md.

## Tutorial de cinco lições

Treino separado; cenário preparado identifica `Treino: cartas de exemplo`. Não alterar cartas de campanha. Usar testes para conferir todas as combinações exibidas.

| Lição | Texto principal | Interação e condição de conclusão |
|---|---|---|
| 1. Suas cartas e a mesa | `Estas duas cartas são suas. As cinco da mesa são de todo mundo. Vale a melhor combinação de cinco cartas, usando quantas das suas você quiser.` | Mostrar jogador A♥ K♦, bot Q♠ Q♣ e board A♣ 7♥ 2♠ 9♦ 3♣. Tocar próprias/comunitárias; avançar após ver par de ases vencer par de damas. |
| 2. Passar e pagar | `Sem aposta para acompanhar, você pode passar (check). Se alguém apostar, pagar (call) coloca as fichas necessárias para continuar.` | Em flop K♥ 7♣ 2♦, jogador 8♥ 8♠: primeiro check legal com call zero; em decisão seguinte bot aposta 20 e jogador toca Pagar 20. Dois checkpoints independentes e salvos do treino. |
| 3. Apostar e aumentar | `Você escolhe quanto arriscar. Aumentar para 60 significa deixar sua aposta desta rodada em 60, não adicionar 60.` | Pré-flop blinds 10/20, jogador no SB seleciona 60, confirma e vê gastar mais 50; etapa mostra all-in com aviso didático e sem debitar campanha. |
| 4. Comparar e desistir | `Nem sempre precisa mostrar a melhor mão: se todo mundo desistir, o pote é seu. Quando mostram, a combinação e as cartas de desempate decidem.` | Jogador A♥ Q♦, bot J♠ 10♣, board K♥ K♦ 7♠ 7♣ 2♦: ambos têm reis e setes, jogador vence pelo ás de desempate. Em checkpoint separado, bot folda diante da aposta do jogador sem revelar cartas. Ranking grátis disponível. |
| 5. Seu primeiro torneio | `Todo mundo começa com as mesmas fichas. Quem fica com todas vence. Os blinds sobem e você pode fechar o jogo para continuar depois.` | Mini-duelo preparado com stacks 100, blinds 5/10, jogador A♥ A♦, bot K♠ K♣, board A♣ 7♥ 2♠ 9♦ 3♣; guiar call de all-in e comparar. Mostrar como abrir mesa 1, deixando claro que a vitória do treino não paga fichas. |

Pular/repetir/revisitar em qualquer lição. Nenhuma compra, limite de tempo ou punição por tentativa errada no tutorial; explicar e permitir novamente. Checklist interno de lições, sem conquistas ou árvore de habilidades.

## Assets de produção

- Cartas vetoriais originais: 52 faces, verso único, quatro ícones de naipe, variação de cores por tema. Base 240×336; leitura garantida reduzida. As variantes usam dados/tintas, sem duplicar 104 texturas desnecessariamente.
- Ícone original 7♥/2♠, master SVG e PNG 1024×1024; exportar ícone 192×192 e adaptive foreground/background 432×432 e monocromático. Sem usar ícone padrão do Godot.
- UI: marcador dealer, fichas, pausa, som, vibração, voltar e relógio como SVGs simples originais; nenhum rosto/avatares narrativos.
- Noto Sans Regular/Semibold para UI e Noto Serif Regular para marca; incorporar arquivos e licenças correspondentes, verificando os arquivos upstream em [Noto Fonts](https://github.com/notofonts/latin-greek-cyrillic). Não presumir que nome de fonte substitui obrigação de licença.
- Áudio original: 8 efeitos (carta, check, call, raise, fold, pote, vitória e alerta), WAV mono 44,1 kHz até 0,5 s; loop instrumental original OGG estéreo 60 s, volume discreto. Sem samples cuja licença seja desconhecida. Créditos referenciam autor/fonte/licença de cada arquivo.
- Arte final segue DESIGN.md, preserva identidade da referência do logo sem depender de raster conceitual como único ícone. Placeholder é permitido no protótipo, não no gate R12.

Defaults: música 35%, efeitos 70%, vibração desligada, texto 100%, quatro cores e reduzir movimento desligados. Alertas textuais nunca dependem de som. Tela Sobre contém versão, licenças e texto de privacidade local. Não criar estatísticas públicas ou cosméticos como condição do release.
