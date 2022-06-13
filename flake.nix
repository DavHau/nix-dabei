{
  description = "An operating system generator, based on not-os, focused on installation";
  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
    in
    {
      packages.${system} =
        with pkgs;
        let
          #docs = import ./lib/makeDocs.nix {
          #  inherit pkgs;
          #  modules = builtins.attrValues self.nixosModules;
          #  # Only document options which are declared inside this flake.
          #  filter = _: opt: opt.declarations == [ ];
          #};
          config = self.nixosConfigurations.default.config;
        in
        {
          # inherit (nixosConfiguration.config.system.build) runvm dist toplevel kexec;
          inherit (config.system.build) toplevel kexecBoot netbootRamdisk dist;
          default = config.system.build.dist;
          #docs = docs.all;
          #inherit pkgs;
        };

      apps.${system} =
        let
          scripts = pkgs.lib.mapAttrs makeShellScript {
            lint = "${pkgs.nix-linter}/bin/nix-linter **/*.nix *.nix";
            format = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt **/*.nix *.nix";
            repl = "nix repl repl.nix";
            docs = "cp -L --no-preserve=mode ${self.packages.${system}.docs}/options.md options.md";
          };
          packages = pkgs.lib.mapAttrs makePackageApp {
            vm = { program = "runvm"; };
          };
          makeSimpleApp = program:
            { type = "app"; programm = toString program; };
          makeShellScript = name: content:
            makeSimpleApp (pkgs.writeScript name content);
          makePackageApp = name: { program ? null }:
            makeSimpleApp self.packages.${system}.${program || name};
        in
        scripts // packages // { default = packages.vm; };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [ nix-tree ];

      };

      overlays.default = _final: prev:
        let
          systemd = prev.systemd.override {
            pname = "systemd-nix-dabei";
            withAnalyze = false;
            withApparmor = false;
            withCompression = false;
            withCoredump = false;
            withCryptsetup = false;
            withDocumentation = false;
            withEfi = false;
            withFido2 = false;
            withHostnamed = false;
            withHwdb = false;
            withImportd = false;
            withLibBPF = false;
            withLocaled = false;
            withLogind = false;
            withMachined = false;
            #withNetworkd = false;
            withNss = false;
            withOomd = false;
            withPCRE2 = false;
            withPolkit = false;
            withRemote = false;
            withResolved = false;
            withShellCompletions = false;
            withTimedated = false;
            withTimesyncd = false;
            withTpm2Tss = false;
            withUserDb = false;
            # To re-enable?
            # withCryptsetup = true;
            # withFido2 = true;
            # withTpm2Tss = true;
            withNetworkd = true;
          };
        in {
        systemdMinimal = systemd;
        systemdStage1 = systemd;
        systemdStage1Network = systemd;
        udev = systemd;

        util-linux = prev.util-linux.override { ncursesSupport = false; nlsSupport = false; };
        openssh = prev.openssh.override { withFIDO = false; withKerberos = false; };

        #procps = prev.procps.override { withSystemd = false; };
        #util-linux = prev.util-linux.override { systemd = null; systemdSupport = false; ncursesSupport = false; nlsSupport = false; };
        #dhcpcd = prev.dhcpcd.override { udev = null; };
        #libusb = prev.libusb.override { enableUdev = false; };
        #rng-tools = prev.rng-tools.override { withPkcs11 = false; withRtlsdr = false; };
        #openssh = prev.openssh.override { withFIDO = false; withKerberos = false; };
        gitMicro = (prev.gitMinimal.override {
          perlSupport = false;
          withManual = false;
          pythonSupport = false;
          withpcre2 = false;
        }).overrideAttrs (_: { doInstallCheck = false; });
      };

      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [ ./configuration.nix ] ++ pkgs.lib.attrValues self.nixosModules;
      };

      nixosModules = {
        environment = import ./modules/environment.nix;
        base = import ./modules/base.nix;
        # runit = import ./modules/runit.nix;
        # stage-1 = import ./modules/stage-1.nix;
        # stage-2 = import ./modules/stage-2.nix;
        # Extracted nixos options shims, where we don't want the whole nixos module file.
        # compat = import ./modules/compat.nix;
        # NixOS modules which can be re-used as-is.
        upstream = {
          imports = [
#            "${self}/modules/filesystems.nix"
#            "${self}/modules/netboot.nix"
#            "${nixpkgs}/nixos/modules/system/etc/etc-activation.nix"
#            "${nixpkgs}/nixos/modules/system/activation/activation-script.nix"
#            "${nixpkgs}/nixos/modules/system/boot/kernel.nix"
#            "${nixpkgs}/nixos/modules/misc/ids.nix"
#            "${nixpkgs}/nixos/modules/misc/nixpkgs.nix"
#            "${nixpkgs}/nixos/modules/misc/assertions.nix"
#            "${nixpkgs}/nixos/modules/misc/lib.nix"
#            "${nixpkgs}/nixos/modules/config/sysctl.nix"
#            "${nixpkgs}/nixos/modules/security/ca.nix"
          ];
        };
        # Let the generated operating system use our nixpkgs and overlay,
        # but still allow flake users to provide their own.
        nixpkgs = {
          config.nixpkgs = {
            inherit pkgs;
            localSystem = { inherit system; };
          };
        };
      };
    };
}
