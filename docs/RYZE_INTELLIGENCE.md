# RyzeIntelligence

`RyzeIntelligence` agora foi reorganizado em camadas para separar treino local, inferencia local e geracao de linguagem.

Para consumo no app, a API recomendada passa a ser `RyzeIntelligenceClient`, que abstrai os backends local, Apple e remoto com a mesma ideia de uso:

```swift
import RyzeIntelligence

let local = try await RyzeIntelligenceClient.local(modelID: "support-intent")
let label = try await local.classify(text: "Cobrar assinatura premium")

let apple = RyzeIntelligenceClient.apple()
let summary = try await apple.generate("Resuma os pontos principais da tela.")

let remote = RyzeIntelligenceClient.remote(
    endpoint: URL(string: "https://api.example.com/v1/generate")!,
    model: "gpt-oss-120b"
)
let answer = try await remote.generate("Crie um onboarding financeiro.")
```

Os componentes mais baixos continuam existindo para casos em que voce queira controle fino:

- `RyzeIntelligenceLocalTrainer`: treino local com `CreateML` quando disponivel.
- `RyzeIntelligencePrediction`: inferencia local usando `CoreML`.
- `RyzeLanguageIntelligence`: fachada unica para modelos generativos.
- `RyzeAppleIntelligenceProvider`: integracao com Apple Intelligence via `FoundationModels`.
- `RyzeRemoteIntelligenceProvider`: integracao com modelos externos via servidor HTTP.

## Objetivos do modulo

- manter compatibilidade com os fluxos atuais do projeto
- permitir evolucao por provider sem acoplar o app ao backend ou ao runtime da Apple
- facilitar testes com injeção de runtime, gateway e transport
- deixar claro o que e treino local, o que e inferencia local e o que e geracao remota

## Treino local

Para classificador de texto:

```swift
import RyzeIntelligence

let intelligence = RyzeTextIntelligence(
    samples: [
        .init(text: "Cobrar assinatura mensal", label: "finance"),
        .init(text: "Gerar relatorio de uso", label: "analytics"),
    ]
)

let result = await intelligence.trainingTextClassifier(
    id: "support-intent",
    name: "Support Intent"
)
```

Para dados tabulares:

```swift
import RyzeIntelligence

let intelligence = RyzeTabularIntelligence(
    rows: [
        [
            "sessions": .int(12),
            "spent": .double(89.9),
            "segment": .string("pro"),
            "target": .string("upgrade")
        ]
    ]
)

let result = await intelligence.trainingClassifier(
    id: "upgrade-model",
    name: "Upgrade Model",
    targetColumn: "target"
)
```

## Inferencia local

Depois de salvar o modelo:

```swift
import RyzeIntelligence

let storedModel = RyzeIntelligenceModel.models.first!
let prediction = await RyzeIntelligencePrediction(model: storedModel)

let label = try await prediction.predictText(from: "Cobrar assinatura premium")
```

## Apple Intelligence

Quando o sistema suportar `FoundationModels`, o mesmo facade pode usar o modelo do sistema:

```swift
import RyzeIntelligence

let service = RyzeLanguageIntelligence(
    provider: RyzeAppleIntelligenceProvider(
        configuration: .init(
            model: .system(useCase: .general),
            instructions: "Responda de forma objetiva e segura."
        )
    )
)

let response = try await service.generate(
    .init(
        prompt: "Resuma os pontos principais da tela inicial.",
        context: [
            "App para iOS, macOS, tvOS, watchOS e visionOS",
            "Tom profissional"
        ]
    )
)
```

Tambem e possivel usar adapters do sistema:

```swift
let provider = RyzeAppleIntelligenceProvider(
    configuration: .init(
        model: .adapterName("my-domain-adapter")
    )
)
```

## Modelos externos

Para um provider remoto:

```swift
import RyzeIntelligence

let serializer = RyzeDefaultRemoteIntelligenceSerializer(
    endpoint: URL(string: "https://api.example.com/v1/generate")!,
    model: "gpt-oss-120b",
    providerName: "example-ai",
    headers: [
        "Authorization": "Bearer TOKEN"
    ]
)

let service = RyzeLanguageIntelligence(
    provider: RyzeRemoteIntelligenceProvider(serializer: serializer)
)

let response = try await service.generate(
    .init(
        prompt: "Sugira um onboarding para um app financeiro.",
        systemPrompt: "Responda em portugues do Brasil."
    )
)
```

## Disponibilidade por plataforma

- treino local depende de `CreateML` e `TabularData`
- inferencia local depende de `CoreML`
- Apple Intelligence depende de `FoundationModels` e dos requisitos do sistema
- tvOS e watchOS podem continuar usando o provider remoto mesmo quando o provider da Apple nao estiver disponivel

## Testes

O modulo foi preparado para teste por injeção:

- `RyzeIntelligenceLocalTrainer` aceita runtime interno customizado
- `RyzeIntelligencePrediction` aceita runtime interno customizado
- `RyzeAppleIntelligenceProvider` usa gateway isolado
- `RyzeRemoteIntelligenceProvider` separa serializer e transport

Isso reduz acoplamento com SDKs nativos e deixa os testes deterministas.
