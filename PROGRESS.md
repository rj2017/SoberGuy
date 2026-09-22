# soberGuy — Status de Implementação

> Referência de escopo/regras: [`SPEC.md`](SPEC.md) (spec completa do MVP).
> Este arquivo é o checklist vivo do que já foi construído vs. o que falta. Atualizar ao final de cada etapa/slice.

## ✅ Slice 1 — Estrutura, Models, Persistência, Home + Setup de Pessoas (concluído e testado)

**Estrutura de pastas (spec §7):** criada em `SoberGuy/` — `App/`, `Coordinators/`, `Models/`, `Services/`, `ViewModels/`, `Views/Home|Setup|Journey|Summary/`, `Utils/`.

**Models (spec §5):** `Person`, `Product`, `Journey` — exatamente como especificado.

**Persistência (spec §6):** `PersistenceService` (protocolo) + `UserDefaultsPersistenceService`. Resume automático no launch testado e funcionando.

**Coordinators:** `Coordinator` (protocolo marcador), `AppCoordinator`, `HomeCoordinator` + `HomeCoordinatorView`.

**Telas:** Tela Inicial ✅. Tela Quantidade de Pessoas ✅ (lista dinâmica, validação de nome duplicado case-insensitive + trim).

---

## ✅ Slice 2 — Adicionar Produto, Cálculo Real (§4.4), Adicionar Pessoa na Jornada, Finalizar + Resumo (concluído e testado)

**Tela Principal da Jornada (spec §3.3):** completa — lista de pessoas com valor **real** calculado (não mais fixo), botões "Adicionar Produto", "Adicionar Pessoa", "Finalizar Jornada".

**`JourneyCoordinator` (novo, `@Observable`):** única fonte de verdade em memória para a `Journey` ativa — guarda `journey`, persiste a cada mutação (`addProduct`, `addPerson`, `finish`), controla navegação (sheet enum `JourneySheetRoute`, push `JourneyRoute.summary`). `JourneyCoordinatorView` análogo a `HomeCoordinatorView`. `AppCoordinator.returnToHome()` adicionado; `RootView` usa `JourneyCoordinatorView` em vez de `JourneyView` direto.

**Modal Adicionar Produto (spec §3.4, §4.2, §4.3):** ✅ — nome livre + valor com máscara `R$ 00,00`. Snapshot de `participantIds` = pessoas presentes no momento (§4.2). Pré-preenchimento (§4.3) derivado direto de `journey.products.last`, sem estado extra.

**Modal Adicionar Pessoa dentro da jornada (spec §3.5, §4.1):** ✅ — mesma validação de nome único (case-insensitive + trim) via `PersonNameValidator` (normalização compartilhada com `SetupPeopleViewModel`).

**Cálculo do valor por pessoa (spec §4.4):** ✅ — `Journey.total(for:)` (extension pura em `Models/Journey.swift`), usada por `JourneyViewModel` e `SummaryViewModel`. Equivalência usada: "produto lançado enquanto P estava na mesa" = "`P.id` ∈ `product.participantIds`" (snapshot já é a resposta, sem comparar timestamps).

**Tela Resumo Final (spec §3.6):** ✅ — lista pessoa + total, botão "X" (`topBarTrailing`) que limpa o cache (`PersistenceService.clearJourney()`) e volta à Tela Inicial via `AppCoordinator.returnToHome()`.

**Ciclo de vida (spec §4.5) agora testável ponta a ponta:** ✅ confirmado no simulador — chegar ao Resumo (isFinished=true persistido, cache ainda não limpo), matar o app sem tocar "X", reabrir → cai na Tela Inicial (não retoma jornada finalizada). Cobre tanto o caminho `AppCoordinator.handleScenePhaseChange` (scenePhase → background) quanto o fallback defensivo em `AppCoordinator.init` (isFinished==true ao carregar do disco) — ambos previstos na spec como válidos.

**Bugs encontrados e corrigidos durante o teste no simulador:**
- Máscara de moeda com `TextField` + `Binding(get:set:)` não reformatava de forma confiável durante digitação ativa (limitação conhecida do SwiftUI). Corrigido trocando por `CurrencyTextField` (`UIViewRepresentable` + `UITextFieldDelegate`), que intercepta cada edição diretamente — abordagem robusta padrão para máscaras de texto em SwiftUI. `Utils/CurrencyTextFieldMask.swift` (struct) foi removido; `Utils/CurrencyTextField.swift` é a versão atual.
- Autocorreção do iOS alterando texto livre digitado (ex.: "Cerveja" → "Verbena" ao perder foco). Corrigido com `.autocorrectionDisabled()` nos campos de nome livre (produto, pessoa no setup, pessoa na jornada).

**Teste manual completo no simulador (iPhone 17, iOS 26.2):** fluxo A/B/C/D (4 pessoas) → Cerveja R$20 → R$5,00 cada ✅ → adicionar E → R$0,00 (não retroativo) ✅ → reabrir Adicionar Produto → pré-preenchido "Cerveja"/R$20,00 ✅ → confirmar → A-D=R$9,00, E=R$4,00 (bate com o exemplo literal da spec) ✅ → Finalizar → Resumo com totais corretos ✅ → matar app sem tocar X → reabre na Home (não retoma) ✅ → nova jornada → Finalizar → X → volta pra Home → force-quit + relaunch → continua na Home (cache limpo) ✅. Build limpo (`xcodebuild clean build` → `BUILD SUCCEEDED`).

---

## ✅ Slice 3 — Remoção de Pessoa durante a Jornada (concluído e testado)

Funcionalidade nova (reverte a decisão anterior de "fora do MVP" — ver `SPEC.md` §2, §4.1, §9). Nenhum arquivo novo, só 3 arquivos modificados:

- **`JourneyCoordinator.removePerson(id:)`** — remove de `journey.people`, persiste. **Não toca em `products`/`participantIds`** (decisão central: o snapshot de cada produto já lançado é imutável, então os valores das pessoas remanescentes não mudam — mesma filosofia não-retroativa do §4.2, só que para saída em vez de entrada).
- **`JourneyViewModel`** — novo `PersonRemovalInfo` (Identifiable) + `removalInfo` (estado local de apresentação do alerta), `canRemovePeople` (regra do mínimo 1 pessoa), `removePerson(_:)` captura o valor devido (via `Journey.total(for:)`, já existente, sem cálculo novo) **antes** de remover.
- **`JourneyView`** — `.swipeActions(edge: .trailing, allowsFullSwipe: true)` com botão destrutivo "Remover" por linha (padrão Apple HIG de swipe-to-delete, igual ao já usado em `SetupPeopleView`), só exibido quando `canRemovePeople` — é assim que a regra do mínimo 1 pessoa é aplicada (sem ação disponível em vez de botão desabilitado). `.alert` (API moderna `isPresented`+`presenting`, não a `Alert` struct antiga) mostra nome + valor devido, botão único "OK".

**Teste manual completo no simulador:** João/Marcos/Maria + 3 cervejas de R$10 → cada um R$10,00 ✅ → swipe-to-delete na Maria revela "Remover" ✅ → popup "Maria deve pagar R$ 10,00" com botão OK único ✅ → após fechar, João e Marcos continuam R$10,00 (sem redistribuição) ✅ → repetido removendo João, restando só Marcos ✅ → swipe na linha do Marcos (única pessoa) **não revela nenhuma ação** (regra do mínimo 1 pessoa) ✅ → force-quit + relaunch confirma remoção persistida ✅. Clean build → `BUILD SUCCEEDED`.

`SPEC.md` atualizada: §2 (movido para "dentro do escopo"), §4.1 (nova subseção "Remoção de pessoa durante a jornada"), §9 (decisão #5 marcada como revisada/revertida).

---

## 🚧 Pendente para o MVP completo

Com o Slice 3 concluído, **todas as telas e regras de negócio do §2, §3 e §4 da spec estão implementadas**. O que resta é polimento/robustez, não funcionalidade nova:

- [ ] Testes automatizados de unidade para `Journey.total(for:)` e para as regras de validação (spec §8 deixa em aberto, "avisar se quiser incluir" — perguntar ao usuário se deseja nesta fase).
- [ ] Revisão de UX/acessibilidade (tamanhos de toque, Dynamic Type, VoiceOver) — não coberto pela spec original, mas vale considerar antes de um lançamento real.
- [ ] Divergência menor de documentação: `SPEC.md` §7 (estrutura de pastas sugerida) ainda lista `Utils/CurrencyTextFieldMask.swift`, mas o arquivo real é `Utils/CurrencyTextField.swift` (renomeado no Slice 2 ao trocar para `UIViewRepresentable`) — cosmético, não bloqueia nada.
- [ ] Nenhuma pendência de regra de negócio ou tela do MVP em si.

---

## Decisões de UX/arquitetura confirmadas (válidas para próximas etapas)
- Setup de pessoas = lista dinâmica, sem campo numérico separado.
- Nome duplicado: comparação case-insensitive + trim, mensagem de erro amigável, bloqueia confirmação — reaproveitado em todo lugar que cadastra pessoa via `PersonNameValidator`.
- MVVC sem UIKit para navegação: `NavigationStack` + Coordinators `@Observable` com `NavigationPath`/enum de rota. **Exceção:** campos de texto com máscara ao vivo (moeda) usam `UIViewRepresentable`+`UITextFieldDelegate` — é a forma robusta de fazer isso em SwiftUI, `Binding(get:set:)` puro não é confiável durante digitação ativa.
- Campos de nome livre (produto, pessoa) sempre com `.autocorrectionDisabled()`.
- Remoção de item de lista = swipe-to-delete via `.swipeActions` (não `.onDelete`, que não permite ocultar a ação condicionalmente por linha), padrão Apple HIG. Regras de "não pode remover" se implementam omitindo a ação, não desabilitando um botão visível.
