# Tasks: Wrong Move mobile

**Input**: spec.md, plan.md, research.md, data-model.md, contracts/game-contracts.md, release-baseline.json e contratos de release em docs/. Defaults fechados sob delegação do autor.
**Status**: primeiro jogável0.1.0-dev implementado, APK debug exportado; tarefas marcadas abaixo têm implementação/testes no host. Gates físicos e release1.0.0 continuam pendentes. Evidências em `docs/VALIDACAO_ANDROID.md`.
**Organization**: setup, fundação, histórias em ordem P1 antes de P2 e refinamento. US5 vem antes de US2 por ser P1 e prover persistência.
**Tests**: incluídos para regras, integridade, saldo e retomada, conforme SC-001/003/004 da especificação. Escrever fixtures que evidenciem falhas antes de implementar a lógica correspondente; não exigir TDD de arte/documentação.
**Format**: `- [ ] Tnnn [P opcional] [USn quando aplicável] ação com caminho`. [P] só após pré-requisitos; não é autorização para editar o mesmo arquivo em paralelo.

**Organização efetiva**: telas leves e modais compartilham `app_view.gd`; orquestração de lifecycle/dicas/Hardcore compartilha `app.gd`/`game_session.gd`. Tarefas concluídas tiveram os caminhos atualizados para os arquivos reais, sem reduzir requisitos. T005/T021/T028/T035/T042/T048/T051/T053/T055 têm implementação ou evidência parcial, mas permanecem abertas por critérios ainda não cumpridos. T024 tem A/B pronto, faltando fluxo confirmado para dois slots inválidos; T026/T027 têm controles/tema/safe area provisórios, faltando validação completa de reflow/acessibilidade. T036/T038 têm conteúdo embutido inicial, não catálogo JSON final.

## Phase 1: Setup

- [x] T001 Criar projeto Compatibility/GDScript em `project.godot`, portrait e base 360×800; verificar editor/templates 4.7.2 e SDK/JDK do host real em `docs/VALIDACAO_ANDROID.md`.
- [x] T002 Criar entrada mínima em `scenes/app/app.tscn` e `scripts/application/app.gd`, preservando GDD/logo e separando pastas conforme plan.md.
- [x] T003 [P] Configurar exclusões em `.gitignore` para `.godot/`, builds e credenciais de exportação; documentar execução em `README.md`.
- [x] T004 Implementar runner headless e saída não zero em falha em `tests/run_tests.gd`, com seleção domain/integration/simulation.
- [ ] T005 Configurar preset público em `export_presets.cfg`, gerar primeiro APK e registrar instalação em aparelho físico em `docs/VALIDACAO_ANDROID.md`.

Checkpoint: ambiente Android validado cedo, sem declarar sucesso apenas por execução desktop.

## Phase 2: Foundational

- [x] T006 Codificar regras v1 de `docs/POKER_RULES.md` em `tests/domain/rules_cases.gd`, incluindo eliminações, abertura curta pós-flop (mínimo25 após5/BB20), reabertura cumulativa e BB short nominal.
- [x] T007 Implementar carta/deck e fluxos RNG separados em `scripts/domain/card.gd`, `scripts/domain/deck.gd` e `tests/domain/test_deck.gd`, com 52 cartas únicas e embaralhamento reproduzível em testes.
- [x] T008 Implementar DTOs em `scripts/domain/game_state.gd`, `scripts/campaign/campaign_state.gd` e aritmética decimal em `scripts/domain/unsigned_decimal.gd`: `2 <= participants <= 6`, `starting_stack > 0`, torneio até6000 fichas, `wallet >= 0`, índices/wallet/revisões arbitrários como strings e uma tentativa por campanha; testar100 dígitos em `tests/domain/test_unsigned_decimal.gd`.
- [x] T009 Implementar comandos/revisão/fila serial em `scripts/application/game_session.gd`, com rejeição de turno antigo e idempotência conforme `specs/001-mobile-poker/contracts/game-contracts.md`.
- [x] T010 Criar projeção sanitizada em `scripts/application/observation_builder.gd` e isolamento em `tests/integration/test_observation.gd`, sem deck/seed/cartas alheias para UI, bot ou dica.

Checkpoint: dados e contratos permitem testar domínio sem cenas; histórias dependem desta fundação.

## Phase 3: US1 — Torneio (P1)

Goal: disputar e terminar torneios com regras corretas. Independent test: duelo e mesa de seis, incluindo all-ins, side pots e passagem a heads-up.

- [x] T011 [P] [US1] Escrever categorias, kickers, A2345, board-only e mãos com múltiplas combinações em `tests/domain/test_hand_evaluator.gd`.
- [x] T012 [P] [US1] Escrever fixtures de call/raise/reabertura/blinds e conservação de fichas em `tests/domain/test_betting.gd` e `tests/domain/test_pots.gd`.
- [x] T013 [US1] Implementar avaliação de melhor mão de cinco entre até sete em `scripts/domain/hand_evaluator.gd`, sem depender de nós visuais.
- [x] T014 [US1] Implementar ações legais e raise-to por street em `scripts/domain/betting_rules.gd`, incluindo all-in curto e reabertura por participante.
- [x] T015 [US1] Implementar side pots, elegibilidade, retorno de excedentes e empate em `scripts/domain/pot_settlement.gd`, cobrindo contribuições 100/250/400 das fixtures.
- [x] T016 [US1] Implementar torneio/mãos/botão/blinds e término antecipado em `scripts/domain/tournament.gd` e `tests/domain/test_tournament.gd`, incluindo 3→2 participantes.
- [x] T017 [US1] Implementar política de `docs/AI_RELEASE.md` em `scripts/ai/basic_agent.gd` e `data/balance/bot_profiles.json`, só AgentObservation/RNG próprio e defaults de release-baseline.json.
- [x] T018 [US1] Criar mesa provisória e cartas em `scenes/table/poker_table.tscn`, `scenes/table/card_view.tscn` e `scripts/presentation/table_view.gd`, com bots 3+2 e informações essenciais legíveis.
- [x] T019 [US1] Criar controles legais, presets, slider, −/+, confirmação e proteção de toque duplicado em `scenes/table/bet_controls.tscn` e `scripts/presentation/bet_controls.gd`.
- [x] T020 [US1] Integrar resultado por mão/torneio e indicação de estilo em `scenes/table/result_panel.tscn` e `scripts/application/app.gd` e `scripts/presentation/app_view.gd`, sem revelar cartas indevidas.
- [ ] T021 [US1] Rodar torneios completos simulados e Android em `tests/simulation/test_tournaments.gd` e `docs/VALIDACAO_ANDROID.md`, registrando duração/latência e preservação de fichas.

Checkpoint: pode validar heads-up antes de T015/T016 multiway completos, mas US1 só termina após 2–6 participantes corretos.

## Phase 4: US5 — Mobile, salvar e retomar (P1)

Goal: interromper e retomar com confiança. Independent test: uma tentativa em cada modo, bloqueio/background/fechamento, preferências e falha de gravação.

- [x] T022 [P] [US5] Criar testes de roundtrip, versão futura, backup e falha por fronteira de commit em `tests/integration/test_save_store.gd`.
- [x] T023 [US5] Implementar schema/migração e snapshot de agregado em `scripts/persistence/save_codec.gd`, com seeds 64 bits como strings e rejeição de overflow/estado inválido.
- [ ] T024 [US5] Implementar slots A/B, checksum e rename atômico em `scripts/persistence/save_store.gd`, conforme `docs/PERSISTENCIA_RELEASE.md`; ignorar tmp, preservar save futuro e confirmar reset de ambas cópias inválidas.
- [ ] T025 [US5] Integrar autosave por comando, lifecycle e menu continuar/salvar/abandonar em `scripts/application/lifecycle.gd` e `scenes/table/pause_panel.tscn`, com confirmação de abandono e retomada pausada.
- [ ] T026 [P] [US5] Implementar preferências em `scripts/persistence/preferences_store.gd` e `scenes/settings/settings.tscn`, incluindo texto 100/125/150%, quatro cores, áudio, vibração e movimento reduzido.
- [ ] T027 [US5] Aplicar safe area, containers, tema e reflow em `scripts/presentation/safe_area.gd` e `assets/ui/mobile_theme.tres`, testando as três fixtures de tela de MOBILE_UX.md sem rolar para agir.
- [ ] T028 [US5] Validar no Android interrupções e dois saves independentes em `tests/integration/test_resume.gd` e `docs/VALIDACAO_ANDROID.md`, sem reaplicar apostas ou resultado.

Checkpoint: primeiro jogável mobile = duelo de US1 + retomada de US5; não precisa esperar campanha/arte final.

## Phase 5: US2 — Campanhas e economia (P2 da história, P1 de entrega)

Goal: vencer, comprar acesso e continuar desafios. Independent test: primeiras mesas, saldo zero, recompra/reenvio, ambas as campanhas e 10.000 índices.

- [x] T029 [P] [US2] Escrever testes de passe/prêmio únicos, bônus, derrota sem prêmio e separação dos saldos em `tests/integration/test_campaign_economy.gd`.
- [x] T030 [US2] Transcrever defaults fechados de `specs/001-mobile-poker/release-baseline.json` e `docs/ECONOMIA_E_PROGRESSAO.md` em `data/balance/campaign.json` e `data/balance/blinds.json`, incluindo fórmula pós6, dica por tier e blind terminal.
- [x] T031 [US2] Implementar gerador versionado por blocos em `scripts/campaign/challenge_generator.gd`, `2 <= participants <= 6`, janela de etapas, tetos de dificuldade e configuração comprada imutável.
- [x] T032 [US2] Implementar acesso/recompensas com recibos e commit conjunto em `scripts/campaign/campaign_service.gd`; primeira mesa gratuita, saldo não negativo e uma tentativa por campanha.
- [x] T033 [US2] Implementar início e mapa linear virtualizado em `scripts/presentation/app_view.gd` e `scripts/application/app.gd`, sem partida livre e com continuar da campanha correta.
- [x] T034 [US2] Implementar detalhe/compra de mesa e resultado com prêmio/bônus em `scripts/presentation/app_view.gd` e `scripts/application/app.gd`, exibindo sucesso só após commit.
- [ ] T035 [US2] Validar 10.000 etapas, atualização de balanceamento e rendimento por minuto em `tests/simulation/test_progression.gd` e `docs/VALIDACAO_ANDROID.md`, sem exigir força infinita da IA.

## Phase 6: US3 — Tutorial, dicas e revisão (P2 da história, P1 de entrega)

Goal: iniciante aprende e compra orientação opcional. Independent test: tutorial pulável/revisitável, consulta grátis, compra/reabertura sem débito duplicado e última mão sanitizada.

- [ ] T036 [P] [US3] Transcrever roteiro fechado de `docs/CONTEUDO_RELEASE.md` em `data/tutorial/lessons.json`, com fixtures de cartas únicas, ações e ranking exibido.
- [x] T037 [US3] Implementar tutorial separado em `scripts/application/tutorial_controller.gd` e projeção de treino em `scripts/presentation/app_view.gd`, sem prêmios de campanha e sem alterar RNG de torneios.
- [ ] T038 [P] [US3] Criar termos/regras PT-BR e ranking grátis em `data/tutorial/glossary.json` e `scenes/tutorial/rules_panel.tscn`, com ação/valor/termo técnico claros.
- [x] T039 [US3] Implementar dica estável força5/equilibrado e textos de `docs/AI_RELEASE.md` em `scripts/ai/hint_advisor.gd`, sem ruído/blefe aleatório, equidade numérica na UI ou informação oculta.
- [x] T040 [US3] Implementar oferta após8 s ativos em `scripts/application/game_session.gd` e `scripts/presentation/app_view.gd`; preço por fórmula/tier e chave decision_id, confirmação, sem alterar stack/pote e reabertura grátis após pausa/tick.
- [x] T041 [US3] Implementar última mão e comparação de resultado em `scripts/application/hand_history.gd` e painel de revisão em `scripts/presentation/app_view.gd`, sem cartas não reveladas.
- [ ] T042 [US3] Testar débito/conteúdo atômicos, saldo insuficiente e revisões antigas em `tests/integration/test_hints.gd`; registrar revisão qualitativa com iniciantes em `docs/VALIDACAO_ANDROID.md`.

## Phase 7: US4 — Hardcore e força dos bots (P2 da história, P1 de entrega)

Goal: campanha independente com pressão de tempo. Independent test: consumir 10 s e reserva de 30 s, pausar, retomar, correr timeout contra toque e conferir ausência de dica.

- [x] T043 [P] [US4] Escrever testes de tempo ativo, reserva, pausa/regras/animação e corrida de ação/timeout em `tests/integration/test_hardcore_clock.gd`.
- [x] T044 [US4] Implementar relógio e checkpoint conservador em `scripts/application/hardcore_clock.gd` e `scripts/persistence/clock_store.gd`, conforme PERSISTENCIA_RELEASE.md: pausa exata, kill sem devolver tempo e perda≤1000 ms; janela ativa só após checkpoint persistido.
- [x] T045 [US4] Integrar timeout check/fold e indicação de tempo/reserva em `scripts/application/game_session.gd` e `scripts/presentation/table_view.gd`, com uma única ação por revisão.
- [x] T046 [US4] Implementar política de `docs/AI_RELEASE.md` em `scripts/ai/strategic_agent.gd` e `scripts/ai/equity_estimator.gd`, amostras fixas/ruído por força, gate500 ms e erro pausado BOT_BUDGET_EXCEEDED, sem fallback estratégico por tempo nem acesso ao deck real.
- [x] T047 [US4] Integrar campanha Hardcore desde o início, aviso, saldo próprio e proibição de dica em `scripts/application/game_session.gd` e `data/balance/hardcore.json`.
- [ ] T048 [US4] Validar força relativa, isolamento de cartas e interrupções do relógio em `tests/simulation/test_agents.gd` e `docs/VALIDACAO_ANDROID.md`, registrando tolerância real de morte abrupta entre checkpoints.

## Phase 8: Polish e entrega Android

- [ ] T049 [P] Produzir inventário final de `docs/CONTEUDO_RELEASE.md` em `assets/cards/`, `assets/ui/` e `assets/fonts/`, com52 faces, ícones originais e Noto Sans/Serif; registrar em `assets/LICENSES.md` e tela Sobre.
- [x] T050 [P] Produzir oito efeitos e loop original60 s em `assets/audio/` e integrar `scripts/presentation/feedback.gd`, defaults de CONTEUDO_RELEASE.md, sem bloquear ações.
- [ ] T051 Validar offline, desempenho, duração, texto ampliado e bateria de interrupções nos aparelhos em `docs/VALIDACAO_ANDROID.md`, conforme `specs/001-mobile-poker/quickstart.md`.
## Phase 9: US6 — Entrega instalável (P1)

Goal: entregar pacote1.0.0 cumprindo R01–R12. Independent test: assinatura/hashes, instalação offline, atualização com save e evidências físicas. Publicação em loja fora desta entrega.

- [ ] T052 [US6] Configurar APK1.0.0/code1/API28–35/ARM64 em `export_presets.cfg`, package `com.wrongmove.game` e debug separado, conforme `docs/RELEASE_ANDROID.md`.
- [ ] T053 [US6] Criar build reproduzível e lock de ferramentas em `tools/build_android.sh` e `docs/BUILD_ANDROID.md`, host/versões reais e export sem segredos.
- [ ] T054 [US6] Criar/usar assinatura dedicada fora do repo, verificar APK e custódia local do autor; registrar somente certificado público/procedimento em `docs/ASSINATURA_ANDROID.md`.
- [ ] T055 [P] [US6] Inspecionar manifesto e implementar dados locais/versão/licenças em `scenes/settings/about.tscn` e `docs/PRIVACIDADE.md`, sem INTERNET/ads/analytics/backup em nuvem.
- [ ] T056 [US6] Implementar upgrade compatível e debug isolado em `tests/integration/test_upgrade.gd`; registrar instalação/atualização com progresso em `docs/VALIDACAO_ANDROID.md`.
- [x] T057 [US6] Validar defaults/runtime e goldens em `tests/simulation/test_release_baseline.gd`, fórmulas, configs compradas e100 dígitos, comparando `specs/001-mobile-poker/release-baseline.json`.
- [ ] T058 [US6] Executar fault injection/retomada/relógio e100 ciclos por tipo em `tests/integration/test_release_recovery.gd`; evidenciar R04/R05 em `docs/VALIDACAO_ANDROID.md`.
- [ ] T059 [US6] Executar bots pareados e torneios/duração em `tests/simulation/test_release_balance.gd`, metas de AI_RELEASE.md e R01/R08/R09; registrar números reais em `docs/VALIDACAO_ANDROID.md`.
- [ ] T060 [US6] Aplicar tutorial a cinco iniciantes e corrigir até R10 passar; registrar sem dados pessoais em `docs/VALIDACAO_ANDROID.md` e ajustar `data/tutorial/lessons.json` se necessário.
- [ ] T061 [US6] Validar R06/R07/R08/R11 em dois aparelhos, com capturas em `docs/validation/` e modelos/APIs reais em `docs/VALIDACAO_ANDROID.md`.
- [ ] T062 [P] [US6] Preparar instruções pt-BR e notas reais em `docs/ENTREGA_LEIA-ME.md` e `CHANGELOG.md`, requisitos/instalação/atualização/limitações.
- [ ] T063 [US6] Montar APK, fontes ZIP, docs, licenças, relatório e SHA256SUMS em `dist/1.0.0/`, conforme `docs/RELEASE_ANDROID.md`, excluindo saves/segredos/caches.
- [ ] T064 [US6] Conferir gates em `specs/001-mobile-poker/checklists/release.md` e aceite em `dist/1.0.0/VALIDACAO.md`; gate não verificado mantém status candidata, não release entregue.

## Dependencies & Execution Order

Setup T001–T005 → fundação T006–T010 → US1 → US5 → US2 → US3 → US4 → refinamento → US6. T052/T053 podem preparar a identidade/build durante T005. Campanha depende de torneio/save; dica de economia; Hardcore de retomada; US6 integra tudo. Nenhum sistema começa por arte final.

Dentro de US1, criar fixtures e avaliador antes do fluxo completo; validar duelo antes de expandir UI e casos multiway. Depois da base comum, modelos de serviços podem ser verificados com fixtures, sem depender da conclusão visual de outras histórias.

### Parallel opportunities

- Setup: T003 após escolher estrutura, enquanto T004 cuida do runner.
- US1: T011/T012 independentes; após contratos, assets provisórios não devem alterar arquivos do motor.
- US5: T026 pode acompanhar codec/store; T027 exige mesa existente e integra as preferências depois.
- US2: T029 usa contratos/fixtures enquanto se configura T030; conectar após serviço pronto.
- US3: T036/T038 podem ocorrer juntos; tutorial e dicas convergem só após os respectivos serviços.
- US4: T043 prepara fixtures enquanto se mede agente existente; T046 pode ocorrer após observações sem editar o relógio.
- Refinamento: T049/T050 em caminhos distintos, após tema e opções definidos.

## Implementation strategy and milestones

1. Marco 1: T001–T010 e primeiras fixtures de US1. Provar exportação e domínio testável.
2. Marco 2: US1 em heads-up + núcleo US5. Primeiro duelo vertical que pode fechar e continuar.
3. Marco 3: concluir multiway de US1 e US5; US2–US4. Recorte de campanha testável com gerador que continua além dele.
4. Marco4: T049–T064 e gates R01–R12, todos os requisitos e pacote entregável.

São64 tarefas:5 setup,5 fundação,11 US1,7 US5,7 US2,7 US3,6 US4,3 refinamento e13 US6. Podem ser subdivididas; não são estimativas de dias. Caminhos descrevem arquivos futuros quando ainda não existem.

## Requirement coverage

| Requisitos | Tarefas principais |
|---|---|
| FR-001/002 | T006–T021, T046/T048 |
| FR-003/004 | T031/T033/T037/T047 |
| FR-005/006/007 | T008/T029–T035 |
| FR-008/009 | T017/T018/T020/T031/T035/T046/T048 |
| FR-010/011 | T025/T028/T043–T048 |
| FR-012/013 | T018/T019/T036–T038/T041 |
| FR-014/015/016 | T039–T042/T047 |
| FR-017/018/019 | T018/T019/T026/T027/T049/T050 |
| FR-020/021 | T022–T028/T051/T052 |
| FR-022/023 | T052–T056/T062–T064 |
| FR-024/028 | T036–T038/T049/T050/T055/T060 |
| FR-025/026 | T008/T023/T024/T031/T035/T057/T058 |
| FR-027 | T039/T040/T042 |
