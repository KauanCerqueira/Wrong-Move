# Guia de validação

Comandos e cenários futuros: projeto, runner e APK ainda não existem. Nenhum teste do jogo foi executado nesta fase.

## Ambiente do marco 1

Instalar Godot 4.7.2, templates correspondentes, OpenJDK 17 e SDK conforme [documentação Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html). Confirmar editor Windows ou Linux e SDK do mesmo host; não misturar caminhos. Criar projeto Compatibility portrait, base 360×800, preset Android. Registrar versões e aparelho em `docs/VALIDACAO_ANDROID.md`.

Após criar os arquivos e disponibilizar `godot` no PATH:

```bash
godot --version
godot --headless --path . --editor --import
godot --headless --path . --script tests/run_tests.gd
godot --path .
```

Runner imprime resumo, seleciona domain/integration/simulation e retorna código não zero em falhas. Após configurar SDK/template/preset e criar diretório de saída:

```bash
godot --headless --path . --export-debug Android builds/android/wrong-move-debug.apk
adb install -r builds/android/wrong-move-debug.apk
```

## Cenários obrigatórios

| Cenário | Resultado |
|---|---|
| Duelo | Torneio completo, ações, prêmio e fim corretos. |
| Seis participantes | Side pots, eliminações e passagem para heads-up; controles legíveis. |
| Modos | Normal sem relógio; Hardcore 10 s + 30 s, check/fold automático e sem dica. |
| Campanha | Primeira mesa gratuita, prêmio/passe únicos, repetição com saldo zero. |
| Dica | 8 s ativos, preço e confirmação, cobrança única por decision_id, reabertura grátis após pausa/tick, sem info oculta. |
| Interrupção | Background, bloqueio, fechamento e retomada durante ação, dica, passe e resultado. |
| Falhas de commit | Queda antes/depois de cada fronteira A/B, recuperação sem saldo duplicado, tmp ignorado. |
| Isolamento | Mudar cartas ocultas com observação/RNG iguais não altera decisão. |
| Independência | Duas partidas e carteiras sem efeitos cruzados. |
| Acessibilidade | Texto 100/125/150%, quatro cores, movimento reduzido, áudio/vibração e áreas seguras. |
| Tutorial/revisão | Revisitável grátis; último histórico só tem informações reveladas. |
| Infinidade | 10.000 índices válidos/determinísticos; configuração comprada preservada após atualização. |

Validar offline em aparelhos físicos. Gates e amostras exatas em `docs/RELEASE_ANDROID.md`; evidências reais, sem marcar teste executado só por existir roteiro.

## Release

Após todos os arquivos implementados, ambiente/assinatura configurados e pasta de saída criada, comando previsto:

```bash
godot --headless --path . --export-release Android dist/1.0.0/wrong-move-1.0.0-arm64.apk
apksigner verify --verbose --print-certs dist/1.0.0/wrong-move-1.0.0-arm64.apk
```

`apksigner` vem dos build-tools; configurar seu caminho no host real. Credenciais são locais/variáveis suportadas pelo exportador, nunca no comando ou no ZIP. Instalar offline e testar upgrade com mesma assinatura. Montar fontes/instruções/relatório/hashes conforme contrato. AAB/loja não são requisitos desta entrega. Checklist final em `checklists/release.md`, inicialmente não executado.
