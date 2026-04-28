import Testing
import Foundation
@testable import PrismServer

@Suite("PrismAppError Tests")
struct PrismAppErrorTests {

    @Test("BadRequest factory")
    func badRequest() {
        let error = PrismAppError.badRequest("Invalid input")
        #expect(error.statusCode == .badRequest)
        #expect(error.errorCode == "BAD_REQUEST")
        #expect(error.message == "Invalid input")
    }

    @Test("Unauthorized factory")
    func unauthorized() {
        let error = PrismAppError.unauthorized()
        #expect(error.statusCode == .unauthorized)
        #expect(error.errorCode == "UNAUTHORIZED")
        #expect(error.message == "Unauthorized")
    }

    @Test("Forbidden factory")
    func forbidden() {
        let error = PrismAppError.forbidden()
        #expect(error.statusCode == .forbidden)
        #expect(error.errorCode == "FORBIDDEN")
    }

    @Test("NotFound factory")
    func notFound() {
        let error = PrismAppError.notFound()
        #expect(error.statusCode == .notFound)
        #expect(error.errorCode == "NOT_FOUND")
    }

    @Test("Conflict factory")
    func conflict() {
        let error = PrismAppError.conflict("Duplicate entry")
        #expect(error.statusCode == .conflict)
        #expect(error.errorCode == "CONFLICT")
        #expect(error.message == "Duplicate entry")
    }

    @Test("InternalError factory")
    func internalError() {
        let error = PrismAppError.internalError()
        #expect(error.statusCode == .internalServerError)
        #expect(error.errorCode == "INTERNAL_ERROR")
    }

    @Test("Custom error code")
    func customCode() {
        let error = PrismAppError.badRequest("Bad", code: "VALIDATION_FAILED")
        #expect(error.errorCode == "VALIDATION_FAILED")
    }

    @Test("Error with details")
    func withDetails() {
        let error = PrismAppError(status: .badRequest, code: "VALIDATION", message: "Invalid", details: ["field": "email"])
        #expect(error.details?["field"] == "email")
    }

    @Test("toResponse returns correct status code")
    func toResponseStatus() {
        let error = PrismAppError.notFound("User not found")
        let response = error.toResponse()
        #expect(response.status == .notFound)
    }

    @Test("Default details is nil")
    func defaultDetailsNil() {
        let error = PrismAppError.badRequest("test")
        #expect(error.details == nil)
    }
}

@Suite("PrismErrorMiddleware Tests")
struct PrismErrorMiddlewareTests {

    @Test("Passes through successful responses")
    func passThrough() async throws {
        let middleware = PrismErrorMiddleware()
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
    }

    @Test("Catches PrismHTTPErrorResponse")
    func catchesHTTPError() async throws {
        let middleware = PrismErrorMiddleware()
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in
            throw PrismAppError.notFound("Not found")
        }
        #expect(response.status == .notFound)
    }

    @Test("Catches unknown errors as 500")
    func catchesUnknownError() async throws {
        let middleware = PrismErrorMiddleware()
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in
            throw TestError.somethingWentWrong
        }
        #expect(response.status == .internalServerError)
    }

    @Test("IncludeStackTrace adds debug info")
    func stackTrace() async throws {
        let middleware = PrismErrorMiddleware(includeStackTrace: true)
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in
            throw TestError.somethingWentWrong
        }
        #expect(response.status == .internalServerError)
    }

    @Test("Custom handler intercepts errors")
    func customHandler() async throws {
        let middleware = PrismErrorMiddleware { error, _ in
            return .text("custom error", status: .badGateway)
        }
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in
            throw TestError.somethingWentWrong
        }
        #expect(response.status == .badGateway)
    }

    @Test("Custom handler returns nil falls through to default")
    func customHandlerNil() async throws {
        let middleware = PrismErrorMiddleware { _, _ in nil }
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in
            throw TestError.somethingWentWrong
        }
        #expect(response.status == .internalServerError)
    }
}

@Suite("PrismProblemDetails Tests")
struct PrismProblemDetailsTests {

    @Test("Default type is about:blank")
    func defaultType() {
        let problem = PrismProblemDetails(title: "Error", status: 400)
        #expect(problem.type == "about:blank")
    }

    @Test("toResponse sets correct status")
    func toResponseStatus() {
        let problem = PrismProblemDetails(title: "Not Found", status: 404, detail: "User 42 not found")
        let response = problem.toResponse()
        #expect(response.status.code == 404)
    }

    @Test("toResponse sets application/problem+json content type")
    func contentType() {
        let problem = PrismProblemDetails(title: "Error", status: 400)
        let response = problem.toResponse()
        #expect(response.headers.value(for: "Content-Type") == "application/problem+json")
    }

    @Test("Full problem details")
    func fullDetails() {
        let problem = PrismProblemDetails(
            type: "https://example.com/errors/validation",
            title: "Validation Error",
            status: 422,
            detail: "Field X is required",
            instance: "/api/users"
        )
        #expect(problem.type == "https://example.com/errors/validation")
        #expect(problem.title == "Validation Error")
        #expect(problem.status == 422)
        #expect(problem.detail == "Field X is required")
        #expect(problem.instance == "/api/users")
    }

    @Test("Nil detail and instance")
    func nilOptionals() {
        let problem = PrismProblemDetails(title: "Error", status: 500)
        #expect(problem.detail == nil)
        #expect(problem.instance == nil)
    }
}

private enum TestError: Error {
    case somethingWentWrong
}
