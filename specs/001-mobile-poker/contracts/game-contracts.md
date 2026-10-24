# Contratos locais

Sem HTTP. Contratos entre regras, sessão, agentes, UI e armazenamento.

## Ação

`ActionCommand(command_id, attempt_id, hand_id, expected_revision, seat_id, kind, raise_to?)`. Kind FOLD/CHECK/CALL/BET_TO/RAISE_TO/ALL_IN; total da street. Validar turno, revisão, stack e direito de aumentar. Sucesso devolve estado/eventos novos; erro não deixa mutação parcial. Reenviar command_id aplicado devolve resultado anterior.

`get_legal_actions(seat_id)` retorna to_call, permissões de check/fold/bet/raise/all-in, min_raise_to, max_raise_to e all-in curto. Campos inaplicáveis ausentes/null, não zero ambíguo. UI/bots não implementam outra versão dessas regras.

## Observações e dicas

`build_observation(seat_id)` devolve cópia de informações autorizadas. `choose_action(observation, agent_rng)` devolve candidato com expected_revision; descartar resultado tardio de turno antigo. Nenhum agente recebe Deck, save ou cartas alheias. Dica usa perspectiva do jogador e aleatoriedade própria, sem promessa de vitória.

`buy_hint(command_id, attempt_id, decision_id, expected_domain_revision, quoted_price)` exige Normal, turno atual, saldo e confirmação. Conteúdo+débito no mesmo commit A/B; falha não cobra parcialmente. Dica reabre sem cobrar no mesmo decision_id, mesmo após pausa/checkpoint. A política e os textos estão em AI_RELEASE.md; tick visual não cria decisão nova.

## Campanha

`unlock_table(command_id, mode, table_id, quoted_cost)` verifica vitória anterior/custo/saldo, fixa configuração e cobra uma vez. Mesa já comprada não cobra.

`start_attempt(command_id, mode, table_id)` exige acesso e ausência de outra tentativa na campanha. Não cobra entrada; novo deck e stack igual.

`finalize_attempt(attempt_id)` fixa resultado, prêmio/bônus, marca de primeira vitória e recibo juntos. Reexecução não credita. Derrota/abandono não pagam.

## Pausa e eventos

`pause(reason)` bloqueia entrada, captura tempo, ignora jobs pendentes e salva. `resume()` mantém decisão/reserva e exige `Continuar` após background. Regras/menu/animações sem decisão congelam tempo. `abandon_attempt(command_id, confirmed=true)` encerra sem remover passe, sem prêmio.

Eventos TurnStarted, ActionApplied, StreetRevealed, CardsRevealed, PotAwarded, HandFinished, AttemptFinished, CampaignUpdated carregam revisão/ID. Eventos para UI/revisão sanitizados, nunca debug com cartas ocultas.

Erros: STALE_REVISION atualiza tela; ILLEGAL_ACTION recalcula controles; INSUFFICIENT_FUNDS informa requisito sem pagamento real; ACTIVE_ATTEMPT oferece retomar/abandonar; SAVE_FAILED permite retry com estado anterior íntegro; SAVE_INCOMPATIBLE preserva arquivos. Sem reset silencioso.

BOT_BUDGET_EXCEEDED pausa e oferece retry com a mesma observação/RNG, sem ação estratégica parcial ou troca do baralho. Quantidade de amostras é fixa por força, não decidida por tempo decorrido.

## Versões e commit

ActionCommand.expected_revision é a revisão do domínio, não a revisão de arquivo ou relógio. IDs e protocolo A/B em `docs/PERSISTENCIA_RELEASE.md`. Ação/timeout são serializados após atualizar tempo; timeout já esgotado vence toque tardio. Assinar/exibir sucesso econômico somente após commit. Falha de save pausa sem reaplicar operação.

## Entrega

FR-022–028 e US6 usam contrato `docs/RELEASE_ANDROID.md` e dados `release-baseline.json`. Nenhuma API pública, servidor ou dependência de loja é introduzida.
