# ``PrismFoundation``

Camada base do Prism: entidades, erros, logging, analytics, recursos, defaults, formatação, locale, arquivos e extensões Foundation.

## Visão Geral

PrismFoundation é o módulo sem dependências que serve como fundação para todos os outros módulos do Prism. Ele fornece protocolos base, helpers de infraestrutura e extensões utilitárias que são usados em toda a stack.

Você raramente importará PrismFoundation diretamente — os módulos de nível superior (``PrismNetwork``, ``PrismArchitecture``, ``PrismUI``) o importam transitivamente. Importe diretamente quando precisar apenas dos helpers de fundação sem o peso dos módulos superiores.

```swift
import PrismFoundation
```

### Protocolos Base

Os protocolos ``PrismEntity`` e ``PrismError`` definem contratos para entidades e erros tipados com logging integrado. Todos os módulos do Prism estendem esses protocolos.

### Logging

``PrismLogger`` e ``PrismSystemLogger`` fornecem logging estruturado via `os.Logger`. Cada módulo define seus próprios log messages conformando ``PrismResourceLogMessage``.

### Recursos

``PrismResourceString``, ``PrismResourceImage`` e ``PrismResourceLogMessage`` abstraem recursos localizados, desacoplando strings e imagens do código.

## Topics

### Protocolos Base

- ``PrismEntity``
- ``PrismError``
- ``PrismMock``

### Logging

- ``PrismLogger``
- ``PrismSystemLogger``
- ``PrismResourceLogMessage``

### Recursos

- ``PrismResourceString``
- ``PrismResourceImage``

### Analytics

- ``PrismAnalyticsProvider``
- ``PrismAnalyticsEvent``
- <doc:AnalyticsGuide>

### Locale

- ``PrismLocale``
- ``PrismLocaleManager``
- <doc:LocaleGuide>

### Armazenamento e Formatação

- ``PrismDefaults``
- ``PrismDateFormatter``

### Arquivos

- ``PrismFileManager``
- ``PrismFilePrivacy``

### Bundle

- ``PrismBundle``

### Extensões

- ``Logging``
- ``Resources``
- ``Defaults``
- ``Files``
- ``Entities``
- ``Extensions``