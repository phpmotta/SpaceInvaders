# Space Invaders - Processador P3 (Assembly)

Este repositório contém uma implementação clássica do jogo **Space Invaders**, desenvolvida inteiramente em **Assembly para o Processador P3**. O projeto foi construído como parte prática da disciplina de Arquitetura de Computadores.

O objetivo principal é demonstrar o domínio sobre conceitos fundamentais de hardware e software de baixo nível, tais como interrupções por hardware, manipulação de periféricos de I/O mapeados em memória, gerenciamento da pilha (Stack) e otimização de rotinas de desenho.

## Como Rodar o Jogo

### Pré-requisitos
Você precisará do simulador oficial do **Processador P3** (executável Java `.jar`).

### Passo a Passo
1. Baixe o arquivo de código fonte do jogo (`Projeto.as`) contido neste repositório.
2. Abra o simulador do Processador P3.
3. No menu superior do simulador, clique em **File > Open** (ou carregar código) e selecione o arquivo `.as`.
4. Clique no botão **Assemble** (ou Montar) para compilar o código fonte em código de máquina.
5. **Muito Importante**: Ative a janela gráfica do periférico clicando em **Peripherals > Janela de Texto** (Text Window).
6. Clique em **Run** (ou Executar) para iniciar a partida.

## Controles

- `A`: Move a nave para a esquerda.
- `D`: Move a nave para a direita.
- `Barra de Espaço`: Dispara o laser.
- `Barra de Espaço (Telas de Fim de Jogo)`: Reinicia a partida e zera as estatísticas.

## Autor

- **Pedro Henrique Penna Motta**
- Engenharia de Computação - CEFET/RJ
