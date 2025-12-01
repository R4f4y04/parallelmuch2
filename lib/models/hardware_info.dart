import 'dart:io';

/// System hardware information for context display.
///
/// This grounds the user by showing actual hardware capabilities.
/// Speedup expectations should be calibrated to the available cores.
class HardwareInfo {
  final int logicalCores;
  final String architecture;
  final String operatingSystem;

  const HardwareInfo({
    required this.logicalCores,
    required this.architecture,
    required this.operatingSystem,
  });

  /// Detect hardware information from the current system
  factory HardwareInfo.detect() {
    return HardwareInfo(
      logicalCores: Platform.numberOfProcessors,
      architecture: _detectArchitecture(),
      operatingSystem: Platform.operatingSystem,
    );
  }

  /// Infer architecture from platform
  static String _detectArchitecture() {
    if (Platform.version.contains('x64') ||
        Platform.version.contains('amd64')) {
      return 'x64';
    } else if (Platform.version.contains('arm64') ||
        Platform.version.contains('aarch64')) {
      return 'ARM64';
    } else if (Platform.version.contains('ia32') ||
        Platform.version.contains('x86')) {
      return 'x86';
    }
    return 'Unknown';
  }

  /// Expected theoretical maximum speedup (Amdahl's Law with 100% parallel fraction)
  int get theoreticalMaxSpeedup => logicalCores;

  /// Friendly display string for UI
  String get displayString =>
      '$logicalCores Logical Cores / ${logicalCores ~/ 2} Physical (Estimated) • $architecture';

  /// Compact string for badges
  String get compactString => '${logicalCores}C / $architecture';

  @override
  String toString() =>
      'HardwareInfo(cores: $logicalCores, arch: $architecture, os: $operatingSystem)';
}
