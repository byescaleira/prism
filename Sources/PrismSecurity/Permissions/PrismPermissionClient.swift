#if canImport(AVFoundation) && canImport(Photos) && canImport(Contacts)
    import AVFoundation
    import Contacts
    import Foundation
    import Photos

    #if canImport(CoreBluetooth)
        import CoreBluetooth
    #endif

    #if canImport(CoreLocation)
        import CoreLocation
    #endif

    #if canImport(CoreMotion)
        import CoreMotion
    #endif

    #if canImport(EventKit)
        import EventKit
    #endif

    #if canImport(Speech)
        import Speech
    #endif

    #if canImport(UserNotifications)
        import UserNotifications
    #endif

    #if canImport(AppTrackingTransparency)
        import AppTrackingTransparency
    #endif

    #if canImport(LocalAuthentication)
        import LocalAuthentication
    #endif

    #if canImport(MediaPlayer)
        import MediaPlayer
    #endif

    /// Unified client for checking and requesting system permissions.
    public final class PrismPermissionClient: Sendable {
        public init() {}

        /// Checks current authorization status for a permission.
        public func status(for permission: PrismPermission) -> PrismPermissionStatus {
            switch permission {
            case .camera:
                mapAVStatus(AVCaptureDevice.authorizationStatus(for: .video))
            case .microphone:
                mapAVStatus(AVCaptureDevice.authorizationStatus(for: .audio))
            case .photoLibrary:
                mapPHStatus(PHPhotoLibrary.authorizationStatus(for: .readWrite))
            case .photoLibraryAddOnly:
                mapPHStatus(PHPhotoLibrary.authorizationStatus(for: .addOnly))
            case .contacts:
                mapCNStatus(CNContactStore.authorizationStatus(for: .contacts))
            #if canImport(EventKit)
            case .calendars:
                mapEKStatus(EKEventStore.authorizationStatus(for: .event))
            case .reminders:
                mapEKStatus(EKEventStore.authorizationStatus(for: .reminder))
            #endif
            #if canImport(Speech)
            case .speechRecognition:
                mapSpeechStatus(SFSpeechRecognizer.authorizationStatus())
            #endif
            #if canImport(LocalAuthentication)
            case .faceID:
                checkBiometricStatus()
            #endif
            default:
                .notDetermined
            }
        }

        /// Requests authorization for a permission.
        @discardableResult
        public func request(_ permission: PrismPermission) async throws -> PrismPermissionStatus {
            switch permission {
            case .camera:
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                return granted ? .authorized : .denied
            case .microphone:
                let granted = await AVCaptureDevice.requestAccess(for: .audio)
                return granted ? .authorized : .denied
            case .photoLibrary:
                let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                return mapPHStatus(status)
            case .photoLibraryAddOnly:
                let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
                return mapPHStatus(status)
            case .contacts:
                return try await requestContacts()
            #if canImport(EventKit)
            case .calendars:
                return try await requestEventKit(.event)
            case .reminders:
                return try await requestEventKit(.reminder)
            #endif
            #if canImport(UserNotifications)
            case .notifications:
                return try await requestNotifications()
            #endif
            #if canImport(Speech)
            case .speechRecognition:
                return await requestSpeechRecognition()
            #endif
            #if canImport(AppTrackingTransparency)
            case .tracking:
                return await requestTracking()
            #endif
            #if canImport(LocalAuthentication)
            case .faceID:
                return try await requestBiometric()
            #endif
            default:
                throw PrismSecurityError.permissionNotAvailable(permission.rawValue)
            }
        }

        /// Requests multiple permissions sequentially.
        public func request(_ permissions: [PrismPermission]) async throws -> [PrismPermission: PrismPermissionStatus] {
            var results: [PrismPermission: PrismPermissionStatus] = [:]
            for permission in permissions {
                results[permission] = try await request(permission)
            }
            return results
        }

        /// Checks multiple permissions at once.
        public func statuses(for permissions: [PrismPermission]) -> [PrismPermission: PrismPermissionStatus] {
            var results: [PrismPermission: PrismPermissionStatus] = [:]
            for permission in permissions {
                results[permission] = status(for: permission)
            }
            return results
        }

        // MARK: - Private Mappers

        private func mapAVStatus(_ status: AVAuthorizationStatus) -> PrismPermissionStatus {
            switch status {
            case .notDetermined: .notDetermined
            case .authorized: .authorized
            case .denied: .denied
            case .restricted: .restricted
            @unknown default: .notDetermined
            }
        }

        private func mapPHStatus(_ status: PHAuthorizationStatus) -> PrismPermissionStatus {
            switch status {
            case .notDetermined: .notDetermined
            case .authorized: .authorized
            case .denied: .denied
            case .restricted: .restricted
            case .limited: .limited
            @unknown default: .notDetermined
            }
        }

        private func mapCNStatus(_ status: CNAuthorizationStatus) -> PrismPermissionStatus {
            switch status {
            case .notDetermined: .notDetermined
            case .authorized: .authorized
            case .denied: .denied
            case .restricted: .restricted
            case .limited: .limited
            @unknown default: .notDetermined
            }
        }

        #if canImport(EventKit)
            private func mapEKStatus(_ status: EKAuthorizationStatus) -> PrismPermissionStatus {
                switch status {
                case .notDetermined: .notDetermined
                case .fullAccess, .writeOnly: .authorized
                case .denied: .denied
                case .restricted: .restricted
                @unknown default: .notDetermined
                }
            }

            private func requestEventKit(_ type: EKEntityType) async throws -> PrismPermissionStatus {
                let store = EKEventStore()
                let granted = try await store.requestFullAccessToEvents()
                return granted ? .authorized : .denied
            }
        #endif

        private func requestContacts() async throws -> PrismPermissionStatus {
            let store = CNContactStore()
            let granted = try await store.requestAccess(for: .contacts)
            return granted ? .authorized : .denied
        }

        #if canImport(UserNotifications)
            private func requestNotifications() async throws -> PrismPermissionStatus {
                let center = UNUserNotificationCenter.current()
                let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                return granted ? .authorized : .denied
            }
        #endif

        #if canImport(Speech)
            private func mapSpeechStatus(_ status: SFSpeechRecognizerAuthorizationStatus) -> PrismPermissionStatus {
                switch status {
                case .notDetermined: .notDetermined
                case .authorized: .authorized
                case .denied: .denied
                case .restricted: .restricted
                @unknown default: .notDetermined
                }
            }

            private func requestSpeechRecognition() async -> PrismPermissionStatus {
                await withCheckedContinuation { continuation in
                    SFSpeechRecognizer.requestAuthorization { status in
                        continuation.resume(returning: self.mapSpeechStatus(status))
                    }
                }
            }
        #endif

        #if canImport(AppTrackingTransparency)
            private func requestTracking() async -> PrismPermissionStatus {
                let status = await ATTrackingManager.requestTrackingAuthorization()
                switch status {
                case .notDetermined: return .notDetermined
                case .authorized: return .authorized
                case .denied: return .denied
                case .restricted: return .restricted
                @unknown default: return .notDetermined
                }
            }
        #endif

        #if canImport(LocalAuthentication)
            private func checkBiometricStatus() -> PrismPermissionStatus {
                let context = LAContext()
                var error: NSError?
                let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
                if canEvaluate { return .authorized }
                guard let laError = error as? LAError else { return .notDetermined }
                switch laError.code {
                case .biometryNotAvailable: return .restricted
                case .biometryNotEnrolled: return .denied
                case .biometryLockout: return .denied
                default: return .notDetermined
                }
            }

            private func requestBiometric() async throws -> PrismPermissionStatus {
                let context = LAContext()
                do {
                    let success = try await context.evaluatePolicy(
                        .deviceOwnerAuthenticationWithBiometrics,
                        localizedReason: "Authenticate to continue"
                    )
                    return success ? .authorized : .denied
                } catch let error as LAError {
                    switch error.code {
                    case .userCancel: throw PrismSecurityError.biometricUserCancel
                    case .biometryNotAvailable: throw PrismSecurityError.biometricNotAvailable
                    case .biometryNotEnrolled: throw PrismSecurityError.biometricNotEnrolled
                    case .biometryLockout: throw PrismSecurityError.biometricLockout
                    default: throw PrismSecurityError.biometricAuthenticationFailed
                    }
                }
            }
        #endif
    }
#endif
