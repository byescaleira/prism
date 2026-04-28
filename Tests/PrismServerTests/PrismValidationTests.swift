import Testing
import Foundation
@testable import PrismServer

@Suite("PrismValidationRule Tests")
struct PrismValidationRuleTests {

    @Test("Required rule rejects nil")
    func requiredNil() {
        let result = PrismValidationRule.required.validate(nil)
        #expect(result == "is required")
    }

    @Test("Required rule rejects empty string")
    func requiredEmpty() {
        let result = PrismValidationRule.required.validate("")
        #expect(result == "is required")
    }

    @Test("Required rule accepts value")
    func requiredValid() {
        let result = PrismValidationRule.required.validate("hello")
        #expect(result == nil)
    }

    @Test("Email rule accepts valid email")
    func emailValid() {
        let result = PrismValidationRule.email.validate("user@example.com")
        #expect(result == nil)
    }

    @Test("Email rule rejects invalid email")
    func emailInvalid() {
        let result = PrismValidationRule.email.validate("not-an-email")
        #expect(result == "must be a valid email")
    }

    @Test("Email rule skips nil")
    func emailNil() {
        let result = PrismValidationRule.email.validate(nil)
        #expect(result == nil)
    }

    @Test("MinLength accepts long enough string")
    func minLengthValid() {
        let result = PrismValidationRule.minLength(3).validate("abc")
        #expect(result == nil)
    }

    @Test("MinLength rejects short string")
    func minLengthInvalid() {
        let result = PrismValidationRule.minLength(5).validate("ab")
        #expect(result == "must be at least 5 characters")
    }

    @Test("MaxLength accepts short enough string")
    func maxLengthValid() {
        let result = PrismValidationRule.maxLength(5).validate("abc")
        #expect(result == nil)
    }

    @Test("MaxLength rejects long string")
    func maxLengthInvalid() {
        let result = PrismValidationRule.maxLength(2).validate("abc")
        #expect(result == "must be at most 2 characters")
    }

    @Test("Integer rule accepts valid integer")
    func integerValid() {
        let result = PrismValidationRule.integer.validate("42")
        #expect(result == nil)
    }

    @Test("Integer rule rejects non-integer")
    func integerInvalid() {
        let result = PrismValidationRule.integer.validate("abc")
        #expect(result == "must be an integer")
    }

    @Test("Numeric rule accepts decimal")
    func numericValid() {
        let result = PrismValidationRule.numeric.validate("3.14")
        #expect(result == nil)
    }

    @Test("Numeric rule rejects non-numeric")
    func numericInvalid() {
        let result = PrismValidationRule.numeric.validate("abc")
        #expect(result == "must be a number")
    }

    @Test("Min rule accepts value at minimum")
    func minValid() {
        let result = PrismValidationRule.min(10).validate("10")
        #expect(result == nil)
    }

    @Test("Min rule rejects value below minimum")
    func minInvalid() {
        let result = PrismValidationRule.min(10).validate("5")
        #expect(result == "must be at least 10")
    }

    @Test("Max rule accepts value at maximum")
    func maxValid() {
        let result = PrismValidationRule.max(100).validate("100")
        #expect(result == nil)
    }

    @Test("Max rule rejects value above maximum")
    func maxInvalid() {
        let result = PrismValidationRule.max(10).validate("20")
        #expect(result == "must be at most 10")
    }

    @Test("Pattern rule accepts matching value")
    func patternValid() {
        let result = PrismValidationRule.pattern(#"^\d{3}$"#).validate("123")
        #expect(result == nil)
    }

    @Test("Pattern rule rejects non-matching value")
    func patternInvalid() {
        let result = PrismValidationRule.pattern(#"^\d{3}$"#, "must be 3 digits").validate("ab")
        #expect(result == "must be 3 digits")
    }

    @Test("OneOf accepts allowed value")
    func oneOfValid() {
        let result = PrismValidationRule.oneOf(["a", "b", "c"]).validate("b")
        #expect(result == nil)
    }

    @Test("OneOf rejects disallowed value")
    func oneOfInvalid() {
        let result = PrismValidationRule.oneOf(["a", "b"]).validate("z")
        #expect(result != nil)
    }

    @Test("URL rule accepts valid URL")
    func urlValid() {
        let result = PrismValidationRule.url.validate("https://example.com")
        #expect(result == nil)
    }

    @Test("URL rule rejects invalid URL")
    func urlInvalid() {
        let result = PrismValidationRule.url.validate("not-a-url")
        #expect(result == "must be a valid URL")
    }

    @Test("UUID rule accepts valid UUID")
    func uuidValid() {
        let result = PrismValidationRule.uuid.validate("550e8400-e29b-41d4-a716-446655440000")
        #expect(result == nil)
    }

    @Test("UUID rule rejects invalid UUID")
    func uuidInvalid() {
        let result = PrismValidationRule.uuid.validate("not-a-uuid")
        #expect(result == "must be a valid UUID")
    }
}

@Suite("PrismValidator Tests")
struct PrismValidatorTests {

    @Test("Validates multiple fields")
    func multipleFields() {
        var validator = PrismValidator()
        validator.field("name", .required, .minLength(2))
        validator.field("email", .required, .email)

        let result = validator.validate(["name": "A", "email": "bad"])
        #expect(!result.isValid)
        #expect(result.errors["name"] != nil)
        #expect(result.errors["email"] != nil)
    }

    @Test("Returns valid result when all pass")
    func allPass() {
        var validator = PrismValidator()
        validator.field("name", .required)
        validator.field("age", .integer)

        let result = validator.validate(["name": "John", "age": "30"])
        #expect(result.isValid)
        #expect(result.errors.isEmpty)
    }

    @Test("allErrors flattens messages")
    func allErrorsFlat() {
        var validator = PrismValidator()
        validator.field("x", .required)
        validator.field("y", .required)

        let result = validator.validate([:])
        #expect(result.allErrors.count == 2)
    }

    @Test("errorResponse returns nil when valid")
    func errorResponseNil() {
        var validator = PrismValidator()
        validator.field("name", .required)
        let result = validator.validate(["name": "ok"])
        #expect(result.errorResponse() == nil)
    }

    @Test("errorResponse returns 422 when invalid")
    func errorResponse422() {
        var validator = PrismValidator()
        validator.field("name", .required)
        let result = validator.validate([:])
        let response = result.errorResponse()
        #expect(response != nil)
        #expect(response?.status == .unprocessableEntity)
    }
}
