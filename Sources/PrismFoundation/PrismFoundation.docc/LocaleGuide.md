# Locale

Localização e troca de idioma em tempo de execução.

## Visão Geral

O Prism suporta 8 idiomas com troca instantânea via ``PrismLocaleManager``. Quando o usuário muda o idioma, todas as views que usam `LocalizedStringKey` são atualizadas automaticamente.

## Idiomas Suportados

| Locale | Identificador | Moeda | Calendário |
|---|---|---|---|
| 🇺🇸 English | `en_US` | USD | Gregoriano |
| 🇧🇷 Português | `pt_BR` | BRL | Gregoriano |
| 🇪🇸 Español | `es_ES` | EUR | Gregoriano |
| 🇫🇷 Français | `fr_FR` | EUR | Gregoriano |
| 🇩🇪 Deutsch | `de_DE` | EUR | Gregoriano |
| 🇸🇦 العربية | `ar_SA` | SAR | Islâmico |
| 🇯🇵 日本語 | `ja_JP` | JPY | Japonês |
| 🇨🇳 中文 | `zh_CN` | CNY | Gregoriano |

## Configuração

### 1. Criar o Manager

```swift
@main struct MyApp: App {
    @State var localeManager = PrismLocaleManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .prism(localeManager: localeManager)
        }
    }
}
```

### 2. Trocar o Idioma

```swift
struct SettingsView: View {
    @Environment(\.localeManager) var localeManager

    var body: some View {
        Picker("Idioma", selection: Binding(
            get: { localeManager?.current ?? .current },
            set: { localeManager?.current = $0 }
        )) {
            ForEach(PrismLocale.allCases, id: \.self) { locale in
                Text(locale.description).tag(locale)
            }
        }
    }
}
```

## Persistência

Por padrão, o ``PrismLocaleManager`` salva a seleção em `UserDefaults` e a restaura no próximo lançamento. Para desabilitar:

```swift
PrismLocaleManager(persistsSelection: false)
```

## Locales Customizados

Restrinja os idiomas disponíveis passando um subset:

```swift
PrismLocaleManager(
    initial: .portugueseBR,
    available: [.portugueseBR, .englishUS, .spanishES]
)
```

## Strings Localizadas

Use `LocalizedStringKey` em componentes PrismUI — a troca de locale via ``PrismLocaleManager`` atualiza automaticamente:

```swift
PrismText("welcome_message")  // Busca em Localizable.xcstrings
PrismButton("sign_in_button", testID: "login") { }
```

Os arquivos `.xcstrings` do projeto devem conter as traduções para cada idioma suportado.
