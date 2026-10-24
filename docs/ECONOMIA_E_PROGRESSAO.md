# Economia e progressão

Baseline v1 fechada sob delegação do autor. Números são os defaults a implementar; ajustes necessários para passar os gates seguem o processo de `RELEASE_ANDROID.md`, sem exigir novas perguntas. Referência numérica: `specs/001-mobile-poker/release-baseline.json`.

## Fichas

Cada campanha guarda saldo próprio para passes; apenas Normal permite gastar esse saldo em dicas. Fichas da tentativa não são saldo de campanha. Todos recebem stack igual e a tentativa não cobra entrada. Saldo inicial zero; primeira mesa aberta.

Vitória repetida entrega prêmio base; primeira vitória entrega base + bônus; derrota/abandono entrega zero. Sem cooldown ou limite de tentativas.

| Mesa | Participantes | Passe | Base | Bônus inicial | Dica |
|---|---:|---:|---:|---:|---:|
| 1 | 2 | 0 | 100 | 100 | 10 |
| 2 | 2 | 120 | 120 | 120 | 12 |
| 3 | 3 | 150 | 145 | 145 | 15 |
| 4 | 2 | 180 | 175 | 175 | 18 |
| 5 | 4 | 220 | 210 | 210 | 21 |
| 6 | 3 | 265 | 250 | 250 | 25 |

Exemplo: primeira vitória na 1 entrega 200; passe da 2 custa 120; restam 80. Perder na 2 mantém esses 80. Dica reduz apenas esse saldo. A validação mede o efeito desses parâmetros, sem deixar fórmula indefinida.

## Infinidade com limites jogáveis

- Mesas 1–6 conforme tabela. Para índice n≥7, participantes vêm do ciclo `[2,3,2,4,3,5,2,4,5,6]`, posição `(n−7) mod 10`. Cada campanha tem seed própria de 128 bits em hexadecimal, gerada uma vez.
- Identidade por campanha, seed, índice e versão do gerador. Salvar configuração ao desbloquear; atualizações não alteram mesas compradas nem partidas salvas.
- Seed do desafio não determina cartas: nova tentativa embaralha novamente.
- Gerar janela de etapas, nunca todos os itens de uma lista infinita em memória.
- Força e pressão têm tetos testados; depois continuar combinações avançadas. Infinito significa continuidade, não inteligência ou blinds ilimitados. Avaliar dificuldade por blocos comparáveis, sem garantir que toda mesa individual seja estritamente mais difícil.
- Para n≥7: `base(n)=min(1000,250+25×(n−6))`; bônus igual ao base; `passe(n)=floor(8×base(n−1)/5)`; dica Normal `ceil(base(n)/10)+10×tier(n)`. Sem multiplicador adicional por formato. Hardcore usa os mesmos valores e não tem dica. Mesa7: base275, bônus275, passe400, dica28. Mesa36 em diante: base1000, bônus1000; passe estabiliza em1600 a partir da37; dica chega a150 no tier5 (mesa51).
- Dicas custam mais conforme a curva cresce e estabilizam no teto de dificuldade/economia; não criar inflação infinita após o teto. Gasto opcional pode exigir repetir mesas; nunca impedir jogar uma mesa aberta.
- Índice, wallet, contadores persistentes e revisões são inteiros arbitrários codificados como strings decimais canônicas (`0` ou número sem zeros à esquerda). Comparar/somar/subtrair/multiplicar/dividir por pequeno inteiro com helper decimal; não passar por float nem int64. Quantias por transação são limitadas pelos tetos acima; torneio permanece inteiro de até6000. Assim a campanha não acaba por overflow de índice.

### Gerador reproduzível v1

`tier(n)=min(5,floor((n−1)/10))`. Força Normal `[0,1,2,3,4,5][tier]`; Hardcore `[3,4,5,6,7,8][tier]`. A força cresce até mesa51, depois continuam configurações avançadas. Estilos vêm de SHA-256 da string UTF-8 `wm-v1|{seed_hex}|{mode}|{n_decimal}|{bot_seat}`: primeiro byte mod3 seleciona cauteloso/equilibrado/agressivo. Normal e Hardcore têm seed e modo diferentes, mas repetição da mesma mesa preserva perfis. Este hash nunca alimenta o deck.

Primeiras forças seguem tier0; todos usam os mesmos stacks. Não esconder trapaça atrás de variação procedural. Gerar no mapa no máximo 30 widgets reciclados e uma janela de 10 etapas futuras; configs compradas ficam imutáveis.

## Estrutura inicial experimental de torneio

Stack 1.000, sem ante/recompra. SB `[10,15,25,40,60,100,150,250,400,600,1000,1500,3000]`; BB=2×SB, permanecer no último nível. A soma máxima de stacks é6000, então a escalada alcança pressão efetiva sem inflar valores indefinidamente. Frequência de nível é fixada no início da tentativa: duelo `[4,4,4,3,3,3][tier]` mãos; mesa maior `[6,6,5,5,4,4][tier]`. Não muda quando bots caem. Nível antes da mão h (1-based) = `min(12,floor((h−1)/frequencia))`. Nunca mudar blinds no meio da mão. Medir duração, sem encerramento artificial.

Blinds maiores aumentam variância; melhorar composição/IA antes de transformar etapas avançadas em all-ins obrigatórios. Hardcore usa stack igual, bots mais fortes e tempo 10 s + 30 s, sem precisar copiar mesa a mesa o Normal.

## Transações e medições

Passe: chave campanha+mesa; prêmio: attempt_id; dica: attempt_id+decision_id. Commit inclui débito/crédito, marca de acesso/vitória, conteúdo da dica e recibo. Reenvio não repete efeito. Tick, pausa e compra da dica não criam nova decision_id.

Medir localmente em debug: duração ativa e total, mãos/torneio, vitórias por formato, saldo/minuto, repetições para pagar passe e dicas. Sem telemetria remota. Simular 10.000 índices e índices de100 dígitos para validade/determinismo; avaliar diversão com pessoas. Se etapas avançadas rendem menos por minuto que as iniciais na política piloto, ajustar prêmios no processo R09 preservando próxima compra acessível. Não nerfar cartas nem impedir repetições legítimas.
