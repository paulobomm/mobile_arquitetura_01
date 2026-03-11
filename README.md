# mobile_arquitetura_01
Materia de Desenvolvimento de Dispositivos Móveis II - Exercicio 02git s

## Atividade 2 - Questionário de Reflexão

**1. Em qual camada foi implementado o mecanismo de cache? Explique por que essa decisão é adequada dentro da arquitetura proposta.**
R: O mecanismo de cache foi implementado na camada de **DataSources** (através do `ProductLocalDataSource`), e é coordenado pela camada de **Repositories** (`ProductRepositoryImpl`). Essa decisão é adequada pois a arquitetura prevê que os DataSources devem lidar apenas com operações de I/O (no caso de cache, uso do `shared_preferences`), enquanto o Repository atua como o mediador que contém a lógica de decidir "de onde os dados vêm" (tentar do remote; se falhar ou estiver sem rede, pega do local).

**2. Por que o ViewModel não deve realizar chamadas HTTP diretamente?**
R: O ViewModel possui a responsabilidade única de estruturar, apresentar e coordenar o estado da interface visual. Se realizasse chamadas HTTP diretamente, haveria forte acoplamento com a infraestrutura, ferindo o princípio da responsabilidade única (SRP) e de separação de interesses. Isso tornaria os testes impossíveis e as regras difíceis de serem reaproveitadas.

**3. O que poderia acontecer se a interface acessasse diretamente o DataSource?**
R: A UI ficaria acoplada a operações de I/O. Ela teria de lidar com as exceções da API, tentar conversão de instâncias (como mapear JSON), gerenciar falhas de rede, sem nenhuma separação clara. A View deixaria de ser apenas declarativa (exibir o que mandam) para se tornar pesada e complexa ("Massive View Controller"), inviabilizando testes e a manutenibilidade.

**4. Como essa arquitetura facilitaria a substituição da API por um banco de dados local?**
R: Graças ao Princípio da Inversão de Dependências (DIP) e injeção de dependências. O ViewModel não faz ideia se os dados vêm da API ou não: ele apenas conhece o contrato do `ProductRepository`. Para trocar o armazenamento de dados remote/API para um banco local (como Sqflite), apenas necessitamos criar um *Local DataSource* robusto, passá-lo ao Repository e nenhuma linha de código precisa ser alterada na Interface de Usuário ou no ViewModel — o sistema continua funcionando perfeitamente.
