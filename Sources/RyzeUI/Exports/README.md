# Personalização de Prefixo do RyzeUI

## Visão Geral

O RyzeUI inclui um sistema de typealiases que permite personalizar o prefixo dos componentes ao importar a biblioteca em seu projeto. Por padrão, todos os componentes usam o prefixo `Ryze` ou `ryze`, mas você pode criar aliases com o prefixo desejado.

## Como Usar

### Opção 1: Usar os Typealiases Existentes (Prefixo "Nova")

O arquivo `RyzeUIPrefixAliases.swift` já inclui typealiases com o prefixo `Nova`. Basta importar o módulo e usar:

```swift
import RyzeUI

// Usando os aliases
var button: NovaButton
var text: NovaText
var stack: NovaVStack
```

### Opção 2: Criar Seus Próprios Typealiases (Recomendado)

Para usar um prefixo personalizado do seu projeto:

1. Copie o arquivo `RyzeUIPrefixAliases.swift` para o seu projeto
2. Substitua `Nova` pelo prefixo desejado (ex: `App`, `My`, `Custom`)
3. Use os aliases no seu código

**Exemplo para um projeto chamado "Zenith":**

```swift
// No seu projeto, crie um arquivo ZenithPrefixAliases.swift:

import RyzeUI

// MARK: - Atoms
public typealias ZenithButton = RyzeButton
public typealias ZenithText = RyzeText
public typealias ZenithTextField = RyzeTextField
public typealias ZenithSymbol = RyzeSymbol
public typealias ZenithVStack = RyzeVStack
public typealias ZenithHStack = RyzeHStack
// ... continue para todos os componentes que você usa

// MARK: - View Extensions
extension View {
    public func zenith(accessibility properties: RyzeAccessibilityProperties) -> some View {
        ryze(accessibility: properties)
    }
    
    public func zenith(testID: String) -> some View {
        ryze(testID: testID)
    }
}
```

**Uso no seu código:**

```swift
import RyzeUI

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
- `RyzeButton` → `NovaButton`
- `RyzeText` → `NovaText`
- `RyzeTextField` → `NovaTextField`
- `RyzeSymbol` → `NovaSymbol`
- `RyzeVStack`, `RyzeHStack`, `RyzeZStack` → `NovaVStack`, etc.
- `RyzeLazyList`, `RyzeList`, `RzeHorizontalList` → `NovaLazyList`, etc.
- `RyzeAsyncImage`, `RyzeShape`, `RyzeSection`, `RyzeLabel`, `RyzeTabView`

### Molecules
- `RyzeTag` → `NovaTag`
- `RyzeCarousel` → `NovaCarousel`
- `RyzePrimaryButton`, `RyzeSecondaryButton` → `NovaPrimaryButton`, etc.
- `RyzeBodyText`, `RyzeFootnoteText` → `NovaBodyText`, etc.
- `RyzeCurrencyTextField` → `NovaCurrencyTextField`
- `RyzeNavigationView`, `RyzeBrowserView`, `RyzeVideoView`

### Accessibility
- `RyzeAccessibilityProperties` → `NovaAccessibilityProperties`
- `RyzeAccessibilityConfig` → `NovaAccessibilityConfig`
- `RyzeAccessibility` → `NovaAccessibility`
- `RyzeAccessibilityAction` → `NovaAccessibilityAction`

### Styles & Tokens
- `RyzeColor`, `RyzeSpacing`, `RyzeRadius`, `RyzeSize` → `NovaColor`, etc.
- `RyzeGradient`, `RyzeSemanticColors`, `RyzeDesignTokens`
- `SpacingToken`, `RadiusToken`, `FontSizeToken`, `MotionToken`, `Breakpoint`

### Protocols
- `RyzeThemeProtocol`, `RyzeColorProtocol`, `RyzeSpacingProtocol`
- `RyzeRadiusProtocol`, `RyzeSizeProtocol`, `RyzeFontProtocol`
- `RyzeTextFieldMask`, `RyzeTextFieldConfiguration`, `RyzeUIMock`

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
