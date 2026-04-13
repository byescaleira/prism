# Personalização de Prefixo do PrismUI

## Visão Geral

O PrismUI inclui um sistema de typealiases que permite personalizar o prefixo dos componentes ao importar a biblioteca em seu projeto. Por padrão, todos os componentes usam o prefixo `Prism` ou `prism`, mas você pode criar aliases com o prefixo desejado.

## Como Usar

### Opção 1: Usar os Typealiases Existentes (Prefixo "Nova")

O arquivo `PrismUIPrefixAliases.swift` já inclui typealiases com o prefixo `Nova`. Basta importar o módulo e usar:

```swift
import PrismUI

// Usando os aliases
var button: NovaButton
var text: NovaText
var stack: NovaVStack
```

### Opção 2: Criar Seus Próprios Typealiases (Recomendado)

Para usar um prefixo personalizado do seu projeto:

1. Copie o arquivo `PrismUIPrefixAliases.swift` para o seu projeto
2. Substitua `Nova` pelo prefixo desejado (ex: `App`, `My`, `Custom`)
3. Use os aliases no seu código

**Exemplo para um projeto chamado "Zenith":**

```swift
// No seu projeto, crie um arquivo ZenithPrefixAliases.swift:

import PrismUI

// MARK: - Atoms
public typealias ZenithButton = PrismButton
public typealias ZenithText = PrismText
public typealias ZenithTextField = PrismTextField
public typealias ZenithSymbol = PrismSymbol
public typealias ZenithVStack = PrismVStack
public typealias ZenithHStack = PrismHStack
// ... continue para todos os componentes que você usa

// MARK: - View Extensions
extension View {
    public func zenith(accessibility properties: PrismAccessibilityProperties) -> some View {
        prism(accessibility: properties)
    }
    
    public func zenith(testID: String) -> some View {
        prism(testID: testID)
    }
}
```

**Uso no seu código:**

```swift
import PrismUI

struct LoginView: View {
    var body: some View {
        ZenithVStack {
            ZenithText("Bem-vindo", testID: "welcome_text")
            ZenithButton("Entrar", testID: "login_button") {
                // ação
            }
        }
        .zenith(testID: "login_screen")
    }
}
```

## Componentes Disponíveis para Alias

### Atoms
- `PrismButton` → `NovaButton`
- `PrismText` → `NovaText`
- `PrismTextField` → `NovaTextField`
- `PrismSymbol` → `NovaSymbol`
- `PrismVStack`, `PrismHStack`, `PrismZStack` → `NovaVStack`, etc.
- `PrismLazyList`, `PrismList`, `RzeHorizontalList` → `NovaLazyList`, etc.
- `PrismAsyncImage`, `PrismShape`, `PrismSection`, `PrismLabel`, `PrismTabView`

### Molecules
- `PrismTag` → `NovaTag`
- `PrismCarousel` → `NovaCarousel`
- `PrismPrimaryButton`, `PrismSecondaryButton` → `NovaPrimaryButton`, etc.
- `PrismBodyText`, `PrismFootnoteText` → `NovaBodyText`, etc.
- `PrismCurrencyTextField` → `NovaCurrencyTextField`
- `PrismNavigationView`, `PrismBrowserView`, `PrismVideoView`

### Accessibility
- `PrismAccessibilityProperties` → `NovaAccessibilityProperties`
- `PrismAccessibilityConfig` → `NovaAccessibilityConfig`
- `PrismAccessibility` → `NovaAccessibility`
- `PrismAccessibilityAction` → `NovaAccessibilityAction`

### Styles & Tokens
- `PrismColor`, `PrismSpacing`, `PrismRadius`, `PrismSize` → `NovaColor`, etc.
- `PrismGradient`, `PrismSemanticColors`, `PrismDesignTokens`
- `SpacingToken`, `RadiusToken`, `FontSizeToken`, `MotionToken`, `Breakpoint`

### Protocols
- `PrismThemeProtocol`, `PrismColorProtocol`, `PrismSpacingProtocol`
- `PrismRadiusProtocol`, `PrismSizeProtocol`, `PrismFontProtocol`
- `PrismTextFieldMask`, `PrismTextFieldConfiguration`, `PrismUIMock`

## Por Que Typealiases e Não Macros?

Swift Macros têm limitações que impedem a geração automática de typealiases no mesmo escopo global onde os tipos originais são declarados. A solução com typealiases manuais:

1. **É mais simples** - Sem dependência de SwiftSyntax
2. **É mais transparente** - Você vê exatamente o que está sendo exportado
3. **É mais flexível** - Pode escolher quais componentes importar
4. **Funciona em qualquer versão do Swift** - Sem necessidade de compiler plugins

## Dicas

- **Importe seletivamente**: Não precisa criar aliases para todos os componentes, apenas os que você usa
- **Mantenha consistência**: Use o mesmo prefixo em todo o projeto
- **Documente**: Adicione comentários explicando o padrão de nomenclatura
- **Versione**: Mantenha o arquivo de aliases versionado junto com seu projeto
