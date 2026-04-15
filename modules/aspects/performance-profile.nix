{ ... }: {
  den.aspects.performance-profile = {
    nixos = { ... }: {
      services.thermald.enable = false;

      systemd.services.platform-profile-performance = {
        description = "Set ACPI platform_profile=performance and raise MMIO RAPL PL1";
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
          mmio=/sys/class/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_0_power_limit_uw
          if [ -w "$mmio" ]; then
            echo 65000000 > "$mmio" || true
          fi
        '';
      };
    };
  };
}
