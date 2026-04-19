{ ... }: {
  den.aspects.performance-profile = {
    nixos = { ... }: {
      services.thermald.enable = false;

      # BIOS "max performance" only sets firmware defaults. The runtime caps
      # (governor, ACPI platform_profile, MMIO RAPL PL1) are set by the OS
      # and default conservatively on Linux without Intel DTT drivers.
      powerManagement.cpuFreqGovernor = "performance";

      systemd.services.platform-profile-performance = {
        description = "Set ACPI platform_profile=performance, HWP boost, MMIO RAPL PL1";
        wantedBy = [ "multi-user.target" ];
        after = [ "systemd-modules-load.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          if [ -w /sys/firmware/acpi/platform_profile ]; then
            echo performance > /sys/firmware/acpi/platform_profile || true
          fi
          if [ -w /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost ]; then
            echo 1 > /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost || true
          fi
          # Raise MMIO RAPL PL1 to match MSR cap (80W); BIOS default is 25W.
          mmio=/sys/class/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_0_power_limit_uw
          if [ -w "$mmio" ]; then
            echo 80000000 > "$mmio" || true
          fi
        '';
      };
    };
  };
}
