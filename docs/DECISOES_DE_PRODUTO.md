# Wrong Move — decisões de produto

Registro da descoberta para a especificação com Spec Kit. Atualizado em 24/10/2026.
Descoberta concluída. A especificação do release1.0.0 está fechada; implementação e validação do aplicativo ainda não executadas.

## Origem e prioridade

- As respostas do autor durante o planejamento orientam as decisões.
- `WRONG_MOVE_GDD.md` é uma referência de visão com propostas e lacunas preenchidas por IA; suas afirmações não constituem requisitos confirmados.
- Respostas explícitas do autor são decisões de produto. Em24/10/2026 ele também delegou ao assistente o fechamento de tudo até a entrega; defaults decorrentes dessa delegação estão identificados nos contratos, sem atribuí-los como escolhas individuais dele.

## Confirmado pelo autor

- Jogo de pôquer 100% gratuito, com o motor e as regras reais de pôquer como centro da experiência.
- Android primeiro; PC em etapa posterior.
- Celular sempre em orientação vertical.
- Inspiração em Balatro: envolvimento, ritmo rápido, repetição prazerosa, progressão e desafio.
- Priorizar qualidade do jogo de pôquer; personagens e árvores de habilidade ficam para possíveis atualizações futuras.
- Suportar duelos entre jogador e bot e mesas com múltiplos bots, com até seis participantes contando o jogador.
- O formato de cada mesa é definido pelo jogo, alternando duelos e mesas de três a seis participantes. O formato é mostrado antes do desbloqueio.
- Acumular fichas para comprar um passe de acesso à próxima mesa.
- O passe desbloqueia a mesa permanentemente.
- Cada desafio define uma quantidade inicial de fichas de jogo, igual para o jogador e todos os bots. O saldo acumulado fora da partida não concede um stack inicial maior.
- O acesso é cobrado só no desbloqueio. Tentativas posteriores gratuitas; dicas têm custo definido pela baseline de economia.
- Os desafios são torneios de eliminação: no duelo, vencer significa ficar com todas as fichas; nas mesas com múltiplos bots, ser o último participante com fichas.
- Perder mantém a mesa desbloqueada e permite tentar novamente imediatamente, inclusive quando o saldo de progressão estiver zerado.
- As fichas apostadas pertencem à tentativa; não são retiradas do saldo persistente para pagar novas tentativas.
- Progressão com referência em Angry Birds, em caminho linear de desbloqueios permanentes.
- Direção de dificuldade aceita: condições equilibradas, adversários mais fortes e maior pressão dos blinds.
- A campanha segue uma sequência linear, variando duelos e mesas com mais bots.
- A primeira mesa fica disponível desde o início, sem custo.
- Para desbloquear a próxima mesa, é necessário vencer a anterior e pagar o custo em fichas de progressão.
- Vitórias concedem fichas de progressão; a primeira vitória em cada mesa concede um bônus maior.
- Repetir mesas já vencidas também concede fichas, permitindo acumular saldo para novos desbloqueios.
- Somente vitórias concedem fichas de progressão; derrotas não concedem recompensa.
- As campanhas normal e Hardcore têm mesas infinitas com dificuldade crescente.
- A escalada combina força dos bots, diferentes estilos de jogo e estruturas de blinds mais exigentes. Aumentar apenas os valores nominais das fichas não conta como dificuldade maior.
- A força dos bots tem um limite prático; mesas avançadas continuam variando as combinações de desafios, sem prometer inteligência ilimitada dos adversários.
- O jogo funciona offline e salva automaticamente a partida para continuar de onde parou após fechar o aplicativo.
- Variante confirmada: Texas Hold'em no-limit, com duas cartas privadas, cinco comunitárias e possibilidade de all-in.
- O cronômetro de decisão existe somente no Hardcore. O modo normal permite decidir sem contagem regressiva.
- Ações e animações favorecem ritmo rápido; tempos definidos em DESIGN.md, AI_RELEASE.md e release-baseline.json.
- Ensinar iniciantes é requisito central: tutorial de qualidade e linguagem fácil de entender, voltados também a quem não conhece pôquer.
- Assistência confirmada: tutorial curto e opcional, consulta ao ranking das mãos e indicação da combinação atual.
- Dicas sugerem uma ação e explicam o motivo. Sob delegação, o release não exibirá probabilidades numéricas.
- A linguagem da interface será português brasileiro informal e fácil de entender, acompanhada do termo técnico entre parênteses quando útil, como `Pagar 40 (call)`.
- Tutorial prático, separado, opcional e revisitável; cinco lições e roteiro fechados em CONTEUDO_RELEASE.md.
- Hardcore terá caminho separado e progresso próprio.
- A primeira versão inclui apenas as campanhas normal e Hardcore, além do tutorial e das telas de apoio. O autor retirou a partida livre do escopo.
- Campanhas normal e Hardcore têm saldos de progressão separados, e cada uma começa com sua primeira mesa gratuita.
- Metas iniciais de duração aceitas para playtest: aproximadamente 3–5 minutos por duelo e 5–10 minutos por mesa maior. Não são limites rígidos nem garantia de duração.
- Hardcore disponível desde o início, apresentado como recomendado para quem já sabe jogar, com bots mais fortes e cronômetro.
- Parâmetros iniciais do Hardcore para playtest: 10 segundos por decisão e reserva de 30 segundos por torneio. A reserva é consumida automaticamente quando o tempo da decisão termina.
- Esgotados o tempo da decisão e a reserva, executar check se legal; se houver aposta para pagar, executar fold.
- Bloquear a tela ou colocar o app em segundo plano pausa e salva a partida, inclusive no Hardcore. A retomada preserva o tempo restante, sem renovar o cronômetro ou a reserva.
- A pausa no Hardcore permite pensar fora do cronômetro; esse comportamento foi explicitado e aceito em favor das interrupções comuns do celular.
- Direção visual confirmada: mesa verde-escura, cartas grandes, marfim e vermelho, com efeitos rápidos inspirados em Balatro.
- Composição mobile vertical aceita como ponto de partida: adversários no topo, comunitárias no centro, mão do jogador e controles na parte inferior.
- Após cada mão, apresentar resultado breve explicando o motivo da vitória quando aplicável, por exemplo comparação das combinações no showdown.
- Disponibilizar revisão da última mão, mostrando apenas cartas que foram reveladas durante a partida.
- Fora do Hardcore, após alguns segundos de indecisão, oferecer o botão `Quer uma dica?`. O conteúdo só é aberto por escolha do jogador; não abrir explicações automaticamente.
- No Hardcore, desativar essa ajuda, mantendo valores, nomes das ações e consulta às regras disponíveis.
- Dicas durante partidas custam fichas de progressão da campanha normal, com preço crescente conforme a dificuldade da mesa e exibido antes da confirmação.
- O pagamento da dica não retira fichas da partida, não altera o pote e não modifica os stacks.
- Tutorial, significado dos botões e consulta às regras permanecem gratuitos; a cobrança é pela orientação sobre a jogada atual.
- A orientação inclui recomendação explicada, sem probabilidades numéricas no release.
- Controles de aposta na parte inferior, com botões grandes para desistir, passar/pagar e apostar/aumentar.
- Seleção do valor por barra de ajuste, botões de diminuir/aumentar e atalhos de meio pote, pote e todas as fichas. Os valores disponíveis devem respeitar as ações legais.
- Apostar/aumentar exige confirmar o valor escolhido; ajustar o seletor não executa a aposta.
- Acessibilidade: opção de naipes em quatro cores, textos ampliáveis e animações reduzidas.
- Configurações separadas para música, efeitos e vibração.
- Sem anúncios, compras, energia, espera obrigatória para jogar ou login obrigatório.
- Dicas pagas sugerem uma ação com explicação breve, usando apenas as cartas do jogador e informações públicas. Não conhecem cartas ocultas dos bots ou cartas futuras e não garantem vitória.
- A mesa oferece `Salvar e sair` e `Abandonar torneio`. Abandonar requer confirmação e encerra a tentativa como derrota.
- Cada campanha mantém uma partida em andamento independente.
- Bots exibem fichas, última ação e indicador simples do estilo, como agressivo ou cauteloso, sem personagens ou histórias nesta versão.

## Decisões encerradas por delegação

- Economia, gerador, blinds e valores: ECONOMIA_E_PROGRESSAO.md e release-baseline.json.
- Regras/casos de borda: POKER_RULES.md; IA/dicas: AI_RELEASE.md.
- Save e relógio: PERSISTENCIA_RELEASE.md, com pausa normal exata e perda máxima1 s, sem devolver tempo, em kill abrupto.
- Textos, tutorial, assets, fontes, áudio e defaults: CONTEUDO_RELEASE.md e DESIGN.md.
- Entrega: APK assinado1.0.0 + fontes + evidências, Android9+ ARM64, sem postagem pública/loja.
- Gate de conclusão: R01–R12 em RELEASE_ANDROID.md; tarefas e testes ainda pendentes de execução.
- Não resta pergunta de produto bloqueante. Ajustes de validação têm processo e limites definidos, sem perguntas para cada número.

## Consolidação

- Especificação inicial: `specs/001-mobile-poker/spec.md`.
- Descoberta, plano e critérios de entrega concluídos; balanceamento tem defaults e gates para ajuste pelo implementador.
- Plano técnico e marcos: `specs/001-mobile-poker/plan.md`; tarefas por história: `specs/001-mobile-poker/tasks.md`.
- Telas: `docs/MOBILE_UX.md`; propostas de números e geração: `docs/ECONOMIA_E_PROGRESSAO.md`; contratos do motor: `docs/POKER_RULES.md`.
- Técnica e números foram fechados pelo assistente sob delegação, mantendo rastreabilidade da origem.

## Próxima etapa

Implementar tasks.md e produzir as evidências de release. Não confundir documentação fechada com aplicativo entregue.
