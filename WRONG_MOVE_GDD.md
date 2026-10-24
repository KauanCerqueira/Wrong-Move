# WRONG MOVE

> **Game Design Document (GDD) — versão 0.1 · 24/10/2026**  
> **Status:** pré-produção / definição de conceito  
> **Formato:** jogo digital de pôquer clássico, inicialmente single-player e offline  
> **Proposta:** *Pôquer de verdade. Decisões rápidas. Às vezes, a jogada errada é a certa.*

---

## 1. Visão geral

**WRONG MOVE** é um jogo **100% gratuito** de **Texas Hold'em heads-up (um jogador contra um adversário controlado pelo computador)**, com uma apresentação arcade minimalista e ritmo extremamente rápido. A referência de experiência é **Balatro**: interface legível, cartas como protagonistas, animações e áudio satisfatórios e a vontade de jogar “só mais uma mão”. **As regras de pôquer, entretanto, são clássicas e não serão modificadas.**

O jogo deve ser simples de abrir e jogar, mas recompensador para quem aprende odds, blefes, controle de apostas e leitura do adversário. Não há dinheiro real, apostas monetárias, microtransações nem vantagens compráveis.

### Pitch de uma linha

**Um duelo de pôquer clássico que tem o ritmo e a personalidade de um arcade.**

### Pilares inegociáveis

1. **Pôquer legítimo:** baralho justo, decisões válidas e resultado determinado pelas regras reais de Texas Hold'em.
2. **Velocidade sem atrito:** menos tempo entre decisões, controles imediatos e animações curtas ou puláveis.
3. **Adversário interessante:** IA com estilo, blefes e adaptação ao histórico — sem enxergar cartas ocultas.
4. **Estética memorável:** interface 2D limpa, cartas grandes, contraste alto e marca elegante.
5. **Acessível e gratuito:** jogável offline, sem dinheiro real, sem publicidade obrigatória ou monetização planejada.

## 2. Público e sensação desejada

- **Casual:** alguém que quer jogar algumas mãos sem instalar um simulador complexo.
- **Entusiasta de pôquer:** alguém que espera regras corretas, apostas legais e decisões estratégicas.
- **Jogador de arcade/indie:** alguém atraído por partidas curtas, apresentação responsiva e desafios progressivos.

A sensação-alvo é **“uma partida a mais”**, não “um cassino realista”. O jogador precisa perceber imediatamente o que acontece na mesa, quem age agora, quanto está no pote e quanto precisa pagar.

## 3. Plataforma, formato e escopo

| Item | Direção |
|---|---|
| Nome | **WRONG MOVE** |
| Gênero | Cartas / estratégia / pôquer arcade |
| Modalidade inicial | Texas Hold'em heads-up (1 contra 1) |
| Primeiro lançamento | **Windows PC**, offline |
| Expansão planejável | Android e outros sistemas; adaptar layout para celular |
| Outros sistemas desktop | Linux/macOS, após testes |
| Navegador | Possível com projeto Godot em GDScript; não é requisito do MVP |
| Modelo comercial | 100% gratuito, com fichas **apenas fictícias** |
| Multiplayer online | **Fora do escopo inicial**; ideia futura, não promessa |
| Motor | **Godot Engine 4.7.2 (estável)** |
| Linguagem recomendada | **GDScript com tipagem estática** |

> **Decisão técnica:** Godot 4.7.2 foi verificada como versão estável em outubro de 2026; Godot 4.8 estava em beta. Para manter exportação web viável na família Godot 4, a primeira implementação utilizará GDScript. C# permanece uma alternativa futura se o foco ficar exclusivamente em aplicativos nativos.

## 4. Os modos do jogo

### 4.1. Arcade — o modo principal

Uma sequência de duelos contra oponentes cada vez mais difíceis. O objetivo de cada duelo é **ganhar todas as fichas do adversário**. O jogador avança após a vitória e encerra a run caso perca.

**Fluxo:**

`Tela inicial → escolher Arcade → escolher dificuldade → enfrentar adversário → vitória/derrota → próximo duelo ou fim da run`.

- Ambos começam cada duelo com o **mesmo número de fichas**.
- Os blinds aumentam em intervalos definidos por mãos disputadas, para evitar confrontos intermináveis.
- Cada adversário traz uma estratégia perceptivelmente diferente.
- Jogador aprende os padrões, mas não deve conseguir explorá-los indefinidamente.
- A próxima mão começa rapidamente, sem tela de recompensa obrigatória após cada pote.
- Metas preliminares de duração: **5 a 10 minutos por confronto** e uma run relativamente curta. São **metas de playtest**, não limites rígidos.

**Ainda não fechado:** número final de adversários por run (protótipo sugerido: **3**, depois avaliar **5**), ritmo dos blinds e progressão estética.

### 4.2. Partida Livre — o modo clássico

Entrar diretamente numa mesa contra a máquina, sem campanha obrigatória.

Configurações previstas:

- Adversário e perfil de dificuldade.
- Stack inicial fictício de cada jogador.
- Small Blind e Big Blind.
- Blinds fixos ou crescentes.
- Opção de começar novo duelo imediatamente.

A partida pode ser um duelo até alguém zerar as fichas ou uma sessão contínua de confrontos, de acordo com a configuração. **Sem ranking pago ou dinheiro real.**

### 4.3. Clássico e Hardcore são dificuldades, não modalidades de pôquer diferentes

A dificuldade escolhida pode existir tanto no Arcade quanto na Partida Livre.

| Aspecto | Clássico | Hardcore |
|---|---|---|
| IA | Personalidade adaptativa | Estratégia mais forte e menos explorável |
| Relógio | Sem pressão obrigatória | Tempo muito curto para agir |
| Blefes | Variáveis por personagem | Coerentes com a estratégia, inclusive blefes calculados |
| Assistência | Regras e explicações acessíveis | Durante a mão, menos ajuda estratégica |
| Baralho | Aleatório e justo | **Exatamente o mesmo baralho justo** |
| Regras | Texas Hold'em tradicional | **As mesmas regras tradicionais** |

#### Relógio Hardcore — proposta inicial

- **Blitz padrão:** 8 segundos iniciais por decisão, mais uma **reserva de 20 segundos por duelo**.
- **Rápido:** 12 segundos por decisão; reserva de 30 segundos.
- **Insano:** 4 segundos por decisão; reserva de 10 segundos.
- Quando o tempo inicial acaba, o relógio consome a reserva, se disponível.
- Esgotado todo o tempo, o jogo executa **Check** se legal; se houver aposta a pagar, executa **Fold**.
- Relógio pausado durante distribuição, animações, transições e demais momentos em que o jogador não pode agir.
- IA responde quase imediatamente **pela experiência**, sem depender de uma animação longa ou simular pensamento deliberadamente lento.

> Os tempos são parâmetros de balanceamento. Testar também acessibilidade e opção de desligar sons/alertas intensos.

## 5. Regras fundamentais do pôquer

### 5.1. Estrutura de uma mão

1. Utilizar **baralho padrão de 52 cartas**, sem curingas e sem cartas especiais.
2. Embaralhar corretamente e distribuir **2 cartas privadas** para cada jogador.
3. Cobrar Small Blind (SB) e Big Blind (BB).
4. **Pré-flop:** rodada de apostas.
5. **Flop:** abrir 3 cartas comunitárias e realizar rodada de apostas.
6. **Turn:** abrir a 4ª carta comunitária e realizar rodada de apostas.
7. **River:** abrir a 5ª carta comunitária e realizar rodada final de apostas.
8. **Showdown:** se dois jogadores ainda estiverem na mão, comparar a melhor combinação de **5 entre as 7 cartas disponíveis** (2 privadas + 5 comunitárias).
9. Entregar o pote ao vencedor; em empate, dividir conforme as regras aplicáveis.
10. Alternar o botão/dealer e iniciar nova mão.

**Queimar uma carta** antes de flop, turn e river é uma regra operacional que será simulada no baralho digital, mesmo que a carta queimada não precise ser animada.

### 5.2. Heads-up: ordem de ação correta

- O **dealer/button** é também o **Small Blind**.
- **Pré-flop:** o Small Blind age primeiro; o Big Blind age depois.
- **Flop, turn e river:** o Big Blind age primeiro; o Small Blind age depois.
- Após cada mão, os papéis invertem.

### 5.3. Ações legais

- **Fold:** desistir diante de uma aposta (ou quando permitido pela implementação), entregando a disputa pelo pote.
- **Check:** passar quando não há valor adicional a pagar.
- **Call:** igualar o valor necessário para continuar.
- **Bet:** abrir uma aposta quando ainda não existe aposta ativa na rodada.
- **Raise:** aumentar uma aposta existente, respeitando mínimo legal e stack.
- **All-in:** apostar todas as fichas restantes; tratar corretamente raises incompletos.

**Aposta mínima, aumento mínimo, fichas insuficientes, apostas não igualadas e retorno de fichas excedentes precisam ser implementados de acordo com regras de no-limit Texas Hold'em.** Não simplificar o motor apenas para a interface ficar mais rápida.

### 5.4. Ranking de mãos, da maior à menor

1. Straight Flush (incluindo Royal Flush como caso especial).
2. Quadra.
3. Full House.
4. Flush.
5. Sequência (Straight).
6. Trinca.
7. Dois pares.
8. Um par.
9. Carta alta.

Regras de desempate: comparar os ranks relevantes e **kickers**; o Ás pode ser alto ou baixo na sequência `A-2-3-4-5`. Naipes **não** definem desempate. O motor deve avaliar mãos empatadas que usem exclusivamente as cartas comunitárias.

### 5.5. Integridade e justiça

- A IA recebe **somente informações públicas + as próprias cartas privadas**.
- Ela não pode consultar mão do jogador nem cartas futuras do baralho.
- O baralho deve ser embaralhado de forma uniformemente aleatória; para testes, permitir uma semente de RNG reproduzível.
- O resultado não é manipulado para favorecer dificuldade, progressão, personagem ou “momentos dramáticos”.
- Não existe rake, aposta monetária ou distribuição viciada.

## 6. IA e perfis de adversários

A IA é uma parte central da identidade do projeto. **A personalidade muda as decisões reais**, não apenas frases de efeito.

### 6.1. Clássico: perfis adaptativos

Personagens conceituais, com nomes provisórios:

- **Conservador:** escolhe melhor as mãos iniciais, blefa pouco e protege suas fichas.
- **Agressivo/blefador:** aposta e aumenta mais, pressiona quando percebe hesitação.
- **Estrategista:** leva em conta posição, tamanho do pote, stack, padrões do jogador e textura do board.

Cada perfil observa estatísticas como:

- Frequência de Fold contra bets e raises.
- Frequência de Raise e 3-bet.
- Tendência de pagar apostas grandes.
- Frequência de agressividade por street (pré-flop, flop, turn, river).
- Apostas relativas ao pote.
- Resultado das mãos **somente quando reveladas** (não inferir cartas privadas automaticamente de um Fold).

**Regra de equilíbrio:** adaptação gradual, baseada em amostra suficiente; o adversário não deve mudar de estratégia drasticamente depois de uma única mão.

### 6.2. Hardcore: IA competitiva

- Mais conhecimento de ranges, posição, stack efetivo, pot odds, equidade aproximada e tamanhos de aposta.
- Estratégias mistas de aposta, call, raise e fold, evitando decisões totalmente previsíveis.
- Exploração limitada dos padrões observados do jogador, sem perder robustez estratégica.
- Nenhuma informação privilegiada do motor.

**Escopo realista:** não anunciar “IA GTO perfeita” sem construir e validar um solucionador. Uma primeira versão forte pode combinar ranges pré-flop, heurísticas pós-flop, cálculo de equidade por amostragem e pesos configuráveis. Refinar desempenho com milhares de partidas simuladas.

### 6.3. Experiência do bot

- Resposta computacional preferencialmente rápida.
- Indicação visual concisa de `CHECK`, `CALL`, `RAISE`, `FOLD` ou `ALL-IN`.
- Comentários ocasionais opcionais e muito curtos, sem diálogos que bloqueiem o jogo.
- Personalidade não deve resultar em **trapaça**, lentidão forçada ou RNG injusto.

## 7. Experiência de jogo: extremamente rápida

### 7.1. Princípio

**O jogador espera apenas por sua própria decisão, não pela interface.**

Tempos abaixo são objetivos de sensação, ajustáveis nos testes:

| Evento | Comportamento pretendido |
|---|---|
| Dar cartas | Animação curta, com modo acelerado |
| Check / Call / Fold | Um clique ou atalho |
| Tamanho de aposta | Presets e ajuste fino rápido |
| Ação da IA | Resposta quase instantânea |
| Ganhar pote | Feedback audiovisual breve e marcante |
| Próxima mão | Transição rápida, sem confirmação obrigatória |
| Repetir duelo | Disponível em um comando |

### 7.2. Painel de apostas

- Mostrar ação legal contextual: **Desistir**, **Check/Pagar**, **Apostar/Aumentar**.
- Exibir claramente `Pagar X`, `Pote Y`, `Stack Z`.
- Presets baseados na situação: por exemplo **½ pote**, **pote** e **all-in**, recalculados para respeitar os limites legais.
- Slider, botões `+/-` e, no PC, entrada direta opcional.
- Atalhos de teclado configuráveis e suporte a mouse; toque no celular.
- Confirmar raise apenas quando o valor foi selecionado: prevenir cliques acidentais, **sem diálogo extra** em cada ação.

### 7.3. Feedback de cartas

- Destaque curto para **Par, Dois Pares, Full House, Straight, Flush**, etc., ao ganhar no showdown.
- Recompensa sonora/visual forte, mas não demorada.
- Animações podem ser aceleradas/desligadas.
- **Replay da última mão** disponível sob demanda, após o encerramento da mão, nunca revelando informação indevida antes disso.

## 8. Identidade visual e marca

### 8.1. Nome e ideia

**WRONG MOVE** faz referência à possibilidade de uma decisão aparentemente ruim ser a jogada vencedora — especialmente em blefes. A direção do nome remete ao imaginário cinematográfico do pôquer, mas não depende de um personagem ou filme licenciado.

**Frase-conceito opcional:** *Make the wrong move at the right time.*

> A disponibilidade comercial/jurídica do nome e a originalidade da marca devem ser verificadas antes de publicar. O título está escolhido para o projeto, mas o registro não foi verificado neste documento.

### 8.2. Logo — direção mais recente

- Logotipo com a expressão **WRONG MOVE** em letras **serifadas, finas e harmoniosas**, em **marfim**.
- Ícone minimalista com **duas cartas sobrepostas e levemente desalinhadas**.
- O par de cartas deve representar a mão **7♥ e 2♠ offsuit**, classicamente associada a uma das piores mãos iniciais de Hold'em — excelente metáfora do nome.
- Naipes e valores devem ser **legíveis**, mesmo em tamanho reduzido; sem excesso de ilustração interna, coroas, personagens ou detalhes dourados.
- O ícone precisa funcionar sozinho (atalho de app, executável, avatar), e o nome deve funcionar separado (capa e splash screen).
- **Não considerar a imagem conceitual renderizada como asset final pronto para produção**. O ícone deverá ser redesenhado ou vetorizado para corrigir geometria, legibilidade e proporção.

### 8.3. Paleta de referência

| Uso | Cor | Hex aproximado |
|---|---|---|
| Fundo/mesa | Verde-petróleo profundo | `#102723` |
| Cartas/texto principal | Marfim | `#F3E9D6` |
| Destaque/ação importante | Vermelho queimado | `#B82E32` |
| Realce secundário | Dourado suave | `#D6AC62` |
| Superfícies escuras | Grafite esverdeado | `#172323` |

Cores ainda sujeitas a contraste, acessibilidade e playtests. **Não exagerar no dourado nem transformar a mesa em uma cena luxuosa de cassino.**

### 8.4. Identidade do gameplay (diferente da tela de título)

- **Jogo 2D**, não 3D/isométrico e não uma cena cinematográfica de cassino.
- **Cartas enormes e legíveis**, centro visual da tela.
- Fundo de mesa verde escuro com textura discreta e, opcionalmente, leve efeito CRT.
- Painéis de informações compactos: bote/dealer, blinds, pote, stacks, street e turno.
- Fontes: **logo serifado fino**; **HUD com tipo digital claro e legível**, não necessariamente a mesma fonte do logo.
- Contraste e leitura vêm antes de efeitos especiais.
- Sem grandes personagens ocupando a mesa, sem copos, luminárias, plantas ou móveis como elementos obrigatórios da partida.
- Inspiração em Balatro **no ritmo e nos princípios de legibilidade**, não em copiar seus assets, seu layout exato ou seus efeitos.

### 8.5. Composição sugerida para PC

- **Esquerda (~20–25%):** pote, blinds, adversário, fase da mão e status.
- **Centro (~75–80%):** 2 cartas privadas do rival (viradas), 5 comunitárias, 2 cartas do jogador.
- **Rodapé/área de ação:** Fold, Check/Call, Raise, presets e valor.
- O menu principal **não** aparece durante a partida.

### 8.6. Direção mobile futura

- Versão em retrato prioritária para celular: oponente na parte superior, mesa/cartas no centro, ações na parte inferior, todos os controles confortáveis para toque.
- Adaptar hierarquia em vez de apenas encolher a interface de PC.
- Alvos de toque amplos; texto e valores grandes; respeitar áreas de câmera/notch e barras de sistema.

### 8.7. Acessibilidade

- Alternar naipes tradicionais / **baralho de quatro cores**.
- Reduzir animações e desligar pós-processamento CRT.
- Controle do volume de música, cartas, fichas e alertas separadamente.
- Atalhos remapeáveis no PC e feedback de ação sempre legível por texto, não só cor/som.
- Tempo Hardcore configurável por intensidade; modo Clássico sem contagem obrigatória.

## 9. Áudio e microanimações

A apresentação deve ser **tátil e rápida**:

- Sons curtos e distintos ao distribuir cartas, empilhar fichas, pagar, aumentar, desistir e vencer.
- Transições de ênfase no pote e nas mãos vencedoras.
- Trilha discreta, repetível, com identidade indie/arcade — sem roubar atenção do jogador.
- Sem telas de comemoração obrigatórias após cada mão.
- Em Hardcore, sinal visual e sonoro opcional quando o relógio está perto de acabar.

**Regras de som:** evitar picos de volume e manter a opção de silêncio completo.

## 10. Progressão, estatísticas e desbloqueios

### Arcade

- Runs independentes com confrontos sucessivos.
- Desbloqueio de **cosméticos somente**: temas de mesa, versos de cartas, fichas, molduras, efeitos sutis.
- Não aumentar a probabilidade de mãos boas nem vender vantagens.

### Estatísticas persistentes (planejadas)

- Vitórias, derrotas e mãos jogadas.
- Maior sequência de vitórias.
- Partidas concluídas por modo/dificuldade.
- Frequência pessoal de Fold, Call e Raise.
- Histórico de mãos e última mão, com armazenamento local limitado/configurável.

> Não foi definido um sistema complexo de conquistas, loja ou inventário. **Evitar aumentar escopo antes do pôquer básico estar sólido.**

## 11. Arquitetura técnica recomendada

### 11.1. Motor gráfico e linguagem

**Godot 4.7.2 estável + GDScript tipado**.

Motivos:

- Godot é gratuito/open-source e adequado para interfaces e jogos 2D.
- Cenas e nós facilitam criar cartas, mesa, HUD e animações reutilizáveis.
- GDScript tem integração direta ao editor e permite exportação web no Godot 4; exportações mobile e desktop são possíveis seguindo os requisitos oficiais.
- Os algoritmos de pôquer são leves o suficiente para a linguagem; não há necessidade inicial de engine 3D nem de backend web.

**C#**: alternativa tecnicamente válida, sobretudo pela experiência prévia do desenvolvedor, mas Godot 4 C# não exporta para Web e tem suporte Android/iOS experimental conforme documentação atual. Portanto não é a escolha inicial deste GDD.

### 11.2. Arquitetura em camadas

A lógica de pôquer deve ser **independente da interface**. Uma carta é um dado; não um nó visual. A UI exibe estados e solicita ações, mas **não decide quem ganhou**.

```text
WRONG MOVE
├── Domain / Core (regras puras)
│   ├── Card / Deck / Shuffle
│   ├── HandEvaluator / HandComparator
│   ├── GameState / RoundState / Pot
│   ├── BettingRules / LegalActions
│   └── HeadsUpMatch / BlindStructure
├── Application (orquestração)
│   ├── GameController
│   ├── TurnController
│   ├── ArcadeRunManager
│   ├── MatchSettings / SaveManager
│   └── HardcoreClock
├── AI
│   ├── OpponentProfile
│   ├── PlayerTendencyTracker
│   ├── EquityEstimator
│   ├── ClassicAgent
│   └── HardcoreAgent
├── Presentation (Godot scenes / UI)
│   ├── MainMenu / ModeSelect
│   ├── PokerTable / CardView / HandView
│   ├── BetControls / PotPanel / ClockWidget
│   ├── Animations / Audio
│   └── HandHistory / ResultOverlay
└── Tests
    ├── HandEvaluatorTests
    ├── BettingRuleTests
    ├── MatchFlowTests
    └── AISimulationTests
```

**Nomes acima são conceitos de módulos, não arquivos ou classes já existentes.**

### 11.3. Responsabilidades

| Módulo | Responsabilidade |
|---|---|
| Deck | Criar 52 cartas, embaralhar e distribuir sem repetição |
| HandEvaluator | Encontrar a melhor mão de 5 entre até 7 cartas |
| BettingRules | Calcular ações legais, aposta mínima, call, raise e all-in |
| GameState | Ser fonte única da verdade do estado da mesa |
| GameController | Executar a máquina de estados e a ordem das fases |
| AI Agent | Escolher uma ação **somente entre as legais** |
| OpponentTracker | Resumir informações públicas das ações anteriores |
| Clock | Aplicar regras do tempo Hardcore sem interferir no motor |
| Presentation | Renderizar dados e animar eventos, sem regras de domínio |
| Persistence | Salvar opções, progresso e estatísticas localmente |

### 11.4. Máquina de estados sugerida

```text
MENU
  ↓
SETUP_MATCH
  ↓
POST_BLINDS → DEAL_HOLE_CARDS → PREFLOP_BETTING
                                     ↓
                               FLOP_BETTING
                                     ↓
                               TURN_BETTING
                                     ↓
                               RIVER_BETTING
                                     ↓
                                SHOWDOWN
                                     ↓
                               AWARD_POT
                                     ↓
                      NEXT_HAND / MATCH_FINISHED
```

A qualquer rodada, se um jogador der **Fold**, ir diretamente a `AWARD_POT` (sem revelar cartas privadas desnecessariamente). Se houver all-in e nenhuma decisão pendente, completar o board e resolver showdown; **não continuar pedindo ações impossíveis**.

### 11.5. Dados e persistência

- Configuração e estatísticas locais em `user://`.
- Preferir arquivos simples versionados (por exemplo JSON, com schema/version) no começo.
- Sem servidor, login ou conta obrigatória no MVP.
- Seeds e logs de debug só devem ser expostos em modo de desenvolvimento; não comprometer a experiência normal.

### 11.6. Estrutura proposta no repositório

```text
wrong-move/
├── project.godot
├── README.md
├── docs/
│   ├── GDD.md
│   ├── RULES.md
│   └── ART_DIRECTION.md
├── assets/
│   ├── fonts/
│   ├── cards/
│   ├── ui/
│   └── audio/
├── scenes/
│   ├── menus/
│   ├── table/
│   └── widgets/
├── scripts/
│   ├── core/
│   ├── game/
│   ├── ai/
│   ├── ui/
│   └── persistence/
└── tests/
```

A árvore pode ser ajustada à evolução real do projeto. O essencial é não misturar regras, IA e apresentação.

## 12. Desenvolvimento assistido por IA

IA pode ajudar no código, testes, refatoração, criação de cenas e inspeção de erros — **o desenvolvedor mantém o controle do projeto**.

Ferramentas consideradas:

- **OpenCode** ou outro agente de programação, trabalhando sobre o repositório.
- **Godot editor** como ambiente principal de desenvolvimento e execução.
- **MCP para Godot**, se um plugin comunitário for compatível e confiável, permitindo controlar cenas e capturar estados do editor.
- **Git** para versionamento local/remoto e revisão de alterações.

Um MCP de terceiros não deve ser tratado como dependência obrigatória, nem como ferramenta automaticamente validada. Testar instalação, permissões, versão de Godot, suporte à máquina local e limites antes de adotá-lo. Nunca conceder a um agente autonomia irrestrita para modificar o projeto sem commits/revisões.

## 13. Plano de implementação por etapas

### Etapa 0 — Preparação

- [ ] Criar repositório, projeto Godot 4.7.2 e organização mínima.
- [ ] Definir resoluções, entradas, tema de UI e configurações básicas.
- [ ] Escrever casos de teste de ranking de mãos e regras de apostas.

### Etapa 1 — Motor de pôquer, sem arte final

- [ ] Baralho e RNG justo.
- [ ] Distribuição e ordem correta de heads-up.
- [ ] Avaliador de mãos com desempates.
- [ ] Motor de apostas no-limit; blinds, check/call/raise/fold/all-in.
- [ ] Pot, showdown, split e reinício da próxima mão.
- [ ] Testes automatizados com casos de borda.

**Critério de saída:** uma partida completa funciona corretamente em uma interface provisória, sem depender de animações.

### Etapa 2 — Primeira experiência jogável

- [ ] Tela da mesa 2D minimalista.
- [ ] Cartas do jogador e comunitárias, pote e stacks.
- [ ] Botões contextuais e valores rápidos.
- [ ] IA básica legalmente correta (ela não precisa ser brilhante ainda).
- [ ] Fluxo de início, fim e reinício do duelo.

**Critério de saída:** o jogador consegue disputar várias mãos seguidas sem quebrar a partida e sem atrasos incômodos.

### Etapa 3 — Identidade e fluidez

- [ ] Ajustar logo 7♥/2♠ e redesenhar ícone para produção.
- [ ] Conjunto original de cartas, fichas, fontes e HUD.
- [ ] Sons e animações rápidas, configuráveis.
- [ ] Ajustes de usabilidade para mouse/teclado e diferentes resoluções.
- [ ] Histórico/replay básico da última mão.

### Etapa 4 — Personalidade e Arcade

- [ ] Criar perfis adaptativos e histórico de tendências.
- [ ] Estrutura de 3 duelos iniciais para testar run.
- [ ] Subida de blinds e progressão de oponentes.
- [ ] Modo Livre com parâmetros editáveis.
- [ ] Estatísticas persistidas.

### Etapa 5 — Hardcore e refinamento

- [ ] Relógio com reserva de tempo.
- [ ] IA mais competitiva; avaliar ranges e equidade.
- [ ] Simulações automatizadas para balancear estilos.
- [ ] Ajustes de dificuldade e experiência do jogador.
- [ ] Testar performance e empacotamento para Windows.

### Etapa 6 — Expansões opcionais

- [ ] Port Android com HUD adaptado para toque.
- [ ] Outros sistemas desktop, depois de testes.
- [ ] Conteúdo visual extra e mais adversários.
- [ ] Eventual multiplayer, somente se houver razão e recursos para manter um serviço justo e seguro.

## 14. Critérios de qualidade e testes obrigatórios

**Motor de mãos**: cobrir todas as categorias, flush contra straight, straight com Ás baixo, full house com duas trincas possíveis, dois pares com kicker, board que joga sozinho e empates.

**Apostas**: cobrir blinds, check após BB, raise mínimo, all-in que não completa aumento, stack inferior ao call, devolução de aposta não coberta, encerramento de street e botão SB/BB correto em heads-up.

**IA**: nunca tentar ação ilegal, nunca consultar carta escondida, consistência de diferentes perfis, latência baixa e estatísticas corretas mesmo quando mãos são encerradas com Fold.

**Interface**: permitir ação com um clique, mostrar claramente pote/stacks/to-call, funcionar em 720p/1080p, suportar escala, respeitar tamanho mínimo dos alvos de toque e não depender somente de cores.

**Tempos e diversão**: acompanhar mediana de duração de mão, tempo morto entre mãos, taxa de desistência/reinício de runs, compreensão das apostas e sensação de “mais uma mão”. Validar com jogadores reais; não supor que rapidez sempre significa satisfação.

## 15. Fora de escopo e regras de produto

**Não implementar no primeiro ciclo:**

- Pôquer com 3 ou mais jogadores simultâneos.
- Outros formatos como Omaha, Seven Card Stud ou torneios multimesa.
- Multiplayer, chat de voz, matchmaking e rankings online.
- Criptomoedas, dinheiro real, saques, depósitos ou microtransações.
- Cartas com poderes, jokers que mudam regras, multiplicadores de pontuação ou manipulação de probabilidade para “facilitar” o jogo.
- Gráficos 3D de cassino, salas complexas, avatares realistas ou narrativa com cutscenes demoradas.

## 16. Decisões fechadas x decisões abertas

### Já decidido

- Nome **WRONG MOVE**.
- Gratuito, pôquer clássico, **heads-up inicialmente**.
- **Arcade + Partida Livre**.
- **Clássico com IA adaptativa + Hardcore com IA competitiva e tempo curto**.
- **Velocidade extrema e diversão** como prioridade absoluta.
- Visual **2D arcade minimalista**, com mesa/cartas em destaque.
- Logo com tipografia fina elegante e conceito **7♥/2♠**.
- Godot como motor, com **GDScript recomendado** na primeira versão.

### Ainda precisa ser decidido ou testado

- Quantos adversários por run: 3, 5 ou outro número.
- Nomes e aparências finais dos adversários.
- Estrutura precisa de blinds e stacks iniciais.
- Balanceamento das três velocidades Hardcore.
- Presets legais de apostas e atalhos definitivos.
- Direção sonora e trilhas originais.
- Arte vetorial final do logo (proporções, legibilidade e versão app).
- Cronograma real, expansão mobile e publicação em lojas.
- Método final de avaliação de equidade da IA Hardcore.

---

## 17. Links técnicos de referência

Documentação consultada em **24/10/2026**:

- Godot (download e versões): <https://godotengine.org/download/archive/>
- Godot 4.7 estável (linha-base): <https://godotengine.org/download/archive/4.7-stable/>
- Godot — linguagens de script: <https://docs.godotengine.org/pt-br/4.x/getting_started/step_by_step/scripting_languages.html>
- Godot — C# e plataformas: <https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/index.html>
- Godot — exportação web: <https://docs.godotengine.org/pt-br/4.x/tutorials/export/exporting_for_web.html>

---

### Resumo executivo

**WRONG MOVE não deve reinventar o pôquer. Deve reinventar a sensação de jogá-lo sozinho no PC:** um jogo de cartas honesto, veloz, elegante e repetível, com controles impecáveis e adversários que tornam cada decisão interessante.
