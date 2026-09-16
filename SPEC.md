# Especificação Refinada — soberGuy (MVP)

> Documento de planejamento para uso como prompt-base com o Claude Code.
> Nome do projeto: **soberGuy**.
> Stack alvo: SwiftUI, arquitetura **MVVC** (Model-View-ViewModel-Coordinator), sem backend, persistência local via `UserDefaults`.

---

## 1. Visão Geral

App mobile iOS para grupos de pessoas em um bar controlarem, em tempo real, quanto cada pessoa deve pagar pelos produtos consumidos coletivamente, dividindo o valor de cada item entre as pessoas presentes na mesa no momento em que o item foi adicionado.

**Sem login. Sem backend. Sem conta de usuário.** Todo o estado vive localmente até o usuário finalizar o fluxo ou desinstalar o app.

---

## 2. Escopo do MVP

**Dentro do escopo:**
- Iniciar uma "jornada" (uma sessão de mesa) informando o número inicial de pessoas.
- Cadastrar pessoas por nome/apelido.
- Adicionar produtos (nome + valor) que são divididos entre as pessoas ativas naquele momento.
- Adicionar novas pessoas no meio da jornada (afeta só produtos futuros, não os já lançados).
- Ver em tempo real quanto cada pessoa já deve.
- Finalizar a jornada e ver o resumo final por pessoa.
- Limpar o cache ao fechar a tela de resumo (botão "X").

**Fora do escopo do MVP** *(confirmado)*:
- Edição ou exclusão de um produto já lançado.
- Remoção de uma pessoa já cadastrada.
- Histórico de jornadas anteriores.
- Múltiplas mesas simultâneas.
- Divisão não-igualitária (ex: só 2 das 5 pessoas dividem uma bebida específica).
- Compartilhamento do resumo final (PDF, imagem, WhatsApp etc).
- Qualquer autenticação, conta ou sincronização em nuvem.

---

## 3. Fluxo de Telas

1. **Tela Inicial** → botão "Iniciar Jornada".
2. **Tela Quantidade de Pessoas** → input numérico + cadastro de nome/apelido de cada pessoa (pelo menos 1 pessoa cadastrada é obrigatório).
3. **Tela Principal da Jornada** (tela "mesa aberta") → mostra:
   - Lista de pessoas com o valor que cada uma já deve.
   - Botão "Adicionar Produto".
   - Botão "Adicionar Pessoa".
   - Botão "Finalizar Jornada".
4. **Modal/Sheet Adicionar Produto** → campos Nome (alfanumérico) e Valor (máscara `R$ 00,00`), pré-preenchidos com o último produto adicionado.
5. **Modal/Sheet Adicionar Pessoa** → campo Nome/apelido.
6. **Tela Resumo Final** → nome de cada pessoa + valor total a pagar + botão "X" no canto superior direito (limpa cache e retorna à Tela Inicial).

---

## 4. Regras de Negócio Detalhadas

### 4.1 Pessoas
- Pessoa = `id`, `nome/apelido`, `timestamp de entrada na jornada`.
- **Nome/apelido deve ser único dentro da jornada** — o app não deve aceitar cadastrar uma pessoa com nome já existente na mesa (validação obrigatória no formulário de "Adicionar Pessoa", com mensagem de erro amigável e sem permitir confirmar o cadastro).
- Pessoas podem ser adicionadas a qualquer momento durante a jornada aberta.
- **Fora do MVP** (confirmado): não é possível remover ou renomear uma pessoa após cadastro.

### 4.2 Produtos
- Produto = `id`, `nome`, `valor`, `timestamp`, `lista de pessoas presentes no momento do lançamento` (snapshot).
- O valor de cada produto é dividido **igualmente** entre todas as pessoas presentes na mesa **no exato momento em que o produto foi adicionado** — não entre as pessoas atuais no momento da consulta.
  - Exemplo: mesa começa com 4 pessoas → cerveja de R$ 20 = R$ 5/pessoa para essas 4. Chega a 5ª pessoa → próxima cerveja de R$ 20 é dividida por 5 = R$ 4/pessoa (a 5ª pessoa paga R$ 4; as anteriores não pagam nada retroativo dessa cerveja anterior).
- Campo "Nome" do produto: alfanumérico, sem validação de conteúdo (livre).
- Campo "Valor": teclado numérico com máscara monetária `R$ 00,00` (formato `pt-BR`).
- **Fora do MVP** (confirmado): não é possível editar/excluir um produto após adicionado.

### 4.3 Pré-preenchimento do formulário de produto
- Ao abrir "Adicionar Produto" novamente, os campos Nome e Valor vêm preenchidos com os últimos valores usados (útil para lançar rodadas repetidas rapidamente).
- Usuário pode editar livremente antes de confirmar.

### 4.4 Cálculo do valor por pessoa
Para cada pessoa P, o valor devido é:

```
total(P) = Σ (valor do produto / nº de pessoas presentes no momento do lançamento)
           para todo produto lançado enquanto P já estava na mesa
```

- Isso é recalculado/exibido em tempo real conforme produtos são adicionados.

### 4.5 Ciclo de vida da jornada
- Apenas **uma jornada ativa por vez**.
- Dados persistem em cache local mesmo se o app for fechado/reaberto, até que:
  (a) o usuário toque "Finalizar Jornada" **e depois** feche a tela de resumo pelo "X", ou
  (b) o app seja desinstalado.
- Ao tocar "Finalizar Jornada": app navega para a Tela Resumo Final, mas **ainda não limpa o cache** (o cache só é limpo ao fechar essa tela pelo "X").
- **Confirmado:** se o usuário finalizou a jornada (está na Tela Resumo Final) mas o processo do app for encerrado (app fechado/matado) antes de tocar no "X", o cache deve ser limpo automaticamente nesse encerramento — ou seja, o app não deve reabrir retomando uma jornada já finalizada. Isso deve ser tratado no ciclo de vida do app (ex: `scenePhase == .background`/término do processo com `isFinished == true` → disparar limpeza do cache).
  - Na prática: ao detectar que o app está indo para segundo plano/sendo encerrado **e** `Journey.isFinished == true`, a `PersistenceService` deve apagar o registro salvo.

---

## 5. Modelo de Dados (proposta)

```swift
struct Person: Identifiable, Codable {
    let id: UUID
    var name: String
    let joinedAt: Date
}

struct Product: Identifiable, Codable {
    let id: UUID
    var name: String
    var value: Decimal
    let addedAt: Date
    let participantIds: [UUID] // snapshot das pessoas presentes no momento
}

struct Journey: Codable {
    var people: [Person]
    var products: [Product]
    var isFinished: Bool
    var startedAt: Date
}
```

---

## 6. Persistência (Cache Local)

- **Confirmado:** `Journey` codificado em JSON, salvo via `UserDefaults` (`Codable`), carregado no `App init`.
- Ao abrir o app:
  - Se existe jornada salva com `isFinished == false` → retomar direto na Tela Principal (pula a Tela Inicial).
  - Se existe jornada salva com `isFinished == true` → não deveria acontecer na prática, pois o cache é limpo ao encerrar o app nesse estado (ver seção 4.5); tratar como caso defensivo limpando o cache e indo para a Tela Inicial.
- Ao clicar "X" na tela de Resumo Final: apagar o registro persistido por completo.
- Ao app ser encerrado com `isFinished == true`: apagar o registro persistido (ver seção 4.5).

---

## 7. Arquitetura MVVC — Estrutura de Pastas Sugerida

```
soberGuy/
├── App/
│   ├── soberGuyApp.swift
│   └── AppCoordinator.swift
├── Coordinators/
│   ├── Coordinator.swift (protocolo base)
│   ├── HomeCoordinator.swift
│   └── JourneyCoordinator.swift
├── Models/
│   ├── Person.swift
│   ├── Product.swift
│   └── Journey.swift
├── Services/
│   ├── PersistenceService.swift (protocolo)
│   └── UserDefaultsPersistenceService.swift
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── SetupPeopleViewModel.swift
│   ├── JourneyViewModel.swift
│   ├── AddProductViewModel.swift
│   ├── AddPersonViewModel.swift
│   └── SummaryViewModel.swift
├── Views/
│   ├── Home/HomeView.swift
│   ├── Setup/SetupPeopleView.swift
│   ├── Journey/JourneyView.swift
│   ├── Journey/AddProductSheet.swift
│   ├── Journey/AddPersonSheet.swift
│   └── Summary/SummaryView.swift
├── Utils/
│   ├── CurrencyFormatter.swift
│   └── CurrencyTextFieldMask.swift
└── Resources/
    └── Assets.xcassets
```

---

## 8. Requisitos Não Funcionais

- Localização: `pt-BR`, moeda fixa em Real (R$).
- Sem dependência de rede (100% offline).
- iOS mínimo sugerido: iOS 16+ (SwiftUI moderno, `NavigationStack`).
- Sem testes automatizados no MVP *(assumido — avisar se quiser incluir testes unitários das ViewModels desde já)*.

---

## 9. Decisões Confirmadas (histórico)

Todos os pontos em aberto da versão anterior deste documento foram resolvidos:

1. ✅ Nomes/apelidos duplicados **não** são permitidos na mesma jornada.
2. ✅ Se o app for encerrado com a jornada já finalizada (mas sem o usuário ter clicado no "X"), o cache é limpo automaticamente nesse encerramento.
3. ✅ Persistência via `UserDefaults`.
4. ✅ Sem edição/exclusão de produtos no MVP.
5. ✅ Sem remoção de pessoas no MVP.

Nenhum ponto em aberto no momento. Caso surjam novas dúvidas durante o desenvolvimento com o Claude Code, adicionar aqui.

---

## 10. Prompt Sugerido para o Claude Code

```
Estou desenvolvendo o app "soberGuy" em SwiftUI usando arquitetura MVV-C
(Model-View-ViewModel-Coordinator). Já existe um projeto Xcode local criado
com esse nome — trabalhe dentro dessa estrutura existente.

Contexto: app de divisão de gastos em bar, sem login, sem backend, 100% offline,
com persistência local via UserDefaults (Codable).

[cole aqui as seções 3, 4, 5, 6 e 7 deste documento]

Comece criando a estrutura de pastas (seção 7), os Models, o PersistenceService,
e depois a Tela Inicial + fluxo de configuração inicial de pessoas.
```

