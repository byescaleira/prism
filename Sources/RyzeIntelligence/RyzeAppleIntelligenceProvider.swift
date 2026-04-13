//
//  RyzeAppleIntelligenceProvider.swift
//  Ryze
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation

public enum RyzeAppleIntelligenceUseCase: String, Codable, Sendable, CaseIterable {
    case general
    case contentTagging
}

public enum RyzeAppleIntelligenceModelReference: Codable, Equatable, Hashable, Sendable {
    case system(useCase: RyzeAppleIntelligenceUseCase)
    case adapterName(String)
    case adapterFile(URL)
}

public struct RyzeAppleIntelligenceConfiguration: Codable, Equatable, Hashable, Sendable {
    public var model: RyzeAppleIntelligenceModelReference
    public var instructions: String?

    public init(
        model: RyzeAppleIntelligenceModelReference = .system(useCase: .general),
        instructions: String? = nil
    ) {
        self.model = model
        self.instructions = instructions
    }
}

internal protocol RyzeAppleIntelligenceGateway: Sendable {
    func status(
        configuration: RyzeAppleIntelligenceConfiguration
    ) async -> RyzeLanguageIntelligenceStatus

    func generate(
        request: RyzeLanguageIntelligenceRequest,
        configuration: RyzeAppleIntelligenceConfiguration
    ) async throws -> RyzeLanguageIntelligenceResponse
}

public actor RyzeAppleIntelligenceProvider: RyzeLanguageIntelligenceProvider {
    public let kind: RyzeLanguageIntelligenceProviderKind = .apple

    private let configuration: RyzeAppleIntelligenceConfiguration
    private let gateway: any RyzeAppleIntelligenceGateway

    public init(
        configuration: RyzeAppleIntelligenceConfiguration = .init()
    ) {
        self.configuration = configuration
        self.gateway = RyzeFoundationModelsGateway()
    }

    init(
        configuration: RyzeAppleIntelligenceConfiguration = .init(),
        gateway: any RyzeAppleIntelligenceGateway
    ) {
        self.configuration = configuration
        self.gateway = gateway
    }

    public func status() async -> RyzeLanguageIntelligenceStatus {
        await gateway.status(configuration: configuration)
    }

    public func generate(
        _ request: RyzeLanguageIntelligenceRequest
    ) async throws -> RyzeLanguageIntelligenceResponse {
        try await gateway.generate(
            request: request,
            configuration: configuration
        )
    }
}

#if canImport(FoundationModels)
    import FoundationModels

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    private struct RyzeFoundationModelsGatewayImpl {
        func status(
            configuration: RyzeAppleIntelligenceConfiguration
        ) -> RyzeLanguageIntelligenceStatus {
            do {
                let model = try resolvedModel(from: configuration.model)

                if model.isAvailable {
                    return RyzeLanguageIntelligenceStatus(
                        provider: .apple,
                        isAvailable: true,
                        supportsStreaming: false,
                        supportsCustomInstructions: true,
                        supportsModelAdapters: true
                    )
                }

                return RyzeLanguageIntelligenceStatus(
                    provider: .apple,
                    isAvailable: false,
                    reason: availabilityReason(from: model.availability),
                    supportsStreaming: false,
                    supportsCustomInstructions: true,
                    supportsModelAdapters: true
                )
            } catch {
                return RyzeLanguageIntelligenceStatus(
                    provider: .apple,
                    isAvailable: false,
                    reason: error.localizedDescription,
                    supportsStreaming: false,
                    supportsCustomInstructions: true,
                    supportsModelAdapters: true
                )
            }
        }

        func generate(
            request: RyzeLanguageIntelligenceRequest,
            configuration: RyzeAppleIntelligenceConfiguration
        ) async throws -> RyzeLanguageIntelligenceResponse {
            let model = try resolvedModel(from: configuration.model)

            guard model.isAvailable else {
                throw RyzeIntelligenceError.providerUnavailable(
                    availabilityReason(from: model.availability)
                )
            }

            let instructions = mergedInstructions(
                configuration: configuration,
                request: request
            )
            let prompt = mergedPrompt(for: request)
            let session = LanguageModelSession(
                model: model,
                instructions: instructions
            )
            let response = try await session.respond(
                to: prompt,
                options: generationOptions(from: request.options)
            )

            return RyzeLanguageIntelligenceResponse(
                provider: .apple,
                model: modelIdentifier(from: configuration.model),
                content: response.content,
                finishReason: "completed",
                usage: nil,
                metadata: [
                    "transcriptEntries": "\(response.transcriptEntries.count)"
                ]
            )
        }

        private func generationOptions(
            from options: RyzeLanguageGenerationOptions
        ) -> GenerationOptions {
            GenerationOptions(
                sampling: nil,
                temperature: options.temperature,
                maximumResponseTokens: options.maximumResponseTokens
            )
        }

        private func mergedInstructions(
            configuration: RyzeAppleIntelligenceConfiguration,
            request: RyzeLanguageIntelligenceRequest
        ) -> String? {
            [configuration.instructions, request.systemPrompt]
                .compactMap { value in
                    guard let value,
                        !value.isEmpty
                    else {
                        return nil
                    }

                    return value
                }
                .joined(separator: "\n\n")
                .nilIfEmpty
        }

        private func mergedPrompt(
            for request: RyzeLanguageIntelligenceRequest
        ) -> String {
            if request.context.isEmpty {
                return request.prompt
            }

            let context = request.context.joined(separator: "\n- ")
            return """
                Context:
                - \(context)

                Request:
                \(request.prompt)
                """
        }

        private func resolvedModel(
            from reference: RyzeAppleIntelligenceModelReference
        ) throws -> SystemLanguageModel {
            switch reference {
            case .system(let useCase):
                return SystemLanguageModel(
                    useCase: resolvedUseCase(from: useCase)
                )
            case .adapterName(let name):
                let adapter = try SystemLanguageModel.Adapter(name: name)
                return SystemLanguageModel(adapter: adapter)
            case .adapterFile(let url):
                let adapter = try SystemLanguageModel.Adapter(fileURL: url)
                return SystemLanguageModel(adapter: adapter)
            }
        }

        private func resolvedUseCase(
            from useCase: RyzeAppleIntelligenceUseCase
        ) -> SystemLanguageModel.UseCase {
            switch useCase {
            case .general:
                .general
            case .contentTagging:
                .contentTagging
            }
        }

        private func availabilityReason(
            from availability: SystemLanguageModel.Availability
        ) -> String {
            switch availability {
            case .available:
                "Available"
            case .unavailable(let reason):
                switch reason {
                case .deviceNotEligible:
                    "This device is not eligible for Apple Intelligence."
                case .appleIntelligenceNotEnabled:
                    "Apple Intelligence is not enabled."
                case .modelNotReady:
                    "The Apple Intelligence model is not ready yet."
                @unknown default:
                    "Apple Intelligence is unavailable."
                }
            }
        }

        private func modelIdentifier(
            from reference: RyzeAppleIntelligenceModelReference
        ) -> String {
            switch reference {
            case .system(let useCase):
                "apple.\(useCase.rawValue)"
            case .adapterName(let name):
                "apple.adapter.\(name)"
            case .adapterFile(let url):
                "apple.adapter.\(url.lastPathComponent)"
            }
        }
    }
#endif

internal struct RyzeFoundationModelsGateway: RyzeAppleIntelligenceGateway {
    func status(
        configuration: RyzeAppleIntelligenceConfiguration
    ) async -> RyzeLanguageIntelligenceStatus {
        #if canImport(FoundationModels)
            if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
                return RyzeFoundationModelsGatewayImpl().status(
                    configuration: configuration
                )
            }
        #endif

        return RyzeLanguageIntelligenceStatus(
            provider: .apple,
            isAvailable: false,
            reason: "Foundation Models is unavailable on this platform or SDK.",
            supportsStreaming: false,
            supportsCustomInstructions: false,
            supportsModelAdapters: false
        )
    }

    func generate(
        request: RyzeLanguageIntelligenceRequest,
        configuration: RyzeAppleIntelligenceConfiguration
    ) async throws -> RyzeLanguageIntelligenceResponse {
        #if canImport(FoundationModels)
            if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
                return try await RyzeFoundationModelsGatewayImpl().generate(
                    request: request,
                    configuration: configuration
                )
            }
        #endif

        throw RyzeIntelligenceError.providerUnavailable(
            "Foundation Models is unavailable on this platform or SDK."
        )
    }
}

extension String {
    fileprivate var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
