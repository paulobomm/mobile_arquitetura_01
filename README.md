# mobile_arquitetura_01
Materia de Desenvolvimento de Dispositivos Móveis II - Exercicio 02git s

## Como Rodar a Aplicação

Siga os passos abaixo para preparar e executar o aplicativo localmente:

1. **Resolver as dependências do projeto:**
   Abra o terminal na pasta do projeto e execute:
   ```bash
   flutter pub get
   ```

2. **Rodar a aplicação:**
   Com um emulador aberto ou dispositivo físico conectado (ou mesmo na Web/Desktop), execute:
   ```bash
   flutter run
   ```

---

## Atividade 2 - Questionário de Reflexão

**1. Em qual camada foi implementado o mecanismo de cache? Explique por que essa decisão é adequada dentro da arquitetura proposta.**
R: O mecanismo de cache foi implementado na camada de **DataSources** (através do `ProductLocalDataSource`), e é coordenado pela camada de **Repositories** (`ProductRepositoryImpl`). Essa decisão é adequada pois a arquitetura prevê que os DataSources devem lidar apenas com operações de I/O (no caso de cache, uso do `shared_preferences`), enquanto o Repository atua como o mediador que contém a lógica de decidir "de onde os dados vêm" (tentar do remote; se falhar ou estiver sem rede, pega do local).

**2. Por que o ViewModel não deve realizar chamadas HTTP diretamente?**
R: O ViewModel possui a responsabilidade única de estruturar, apresentar e coordenar o estado da interface visual. Se realizasse chamadas HTTP diretamente, haveria forte acoplamento com a infraestrutura, ferindo o princípio da responsabilidade única (SRP) e de separação de interesses. Isso tornaria os testes impossíveis e as regras difíceis de serem reaproveitadas.

**3. O que poderia acontecer se a interface acessasse diretamente o DataSource?**
R: A UI ficaria acoplada a operações de I/O. Ela teria de lidar com as exceções da API, tentar conversão de instâncias (como mapear JSON), gerenciar falhas de rede, sem nenhuma separação clara. A View deixaria de ser apenas declarativa (exibir o que mandam) para se tornar pesada e complexa ("Massive View Controller"), inviabilizando testes e a manutenibilidade.

**4. Como essa arquitetura facilitaria a substituição da API por um banco de dados local?**
R: Graças ao Princípio da Inversão de Dependências (DIP) e injeção de dependências. O ViewModel não faz ideia se os dados vêm da API ou não: ele apenas conhece o contrato do `ProductRepository`. Para trocar o armazenamento de dados remote/API para um banco local (como Sqflite), apenas necessitamos criar um *Local DataSource* robusto, passá-lo ao Repository e nenhuma linha de código precisa ser alterada na Interface de Usuário ou no ViewModel — o sistema continua funcionando perfeitamente.

## Atividade 3 - Questionário sobre Gerenciamento de Estado

**1. O que significa gerenciamento de estado em uma aplicação Flutter?**
R: Em Flutter, o "estado" (state) é qualquer dado ou informação que pode mudar ao longo do tempo e afetar a interface gráfica. Gerenciar esse estado significa controlar, atualizar e sincronizar a camada lógica com a camada visual (UI). O bom gerenciamento de estado garante que as informações atualizadas cheguem até os widgets que precisam delas, provocando reconstruções *apenas* onde necessário, sem recriar partes desnecessárias da tela e mantendo a arquitetura puramente organizada.

**2. Por que manter o estado diretamente dentro dos widgets pode gerar problemas em aplicações maiores?**
R: Ao usar apenas `setState` (dentro de um `StatefulWidget`), a lógica de negócios e de interface acabam se misturando na mesma classe. Em aplicativos maiores, isso cria "Massive View Controllers" ou "Massive Widgets", dificultando o compartilhamento desse estado entre várias partes do aplicativo sem passar dados de pai para filho de forma confusa. Isso dificulta e impossibilita testes de lógicas, prejudica a manutenibilidade do app e pode gerar graves quedas de performance com a reconstrução desnecessária da árvore inteira de widgets.

**3. Qual é o papel do método notifyListeners() na abordagem Provider?**
R: Utilizando a abordagem com Provider estendendo `ChangeNotifier`, o método `notifyListeners()` serve como um gatilho. Toda vez que uma variável interna é modificada e o `notifyListeners()` é disparado, ele alerta internamente o framework do Flutter para sinalizar a todos os widgets que estavam "escutando" esse objeto (consumidores como `Consumer` ou widgets injetados com `context.watch()`) de que essas mudanças ocorreram para que sua reconstrução seja feita com o novo valor correspondente.

**4. Qual é a principal diferença conceitual entre Provider e Riverpod?**
R: Enquanto o **Provider** constrói sua base de dependências conectada na *Árvore de Widgets* (usando o widget visual `InheritedWidget`), gerando um risco fatal de uso indevido (como o comum `ProviderNotFoundException`); o **Riverpod** foi recriado para separar o estado sendo "compile-safe" e trabalhando de forma isolada da Árvore de Widgets de forma global. Ele tem maior flexibilidade para lidar com gerência assíncrona, combinação de múltiplos estados dependentes, garante mais estabilidade na execução sem o risco de ser não acessível num respectivo pedaço de tela, e conta com funcionalidades modernas como cancelamento e descarte de estado sem esforço.

**5. No padrão BLoC, por que a interface não altera diretamente o estado da aplicação?**
R: O padrão BLoC (Business Logic Component) exige uma estrita separação entre a camada de lógica e de UI. Se a UI fosse autorizada a modificar o estado do aplicativo à vontade, seríamos rapidamente reféns de "códigos espalhados por telas diferentes" sem clareza lógica da ordem em que mudanças e regras da aplicação ocorrem. Para garantir a centralização de negócio blindada e o funcionamento do Fluxo Unidirecional de Dados (onde apenas leitura afeta UI, mas UI só age disparando Eventos), a Interface é limitada apenas a reagir a fluxos de novos Eventos sem gerenciar sua mutabilidade de forma direta.

**6. Considere o fluxo do padrão BLoC: Evento → Bloc → Novo estado → Interface. Qual é a vantagem de organizar o fluxo dessa forma?**
R: A maior vantagem é a **previsibilidade e capacidade de testes unitários super organizados**. O "Fluxo Unidirecional de Dados" certifica-se de que nada saia do esperado controlando rastreamento de todos os acontecimentos: É possível "ver" a lista de eventos enviados pela UI, ver como o BLoC o processa e inspecionar unicamente com extrema fácil manipulação em logs um novo estado e erro processado nele. Isso facilita e agiliza fortemente testadores e depuradores, a garantir com certeza que interface "A", baseada em evento "B", resultará em uma regra limpa "C", podendo a lógica também ser reutilizada para diversas saídas visuais diferentes.

**7. Qual estratégia de gerenciamento de estado foi utilizada em sua implementação?**
R: A estratégia adotada nesta implementação (`mobile_arquitetura_01`) fez uso em sua estrutura essencial de uma abordagem com **ValueNotifier** atrelado diretamente nas lógicas separadas pelas classes de um `ViewModel` dedicado para ditar as instâncias assíncronas no contexto dos componentes UI, além de, conforme visível na base do Provider principal que a alimenta, a base de **Riverpod** para controle assíncrono avançado das listas e funcionalidades da camada de Dados e de estado de filtros.

**8. Durante a implementação, quais foram as principais dificuldades encontradas?**
R: A transição de responsabilidades estritas em arquitetura de interface e separar puramente injeção de estado. Fica sendo o desafio inicial mais expressivo assimilar totalmente o fluxo de consumir o repositório como dados remotos de forma assíncrona até refletir essa "Future/Stream" como um fluxo visual tratável pela árvore da UI de maneira performática usando referências globais do Riverpod, sem confundir o responsabilidade sobre quem dita as instâncias lógicas se é a controladora ViewModel ou componente reativo StateNotifier.

## Atividade 4 - Múltiplas Telas e Navegação

**1. Qual era a estrutura do seu projeto antes da inclusão das novas telas?**
R: O projeto consistia originalmente de uma única tela central (`ProductPage`), que atuava tanto como a porta de entrada inicial do aplicativo quanto como a lista contínua de produtos consumidos da Fake API.

**2. Como ficou o fluxo da aplicação após a implementação da navegação?**
R: O fluxo tornou-se sequencial e organizado em 3 etapas: o usuário inicia na Tela Inicial (`HomePage`), pode navegar navegando para a Listagem de Produtos (`ProductPage`) e, ao tocar em um item específico, avança para a Tela de Detalhes do Produto (`ProductDetailsPage`).

**3. Qual é o papel do Navigator.push() no seu projeto?**
R: O `Navigator.push()` (e o `pushNamed()`) é o mecanismo responsável por empilhar (adicionar) uma nova rota/tela sobre a atual na pilha de navegação do Flutter, permitindo a transição e a sobreposição visual da nova página. Em nosso projeto, é usado para ir da Home para os Produtos, e dos Produtos para os Detalhes.

**4. Qual é o papel do Navigator.pop() no seu projeto?**
R: Sua função é desempilhar a tela mais recente da pilha de navegação (como fechar a tela atual e "revelar" a que estava por baixo). Pode ser acionado automaticamente pela seta de voltar padrão na `AppBar` ou explicitamente via botões para retornar à listagem ou diretamente à tela `HomePage` (via `popUntil()`).

**5. Como os dados do produto selecionado foram enviados para a tela de detalhes?**
R: Eles foram repassados como `arguments` no momento da navegação através do mecanismo de rotas. No `onTap` de um produto, despachamos o objeto contendo as propriedades específicas; por trás dos panos, o `onGenerateRoute` captura esse objeto tipado e constrói a tela de detalhes injetando-o diretamente pelo seu construtor.

**6. Por que a tela de detalhes depende das informações da tela anterior?**
R: Porque ela é uma tela "modelo/genérica". Ela não faz uma nova requisição à API para buscar um produto; ela já reaproveita as instâncias em carregadas em memória pela listagem anterior (passada por argumento). Sem essas informações injetadas, ela não teria contexto dos dados (título, preço, descrição, imagem) para desenhar na interface.

**7. Quais foram as principais mudanças feitas no projeto original?**
R: 
- Criação e estruturação da `HomePage` e da `ProductDetailsPage`. 
- Modificação direta do `main.dart` para gerenciar a transição inteligente via rotas nomeadas (`routes` e `onGenerateRoute`).
- Atualização do domínio `Product` e `ProductModel` para buscar `description`, `category` e as métricas de `rating` vindos da Mock API providenciando mais dados para a tela de detalhes.
- Inclusão do Riverpod Provider `themeProvider` para permitir o controle do Dark Mode (tema) global através da barra de ações.

**8. Quais dificuldades você encontrou durante a adaptação do projeto para múltiplas telas?**
R: A dificuldade principal na arquitetura de repasse de argumentos é organizar e prever qual o formato estrutural em que as informações devem transitar pelo `Navigator` (garantindo que o objeto não chegue nulo) e como padronizar o mapeamento JSON dos novos campos estendidos da Fake API (`rating` subnivelado e descrição) minimizando quebras silenciosas durante as extrações lógicas e durante a forte tipagem da rota nomeada (`settings.arguments as Product`).
