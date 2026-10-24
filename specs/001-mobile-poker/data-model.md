# Data model

Modelo lógico fechado para schema1; dados explícitos, nunca nós Godot serializados. Contrato completo de commit e relógio: `docs/PERSISTENCIA_RELEASE.md`.

| Entidade | Campos | Restrições |
|---|---|---|
| SaveEnvelope | schema_version, save_revision, domain_revision, rules_version, balance_version, generator_version, normal, hardcore, tutorial_progress, receipts, checksum | Agregado validado A/B; checksum dos bytes canônicos; revisões em decimal arbitrário. |
| CampaignProgress | mode, seed, frontier, wallet, unlocked_tables, completed_tables, next_attempt_counter, active_attempt | `wallet >= 0`; inteiros persistentes decimais arbitrários; uma tentativa ativa por campanha; primeira mesa liberada; saldos separados. |
| TableConfig | id, index, generator_version, participants, starting_stack, blind_schedule, profiles, unlock_cost, reward, bonus, hint_price | `2 <= participants <= 6`; `starting_stack > 0` igual para todos; valores inteiros não negativos; configuração comprada imutável. |
| AttemptState | id, config_snapshot, status, seats, hand_number, button, blind_level, hand, clock, last_hand, rng_streams, pending_decision, last_dealt_seat_ring | ACTIVE/PAUSED/WON/LOST/ABANDONED; terminal não reativa; prêmio por attempt_id; RNG com algoritmo/versão/estado string. |
| SeatState | id, human, stack, hole_cards, folded, all_in, street_contribution, hand_contribution, acted_at_bet_level | Contribuições/stack não negativos; eliminado não recebe cartas; privados só no domínio/save. |
| HandState | id, domain_revision, decision_id, phase, deck_order, cursor, burns, board, actor, current_bet, last_full_raise, pots, actions, reveals | PREFLOP/FLOP/TURN/RIVER/SHOWDOWN/SETTLED; cartas únicas; direitos por jogador; decision_id não muda por pausa/tick. |
| Pot | amount, contributor_ids, eligible_ids, awards | Fold remove elegibilidade, não contribuição; prêmios somam o pote. |
| ClockState | decision_remaining_ms, reserve_remaining_ms, running, pause_reason | Apenas Hardcore; valores não negativos; nova decisão repõe apenas tempo individual, não reserva. |
| Receipt | command_id, kind, business_key, campaign_id, resulting_revision, delta, result | Aplicação única; reenvio devolve resultado. |
| HintRecord | attempt_id, decision_id, cost, action, explanation | Uma cobrança por decisão; conteúdo persistido para reabrir, independente de save_revision. |
| PlayerView/AgentObservation | board, stacks, public_actions, own_cards, legal_actions, public_pots, reveals | Sem deck, seed, cartas privadas alheias ou referência ao snapshot. |
| Preferences | music, sfx, vibration, text_scale, four_color, reduced_motion | Faixas válidas e defaults; pode persistir separado da economia. |

## Transições

Mesa locked → comprável após vitória anterior → unlocked → completed; completed continua aberta. Tentativa ACTIVE ↔ PAUSED; ACTIVE → WON/LOST e ACTIVE/PAUSED → ABANDONED confirmado. Nova tentativa tem outro ID e deck; retomar não reinicia nada.

Mão: blinds/distribuição → pré-flop → flop → turn → river → showdown → liquidação. Fold encerra antecipadamente; all-in sem decisão completa o board. Resultado+saldo+recibo são calculados, validados e gravados juntos antes de exibir sucesso.

## Persistência

Slots `user://save/state_a.json` e `state_b.json`, temporário por slot, mais `user://preferences.cfg`. O commit é substituição atômica do slot inativo; recuperar maior revisão válida A/B, nunca promover temporário. Contrato normativo em PERSISTENCIA_RELEASE.md, incluindo falta de espaço, corrupção e save futuro.

Preservar deck/posição, RNG dos bots e decisões pendentes. Seeds/estados como strings; carteira/índices/revisões/contadores em decimal arbitrário, sem conversão por float/int64. Fichas do torneio usam inteiros limitados a6000 de soma, não a moeda persistente. Testar valores de100 dígitos. Não sobrescrever save futuro.

Autosave após comandos. Capturar tempo exato em pausa e checkpoint conservador compacto durante atividade: morte abrupta perde até1000 ms, nunca devolve tempo. Animações reconstruídas sem reaplicar apostas. Migração por schema_version; validar cartas/fichas/revisão. Recibos de tentativas terminais compactados em marcadores de passe/conquista e contador, sem perder idempotência.
