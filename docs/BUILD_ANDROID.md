# Build Android de desenvolvimento

Estado em24/10/2026: APK0.1.0-dev, não release1.0.0. Preset Android gera `com.wrongmove.game.debug`, somente ARM64, Compatibility, portrait. O script recusa exportação release até existir configuração de produção e assinatura adequada.

## Ferramentas efetivamente usadas

| Ferramenta | Versão |
| --- | --- |
| Godot/editor/templates oficiais | 4.7.2.stable.official.ed1daf0bf |
| Java | OpenJDK17 |
| Gradle wrapper do template | 8.11.1 |
| Android SDK compile platform | android-36 |
| Build tools usados pelo Gradle | 36.1.0 |
| Platform tools instalados | 37.0.1 |
| Android mínimo / target | 28 /35 |
| ABI | arm64-v8a |

Editor/templates tiveram seus ZIPs conferidos contra SHA512 oficial antes da extração. O template Gradle4.7.2 instalado exige compile36/build-tools36.1.0; substituem a hipótese inicial compile35/build-tools35.0.1. Não altera Android mínimo nem target do produto. Bibliotecas nativas vieram pré-compiladas do template; não houve compilação C++ ou instalação de NDK para este build.

Ambiente usado: Linux/WSL, Java em `/usr/lib/jvm/java-17-openjdk-amd64`, SDK em `/root/.local/share/wrong-move/android-sdk`, editor em `/root/.local/share/wrong-move/tools/`. São caminhos locais, não requisitos para outros computadores.

## Repetir

1. Instalar o editor padrão Godot4.7.2 e seus export templates correspondentes.
2. Instalar JDK17, command-line tools, platform-tools, SDK android-36/build-tools36.1.0; aceitar licenças do SDK.
3. Nas configurações do editor, Android, informar os caminhos locais do Java SDK e Android SDK.
4. Abrir `project.godot` e executar Project → Install Android Build Template. `android/build/` é gerado e ignorado, não código autoral.
5. Executar os comandos abaixo na raiz. No Windows, também é possível exportar pelo editor usando o preset Android e debug habilitado.

```bash
godot --headless --path . --editor --import
bash tools/run_tests.sh
bash tools/build_android.sh debug
```

Se o executável não estiver no PATH, prefixar os dois scripts com `WRONG_MOVE_GODOT=/caminho/para/godot`. A primeira exportação baixa dependências Gradle e pode levar vários minutos. O jogo instalado não precisa de conexão; as ferramentas de build precisam.

Saída: `builds/android/wrong-move-debug.apk`. Inclui assinatura debug local, não chave de distribuição. Não compartilhar nem versionar keystores. Recompilar em outro computador pode mudar assinatura/hash; isto não é promessa de build bit-a-bit idêntico.

## Conferir pacote

Com os executáveis do SDK no PATH:

```bash
apksigner verify --verbose builds/android/wrong-move-debug.apk
aapt dump badging builds/android/wrong-move-debug.apk
aapt dump permissions builds/android/wrong-move-debug.apk
sha256sum builds/android/wrong-move-debug.apk
adb devices -l
adb install -r builds/android/wrong-move-debug.apk
```

O último comando só deve ser executado com aparelho de teste escolhido. Nenhum estava conectado nesta execução. Atualizar requer mesma assinatura; desinstalar remove progresso. A chave debug local não substitui custódia da futura chave de produção.
