# Implementation Plan: Wrong Move mobile

**Branch**: nenhuma branch Git criada; identificador da feature: `001-mobile-poker`.
**Date**: 2026-10-24 | **Spec**: [spec.md](spec.md)
**Status**: plano fechado até entrega1.0.0; implementação e gates ainda não executados.

## Summary

Pôquer rápido e envolvente, Android vertical, offline, Texas Hold'em no-limit para 2–6 participantes. Duas campanhas infinitas, Normal e Hardcore, com saldos próprios e desbloqueios permanentes.

O autor delegou as decisões restantes. Técnica e números são defaults normativos de release, ajustáveis pelo processo de `docs/RELEASE_ANDROID.md`; não são escolhas individuais historicamente feitas pelo autor.

Primeiro protótipo: duelo completo no Android, controles verticais provisórios, bot básico legalmente correto, resultado e retomada. Modelar participantes e contribuições para 2–6 desde o início, mas validar heads-up primeiro. Mesas maiores entram antes da campanha completa.

## Technical Context

**Language/Version**: GDScript tipado e Godot4.7.2 estável; editor/templates iguais, versão conferida em24/10/2026.
**Primary Dependencies**: APIs nativas, renderer Compatibility, OpenJDK 17 e Android SDK para exportar; sem backend, serviço de IA ou addon obrigatório. Test runner GDScript headless pequeno.
**Storage**: `user://`, slots JSON A/B, checksum e rename atômico conforme PERSISTENCIA_RELEASE.md; preferências ConfigFile e checkpoint compacto de relógio. Não usar protocolo provisório primary/bak.
**Testing**: fixtures e invariantes de regras, integração de persistência/relógio, simulações e testes físicos Android. SC-001/003/004 justificam testes críticos.
**Target Platform**: Android9+/API28, ARM64, 3 GB RAM, 512 MB livres, OpenGL ES3.0; targetAPI35, compileAPI36 (template oficial verificado). Matriz física de entrada/intermediário em RELEASE_ANDROID.md; alvo do produto, não mínimo universal da engine.
**Project Type**: um projeto Godot 2D, mobile offline, sem API remota.
**Performance Goals**: gates R08/R09: p95 frame≤33,4 ms entrada/≤16,7 ms intermediário; bot p95≤250 ms/máximo500 ms; cold start≤5 s/≤3 s. Duração medida sem fim artificial.
**Constraints**: portrait, até cinco bots, dados ocultos isolados, retomada, quatro cores, texto ampliável, sem compras/anúncios/login obrigatório.
**Scale/Scope**: oito áreas de interface, duas campanhas, tutorial, última mão e geração procedural. Sem partida livre, multiplayer, nuvem, loja ou árvore de habilidades.

## Constitution Check

`.specify/memory/constitution.md` contém apenas o template, sem princípios ratificados. Não interpretar exemplos como regras aprovadas. O plano segue a especificação e as decisões do autor.

Gates verificados antes e depois do desenho: PASS para pôquer legítimo e conservação de fichas; PASS para domínio independente da UI; PASS para Android vertical/offline; PASS para stacks iguais e saldos separados; PASS para escopo sem partida livre; PASS para propostas identificadas sem inventar aprovação do autor.

## Project Structure

```text
project.godot
export_presets.cfg
PRODUCT.md / DESIGN.md
docs/
  DECISOES_DE_PRODUTO.md
  MOBILE_UX.md
  ECONOMIA_E_PROGRESSAO.md
  POKER_RULES.md
  VALIDACAO_ANDROID.md                 # criado durante implementação
assets/{cards,fonts,ui,audio}/
scenes/{app,campaign,table,tutorial,settings}/
scripts/
  domain/                             # regras puras, sem cenas
  application/                        # comandos, sessão, relógio
  ai/                                 # agentes locais e observações
  campaign/                           # geração e economia
  persistence/                        # schema, commit, recuperação
  presentation/                       # views e navegação
data/{balance,tutorial}/
tests/{domain,integration,simulation}/
tests/run_tests.gd
specs/001-mobile-poker/
  spec.md / plan.md / research.md / data-model.md
  contracts/game-contracts.md
  quickstart.md / tasks.md / checklists/requirements.md
```

Árvore de código futura; nesta etapa só documentos foram criados. GDD e logo existentes permanecem como referências.

## Architecture

Toque → comando com ID/revisão → validação → novo estado/eventos → persistência → renderização. Só uma fila serial aplica comandos. Animação não altera resultado nem aceita ações de um turno antigo.

| Componente | Responsabilidade e limite |
|---|---|
| Domain | Cartas, avaliação, apostas, potes, botão e eliminação. Inteiros para fichas. Sem Control, arquivos ou áudio. |
| GameSession | Único caminho para comandos humanos, bots, dicas e timeout; rejeita revisão antiga/duplicatas. |
| ObservationBuilder | Copia informações públicas e cartas do próprio participante; nunca entrega Deck ou snapshot aos agentes. |
| Agent | Ranges/heurísticas, decisões mistas e equidade amostrada entre desconhecidos possíveis, nunca cartas reais ocultas. |
| CampaignService | Configuração por etapa/versão, compra única de acesso, prêmio único por tentativa. |
| SaveStore | Agregado completo, temporário validado, backup e recuperação de revisão íntegra. |
| HardcoreClock | Tempo ativo monotônico; pausa em background, regras, menu e animações sem decisão. Não calcula regras. |
| Presentation | PlayerView sanitizada, cartas, controles, feedback, navegação e acessibilidade. |

RNGs separados para deck, geração de desafios e bots/dicas. Configuração de mesa não determina as cartas. Nova tentativa tem novo embaralhamento; retomar mantém deck e posição. Bots não compartilham mãos privadas. Começar com heurísticas; distribuir cálculo de equidade por frames ou worker apenas se medição justificar. Sem solver GTO obrigatório.

## Milestones

Prioridades de entrega: P0 prova o protótipo; P1 completa lançamento; P2 futuro. Diferem da prioridade das histórias em spec.md.

| Marco | Entrega e trabalho | Risco | Critério de saída |
|---|---|---|---|
| 1. Fundação (P0) | Projeto, APK vertical vazio, cartas, ranking, regras e runner | Descobrir tarde problemas Android ou apostas | APK abre no aparelho; fixtures/invariantes passam. |
| 2. Primeiro jogável (P0) | Duelo completo, bot básico, controles, resultado e retomada | Fluxo lento ou ilegível | Jogar e retomar torneios no aparelho sem intervenção técnica. |
| 3. Recorte completo (P1) | Até seis participantes, mapa, economia, geração infinita, tutorial/dicas e Hardcore | Side pots, curva infinita e saldo inconsistente | Completar vitória, desbloqueio, derrota, repetição e retomada em ambos os modos. |
| 4. Refinamento/Android (P1) | Arte/áudio, acessibilidade, recuperação, simulações, aparelhos e pacote | Bugs de retomada e controles sob texto ampliado | Nenhum bloqueante de regras/save/saldo; métricas e limitações registradas; build candidata. |

P2: PC, cosméticos, personagens, metaprogressão adicional e eventual multiplayer. Marco 3 usa poucas mesas representativas para validar o gerador; o lançamento continua tendo progressão infinita. Não fixar semanas sem medir o esforço dos marcos 1–2.

## Risks and validation

- Testar all-ins múltiplos, side pots e passagem para heads-up antes de campanha em mesa cheia.
- Compra de dica, passe e vitória precisam de débito/crédito+resultado na mesma revisão persistida.
- IA: mesma observação e mesmo RNG devem dar a mesma decisão mesmo ao alterar cartas ocultas reais.
- Duração não é garantida: medir distribuição, mãos/torneio e tempo ativo separado das pausas. Blinds acelerados aumentam variância e não substituem bots melhores.
- Dificuldade cresce por blocos até tetos de força/pressão; depois varia configurações avançadas. Infinito não significa inteligência ou blinds ilimitados.
- Primeira vitória deve permitir próximo passe sem grind obrigatório; medir se duelos antigos rendem saldo/minuto demais.
- Validar cinco bots, board e texto 150% antes da arte final.

## Complexity Tracking

Sem violações dos gates. Um projeto e snapshots locais bastam; banco, backend e event sourcing completo não são necessários. Histórico limitado à última mão. Templates e configurações de balanceamento em dados.

## Próximo passo executável

T001–T004 implementadas; primeiro APK debug exportado. T005 permanece parcial até instalação física. Implementação corrente e evidências: docs/VALIDACAO_ANDROID.md. Guia de validação: quickstart.md.
