# WRONG MOVE — Redesign profissional de jogo mobile

## 1. Seu papel

Você é uma equipe sênior de desenvolvimento de jogos, reunindo as competências de:

- Game Art Director
- Senior Mobile Game UI/UX Designer
- 2D Game Artist
- Character Designer
- Motion Designer
- Game Feel Designer
- Senior Game Developer

Seu objetivo é transformar **WRONG MOVE**, um jogo de Texas Hold'em que já está funcional, em um produto com a qualidade visual, a personalidade e o acabamento esperados de um estúdio independente profissional.

**Não quero apenas uma interface mais bonita. Quero que o projeto deixe de parecer um protótipo e passe a parecer um jogo comercialmente apresentável, mesmo sendo 100% gratuito.**

Você deve analisar o projeto existente, identificar sua tecnologia e arquitetura, compreender a implementação atual e executar a reformulação de maneira organizada.

O jogo já possui regras, inteligência artificial, campanha, tutorial, configurações e uma interface funcional.

Preserve essas funcionalidades.

---

# 2. O que é WRONG MOVE?

WRONG MOVE é um jogo de pôquer clássico inspirado na fluidez, no feedback visual e na satisfação das interações de Balatro.

Entretanto, suas regras são as do Texas Hold'em tradicional.

Não existem cartas mágicas, multiplicadores, poderes, vantagens artificiais ou alterações nas probabilidades do baralho.

O diferencial do jogo é:

- Partidas extremamente rápidas.
- Jogabilidade casual, mas com profundidade estratégica.
- Adversários com personalidade.
- Inteligência artificial que reconhece padrões do jogador.
- Modo Hardcore com adversários competitivos e tempo limitado de decisão.
- Progressão Arcade.
- Partidas livres.
- Atmosfera elegante e minimalista.
- Experiência offline com fichas fictícias.
- Ausência de monetização, compras ou anúncios.

A experiência deve despertar a sensação:

**"Vou jogar só mais uma mão."**

## Inspirações

**Balatro:** qualidade das animações, feedback de cartas, sons, ritmo arcade e identidade visual consistente.

https://www.playbalatro.com/

**partypoker Mobile:** distribuição de elementos, ergonomia e organização de mesas de pôquer em celulares.

https://www.partypoker.com/

**Poker Now:** clareza da interface, simplicidade e facilidade para reconhecer informações importantes.

https://www.pokernow.club/

**Baralhos premium de design:** detalhes artísticos, ilustrações próprias, naipes elegantes e tipografia cuidadosa.

Essas referências servem para orientar o design. Não copie diretamente artes, personagens, interfaces completas ou recursos protegidos.

---

# 3. Diagnóstico da versão atual

Analise cuidadosamente as screenshots fornecidas e todas as telas implementadas no projeto.

Minha avaliação inicial é que o jogo possui uma boa base funcional, mas ainda apresenta problemas de direção de arte.

## Problemas mais graves

### 3.1. O jogo parece uma interface administrativa

Existem muitas caixas, bordas, divisores e componentes retangulares.

Os elementos parecem pertencer a um dashboard ou formulário, não a uma experiência de entretenimento.

O problema não será resolvido apenas arredondando botões ou trocando cores.

### 3.2. O adversário não possui identidade

Atualmente, o jogador enfrenta personagens identificados genericamente como "Bot 1".

Isso destrói a imersão.

Não quero enfrentar um número. Quero enfrentar uma pessoa fictícia com nome, aparência, personalidade e maneira própria de jogar.

### 3.3. As cartas parecem recursos genéricos

As cartas possuem valores e naipes funcionais, mas não têm a qualidade visual necessária para serem o elemento central de um jogo profissional.

Precisamos de um baralho próprio, visualmente marcante, muito bem ilustrado e extremamente legível.

### 3.4. A mesa é grande, mas pouco interessante

O oval ocupa boa parte da tela, enquanto as cartas, as fichas e os personagens não recebem o destaque adequado.

Há espaços vazios que não contribuem para a jogabilidade.

A mesa deve funcionar como cenário, não como protagonista.

### 3.5. Falta personalidade nas interações

As ações funcionam mecanicamente, mas precisam transmitir mais satisfação.

Distribuir cartas, apostar, blefar, desistir e vencer devem provocar respostas audiovisuais claras e agradáveis.

### 3.6. A estética não é consistente

A tela inicial sugere um jogo elegante, com cartas ilustradas e tipografia refinada.

A partida, entretanto, apresenta elementos simplificados demais, sem a mesma qualidade artística.

**Todo o jogo precisa parecer feito pelo mesmo estúdio, com a mesma direção visual.**

---

# 4. Nova direção de arte

A proposta visual definitiva será:

**Pôquer clássico + elegância editorial + arcade moderno + ilustração 2D premium.**

Quero algo bonito, original e reconhecível, sem cair nos clichês de cassino.

## O que manter

- Verde escuro como principal cor.
- Marfim nas cartas e ações importantes.
- Vermelho escuro em destaques.
- Dourado discreto em pequenos detalhes.
- Tipografia elegante no logotipo e nos títulos.
- Referências à iconografia clássica do pôquer.

## O que eliminar

- Excesso de molduras douradas.
- Bordas ao redor de quase todos os elementos.
- Texturas pesadas.
- Gradientes exagerados.
- Excesso de texto pequeno.
- Ícones genéricos sem personalidade.
- Efeitos permanentes de brilho.
- Botões com aparência de HTML comum.
- Informações repetidas.
- Elementos decorativos que não contribuem para a identidade.

O jogo deve transmitir refinamento sem parecer um aplicativo bancário, um cassino genérico ou um dashboard.

## Paleta inicial

- Verde profundo: `#0C211B`
- Verde de mesa: `#174535`
- Verde intermediário: `#285341`
- Marfim: `#F5E9D4`
- Vermelho: `#B82E32`
- Dourado discreto: `#D6AC62`
- Texto secundário: `#A1B2A6`

Ajuste as tonalidades quando necessário para obter contraste, unidade visual e boa legibilidade.

## Tipografia

Utilizar dois papéis tipográficos distintos:

**Marca e títulos:** fonte serifada elegante, fina e com excelente composição.

**Interface e jogabilidade:** fonte sans-serif moderna, objetiva e confortável para leitura mobile.

Números de apostas, fichas e cronômetros devem ter ótimo contraste, tamanhos adequados e alinhamento consistente.

Não utilizar letras excessivamente espaçadas em textos pequenos.

---

# 5. O baralho precisa ser redesenhado completamente

**Esta é uma das prioridades máximas do projeto.**

As cartas são os elementos mais vistos durante toda a experiência.

Quero um baralho original de WRONG MOVE, com qualidade de um produto de design profissional.

## Cartas numéricas

Criar uma linguagem gráfica própria para todas as cartas de 2 a 10.

Características:
- Fundo marfim.
- Textura sutil de papel.
- Naipes com formas exclusivas, mas imediatamente reconhecíveis.
- Índices grandes e legíveis.
- Proporções equilibradas.
- Excelente leitura em tamanhos pequenos.
- Sombras discretas.
- Cantos levemente arredondados.

Evitar excesso de ornamentos nas cartas numéricas.

A organização dos naipes deve respeitar os valores reais das cartas. Uma carta de sete deve representar sete símbolos, seguindo um desenho de baralho coerente.

## Ases

Os ases podem receber um tratamento especial.

O ás de espadas deve ter um símbolo central personalizado que represente a identidade WRONG MOVE.

Ainda assim, o baralho deve permanecer fácil de reconhecer.

## Valete, Dama e Rei

**Quero ilustrações próprias, não letras gigantes ou figuras genéricas.**

Criar um estilo de ilustração inspirado em baralhos tradicionais, mas com linguagem contemporânea.

As figuras devem parecer integrantes da mesma família visual.

Características desejadas:
- Ilustração 2D.
- Traços elegantes.
- Composição harmoniosa.
- Paleta restrita.
- Detalhes reconhecíveis.
- Aparência sofisticada sem realismo excessivo.
- Consistência entre os naipes.

Pode-se utilizar composições espelhadas de baralhos tradicionais, reinterpretadas com arte original.

## Verso das cartas

Criar um verso exclusivo baseado na identidade WRONG MOVE.

Utilizar:
- Verde escuro.
- Marfim.
- Geometria sutil.
- Naipes ou símbolos estilizados.
- Composição simétrica.

Precisa funcionar tanto em tamanho grande quanto nas cartas pequenas do adversário.

## Entregável

Criar ou especificar um conjunto reutilizável de recursos gráficos para as 52 cartas e seus versos.

Se as ferramentas disponíveis não permitirem gerar ilustrações de alta qualidade diretamente, estabelecer um pipeline de assets e placeholders bem definidos, sem fingir que os recursos finais foram produzidos.

---

# 6. Criar personagens reais para os adversários

Não utilizar mais "Bot 1", "Bot 2" ou nomes semelhantes na interface final.

Quero uma galeria de adversários com identidade própria.

Cada personagem precisa de:

- Nome.
- Retrato ilustrado.
- Paleta e detalhes visuais próprios.
- Personalidade reconhecível.
- Estilo de jogo coerente.
- Comportamentos distintos.
- Pequenas expressões ou reações.

## Personagem 01 — Nico

**Arquétipo:** o jogador impulsivo.

Um jovem confiante, competitivo e provocador.

Estilo:
- Paga apostas com relativa frequência.
- Blefa ocasionalmente.
- Pode se precipitar.
- É acessível para iniciantes.

Visual:
- Retrato 2D estilizado.
- Expressão confiante.
- Design simples e marcante.
- Mesma estética gráfica do baralho.

Deve substituir o "Bot 1" no primeiro confronto da campanha.

## Personagem 02 — Mara

**Arquétipo:** a estrategista.

Observadora, calculista e pouco expressiva.

Estilo:
- Analisa padrões do jogador.
- Usa blefes de maneira mais seletiva.
- Explora ações previsíveis.
- Pressiona quando percebe fraqueza.

Visual:
- Retrato elegante.
- Silhueta facilmente reconhecível.
- Expressão séria.
- Identidade distinta de Nico.

## Personagem 03 — Otto

**Arquétipo:** o veterano.

Experiente, paciente e conservador.

Estilo:
- Seleção criteriosa de mãos.
- Poucos blefes sem justificativa.
- Forte leitura de risco.
- Disciplina nas decisões.

Visual:
- Personagem mais velho.
- Aparência experiente.
- Roupas discretas.
- Retrato com personalidade.

## Personagem 04 — Dante

**Arquétipo:** o especialista.

Adversário de alto nível, especialmente adequado aos confrontos difíceis.

Estilo:
- Estratégia agressiva quando apropriado.
- Adaptação ao comportamento do jogador.
- Apostas variadas e justificáveis.
- Boa leitura de ranges.
- Capacidade de explorar padrões sem conhecer cartas privadas.

Visual:
- Elegante e intimidador.
- Retrato expressivo.
- Silhueta memorável.
- Identidade de adversário final.

Os nomes e perfis são propostas iniciais. Verifique a estrutura real da campanha antes de definir a quantidade final de personagens.

## Expressões e reações

Planejar estados visuais como:

- Neutro.
- Confiante.
- Desconfiado.
- Satisfeito.
- Frustrado.

As reações devem ser breves e coerentes com o que a IA legitimamente sabe.

**Não revelar involuntariamente informações secretas sobre a mão do adversário por meio das expressões.**

Não quero avatares 3D nem personagens ocupando metade da tela.

Quero pequenos retratos 2D excelentes, com muita personalidade.

---

# 7. Reformular completamente a tela da partida

Esta é a tela mais importante.

Ela deve receber a maior quantidade de atenção, testes e refinamento.

Referência de organização: partypoker Mobile.

Referência de game feel: Balatro.

Referência de simplicidade: Poker Now.

## Organização vertical

### Parte superior

Mostrar:
- Nome da mesa.
- Blinds.
- Número da mão.
- Botão de pausa.

As informações devem ocupar pouco espaço.

### Área do adversário

Mostrar:
- Retrato do personagem.
- Nome próprio.
- Fichas restantes.
- Duas cartas privadas fechadas.
- Indicador de quem deve agir.

Quando for a vez do adversário, destacar discretamente seu retrato.

### Centro

Mostrar:
- Pote.
- Cartas comunitárias.
- Pequena representação das fichas.

Aumentar significativamente a qualidade visual das cartas.

Não permitir que o contorno da mesa domine a composição.

### Área do jogador

Mostrar:
- Duas cartas privadas grandes.
- Fichas restantes.
- Indicador do dealer quando aplicável.
- Estado da jogada.

As cartas do jogador devem ser uma das maiores fontes de atenção da tela.

### Área de ações

Mostrar apenas as ações legais para o estado atual:

- Desistir.
- Check ou Pagar.
- Aumentar.

Botões grandes, extremamente legíveis e com excelente resposta ao toque.

Não utilizar múltiplos controles pequenos disputando atenção.

---

# 8. Redesenhar o sistema de apostas

O usuário definiu que prefere um **slider horizontal** aos botões permanentes de frações do pote.

O fluxo será:

1. Jogador toca em Aumentar.
2. Um painel compacto desliza da parte inferior.
3. Aparece o valor atual da aposta.
4. Um slider permite ajustar o valor.
5. O número responde imediatamente ao movimento.
6. O jogador confirma o aumento.
7. O painel desaparece.

O slider deve respeitar:
- Aposta mínima legal.
- Quantidade de fichas disponíveis.
- Valores necessários para pagar.
- Regras de aumento.
- Situações de all-in.
- Regras de no-limit Texas Hold'em.

O usuário precisa conseguir selecionar valores precisos.

Não adicionar novamente conjuntos permanentes de botões 25%, 50%, 75% e 100%.

Se houver necessidade, permitir ajustes finos sem sobrecarregar a tela.

**Prioridade: rapidez, precisão e ergonomia.**

---

# 9. Sistema de animações — Game Feel

Quero animações que pareçam desenvolvidas por um estúdio de jogos, não transições CSS aplicadas aleatoriamente.

Cada ação precisa ter um comportamento visual característico.

## Distribuição

Cartas saem do baralho e deslizam rapidamente até jogador e adversário.

Utilizar:
- Movimento suave.
- Leve rotação.
- Sombra dinâmica discreta.
- Som de papel.
- Timing consistente.

Não utilizar efeitos lentos.

## Flop, Turn e River

As cartas comunitárias devem ser reveladas com um movimento satisfatório.

Utilizar uma animação de flip convincente.

No flop, mostrar as três cartas em sequência rápida.

## Apostas

Fichas devem se mover até o pote com animação curta.

O valor do pote deve atualizar suavemente.

Aumentos podem receber feedback ligeiramente mais expressivo que pagamentos simples.

## Fold

As cartas são recolhidas rapidamente.

A mão encerra sem uma espera desnecessária.

## Check

Mostrar um pequeno feedback próximo ao personagem responsável pela ação.

## All-in

Criar um momento marcante:
- Pequena antecipação.
- Movimento das fichas.
- Destaque de cor.
- Som exclusivo.
- Retorno rápido à partida.

Não usar tremores excessivos ou flashes agressivos.

## Vitória

Destacar as cartas responsáveis pela combinação vencedora.

Mostrar o nome da mão.

Movimentar as fichas até o vencedor.

Atualizar o saldo.

A experiência deve ser satisfatória, mas não demorada.

## Derrota

Feedback discreto.

Sem animações punitivas ou longas.

## Personagens

Adicionar pequenas transições entre expressões.

A reação não deve bloquear o andamento da partida.

## Diretrizes técnicas

- Priorizar desempenho mobile.
- Evitar efeitos caros desnecessários.
- Usar interpolação e easing adequados.
- Permitir reduzir ou desativar animações.
- Permitir acelerar transições repetitivas.
- Não bloquear a lógica do jogo durante efeitos puramente visuais.
- Não modificar resultados ou probabilidades.
- Manter áudio e animação sincronizados.

---

# 10. Reformulação das demais telas

Depois que a tela principal estiver visualmente aprovada, aplicar o design system às demais páginas.

## Tela inicial

Simplificar a apresentação.

Dar mais destaque ao logo WRONG MOVE e às cartas 7♥ e 2♠.

Mostrar ações principais de maneira clara.

Retirar botões excessivos e molduras decorativas.

Adicionar uma animação curta de entrada.

## Campanha

Transformar o mapa em uma progressão visual mais interessante.

Cada desafio deve ter identidade própria.

Utilizar fichas, retratos ou outros elementos de pôquer de maneira consistente.

Destacar o desafio atual e reduzir o peso das etapas bloqueadas.

## Campanha Hardcore

Manter a mesma identidade, mas com detalhes que comuniquem pressão e competitividade.

Não transformar toda a tela em vermelho.

## Resultado da mão

Não substituir imediatamente a mesa por um formulário.

Mostrar o resultado sobre a própria partida, com feedback visual e opção de continuar.

## Vitória da mesa

Criar uma celebração elegante.

Mostrar o adversário derrotado, progresso e próximo desafio.

## Tutorial

Transformar explicações longas em atividades curtas e interativas.

Usar cartas reais, animações e pequenas demonstrações.

## Regras

Mostrar ranking de mãos com ilustrações de combinações, não apenas texto.

## Pausa

Utilizar um painel sobreposto ao jogo.

Ações organizadas por prioridade.

## Configurações

Simplificar componentes.

Organizar áudio, jogabilidade, animações e acessibilidade.

Manter controles coerentes com o restante da interface.

---

# 11. Identidade e identidade sonora

O projeto precisa ter um conjunto artístico consistente.

Definir:

- Baralho oficial.
- Verso das cartas.
- Estilo de fichas.
- Estilo de avatares.
- Tipografia.
- Cores.
- Sistema de ícones.
- Som de distribuição.
- Som de fichas.
- Som de vitória.
- Feedback de menu.
- Transições entre cenas.

Não quero recursos de diferentes estilos misturados na mesma tela.

Os efeitos sonoros devem ser curtos, limpos e satisfatórios.

Evitar sons exagerados de cassino social.

---

# 12. Requisitos de usabilidade

O jogo deve funcionar bem em telas verticais de diferentes tamanhos.

Verificar especialmente:
- Proporções.
- Áreas seguras.
- Tamanho dos botões.
- Legibilidade.
- Espaçamento.
- Contraste.
- Comportamento do slider.
- Animações em dispositivos modestos.

Não permitir cartas cortadas, painéis fora da tela ou controles inacessíveis.

A experiência deve ser confortável mesmo durante sessões longas.

Um jogador deve conseguir reconhecer o estado da mão quase instantaneamente.

---

# 13. Requisitos técnicos

Primeiro, inspecione a estrutura real do projeto.

Identifique a engine, linguagem, sistema de UI e arquitetura efetivamente utilizados.

Não presuma que o projeto esteja obrigatoriamente em Godot ou em qualquer outra tecnologia.

Se for Godot, aproveite os recursos adequados da engine para cenas, componentes, animações, responsividade e gerenciamento de assets.

Se utilizar outra stack, adapte a proposta.

Preserve o motor de pôquer.

Não reimplemente a lógica existente sem necessidade.

Preserve:
- Regras do Texas Hold'em.
- Avaliação das mãos.
- Blinds.
- Apostas.
- Empates e divisão do pote.
- IA dos adversários.
- Salvamento.
- Progressão.
- Hardcore.
- Tutorial.
- Configurações.

As mudanças devem ser concentradas na apresentação e nos recursos gráficos.

Antes de alterar componentes compartilhados, identifique dependências e riscos de regressão.

---

# 14. Processo obrigatório

Não execute apenas uma reformulação superficial.

Trabalhe em etapas.

## Etapa 1 — Auditoria

Examine o código e as screenshots.

Identifique os problemas reais do projeto.

Apresente um diagnóstico visual e técnico.

## Etapa 2 — Direção de arte

Defina um design system consistente.

Documente:
- Paleta.
- Tipografia.
- Estilo do baralho.
- Estilo dos personagens.
- Fichas.
- Botões.
- Animações.

## Etapa 3 — Recursos gráficos

Criar ou preparar os assets necessários.

Priorizar:
1. Baralho.
2. Verso das cartas.
3. Nico.
4. Fichas.
5. Controles e ícones.

## Etapa 4 — Nova mesa

Reformular a tela principal utilizando os recursos definidos.

Implementar o sistema de slider.

## Etapa 5 — Animações

Adicionar distribuição, apostas, revelação, descarte e vitória.

## Etapa 6 — Restante do projeto

Aplicar a direção visual ao início, campanhas, tutorial, resultados, regras, pausa e configurações.

## Etapa 7 — Testes

Executar o jogo, testar a jogabilidade e analisar screenshots reais do resultado.

Corrigir:
- Elementos desalinhados.
- Cartas ilegíveis.
- Botões pequenos.
- Sobreposições.
- Quebras de responsividade.
- Problemas de animação.
- Regressões nas regras.

Não considerar um componente concluído apenas porque compilou ou apareceu na tela.

---

# 15. Critérios de qualidade

O trabalho só estará satisfatório quando:

1. O jogo possuir identidade visual consistente.
2. As cartas tiverem arte própria e acabamento profissional.
3. Os adversários tiverem nomes e retratos.
4. A mesa parecer um jogo mobile de qualidade, não um dashboard.
5. O controle de apostas for rápido e intuitivo.
6. As animações tornarem as jogadas satisfatórias.
7. O visual funcionar em celulares pequenos.
8. Os elementos importantes forem legíveis.
9. O menu principal e a partida parecerem partes do mesmo produto.
10. A lógica atual continuar funcionando.
11. O jogo permanecer completamente gratuito.
12. A experiência continuar extremamente rápida.

---

# 16. Resultado que eu espero

Não quero um simples redesign de interface.

Quero uma evolução artística real.

WRONG MOVE deve parecer um jogo indie com direção de arte cuidadosamente planejada.

Imagine uma mistura de:

**A satisfação de Balatro.**

**A ergonomia do partypoker.**

**A simplicidade do Poker Now.**

**A elegância gráfica de um baralho premium.**

**A personalidade de adversários memoráveis.**

Tudo com uma identidade original, consistente e adequada para dispositivos mobile.

O jogador deve sentir que está enfrentando Nico, Mara, Otto ou Dante, e não apenas interagindo com funções de um programa.

Ele deve gostar de observar as cartas sendo distribuídas, as fichas se movendo e as combinações sendo reveladas.

**Meu objetivo é que WRONG MOVE pareça um jogo feito por um estúdio, não por alguém que apenas montou uma interface funcional.**

Comece inspecionando o projeto, apresente os problemas concretos encontrados e avance com a reformulação da direção de arte e da tela de partida como prioridade máxima.

Evite alterações cosméticas isoladas. Cada decisão visual deve contribuir para uma identidade coesa.
