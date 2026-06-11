# mobile_arquitetura_01
Materia de Desenvolvimento de Dispositivos Móveis II - Exercicio 02

## Pré-requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) (stable, versão 3.44+)
- Dart 3.9+

> **Para rodar no Android:** é necessário Java 17. Versões mais recentes (como Java 25, padrão no Ubuntu 26.04) causam erro de build no Gradle.
> ```bash
> sudo apt install openjdk-17-jdk
> flutter config --jdk-dir /usr/lib/jvm/java-17-openjdk-amd64
> ```
>
> **Para rodar no Linux Desktop ou Chrome (Web):** nenhuma configuração adicional é necessária.

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

---

## Atividade 5 - Evolução do Projeto (Questões de Reflexão)

**1. Quais eram as limitações da versão inicial do projeto?**
R: A versão inicial era estritamente focada em leitura (apenas requisições GET), muito restrita no consumo dos dados (poucos atributos da Fake Store API extraídos do JSON limitando as informações na tela), possuía apenas uma única tela renderizando a lista completa (sem navegação e rotas declaradas) e não contava com recursos visuais ou estruturais para inclusão, edição ou exclusão interativa de produtos pelo usuário final.

**2. Quais mudanças estruturais você realizou na aplicação?**
R: A aplicação foi significativamente expandida e estabilizada de forma modular. A arquitetura em camadas (adaptada na base lógica do MVVM com Repository) foi aprimorada e consolidada com a inclusória de contratos "CRUD" (Create, Update, Delete) nas interfaces robustas da camada `Domain`, integradas à lógica realística do Cache na camada `Data` (repositórios e local datasource), e exportadas aos provedores centralizados do StateNotifier Riverpod na camada `Presentation`. Ainda, foram isoladas logicamente novas visualizações complexas (`ProductFormPage`) sem misturar estado visual das rotas e requisição remota.

**3. Como ficou a organização das telas e do fluxo de navegação?**
R: O fluxo explodiu de uma tela morta para um sistema multi-tela gerenciado limpo pelo widget principal através de rotas nomeadas estáticas e dinamicamente enviadas (para lidar com pass-through de tipagem e objetos em memória). A árvore segue: `HomePage` (Base/Start) -> `ProductPage` (Manager principal da grade) -> `ProductDetailsPage` (Visão aprofundada estática). Como atalho utilitário a este esquema, da Listagem principal, há desvios dinâmicos para o `ProductFormPage`, que inteligentemente recicla o construtor usando estado nulo sendo tratado ativamente na Controller dos Forms para servir simultaneamente quer para 'criação vazia' mediante o FAB/botão add e quer de uma 'edição carregada instantânea' mediante toque num item.

**4. Quais atributos do produto passaram a ser utilizados na nova versão?**
R: Expandimos agressivamente nosso PODO para extrair chaves cruciais cruas de um E-commerce vivo que inicialmente eram negligenciadas por estarem em nós JSON em cascata ou desnecessárias em card pequeno: o nó complexo `rating` (contendo pontuação avaliadora `rate` em ponto flutuante, e o número inteiro de avaliadores `count`), a categoria `category` (agora utilizada em tags contextuais de interface) e o campo detalhado longo da `description`. Estes, juntamente ao id, price, title e imagem preexistentes, preenchem ativamente as lacunas gráficas das Details/Forms Pages.

**5. Como você organizou a camada de acesso a dados?**
R: Mantive o isolamento clássico com forte "Single source of truth" (fonte única de verdade). O `ProductRemoteDataSource` fica estritamente com a incumbência declarativa de escoar retornos complexos da API HTTP RESTful. O antes singelo provedor de escape, o `ProductLocalDataSource`, virou o forte controlador do CRUD através do cache das Storage/SharedPreferences para lidar elegantemente com a gravação offline. O maestro de tudo permaneceu sendo a classe impl `ProductRepositoryImpl` (na divisa do Data layer), sendo ele o encarregado inteligente de disparar escritas interativas para o datasource Offline de forma exclusiva sem perturbar o inoperante método de escrita Mock Remote.

**6. Seu projeto foi preparado para operações além do GET? Explique.**
R: Sim, todo o maquinário invisível e visível foi perfeitamente acomodado e desenhado para as operações de escrita escaláveis. Assinaturas explícitas como `createProduct(Product)`, `updateProduct(Product)` e `deleteProduct(id)` agora residem no contrato principal de repasse, foram orquestradas com sucesso em código simulando assincronismo (na camada infra), e seus disparos de chamadas interagem via arquitetura de estado (Provider e Notifier) refletindo, imediatamente, a injeção ou deleção gráfica interativa sem exigir do usuário atualizar a aplicação (Pull 2 Refresh), quebrando totalmente o paradigma que a aplicação só lidava com fluxos GET unilaterais sem mutação.

**7. Houve uso ou planejamento de persistência local? Justifique.**
R: Sim, ele foi a engrenagem que sustentou o fim do requisito nesta iteração Ead. Devido às severas (e compreensíveis) limitações em gravar e iterar com idempotência bancos em API de ensino aberta pública como a FakeStore API, utilizar requisições puras POST ou Delete no servidor deles não traria, após atualizar ou reiniciar o aplicativo, o objeto de volta a um ciclo permanente refletindo a interação do tester. Assim adotei o "Offline-Persistance approach" em 100% da camada de escrita; manipulando o LocalDataSource com SharedPreferences para fazer o CRUD no JSON interno, simulando fisicamente em hardware local um backend funcional que não apaga nos bootloops contornando a falibilidade da arquitetura da API Mock.

**8. Quais foram as principais dificuldades encontradas durante a evolução do projeto?**
R: O maior impeditivo lógico desta fase inteira foi sem dúvidas fundir um "State Management dinâmico imutável", como o async *Riverpod*, a uma engine híbrida de listagem vinda de cache/HTTP simultaneamente durante as ações do Form (escrita). Manter íntegra a arquitetura `AsyncData` no Riverpod para conseguir refletir perfeitamente o acréscimo de um objeto recém salvo do Storage de volta na tela - espelhando dezenas de propriedades complexas reativas do zero - sem recarregar forçadamente do zero o Provider causativo a cada clique (desperdiçando I/O) ou mesmo desestabilizando null checks de tela; isso exige conhecimento profundo nas regras de mutabilidade controlada no estado que, sem dúvidas, forçou um desenho lógico metódico avançado sobre o "StateNotifier".
