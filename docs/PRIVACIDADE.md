# Dados locais — primeiro jogável

Wrong Move usa fichas fictícias, sem dinheiro real, compras, anúncios, conta, analytics ou servidor. O manifesto do APK debug foi inspecionado: somente `android.permission.VIBRATE`, sem INTERNET. Uso da vibração depende da opção do jogador.

Progresso, tentativas em Normal/Hardcore, tutorial e preferências ficam na área privada do aplicativo. Não há exportação de save nem backup Android em nuvem habilitado. Desinstalar ou apagar dados remove progresso. Uma atualização com mesma identidade e assinatura deve preservar os arquivos; o fluxo ainda precisa de teste físico antes do release.

A instalação de desenvolvimento usa `com.wrongmove.game.debug`; o futuro release terá identidade e armazenamento separados. O jogo não envia dados aos desenvolvedores. Arquivos de teste do projeto ficam fora do pacote Android exportado.
