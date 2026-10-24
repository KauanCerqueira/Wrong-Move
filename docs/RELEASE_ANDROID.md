# Contrato de entrega Android 1.0.0

**Status da especificação: fechado para implementação. Aplicativo: primeiro jogável0.1.0-dev; gates do release1.0.0 pendentes.** Evidências em [VALIDACAO_ANDROID.md](VALIDACAO_ANDROID.md).

O autor delegou as decisões restantes ao assistente em 24/10/2026. Este contrato e `specs/001-mobile-poker/release-baseline.json` fixam a primeira entrega. Não é necessário voltar a perguntar sobre números, assets, regras ou canal de distribuição já definidos aqui. Ajustes de balanceamento exigidos pelos testes são feitos e registrados pelo implementador dentro dos limites deste pacote.

## O que significa entrega

Entregar localmente um APK release assinado e instalável, código-fonte, instruções, relatório de validação e checksums. O primeiro canal é instalação direta no Android. Não exigir conta de desenvolvedor, postagem pública, Play Console ou AAB para considerar essa entrega concluída. Publicação em loja, PC e serviços remotos são versões posteriores.

Artefatos em `dist/1.0.0/`:

- `wrong-move-1.0.0-arm64.apk`, release, não debuggable, assinatura própria de distribuição.
- `wrong-move-1.0.0-source.zip`, fontes, dados, assets licenciados, export preset sem segredos, documentação e lock das versões; excluir caches, saves pessoais, keystores e builds redundantes.
- `LEIA-ME.md`, instalar/atualizar, requisitos, controles, privacidade, limitações e local do código.
- `CHANGELOG.md`, escopo realmente entregue e problemas conhecidos não bloqueantes.
- `VALIDACAO.md`, evidências dos gates abaixo, aparelho/SO/ABI, comandos e resultados reais.
- `SHA256SUMS.txt`, hashes dos artefatos; hash do certificado público em VALIDACAO.md.

Assinatura é necessária para instalação e continuidade de atualizações; conferir [documentação Android](https://developer.android.com/studio/publish/app-signing). Criar keystore de release dedicado no ambiente do proprietário, preservar fora do repo e fornecer custódia local documentada ao autor. Senhas nunca entram em APK, log ou ZIP. Não tratar chave temporária do agente como custódia entregue. Debug usa package ID separado para não exigir apagar o progresso do release.

## Identidade, compatibilidade e distribuição

- Nome Wrong Move; package ID `com.wrongmove.game`, debug `com.wrongmove.game.debug`; versionName 1.0.0, versionCode 1. Não presumir propriedade de domínio ou disponibilidade em loja.
- Android mínimo 9/API 28; target API35 e compile API36, ARM64, OpenGL ES 3.0, 3 GB RAM, 512 MB livres. Não prometer 32 bits, iOS, tablets em paisagem ou versões anteriores.
- Godot 4.7.2 estável, GDScript, Compatibility e templates correspondentes. JDK17; SDK platform36 e build-tools36.1.0 exigidos pelo template Gradle oficial efetivamente instalado. Ajuste técnico registrado em BUILD_ANDROID.md; min28/target35 e escopo de produto preservados. Referência: [Godot Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html). Não variar editor/templates sem testar novamente.
- Locale pt-BR, orientação vertical inclusive durante pausas; respeitar recortes e barras. Voltar do Android abre pausa na mesa e retorna na navegação, sem abandono acidental.
- Release sem INTERNET, anúncios, analytics, notificações, faturamento, coleta de conta ou acesso amplo a arquivos. Vibração é opcional, usa apenas a permissão pertinente. Sem pedido de microfone, contatos ou localização.
- Saves locais privados; sem backup na nuvem ou exportação de save nesta versão. Desinstalar/apagar dados remove progresso; atualizar com a mesma assinatura preserva. Informar isso nas instruções e na tela Sobre.

## Escopo completo do lançamento

Duas campanhas infinitas com desbloqueios próprios; torneios 2–6; bots de três estilos e força graduada; tutorial de cinco lições; dica paga Normal; ranking/combinação atual; revisão da última mão; pausa e um save por campanha; controles/apostas, áudio, texto ampliável e quatro cores. Nenhum requisito desse conjunto pode ser removido para chamar o protótipo de 1.0.0.

Sem partida livre, números de equidade na UI, estatísticas acumuladas públicas, cosméticos desbloqueáveis, compras, conta ou multiplayer. Última mão fica por campanha, disponível após encerramento; sem navegação de cartas futuras. Tutorial compartilhado não mistura saldos.

## Gates de aceite, todos obrigatórios

| Gate | Passa quando | Evidência exigida |
|---|---|---|
| R01 Regras | Fixtures de ranking/apostas/potes/posição passam 100%; zero violação em 10.000 mãos simuladas com 2–6 participantes, incluindo cada contagem | Resumo do runner e seeds de falhas corrigidas. |
| R02 Justiça | Mesmo input autorizado e RNG do agente produzem mesma ação apesar de mudar ocultos; deck não depende de campanha/dificuldade | Testes automatizados e contratos de observação. |
| R03 Economia | Passe, prêmio, dica e abandono corretos, replay de comandos sem duplicar; zero saldo negativo; primeira vitória líquida sem dicas paga o próximo passe | Fixtures das seis primeiras + 10.000 índices e casos em inteiros de 100 dígitos. |
| R04 Save | 100 ciclos por tipo (background, bloqueio, fechar/abrir) e falhas nas fronteiras A/B sem perder transação confirmada; versão futura não sobrescrita | Testes e 20 interrupções físicas por aparelho, distribuídas entre modos e operações. |
| R05 Hardcore | 10 s + 30 s, timeout único, pausa exata em saída normal; morte abrupta nunca devolve tempo e perde no máximo 1 s por ocorrência | Testes com relógio controlado e kill físico, incluindo corrida toque/timeout. |
| R06 Mobile | Todas as ações/quantias e cinco bots legíveis em 360×640, 360×800 e 412×915, textos 100/125/150%, safe areas | Capturas reais e fixtures; nenhum botão essencial cortado. |
| R07 Offline | Instalação, tutorial, modos, dicas, saldo e retomada funcionam em modo avião; manifesto cumpre permissões definidas | Checklist físico e inspeção do APK. |
| R08 Desempenho | Em 20 min de mesa cheia: p95 de frames ≤33,4 ms no aparelho de entrada e ≤16,7 ms no intermediário, excluindo transições/sistema; abertura fria ≤5 s entrada/≤3 s intermediário; bot p95 ≤250 ms, máximo 500 ms | Métricas de build release, aparelhos e configurações; zero ANR/crash na sessão. |
| R09 Ritmo | Em 30 torneios por formato (2,3,4,5,6) com piloto automatizado de decisão, mediana ativa ≤5 min duelo/≤10 min mesa maior; em playtest registrar também duração humana, sem prazo forçado | Distribuição p50/p90 e mãos; duas rodadas de ajustes se falhar, mantendo regras/stack igual. |
| R10 Aprendizado | Em uma rodada de 5 iniciantes, pelo menos 4 concluem tutorial e fazem pagar/aumentar/passagem sem intervenção externa; sem erro de regra no texto | Roteiro aplicado, observações e correções. |
| R11 Estabilidade | Zero bugs bloqueantes/altos abertos; 2 h de uso misto por aparelho sem crash; upgrades preservam saves/assinatura | Lista de bugs por severidade e resultado da instalação/atualização. |
| R12 Entrega | APK assinado válido, instala offline, fontes/ícones/sons finais e licenças presentes, ZIP e hashes conferidos, keystore sob custódia do autor | Pasta final, inspeção de assinatura, hashes e documentação de custódia sem segredos. |

Matriz mínima física: um ARM64 com 3–4 GB/API 28–30 e um intermediário com 6 GB ou mais/API 34–36; ao menos um tem recorte. Registrar modelos realmente disponíveis. Emulador cobre APIs/proporções extras, não substitui a matriz física. Se hardware ou assinatura estão indisponíveis na execução, marcar gate como não verificado e build como candidata, sem chamar release entregue.

Severidade bloqueante: jogo não inicia, regra incorreta, informação oculta exposta, perda/duplicação de saldo, save inutilizável, controle essencial inacessível. Alta: fluxo obrigatório quebrado, cronômetro errado, tutorial ensina regra errada, incompatibilidade na matriz. Baixa: defeito cosmético que não impede entendimento; documentar e só aceitar se todos os gates continuarem passando.

Ajustar dentro do plano: intervalos de blinds de 3–8 mãos, força/mistura dos perfis, duração de feedback de 0–300 ms, prêmios/passes mantendo invariantes e frequência da ajuda entre 6–12 s. Registrar mudança e incrementar balance_version; atualizar baseline/spec/tarefas afetadas e repetir testes. Não mudar regras, cobrar entrada por tentativa ou adicionar monetização como ajuste de balanceamento.

## O que está pronto agora

A especificação e o processo de entrega estão definidos e existe um primeiro jogável com APK debug. Implementação restante, acabamento e execução integral dos gates continuam como tarefas de desenvolvimento. Nenhum gate foi aprovado só por documentação, teste no host ou compilação de APK.
