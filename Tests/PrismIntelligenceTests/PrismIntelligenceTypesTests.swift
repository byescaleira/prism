//
//  PrismIntelligenceTypesTests.swift
//  Prism
//
//  Created by Rafael Escaleira on 05/05/26.
//

import Foundation
import Testing

@testable import PrismIntelligence

// MARK: - PrismIntelligenceBackendKind

@Suite("PrismIntelligenceBackendKind")
struct PrismIntelligenceBackendKindTests {
    @Test("Has exactly 3 cases: local, apple, remote")
    func hasThreeCases() {
        let allCases = PrismIntelligenceBackendKind.allCases
        #expect(allCases.count == 3)
        #expect(allCases.contains(.local))
        #expect(allCases.contains(.apple))
        #expect(allCases.contains(.remote))
    }

    @Test("Codable round-trip preserves each case")
    func codableRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for kind in PrismIntelligenceBackendKind.allCases {
            let data = try encoder.encode(kind)
            let decoded = try decoder.decode(PrismIntelligenceBackendKind.self, from: data)
            #expect(decoded == kind)
        }
    }
}

// MARK: - PrismIntelligenceCapability

@Suite("PrismIntelligenceCapability")
struct PrismIntelligenceCapabilityTests {
    @Test("Has exactly 4 cases")
    func hasFourCases() {
        let allCases = PrismIntelligenceCapability.allCases
        #expect(allCases.count == 4)
        #expect(allCases.contains(.textClassification))
        #expect(allCases.contains(.tabularClassification))
        #expect(allCases.contains(.tabularRegression))
        #expect(allCases.contains(.languageGeneration))
    }

    @Test("Codable round-trip preserves each case")
    func codableRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for capability in PrismIntelligenceCapability.allCases {
            let data = try encoder.encode(capability)
            let decoded = try decoder.decode(PrismIntelligenceCapability.self, from: data)
            #expect(decoded == capability)
        }
    }
}

// MARK: - PrismIntelligenceStatus

@Suite("PrismIntelligenceStatus")
struct PrismIntelligenceStatusTests {
    @Test("Init with all parameters preserves values")
    func initPreservesAllValues() {
        let status = PrismIntelligenceStatus(
            backend: .apple,
            isAvailable: true,
            reason: "ready",
            capabilities: [.textClassification, .languageGeneration],
            modelID: "model-1",
            modelName: "Test Model",
            provider: .apple,
            supportsStreaming: true,
            supportsCustomInstructions: true,
            supportsModelAdapters: true
        )

        #expect(status.backend == .apple)
        #expect(status.isAvailable == true)
        #expect(status.reason == "ready")
        #expect(status.capabilities == [.textClassification, .languageGeneration])
        #expect(status.modelID == "model-1")
        #expect(status.modelName == "Test Model")
        #expect(status.provider == .apple)
        #expect(status.supportsStreaming == true)
        #expect(status.supportsCustomInstructions == true)
        #expect(status.supportsModelAdapters == true)
    }

    @Test("Default boolean parameters are false")
    func defaultBooleansAreFalse() {
        let status = PrismIntelligenceStatus(
            backend: .local,
            isAvailable: false,
            capabilities: []
        )

        #expect(status.supportsStreaming == false)
        #expect(status.supportsCustomInstructions == false)
        #expect(status.supportsModelAdapters == false)
        #expect(status.reason == nil)
        #expect(status.modelID == nil)
        #expect(status.modelName == nil)
        #expect(status.provider == nil)
    }

    @Test("Equatable conformance")
    func equatable() {
        let a = PrismIntelligenceStatus(
            backend: .remote,
            isAvailable: true,
            capabilities: [.tabularRegression]
        )
        let b = PrismIntelligenceStatus(
            backend: .remote,
            isAvailable: true,
            capabilities: [.tabularRegression]
        )
        let c = PrismIntelligenceStatus(
            backend: .local,
            isAvailable: false,
            capabilities: []
        )

        #expect(a == b)
        #expect(a != c)
    }

    @Test("Hashable conformance")
    func hashable() {
        let a = PrismIntelligenceStatus(
            backend: .apple,
            isAvailable: true,
            capabilities: [.languageGeneration]
        )
        let b = PrismIntelligenceStatus(
            backend: .apple,
            isAvailable: true,
            capabilities: [.languageGeneration]
        )

        #expect(a.hashValue == b.hashValue)

        var set = Set<PrismIntelligenceStatus>()
        set.insert(a)
        set.insert(b)
        #expect(set.count == 1)
    }

    @Test("Codable round-trip")
    func codableRoundTrip() throws {
        let status = PrismIntelligenceStatus(
            backend: .remote,
            isAvailable: true,
            reason: "ok",
            capabilities: [.textClassification, .tabularClassification],
            modelID: "m-1",
            modelName: "Model",
            provider: .remote,
            supportsStreaming: true,
            supportsCustomInstructions: false,
            supportsModelAdapters: true
        )

        let data = try JSONEncoder().encode(status)
        let decoded = try JSONDecoder().decode(PrismIntelligenceStatus.self, from: data)
        #expect(decoded == status)
    }
}

// MARK: - PrismIntelligenceRequest

@Suite("PrismIntelligenceRequest")
struct PrismIntelligenceRequestTests {
    @Test("classifyText stores the correct associated value")
    func classifyTextAssociatedValue() {
        let request = PrismIntelligenceRequest.classifyText("hello world")
        if case .classifyText(let text) = request {
            #expect(text == "hello world")
        } else {
            Issue.record("Expected .classifyText case")
        }
    }

    @Test("classifyFeatures stores the correct associated value")
    func classifyFeaturesAssociatedValue() {
        let features: PrismIntelligenceFeatureRow = [
            "age": .int(30),
            "score": .double(0.85),
        ]
        let request = PrismIntelligenceRequest.classifyFeatures(features)
        if case .classifyFeatures(let row) = request {
            #expect(row == features)
        } else {
            Issue.record("Expected .classifyFeatures case")
        }
    }

    @Test("regressFeatures stores the correct associated value")
    func regressFeaturesAssociatedValue() {
        let features: PrismIntelligenceFeatureRow = [
            "area": .double(120.5)
        ]
        let request = PrismIntelligenceRequest.regressFeatures(features)
        if case .regressFeatures(let row) = request {
            #expect(row == features)
        } else {
            Issue.record("Expected .regressFeatures case")
        }
    }

    @Test("generate stores the correct associated value")
    func generateAssociatedValue() {
        let langRequest = PrismLanguageIntelligenceRequest(
            prompt: "Summarize this",
            systemPrompt: "Be brief"
        )
        let request = PrismIntelligenceRequest.generate(langRequest)
        if case .generate(let inner) = request {
            #expect(inner == langRequest)
        } else {
            Issue.record("Expected .generate case")
        }
    }

    @Test("Equatable conformance")
    func equatable() {
        let a = PrismIntelligenceRequest.classifyText("test")
        let b = PrismIntelligenceRequest.classifyText("test")
        let c = PrismIntelligenceRequest.classifyText("other")
        let d = PrismIntelligenceRequest.regressFeatures(["x": .int(1)])

        #expect(a == b)
        #expect(a != c)
        #expect(a != d)
    }
}

// MARK: - PrismIntelligenceResponse

@Suite("PrismIntelligenceResponse")
struct PrismIntelligenceResponseTests {
    @Test("text returns label for textClassification")
    func textReturnsLabelForTextClassification() {
        let response = PrismIntelligenceResponse.textClassification("positive")
        #expect(response.text == "positive")
    }

    @Test("text returns content for language case")
    func textReturnsContentForLanguage() {
        let langResponse = PrismLanguageIntelligenceResponse(
            id: "resp-1",
            provider: .remote,
            content: "Generated text",
            createDate: 0
        )
        let response = PrismIntelligenceResponse.language(langResponse)
        #expect(response.text == "Generated text")
    }

    @Test("text returns nil for tabularClassification")
    func textReturnsNilForTabularClassification() {
        let response = PrismIntelligenceResponse.tabularClassification(
            ["cat": 0.8, "dog": 0.2]
        )
        #expect(response.text == nil)
    }

    @Test("text returns nil for tabularRegression")
    func textReturnsNilForTabularRegression() {
        let response = PrismIntelligenceResponse.tabularRegression(42.5)
        #expect(response.text == nil)
    }

    @Test("Equatable conformance")
    func equatable() {
        let a = PrismIntelligenceResponse.textClassification("pos")
        let b = PrismIntelligenceResponse.textClassification("pos")
        let c = PrismIntelligenceResponse.tabularRegression(1.0)

        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - PrismIntelligenceResult

@Suite("PrismIntelligenceResult")
struct PrismIntelligenceResultTests {
    @Test("error case exists")
    func errorCaseExists() {
        let result = PrismIntelligenceResult.error
        if case .error = result {
            // pass
        } else {
            Issue.record("Expected .error case")
        }
    }

    @Test("saved case stores model")
    func savedCaseStoresModel() {
        let model = PrismIntelligenceModel(id: "m1", name: "Model 1")
        let result = PrismIntelligenceResult.saved(model: model)
        if case .saved(let stored) = result {
            #expect(stored.id == "m1")
            #expect(stored.name == "Model 1")
        } else {
            Issue.record("Expected .saved case")
        }
    }

    @Test("failure case stores error")
    func failureCaseStoresError() {
        let error = PrismIntelligenceError.trainingFailed("out of memory")
        let result = PrismIntelligenceResult.failure(error)
        if case .failure(let stored) = result {
            #expect(stored == error)
        } else {
            Issue.record("Expected .failure case")
        }
    }

    @Test("Equatable conformance")
    func equatable() {
        let a = PrismIntelligenceResult.error
        let b = PrismIntelligenceResult.error
        let c = PrismIntelligenceResult.failure(.modelNotFound("x"))
        let d = PrismIntelligenceResult.failure(.modelNotFound("x"))

        #expect(a == b)
        #expect(c == d)
        #expect(a != c)
    }
}

// MARK: - PrismTextTrainingConfiguration

@Suite("PrismTextTrainingConfiguration")
struct PrismTextTrainingConfigurationTests {
    @Test("Init stores id and name")
    func initStoresIdAndName() {
        let config = PrismTextTrainingConfiguration(id: "tc-1", name: "Sentiment")
        #expect(config.id == "tc-1")
        #expect(config.name == "Sentiment")
    }

    @Test("Optional fields default to nil")
    func optionalFieldsDefaultToNil() {
        let config = PrismTextTrainingConfiguration(id: "tc-1", name: "Sentiment")
        #expect(config.localeIdentifier == nil)
        #expect(config.maxIterations == nil)
    }

    @Test("Custom optional values are preserved")
    func customOptionalValues() {
        let config = PrismTextTrainingConfiguration(
            id: "tc-2",
            name: "French Classifier",
            localeIdentifier: "fr_FR",
            maxIterations: 500
        )
        #expect(config.localeIdentifier == "fr_FR")
        #expect(config.maxIterations == 500)
    }

    @Test("Equatable conformance")
    func equatable() {
        let a = PrismTextTrainingConfiguration(id: "x", name: "X")
        let b = PrismTextTrainingConfiguration(id: "x", name: "X")
        let c = PrismTextTrainingConfiguration(id: "y", name: "Y")

        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - PrismTabularTrainingConfiguration

@Suite("PrismTabularTrainingConfiguration")
struct PrismTabularTrainingConfigurationTests {
    @Test("Default values match expected constants")
    func defaultValues() {
        let config = PrismTabularTrainingConfiguration(id: "tab-1", name: "Default")

        #expect(config.targetColumn == "target")
        #expect(config.maxDepth == 20)
        #expect(config.maxIterations == 10_000)
        #expect(config.minLossReduction == 0)
        #expect(config.minChildWeight == 0.01)
        #expect(config.randomSeed == 42)
        #expect(config.stepSize == 0.01)
        #expect(config.rowSubsample == 1.0)
        #expect(config.columnSubsample == 1.0)
        #expect(config.featureColumns == nil)
        #expect(config.earlyStoppingRounds == nil)
    }

    @Test("Custom values are preserved")
    func customValuesPreserved() {
        let config = PrismTabularTrainingConfiguration(
            id: "tab-2",
            name: "Custom",
            targetColumn: "price",
            maxDepth: 10,
            maxIterations: 5_000,
            minLossReduction: 0.1,
            minChildWeight: 0.05,
            randomSeed: 7,
            stepSize: 0.05,
            featureColumns: ["rooms", "area"],
            earlyStoppingRounds: 3,
            rowSubsample: 0.8,
            columnSubsample: 0.7
        )

        #expect(config.id == "tab-2")
        #expect(config.name == "Custom")
        #expect(config.targetColumn == "price")
        #expect(config.maxDepth == 10)
        #expect(config.maxIterations == 5_000)
        #expect(config.minLossReduction == 0.1)
        #expect(config.minChildWeight == 0.05)
        #expect(config.randomSeed == 7)
        #expect(config.stepSize == 0.05)
        #expect(config.featureColumns == ["rooms", "area"])
        #expect(config.earlyStoppingRounds == 3)
        #expect(config.rowSubsample == 0.8)
        #expect(config.columnSubsample == 0.7)
    }

    @Test("Equatable conformance")
    func equatable() {
        let a = PrismTabularTrainingConfiguration(id: "t", name: "T")
        let b = PrismTabularTrainingConfiguration(id: "t", name: "T")
        let c = PrismTabularTrainingConfiguration(
            id: "t",
            name: "T",
            maxDepth: 5
        )

        #expect(a == b)
        #expect(a != c)
    }
}
