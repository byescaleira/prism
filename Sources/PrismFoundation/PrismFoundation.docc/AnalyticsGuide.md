# Analytics

Rastreamento automático de métricas em componentes PrismUI.

## Visão Geral

O sistema de analytics do Prism é **provider-agnostic**: você implementa ``PrismAnalyticsProvider`` com o backend de sua preferência (Firebase, Mixpanel, Amplitude, custom) e o Prism injeta eventos automaticamente.

### Implementando um Provider

```swift
struct FirebaseAnalytics: PrismAnalyticsProvider {
    func track(_ event: PrismAnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)
    }
}
```

### Registrando no App

```swift
@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .prism(analytics: FirebaseAnalytics())
        }
    }
}
```

## Eventos Automáticos

Os seguintes componentes emitem eventos automaticamente quando um provider está configurado:

| Componente | Evento | Parâmetros |
|---|---|---|
| `PrismButton` | `button_tap` | `label`, `test_id` |
| `PrismTextField` | `field_interaction` | `test_id`, `action` (focus/blur) |
| `PrismCarousel` | `carousel_scroll` | `test_id`, `index` |
| `PrismTabView` | `tab_select` | `test_id`, `tab` |
| `PrismNavigationView` | `screen_view` | `screen_name`, `route` |

## Eventos Customizados

Use o modificador `.prismTrack(_:)` para emitir eventos customizados:

```swift
PrismText("Oferta Especial")
    .prismTrack(.custom("promo_viewed", parameters: ["id": "summer2026"]))
```

Ou crie eventos diretamente:

```swift
analyticsProvider.track(
    .custom("checkout_started", parameters: ["items": "3"])
)
```

## Sem Provider = Sem Overhead

Se nenhum provider for registrado via `.prism(analytics:)`, nenhum evento é criado ou processado. O custo em runtime é zero.
