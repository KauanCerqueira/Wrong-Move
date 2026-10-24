# Feature Specification: Wrong Move — pôquer mobile

**Feature Branch**: não criada; especificação independente de branch.

**Created**: 2026-10-24

**Status**: Especificação fechada para implementação e entrega Android1.0.0; aceite do aplicativo ainda não executado.

**Delegação**: O autor autorizou o assistente a resolver decisões restantes em24/10/2026. Defaults e critérios de entrega são normativos; ajustes exigidos por testes seguem `docs/RELEASE_ANDROID.md`.

**Input**: Decisões do autor registradas em `docs/DECISOES_DE_PRODUTO.md`: jogo gratuito de Texas Hold'em no-limit para Android, vertical, offline, com campanhas Normal e Hardcore infinitas e partidas rápidas. PC será uma etapa posterior.

## User Scenarios & Testing

### User Story 1 - Disputar um torneio de pôquer (Priority: P1)

O jogador disputa um duelo ou uma mesa de até seis participantes, com controles acessíveis e regras corretas, até vencer ou ser eliminado.

**Why this priority**: O pôquer é o centro da experiência; progressão e apresentação dependem de partidas confiáveis.

**Independent Test**: Completar um torneio com jogador e bots, incluindo apostas, all-ins, showdown e eliminação, sem depender de desbloqueios.

**Acceptance Scenarios**:

1. **Given** uma mesa iniciada, **When** as fichas são distribuídas, **Then** todos começam com o mesmo stack definido pelo desafio.
2. **Given** um turno do jogador, **When** os controles aparecem, **Then** mostram ações e valores legais; ajustar uma aposta não a executa antes da confirmação.
3. **Given** um all-in com contribuições diferentes, **When** a mão termina, **Then** cada participante disputa apenas os potes a que tem direito, com devolução de excedentes não cobertos.
4. **Given** um torneio em andamento, **When** resta somente um participante com fichas, **Then** ele vence; a eliminação do jogador encerra sua tentativa como derrota.
5. **Given** a identificação dos bots, **When** o jogador observa a mesa, **Then** consegue consultar fichas, última ação e indicador simples do estilo de cada bot.

### User Story 2 - Avançar nas campanhas (Priority: P2)

O jogador vence mesas, recebe fichas de progressão e desbloqueia permanentemente novos desafios numa sequência linear que continua além das primeiras etapas.

**Why this priority**: Dá propósito à repetição e variedade aos torneios.

**Independent Test**: Completar uma sequência de desbloqueio, vitória, recompensa, derrota e repetição, verificando os dois saldos independentes.

**Acceptance Scenarios**:

1. **Given** qualquer campanha recém-iniciada, **When** o jogador abre o caminho, **Then** a primeira mesa está liberada gratuitamente.
2. **Given** a mesa anterior vencida e saldo suficiente, **When** o jogador paga o desbloqueio, **Then** a próxima mesa fica acessível permanentemente e exibe seu formato antes da compra.
3. **Given** uma mesa liberada, **When** o jogador perde ou seu saldo chega a zero, **Then** pode repetir a tentativa imediatamente e gratuitamente.
4. **Given** uma vitória, **When** o prêmio é entregue, **Then** credita o saldo da campanha correspondente; a primeira vitória concede bônus maior e repetições também rendem fichas. Derrotas não rendem fichas.
5. **Given** etapas avançadas, **When** o jogador progride, **Then** encontra novos desafios sem um fim de campanha predeterminado, alternando formatos e combinações de dificuldade.

### User Story 3 - Aprender e consultar ajuda (Priority: P2)

Quem não conhece pôquer aprende em mãos guiadas e encontra explicações em português brasileiro informal, com os termos técnicos apresentados entre parênteses.

**Why this priority**: Torna o jogo compreensível para iniciantes sem exigir conhecimento prévio.

**Independent Test**: Percorrer o tutorial e uma mão normal usando explicações, ranking e uma dica paga.

**Acceptance Scenarios**:

1. **Given** o tutorial, **When** o jogador entra, **Then** participa de mãos guiadas, pode pular e pode revisitar depois.
2. **Given** uma ação disponível, **When** seu botão é exibido, **Then** apresenta linguagem compreensível, termo técnico e valor quando aplicável, como `Pagar 40 (call)`.
3. **Given** indecisão no Normal, **When** passa o intervalo configurado, **Then** surge `Quer uma dica?`, sem abrir conteúdo ou cobrar automaticamente.
4. **Given** uma dica oferecida, **When** o jogador confirma o preço, **Then** paga com fichas de progressão, recebe uma sugestão explicada e mantém pote e stacks inalterados.
5. **Given** tutorial ou consulta às regras, **When** o jogador acessa o conteúdo, **Then** não há custo. A dica usa apenas informações disponíveis ao jogador e não garante vitória.
6. **Given** uma mão encerrada, **When** o resultado aparece, **Then** explica brevemente o motivo da vitória; a revisão da última mão não revela cartas que permaneceram ocultas.

### User Story 4 - Jogar Hardcore (Priority: P2)

Jogadores que querem pressão de tempo acessam uma campanha própria, com bots mais fortes e cronômetro.

**Why this priority**: Oferece um desafio distinto sem impor tempo aos iniciantes.

**Independent Test**: Iniciar Hardcore, consumir tempo e reserva, pausar e retomar, verificar a ação automática e a independência da campanha Normal.

**Acceptance Scenarios**:

1. **Given** o primeiro acesso ao jogo, **When** o jogador escolhe Hardcore, **Then** pode jogar, com indicação de que é recomendado para quem já conhece pôquer.
2. **Given** um turno, **When** o tempo de decisão termina, **Then** consome automaticamente a reserva; esgotados ambos, executa check se legal, ou fold quando existe aposta a pagar.
3. **Given** Hardcore, **When** o jogador consulta a interface, **Then** dicas de jogada estão indisponíveis, mas valores, ações e regras continuam acessíveis.
4. **Given** uma conquista no Hardcore, **When** o saldo e o avanço mudam, **Then** não alteram a campanha Normal.

### User Story 5 - Jogar no celular e retomar depois (Priority: P1)

O jogador usa o app verticalmente, offline, ajusta a apresentação e interrompe a sessão sem perder a partida.

**Why this priority**: Interrupções e diferentes necessidades de leitura fazem parte do uso mobile.

**Independent Test**: Jogar offline, colocar o app em segundo plano, fechá-lo e retomar as duas campanhas, verificando estado, tempo e preferências.

**Acceptance Scenarios**:

1. **Given** uma partida, **When** o jogador bloqueia a tela ou sai do app, **Then** ela pausa e fica salva; a retomada restaura estado e tempo restante sem renovar a reserva.
2. **Given** uma mesa, **When** o jogador escolhe `Salvar e sair`, **Then** pode continuar depois; `Abandonar torneio` exige confirmação e registra derrota.
3. **Given** uma partida salva em cada campanha, **When** o jogador alterna entre elas, **Then** cada uma preserva seu estado independente.
4. **Given** preferências de acessibilidade, **When** ajusta tamanho do texto, naipes, animações, música, efeitos ou vibração, **Then** as escolhas são aplicadas e persistidas.

### User Story 6 - Receber e instalar o release (Priority: P1)

O autor recebe versão completa instalável, fontes e instruções; o jogador instala offline e preserva progresso ao atualizar.

**Why this priority**: Protótipo ou APK debug não conclui a entrega.

**Independent Test**: Conferir pacote, assinatura/hashes, instalar em dois aparelhos e atualizar sem apagar save.

**Acceptance Scenarios**:

1. **Given** uma candidata, **When** os gates R01–R12 passam, **Then** entregar APK release assinado, fontes, instruções, changelog, licenças e evidências reais.
2. **Given** aparelho suportado offline, **When** instala o APK, **Then** os dois modos e funções completas funcionam sem serviço externo.
3. **Given** progresso compatível, **When** instala atualização com mesma assinatura, **Then** preserva carteiras, mesas e partidas; debug usa identidade separada.
4. **Given** assinatura ou testes físicos indisponíveis, **When** prepara build, **Then** marcá-la candidata não verificada, sem declarar release entregue.

### Edge Cases

- Empates, board como melhor mão, sequência com ás baixo, desempates por kicker e distribuição de fichas indivisíveis.
- Blinds superiores ao stack, all-in inferior ao call, raise incompleto e reabertura ou encerramento da ação.
- Vários all-ins e potes separados; transição de mesa com vários bots para heads-up.
- Eliminações simultâneas, último adversário eliminado e fim da mão antes do showdown por desistências.
- Fechamento durante aposta, cobrança de dica, desbloqueio ou entrega de prêmio: retomar sem duplicar nem perder transações concluídas.
- Pausas durante a troca de turno ou esgotamento do relógio: não executar duas ações nem conceder tempo extra.
- Saldo insuficiente para dica ou desbloqueio: informar o requisito sem cobrar nem impedir repetir mesas liberadas.
- Alteração do valor legal de uma aposta e toque repetido: nunca executar ação inválida ou duplicada.
- Textos ampliados e cinco bots em tela vertical: preservar leitura das informações e acesso às ações.
- Índices/carteiras acima de limites numéricos comuns, falta de espaço, save futuro e corrupção de cópias.
- Instalação/atualização, identidade/assinatura diferente e recursos opcionais negados sem impedir jogo offline.

## Requirements

### Functional Requirements

- **FR-001**: Oferecer Texas Hold'em no-limit com baralho padrão, avaliação correta de mãos, apostas legais, blinds, potes, empates e eliminação para dois a seis participantes.
- **FR-002**: Manter a distribuição das cartas independente da dificuldade: baralho justo e bots sem acesso a cartas ocultas de outros participantes ou cartas futuras. A força dos bots altera decisões e chances de vitória, nunca o embaralhamento. Este requisito explicita a premissa de pôquer legítimo.
- **FR-003**: Oferecer apenas campanhas Normal e Hardcore, tutorial e telas de apoio nesta versão; não incluir partida livre.
- **FR-004**: Gerar caminhos lineares infinitos com desafios de formato predeterminado, variando duelos e mesas de três a seis participantes e mostrando o formato antes do desbloqueio.
- **FR-005**: Separar saldo de progressão e fichas de torneio; todos começam cada tentativa com o mesmo stack, independentemente do saldo acumulado.
- **FR-006**: Cobrar apenas o desbloqueio permanente, exigindo vitória na mesa anterior e saldo suficiente. Liberar a primeira mesa gratuitamente em ambas as campanhas e permitir repetições sem custo de entrada.
- **FR-007**: Premiar somente vitórias, incluindo repetições, com bônus maior na primeira conquista e entrega única por resultado.
- **FR-008**: Variar força e estilo dos bots e estruturas de blinds; valores nominais maiores não bastam como escalada. A inteligência dos bots tem limite prático e não deve ser anunciada como ilimitada.
- **FR-009**: Identificar bots por fichas, última ação e estilo simples, sem exigir personagens, histórias ou árvore de habilidades.
- **FR-010**: No Normal, permitir decisões sem cronômetro; no Hardcore, oferecer tempo por decisão, reserva por torneio e ação automática ao esgotamento.
- **FR-011**: Manter campanhas, saldos e uma partida salva por campanha independentes; disponibilizar Hardcore desde o início.
- **FR-012**: Oferecer tutorial prático separado, opcional e revisitado, linguagem brasileira informal com termos técnicos e ranking de mãos acessível.
- **FR-013**: Mostrar a combinação atual do jogador e informações claras de pote, stacks, blinds, turno, valores para pagar e ações legais.
- **FR-014**: No Normal, oferecer dica após intervalo de indecisão, com cobrança voluntária e explícita em fichas de progressão; preço crescente por dificuldade e sugestão explicada sem informação privilegiada.
- **FR-015**: Manter tutorial e regras gratuitos e não oferecer dicas de jogada no Hardcore.
- **FR-016**: Apresentar resultado breve e revisão da última mão, respeitando quais cartas foram reveladas.
- **FR-017**: Usar orientação vertical, adversários no topo, comunitárias no centro e mão/controles abaixo; privilegiar cartas grandes, verde-escuro, marfim e vermelho e efeitos rápidos.
- **FR-018**: Oferecer botões de ações grandes, ajuste de aposta por barra e botões, presets de meio pote, pote e all-in respeitando limites legais e confirmação do valor de aposta/aumento.
- **FR-019**: Oferecer quatro cores de naipes, texto ampliável, animações reduzidas e controles de música, efeitos e vibração.
- **FR-020**: Funcionar offline, sem anúncios, compras, energia, espera obrigatória para jogar ou login obrigatório.
- **FR-021**: Pausar e salvar ao sair ou bloquear a tela, inclusive no Hardcore, preservando relógio e reserva. Disponibilizar salvar/sair e abandono confirmado como derrota.
- **FR-022**: Entregar1.0.0 por APK assinado e fontes, instruções, changelog, licenças, hashes e evidências; publicação em loja fora desta entrega.
- **FR-023**: Preservar save em atualização compatível, informar perda por desinstalação/apagar dados; sem nuvem, conta ou telemetria.
- **FR-024**: Entregar conteúdo pt-BR completo e assets finais, sem placeholders em fluxos obrigatórios.
- **FR-025**: Progredir sem overflow de índice/saldo; mesas compradas mantêm regras e valores após balanceamento novo.
- **FR-026**: Preservar revisão confirmada em falha de gravação, oferecer retry sem reset silencioso e preservar save futuro.
- **FR-027**: Dica estável na mesma decisão, uma cobrança por contexto e nenhuma equidade numérica exposta nesta versão.
- **FR-028**: Tutorial em cinco lições revisáveis e regras/termos/ações consultáveis sem custo.

### Key Entities

- **Campanha**: modalidade, saldo, maior etapa, mesas liberadas e partida em andamento.
- **Desafio/mesa**: etapa, formato, participantes, stack inicial, estrutura de blinds, perfis dos bots, custo de desbloqueio e recompensas.
- **Torneio/tentativa**: participantes restantes, stacks, botão, blinds, mão atual, resultado e relógio quando aplicável.
- **Mão**: cartas, comunitárias, apostas, potes, ações legais, ações realizadas e informações reveladas.
- **Bot**: estilo visível, força e decisões baseadas nas próprias cartas e informações públicas.
- **Dica**: contexto, preço, confirmação e sugestão explicada.
- **Progresso e preferências locais**: desbloqueios, prêmios entregues, tutorial e ajustes de acessibilidade/áudio.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Todos os cenários de referência de mãos e apostas passam, sem criação/perda indevida de fichas nem ações ilegais.
- **SC-002**: Toda mesa liberada pode ser repetida com saldo de progressão zero e sem espera obrigatória.
- **SC-003**: Toda primeira conquista e repetição de vitória recebe exatamente um prêmio apropriado, inclusive após interrupções.
- **SC-004**: Em todos os cenários de interrupção verificados, ambas as campanhas retomam corretamente, sem renovar tempo ou duplicar transações.
- **SC-005**: Metas iniciais de playtest aprovadas: duelos próximos de 3–5 minutos e mesas maiores de 5–10 minutos; medir a distribuição por etapa e ajustar os parâmetros, sem impor encerramento artificial ao torneio.
- **SC-006**: Todo o ciclo de tutorial, partida, recompensa, desbloqueio e retomada funciona sem conexão e sem pagamento real.
- **SC-007**: O caminho continua fornecendo mesas após o conjunto inicial, mantendo formatos válidos, custos/recompensas válidos e adversários sujeitos às mesmas regras.
- **SC-008**: Nenhuma tela essencial perde ações ou valores necessários com as opções de texto ampliado e animações reduzidas nos aparelhos-alvo definidos no plano.
- **SC-009**: Todos os gates R01–R12 passam com evidências reais; documentação não é execução de teste.
- **SC-010**: Arquivos de entrega, hashes e assinatura verificáveis; APK instala offline na matriz física mínima.
- **SC-011**: Nenhum caso de atualização compatível perde carteira, acesso ou tentativa.
- **SC-012**: Kill abrupto não devolve tempo Hardcore; pode perder até1 s pelo checkpoint conservador. Pausa normal preserva tempo exato.
- **SC-013**: Pelo menos4 de5 iniciantes concluem tutorial e distinguem passar/pagar/aumentar sem ajuda externa.

## Assumptions

- As decisões do autor têm prioridade sobre propostas do GDD original, que permanece como referência histórica de visão.
- O primeiro lançamento é Android; PC posterior. Tecnologia e ambiente estão definidos em plan.md e no contrato de entrega.
- Hardcore começa, para playtest, com 10 segundos por decisão e reserva de 30 segundos por torneio, consumida automaticamente. Os números são parâmetros ajustáveis aprovados.
- No Hardcore, pausar permite pensar fora do cronômetro; esse efeito foi apresentado e aceito para atender interrupções do celular.
- Baralho justo e ausência de informação privilegiada para bots explicitam a proposta de pôquer legítimo; não existe manipulação de resultados para dificuldade.
- Tutorial e regras são gratuitos. Sem saldo para uma dica paga, a tentativa pode continuar normalmente sem a dica.
- Preços, stacks, blinds, dicas, conteúdo e geração têm defaults fechados nos contratos de release, por delegação do autor; ajustes seguem processo explícito, sem decisão de produto em aberto.
- Campanha infinita significa continuidade de desafios, sem promessa de força ilimitada da IA. A curva exige validação para não se tornar trivial, impossível ou excessivamente demorada.
- Entrega por APK/fontes sem publicação em loja, conta, sincronização, estatísticas públicas acumuladas ou backup em nuvem. Aparelhos, assets e recuperação estão definidos.

## Pacote normativo

Decisões explícitas do autor prevalecem. Para1.0.0, ler esta especificação com [entrega](../../docs/RELEASE_ANDROID.md), [regras](../../docs/POKER_RULES.md), [economia](../../docs/ECONOMIA_E_PROGRESSAO.md), [IA](../../docs/AI_RELEASE.md), [persistência](../../docs/PERSISTENCIA_RELEASE.md), [conteúdo](../../docs/CONTEUDO_RELEASE.md), [UX](../../docs/MOBILE_UX.md) e [baseline numérica](release-baseline.json). Contratos fechados substituem sugestões anteriores dos mesmos assuntos. Corrigir divergências sem atribuir ao usuário escolhas do assistente.
