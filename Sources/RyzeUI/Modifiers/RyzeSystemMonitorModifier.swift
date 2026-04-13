//
//  RyzeSystemMonitorModifier.swift
//  Ryze
//
//  Created by Rafael Escaleira on 24/09/25.
//

import SwiftUI

// MARK: - RyzeSystemMonitor

public struct RyzeSystemMonitor: Sendable {
    public var cpuPercentageUsage: Double
    public var cpuTotalPercentage: Double
    public var cpuUsage: Int
    public var cpuCores: Int

    public var memoryPercentageUsage: Double
    public var memoryTotalPercentage: Double
    public var memoryUsed: String
    public var memoryTotal: String

    public init(
        cpuPercentageUsage: Double = .zero,
        cpuTotalPercentage: Double = .zero,
        cpuUsage: Int = .zero,
        cpuCores: Int = .zero,
        memoryPercentageUsage: Double = .zero,
        memoryTotalPercentage: Double = .zero,
        memoryUsed: String = "",
        memoryTotal: String = ""
    ) {
        self.cpuPercentageUsage = cpuPercentageUsage
        self.cpuTotalPercentage = cpuTotalPercentage
        self.cpuUsage = cpuUsage
        self.cpuCores = cpuCores
        self.memoryPercentageUsage = memoryPercentageUsage
        self.memoryTotalPercentage = memoryTotalPercentage
        self.memoryUsed = memoryUsed
        self.memoryTotal = memoryTotal
    }

    // MARK: - Computed Properties

    public var cpuUsageFormatted: String {
        String(format: "%.1f%%", cpuPercentageUsage * 100)
    }

    public var memoryUsageFormatted: String {
        String(format: "%.1f%%", memoryPercentageUsage * 100)
    }
}

// MARK: - RyzeSystemMonitorModifier

struct RyzeSystemMonitorModifier: ViewModifier {
    @Binding var systemMonitor: RyzeSystemMonitor

    init(systemMonitor: Binding<RyzeSystemMonitor>) {
        self._systemMonitor = systemMonitor
    }

    func body(content: Content) -> some View {
        content
            .task(id: "system_monitor") {
                let stream = SystemMonitorStream(interval: .seconds(1))
                for await metrics in stream {
                    await MainActor.run {
                        systemMonitor = metrics
                    }
                }
            }
    }
}

// MARK: - SystemMonitorStream

struct SystemMonitorStream: AsyncSequence {
    typealias Element = RyzeSystemMonitor

    private let interval: Duration
    private var previousCpuInfo: host_cpu_load_info?

    init(interval: Duration = .seconds(1)) {
        self.interval = interval
    }

    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(previousCpuInfo: previousCpuInfo, interval: interval)
    }

    struct AsyncIterator: AsyncIteratorProtocol {
        var previousCpuInfo: host_cpu_load_info?
        let interval: Duration
        var isFinished = false

        mutating func next() async -> Element? {
            guard !isFinished else { return nil }

            try? await Task.sleep(for: interval)

            guard let cpu = getCpuUsage(&previousCpuInfo),
                let memory = getMemoryUsage()
            else {
                return RyzeSystemMonitor()
            }

            return RyzeSystemMonitor(
                cpuPercentageUsage: cpu.cpuPercentageUsage,
                cpuTotalPercentage: cpu.cpuTotalPercentage,
                cpuUsage: cpu.cpuUsage,
                cpuCores: cpu.cpuCores,
                memoryPercentageUsage: memory.memoryPercentageUsage,
                memoryTotalPercentage: memory.memoryTotalPercentage,
                memoryUsed: memory.memoryUsed,
                memoryTotal: memory.memoryTotal
            )
        }

        // MARK: - CPU Usage (Instance Method)

        private func getCpuUsage(_ previousCpuInfo: inout host_cpu_load_info?) -> (
            cpuPercentageUsage: Double,
            cpuTotalPercentage: Double,
            cpuUsage: Int,
            cpuCores: Int
        )? {
            var totalUsageOfCPU: Double = .zero
            var threadsList: thread_act_array_t?
            var threadsCount = mach_msg_type_number_t(0)

            let threadsResult = task_threads(mach_task_self_, &threadsList, &threadsCount)
            guard threadsResult == KERN_SUCCESS else { return nil }

            for index in .zero..<threadsCount {
                var threadInfo = thread_basic_info()
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)

                let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(
                            threadsList![Int(index)],
                            thread_flavor_t(THREAD_BASIC_INFO),
                            $0,
                            &threadInfoCount
                        )
                    }
                }

                guard infoResult == KERN_SUCCESS else { continue }

                let threadBasicInfo = threadInfo as thread_basic_info
                if threadBasicInfo.flags & TH_FLAGS_IDLE == .zero {
                    let threadUsage = Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)
                    totalUsageOfCPU += threadUsage
                }
            }

            vm_deallocate(
                mach_task_self_,
                vm_address_t(UInt(bitPattern: threadsList)),
                vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride)
            )

            let cpuCores = ProcessInfo.processInfo.activeProcessorCount
            let adjustedUsage = totalUsageOfCPU * Double(cpuCores)
            let cpuTotalPercentage = Double(cpuCores)
            let cpuPercentageUsage = adjustedUsage / cpuTotalPercentage
            let cpuUsage = adjustedUsage.rounded().int

            return (cpuPercentageUsage, cpuTotalPercentage, cpuUsage, cpuCores)
        }
    }

    // MARK: - Memory Usage (Static)

    private static func getMemoryUsage() -> (
        memoryPercentageUsage: Double,
        memoryTotalPercentage: Double,
        memoryUsed: String,
        memoryTotal: String
    )? {
        var info = task_vm_info()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size / MemoryLayout<integer_t>.size)

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(TASK_VM_INFO),
                    $0,
                    &count
                )
            }
        }

        guard kerr == KERN_SUCCESS else { return nil }

        let phys_footprint = Int64(info.phys_footprint)
        let totalMemoryBytes = Int64(ProcessInfo.processInfo.physicalMemory)
        let usageBytes = phys_footprint

        guard totalMemoryBytes > .zero else { return nil }

        let memoryUsed = Self.formatBytes(usageBytes)
        let memoryTotal = Self.formatBytes(totalMemoryBytes)
        let memoryPercentageUsage = Double(usageBytes) / Double(totalMemoryBytes)

        return (memoryPercentageUsage, 1, memoryUsed, memoryTotal)
    }

    // MARK: - Helper

    private static func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - View Extension

extension View {
    public func ryze(systemMonitor: Binding<RyzeSystemMonitor>) -> some View {
        self.modifier(RyzeSystemMonitorModifier(systemMonitor: systemMonitor))
    }
}
