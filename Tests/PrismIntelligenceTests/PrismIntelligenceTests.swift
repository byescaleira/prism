import Foundation
import XCTest

@testable import PrismFoundation
@testable import PrismIntelligence

final class PrismIntelligenceTests: XCTestCase {
    func testFeatureValueCoercionSupportsPrimitiveTypes() {
        XCTAssertEqual(PrismIntelligenceFeatureValue("prism"), .string("prism"))
        XCTAssertEqual(PrismIntelligenceFeatureValue(7), .int(7))
        XCTAssertEqual(PrismIntelligenceFeatureValue(7.5), .double(7.5))
        XCTAssertEqual(PrismIntelligenceFeatureValue(Float(2.5)), .double(2.5))
        XCTAssertEqual(PrismIntelligenceFeatureValue(true), .bool(true))
        XCTAssertNil(PrismIntelligenceFeatureValue(Date()))
    }

    func testFeatureValueExposesFoundationAndDoubleViews() {
        XCTAssertEqual(
            PrismIntelligenceFeatureValue.int(3).foundationValue as? Int,
            3
        )
        XCTAssertEqual(
            PrismIntelligenceFeatureValue.double(3.5).doubleValue,
            3.5
        )
        XCTAssertEqual(
            PrismIntelligenceFeatureValue.int(3).doubleValue,
            3
        )
        XCTAssertNil(PrismIntelligenceFeatureValue.bool(true).doubleValue)
    }

    func testModelLoadsLegacyStorageAndKeepsCompatibilityFields() {
        struct LegacyModel: Codable {
            let id: String
            let name: String
            let isTraining: Bool
            let createDate: TimeInterval?
            let updateDate: TimeInterval?
            let accuracy: Double?
            let rootMeanSquaredError: Double?
        }

        let suite = makeDefaultsSuite()
        defer {
            suite.userDefaults.removePersistentDomain(forName: suite.name)
        }

        let legacy = [
            LegacyModel(
                id: "legacy",
                name: "Legacy Model",
                isTraining: false,
                createDate: 10,
                updateDate: 20,
                accuracy: 0.91,
                rootMeanSquaredError: 0.09
            )
        ]
        suite.userDefaults.set(
            try? JSONEncoder().encode(legacy),
            forKey: "prism.models"
        )

        let loaded = PrismIntelligenceModel.loadStoredModels(
            defaults: suite.defaults
        )

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.id, "legacy")
        XCTAssertEqual(loaded.first?.kind, .custom)
        XCTAssertEqual(loaded.first?.engine, .coreML)
        XCTAssertEqual(loaded.first?.accuracy, 0.91)
    }

    func testCatalogSaveReplaceRemoveAndClean() async {
        let suite = makeDefaultsSuite()
        defer {
            suite.userDefaults.removePersistentDomain(forName: suite.name)
        }

        let catalog = PrismIntelligenceCatalog(defaults: suite.defaults)
        let first = PrismIntelligenceModel(
            id: "model",
            name: "First",
            kind: .textClassifier,
            engine: .createML
        )
        let updated = PrismIntelligenceModel(
            id: "model",
            name: "Updated",
            kind: .textClassifier,
            engine: .createML
        )

        await catalog.save(first)
        await catalog.save(updated)

        let allModels = await catalog.allModels()
        XCTAssertEqual(allModels.count, 1)
        XCTAssertEqual(allModels.first?.name, "Updated")

        let removed = await catalog.remove(id: "model")
        XCTAssertEqual(removed?.name, "Updated")
        let modelsAfterRemove = await catalog.allModels()
        XCTAssertTrue(modelsAfterRemove.isEmpty)

        await catalog.save(first)
        await catalog.clean()
        let modelsAfterClean = await catalog.allModels()
        XCTAssertTrue(modelsAfterClean.isEmpty)
    }

    func testTextIntelligenceTrainingPersistsModelAndReturnsMetrics() async throws {
        let suite = makeDefaultsSuite()
        let tempDirectory = makeTemporaryDirectory()
        defer {
            suite.userDefaults.removePersistentDomain(forName: suite.name)
            try? FileManager.default.removeItem(at: tempDirectory)
        }

        let trainer = PrismIntelligenceLocalTrainer(
            catalog: PrismIntelligenceCatalog(defaults: suite.defaults),
            fileManager: PrismFileManager(documentsURL: tempDirectory),
            runtime: MockTrainingRuntime(
                textMetrics: .init(
                    accuracy: 0.95,
                    rootMeanSquaredError: 0.05
                )
            )
        )
        let intelligence = PrismTextIntelligence(
            samples: [
                .init(text: "Ótimo app", label: "positivo"),
                .init(text: "Muito ruim", label: "negativo"),
            ],
            trainer: trainer
        )

        let result = await intelligence.trainingTextClassifier(
            id: "sentiment",
            name: "Sentiment"
        )

        guard case .saved(let model) = result else {
            return XCTFail("Expected saved model result.")
        }

        XCTAssertEqual(model.kind, PrismIntelligenceModelKind.textClassifier)
        XCTAssertEqual(model.engine, PrismIntelligenceEngineKind.createML)
        XCTAssertEqual(model.accuracy, 0.95)
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: tempDirectory.appendingPathComponent("sentiment.mlmodel").path
            )
        )
    }

    func testTextIntelligenceFailsFastWhenRowsAreInvalid() async {
        let intelligence = PrismTextIntelligence(
            data: [
                ["text": "ok", "label": "positivo"],
                ["text": "missing label"],
            ]
        )

        let result = await intelligence.trainingTextClassifier(
            id: "sentiment",
            name: "Sentiment"
        )

        guard case .failure(let error) = result else {
            return XCTFail("Expected failure for invalid rows.")
        }

        XCTAssertEqual(
            error,
            .invalidTrainingData("Found 1 invalid text training rows.")
        )
    }

    func testTabularIntelligenceSupportsClassifierAndRegressor() async {
        let suite = makeDefaultsSuite()
        let tempDirectory = makeTemporaryDirectory()
        defer {
            suite.userDefaults.removePersistentDomain(forName: suite.name)
            try? FileManager.default.removeItem(at: tempDirectory)
        }

        let trainer = PrismIntelligenceLocalTrainer(
            catalog: PrismIntelligenceCatalog(defaults: suite.defaults),
            fileManager: PrismFileManager(documentsURL: tempDirectory),
            runtime: MockTrainingRuntime(
                regressionMetrics: .init(
                    accuracy: 0.82,
                    rootMeanSquaredError: 1.3
                ),
                classificationMetrics: .init(
                    accuracy: 0.88,
                    rootMeanSquaredError: 0.12
                )
            )
        )
        let intelligence = PrismTabularIntelligence(
            rows: [
                [
                    "feature": .double(1.2),
                    "target": .double(4.5),
                ]
            ],
            trainer: trainer
        )

        let classifier = await intelligence.trainingClassifier(
            id: "classifier",
            name: "Classifier"
        )
        let regressor = await intelligence.trainingRegressor(
            id: "regressor",
            name: "Regressor"
        )

        guard case .saved(let classifierModel) = classifier else {
            return XCTFail("Expected saved classifier model.")
        }
        guard case .saved(let regressorModel) = regressor else {
            return XCTFail("Expected saved regressor model.")
        }

        XCTAssertEqual(classifierModel.kind, PrismIntelligenceModelKind.tabularClassifier)
        XCTAssertEqual(classifierModel.accuracy, 0.88)
        XCTAssertEqual(regressorModel.kind, PrismIntelligenceModelKind.tabularRegressor)
        XCTAssertEqual(regressorModel.rootMeanSquaredError, 1.3)
    }

    func testPredictionFacadeRoutesToRuntimeAndUsesInjectedStorage() async throws {
        let tempDirectory = makeTemporaryDirectory()
        defer {
            try? FileManager.default.removeItem(at: tempDirectory)
        }

        let predictor = await PrismIntelligencePrediction(
            model: PrismIntelligenceModel(
                id: "local",
                name: "Local",
                artifactName: "local.mlmodel"
            ),
            fileManager: PrismFileManager(documentsURL: tempDirectory),
            runtime: MockPredictionRuntime()
        )

        let regression = try await predictor.predictRegression(
            from: ["value": PrismIntelligenceFeatureValue.double(3.14)]
        )
        let classifier = try await predictor.predictClassifier(
            from: ["value": PrismIntelligenceFeatureValue.double(3.14)]
        )
        let text = try await predictor.predictText(from: "hello")

        XCTAssertEqual(regression, 7.5)
        XCTAssertEqual(classifier["positive"], 0.9)
        XCTAssertEqual(text, "positive")
    }

    func testLanguageIntelligenceStopsWhenProviderIsUnavailable() async {
        let intelligence = PrismLanguageIntelligence(
            provider: MockLanguageProvider(
                status: .init(
                    provider: .remote,
                    isAvailable: false,
                    reason: "offline"
                )
            )
        )

        do {
            _ = try await intelligence.generate(
                .init(prompt: "Hello")
            )
            XCTFail("Expected provider unavailable error.")
        } catch let error as PrismIntelligenceError {
            XCTAssertEqual(error, .providerUnavailable("offline"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAppleProviderDelegatesStatusAndGenerationToGateway() async throws {
        let provider = PrismAppleIntelligenceProvider(
            configuration: .init(),
            gateway: MockAppleGateway()
        )

        let status = await provider.status()
        let response = try await provider.generate(
            .init(
                prompt: "Summarize",
                systemPrompt: "Be concise"
            )
        )

        XCTAssertTrue(status.isAvailable)
        XCTAssertEqual(response.provider, .apple)
        XCTAssertEqual(response.content, "Apple response")
    }

    func testDefaultRemoteSerializerBuildsRequestAndParsesResponse() throws {
        let serializer = PrismDefaultRemoteIntelligenceSerializer(
            endpoint: URL(string: "https://example.com/inference")!,
            model: "gpt-x",
            providerName: "demo",
            headers: ["Authorization": "Bearer token"],
            timeout: 12
        )
        let request = try serializer.makeURLRequest(
            for: .init(
                prompt: "Hello",
                systemPrompt: "System",
                context: ["ctx"],
                options: .init(
                    temperature: 0.2,
                    maximumResponseTokens: 120
                ),
                metadata: ["user": "123"]
            )
        )

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.timeoutInterval, 12)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token")
        XCTAssertNotNil(request.httpBody)

        let response = HTTPURLResponse(
            url: URL(string: "https://example.com/inference")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let data = try JSONEncoder().encode(
            RemoteResponseFixture(
                text: "Remote response",
                model: "gpt-x",
                provider: "demo",
                finishReason: "stop",
                usage: .init(
                    promptTokens: 10,
                    completionTokens: 20,
                    totalTokens: 30
                )
            )
        )

        let decoded = try serializer.decodeResponse(
            data: data,
            response: response
        )

        XCTAssertEqual(decoded.content, "Remote response")
        XCTAssertEqual(decoded.model, "gpt-x")
        XCTAssertEqual(decoded.usage?.totalTokens, 30)
        XCTAssertEqual(decoded.metadata["provider"], "demo")
    }

    func testRemoteProviderMapsTransportFailures() async {
        let provider = PrismRemoteIntelligenceProvider(
            serializer: PrismDefaultRemoteIntelligenceSerializer(
                endpoint: URL(string: "https://example.com/inference")!
            ),
            transport: MockTransport(
                result: .failure(
                    URLError(.notConnectedToInternet)
                )
            )
        )

        do {
            _ = try await provider.generate(.init(prompt: "Hello"))
            XCTFail("Expected transport failure.")
        } catch let error as PrismIntelligenceError {
            guard case .networkFailure = error else {
                return XCTFail("Expected network failure.")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testUnifiedLocalClientReportsStatusAndExecutesConvenienceMethods() async throws {
        let tempDirectory = makeTemporaryDirectory()
        defer {
            try? FileManager.default.removeItem(at: tempDirectory)
        }

        let artifactURL = tempDirectory.appendingPathComponent("local.mlmodel")
        try Data("model".utf8).write(to: artifactURL)

        let client = PrismIntelligenceClient(
            localModel: PrismIntelligenceModel(
                id: "local",
                name: "Local",
                kind: .custom,
                engine: .coreML,
                artifactName: "local.mlmodel"
            ),
            fileManager: PrismFileManager(documentsURL: tempDirectory),
            service: MockUnifiedLocalService()
        )

        let status = await client.status()
        let text = try await client.classify(text: "hello")
        let scores = try await client.classify(
            features: ["value": 1.2]
        )
        let regression = try await client.regress(
            features: ["value": 2.4]
        )
        let response = try await client.execute(
            .classifyText("hello")
        )

        XCTAssertTrue(status.isAvailable)
        XCTAssertEqual(status.backend, .local)
        XCTAssertEqual(status.modelID, "local")
        XCTAssertEqual(
            status.capabilities,
            [
                .textClassification,
                .tabularClassification,
                .tabularRegression,
            ]
        )
        XCTAssertEqual(text, "positive")
        XCTAssertEqual(scores["positive"], 0.9)
        XCTAssertEqual(regression, 7.5)
        XCTAssertEqual(response.text, "positive")
    }

    func testUnifiedLanguageClientReportsStatusAndGeneratesFromPrompt() async throws {
        let client = PrismIntelligenceClient(
            languageService: MockUnifiedLanguageService(),
            backend: .apple,
            provider: .apple
        )

        let status = await client.status()
        let text = try await client.generate(
            "Summarize",
            systemPrompt: "Be concise",
            context: ["ctx"]
        )
        let response = try await client.execute(
            .generate(
                .init(prompt: "Summarize")
            )
        )

        XCTAssertTrue(status.isAvailable)
        XCTAssertEqual(status.backend, .apple)
        XCTAssertEqual(status.provider, .apple)
        XCTAssertEqual(status.capabilities, [.languageGeneration])
        XCTAssertEqual(text, "Unified response")
        XCTAssertEqual(response.text, "Unified response")
    }

    func testUnifiedClientFailsWhenUsingUnsupportedBackendOperation() async {
        let client = PrismIntelligenceClient(
            languageService: MockUnifiedLanguageService(),
            backend: .remote,
            provider: .remote
        )

        do {
            _ = try await client.classify(text: "hello")
            XCTFail("Expected unsupported operation.")
        } catch let error as PrismIntelligenceError {
            XCTAssertEqual(
                error,
                .unsupportedOperation(
                    "Text classification is not supported by the remote backend."
                )
            )
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testUnifiedLocalFactoryFailsForUnknownModelID() async {
        let suite = makeDefaultsSuite()
        defer {
            suite.userDefaults.removePersistentDomain(forName: suite.name)
        }

        do {
            _ = try await PrismIntelligenceClient.local(
                modelID: "missing",
                catalog: PrismIntelligenceCatalog(defaults: suite.defaults)
            )
            XCTFail("Expected missing model error.")
        } catch let error as PrismIntelligenceError {
            XCTAssertEqual(error, .modelNotFound("missing"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testUnifiedLocalClientRejectsInvalidUntypedFeatureDictionary() async {
        let client = PrismIntelligenceClient(
            localModel: PrismIntelligenceModel(
                id: "local",
                name: "Local",
                kind: .tabularClassifier,
                engine: .coreML,
                artifactName: "local.mlmodel"
            ),
            fileManager: PrismFileManager(documentsURL: makeTemporaryDirectory()),
            service: MockUnifiedLocalService()
        )

        do {
            _ = try await client.classify(
                features: ["invalid": Date()]
            )
            XCTFail("Expected unsupported input.")
        } catch let error as PrismIntelligenceError {
            XCTAssertEqual(
                error,
                .unsupportedInput(
                    "Could not convert feature dictionary into supported values."
                )
            )
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testUnifiedLocalClientRejectsLanguageGeneration() async {
        let client = PrismIntelligenceClient(
            localModel: PrismIntelligenceModel(
                id: "local",
                name: "Local",
                kind: .textClassifier,
                engine: .coreML,
                artifactName: "local.mlmodel"
            ),
            fileManager: PrismFileManager(documentsURL: makeTemporaryDirectory()),
            service: MockUnifiedLocalService()
        )

        do {
            _ = try await client.generate("Hello")
            XCTFail("Expected unsupported operation.")
        } catch let error as PrismIntelligenceError {
            XCTAssertEqual(
                error,
                .unsupportedOperation(
                    "Language generation is not supported by the local model local."
                )
            )
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testUnifiedLocalStatusReportsUnavailableWhenEngineIsNotLocalCompatible() async {
        let client = PrismIntelligenceClient(
            localModel: PrismIntelligenceModel(
                id: "remote-model",
                name: "Remote Model",
                kind: .custom,
                engine: .remote,
                artifactName: "remote-model.mlmodel"
            ),
            fileManager: PrismFileManager(documentsURL: makeTemporaryDirectory()),
            service: MockUnifiedLocalService()
        )

        let status = await client.status()

        XCTAssertFalse(status.isAvailable)
        XCTAssertEqual(
            status.reason,
            "Local inference only supports Core ML compatible models."
        )
    }

    func testIntelligenceErrorsExposeLocalizedDescriptions() {
        let errors: [PrismIntelligenceError] = [
            .invalidTrainingData("bad rows"),
            .unsupportedPlatform("unsupported"),
            .unsupportedOperation("not allowed"),
            .modelNotFound("model"),
            .artifactNotFound("artifact.mlmodel"),
            .unsupportedInput("bad input"),
            .predictionFailed("no output"),
            .trainingFailed("failed"),
            .providerUnavailable("offline"),
            .invalidResponse("bad"),
            .networkFailure("timeout"),
            .adapterFailure("adapter"),
            .underlying("plain"),
        ]

        XCTAssertEqual(
            errors.compactMap(\.errorDescription).count,
            errors.count
        )
        XCTAssertEqual(
            PrismIntelligenceError.unsupportedOperation("not allowed").errorDescription,
            "Unsupported operation: not allowed"
        )
    }
}

private struct DefaultsSuite {
    let name: String
    let userDefaults: UserDefaults
    let defaults: PrismDefaults
}

private func makeDefaultsSuite() -> DefaultsSuite {
    let name = "prism.tests.\(UUID().uuidString)"
    let userDefaults = UserDefaults(suiteName: name)!
    userDefaults.removePersistentDomain(forName: name)
    return DefaultsSuite(
        name: name,
        userDefaults: userDefaults,
        defaults: PrismDefaults(userDefaults: userDefaults)
    )
}

private func makeTemporaryDirectory() -> URL {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
    try? FileManager.default.createDirectory(
        at: url,
        withIntermediateDirectories: true
    )
    return url
}

private actor MockTrainingRuntime: PrismIntelligenceTrainingRuntime {
    let textMetrics: PrismIntelligenceModelMetrics
    let regressionMetrics: PrismIntelligenceModelMetrics
    let classificationMetrics: PrismIntelligenceModelMetrics

    init(
        textMetrics: PrismIntelligenceModelMetrics = .init(),
        regressionMetrics: PrismIntelligenceModelMetrics = .init(),
        classificationMetrics: PrismIntelligenceModelMetrics = .init()
    ) {
        self.textMetrics = textMetrics
        self.regressionMetrics = regressionMetrics
        self.classificationMetrics = classificationMetrics
    }

    func trainTextClassifier(
        data: [PrismTextTrainingSample],
        configuration: PrismTextTrainingConfiguration,
        destination: URL
    ) async throws -> PrismIntelligenceModelMetrics {
        try Data("text".utf8).write(to: destination)
        return textMetrics
    }

    func trainTabularRegressor(
        data: [PrismIntelligenceFeatureRow],
        configuration: PrismTabularTrainingConfiguration,
        destination: URL
    ) async throws -> PrismIntelligenceModelMetrics {
        try Data("regressor".utf8).write(to: destination)
        return regressionMetrics
    }

    func trainTabularClassifier(
        data: [PrismIntelligenceFeatureRow],
        configuration: PrismTabularTrainingConfiguration,
        destination: URL
    ) async throws -> PrismIntelligenceModelMetrics {
        try Data("classifier".utf8).write(to: destination)
        return classificationMetrics
    }
}

private struct MockPredictionRuntime: PrismIntelligencePredictionRuntime {
    func regressionPrediction(
        modelURL: URL,
        features: PrismIntelligenceFeatureRow
    ) async throws -> Double {
        7.5
    }

    func classifierPrediction(
        modelURL: URL,
        features: PrismIntelligenceFeatureRow
    ) async throws -> [String: Double] {
        ["positive": 0.9, "negative": 0.1]
    }

    func textPrediction(
        modelURL: URL,
        text: String
    ) async throws -> String {
        "positive"
    }
}

private struct MockLanguageProvider: PrismLanguageIntelligenceProvider {
    let kind: PrismLanguageIntelligenceProviderKind = .remote
    let status: PrismLanguageIntelligenceStatus

    func status() async -> PrismLanguageIntelligenceStatus {
        status
    }

    func generate(
        _ request: PrismLanguageIntelligenceRequest
    ) async throws -> PrismLanguageIntelligenceResponse {
        PrismLanguageIntelligenceResponse(
            provider: .remote,
            content: "mock"
        )
    }
}

private struct MockAppleGateway: PrismAppleIntelligenceGateway {
    func status(
        configuration: PrismAppleIntelligenceConfiguration
    ) async -> PrismLanguageIntelligenceStatus {
        PrismLanguageIntelligenceStatus(
            provider: .apple,
            isAvailable: true,
            supportsStreaming: true,
            supportsCustomInstructions: true,
            supportsModelAdapters: true
        )
    }

    func generate(
        request: PrismLanguageIntelligenceRequest,
        configuration: PrismAppleIntelligenceConfiguration
    ) async throws -> PrismLanguageIntelligenceResponse {
        PrismLanguageIntelligenceResponse(
            provider: .apple,
            model: "apple.general",
            content: "Apple response"
        )
    }
}

private struct MockTransport: PrismRemoteIntelligenceTransport {
    let result: Result<(Data, URLResponse), Error>

    func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse) {
        try result.get()
    }
}

private actor MockUnifiedLocalService: PrismIntelligenceLocalServing {
    func predictText(
        from text: String
    ) async throws -> String {
        "positive"
    }

    func predictClassifier(
        from features: PrismIntelligenceFeatureRow
    ) async throws -> [String: Double] {
        ["positive": 0.9, "negative": 0.1]
    }

    func predictRegression(
        from features: PrismIntelligenceFeatureRow
    ) async throws -> Double {
        7.5
    }
}

private actor MockUnifiedLanguageService: PrismLanguageIntelligenceServing {
    func status() async -> PrismLanguageIntelligenceStatus {
        PrismLanguageIntelligenceStatus(
            provider: .apple,
            isAvailable: true,
            supportsCustomInstructions: true
        )
    }

    func generate(
        _ request: PrismLanguageIntelligenceRequest
    ) async throws -> PrismLanguageIntelligenceResponse {
        PrismLanguageIntelligenceResponse(
            provider: .apple,
            model: "apple.general",
            content: "Unified response"
        )
    }
}

private struct RemoteResponseFixture: Encodable {
    let text: String
    let model: String
    let provider: String
    let finishReason: String
    let usage: PrismLanguageTokenUsage
}
