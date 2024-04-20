{
  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import "${nixpkgs}" {
      inherit system;
    };

    zephyr-sdk-version = "0.16.3";
    # only install arm-zephyr-eabi toolchain (for nice!nanov2)
    toolchain = "arm-zephyr-eabi";
    # nice!nanov2 uses a Nordic nRF52840, which has a Cortex-M4 CPU
    architecture = "arm-cortex_a15-linux-gnueabihf";

    crosstool-ng-deps = toString (map (p: "ln -s " + builtins.fetchurl {inherit (p) name url sha256;} + " ./tars/" + p.name + ";\n") [
      # LINUX
      {
        name = "linux-5.2.17.tar.gz";
        url = "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.2.17.tar.gz";
        sha256 = "sha256:1ae1dcbae8fb979d2bf589c3be8aa8966a106ca6ce77cffd270c5c9f33c1a421";
      }
      # BINUTILS
      {
        name = "binutils-2.38.tar.xz";
        url = "https://ftp.gnu.org/gnu/binutils/binutils-2.38.tar.xz";
        sha256 = "sha256:e316477a914f567eccc34d5d29785b8b0f5a10208d36bbacedcc39048ecfe024";
      }
      # GCC
      {
        name = "gcc-12.1.0.tar.gz";
        url = "https://ftp.gnu.org/gnu/gcc/gcc-12.1.0/gcc-12.1.0.tar.gz";
        sha256 = "sha256:e88a004a14697bbbaba311f38a938c716d9a652fd151aaaa4cf1b5b99b90e2de";
      }
      # GLIBC
      {
        name = "glibc-2.28.tar.gz";
        url = "https://ftp.gnu.org/gnu/glibc/glibc-2.28.tar.gz";
        sha256 = "sha256:f318d6e3f1f4ed0b74d2832ac4f491d0fb928e451c9eda594cbf1c3bee7af47c";
      }
      # DEBUG
      {
        name = "duma_2_5_15.tar.gz";
        # url = "https://github.com/johnsonjh/duma/archive/refs/tags/VERSION_2_5_15.tar.gz"; # extracts to duma-VERSION_2_5_15
        url = "https://downloads.sourceforge.net/project/duma/duma/2.5.15/duma_2_5_15.tar.gz";
        sha256 = "sha256:baaf794854e3093ad1bddadbfb8ad4b220a7117d70359ee216bd59e353734e17";
      }
      {
        name = "gdb-12.1.tar.gz";
        url = "https://ftp.gnu.org/gnu/gdb/gdb-12.1.tar.gz";
        sha256 = "sha256:87296a3a9727356b56712c793704082d5df0ff36a34ca9ec9734fc9a8bdfdaab";
      }
      {
        name = "ltrace-0.7.3.tar.gz";
        url = "https://gitlab.com/cespedes/ltrace/-/archive/01b10e191e99d8cb147e5a2b7da8196e0ec6fb94/trace-01b10e191e99d8cb147e5a2b7da8196e0ec6fb94.tar.gz";
        sha256 = "sha256:d9b5c0c8494f891e5c0f01976b38e19a90546563a288fd5ea91aaf2b175ec930";
      }
      {
        name = "strace-5.16.tar.xz";
        url = "https://strace.io/files/5.16/strace-5.16.tar.xz";
        sha256 = "sha256:dc7db230ff3e57c249830ba94acab2b862da1fcaac55417e9b85041a833ca285";
      }
      # LIBS
      {
        name = "zlib-1.2.13.tar.gz";
        url = "https://github.com/madler/zlib/releases/download/v1.2.13/zlib-1.2.13.tar.gz";
        sha256 = "sha256:b3a24de97a8fdbc835b9833169501030b8977031bcb54b3b3ac13740f846ab30";
      }
      {
        name = "gmp-6.2.1.tar.xz";
        url = "https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz";
        sha256 = "sha256:fd4829912cddd12f84181c3451cc752be224643e87fac497b69edddadc49b4f2";
      }
      {
        name = "mpfr-4.1.0.tar.xz";
        url = "https://www.mpfr.org/mpfr-4.1.0/mpfr-4.1.0.tar.xz";
        sha256 = "sha256:0c98a3f1732ff6ca4ea690552079da9c597872d30e96ec28414ee23c95558a7f";
      }
      {
        name = "isl-0.24.tar.gz";
        #url = "https://repo.or.cz/isl.git/snapshot/refs/tags/isl-0.24.tar.gz"; # extracts to isl-isl-0.24
        #url = "https://repo.or.cz/isl.git/snapshot/3ea3e8b77475bea49b35b8215d8f66af94121b3c.tar.gz"; # extracts to isl-3ea3e8b
        url = "https://downloads.sourceforge.net/project/libisl/isl-0.24.tar.gz";
        sha256 = "sha256:26e6e4d60ad59b3fff9948eb36743f0c874e124e410ef5bab930d0f546bc580d";
      }
      {
        name = "cloog-0.18.4.tar.gz";
        url = "https://repo.or.cz/cloog.git/snapshot/001fa4fb0b33fdf883c2315af3e04ab404223cfa.tar.gz";
        sha256 = "sha256:98df4df8556f79c395be39572095e879e3c0f01c5747c2a52d9410163a862b7b";
      }
      {
        name = "mpc-1.2.1.tar.gz";
        url = "https://ftp.gnu.org/gnu/mpc/mpc-1.2.1.tar.gz";
        sha256 = "sha256:17503d2c395dfcf106b622dc142683c1199431d095367c6aacba6eec30340459";
      }
      {
        name = "libelf-0.8.13.tar.gz";
        url = "https://fossies.org/linux/misc/old/libelf-0.8.13.tar.gz";
        sha256 = "sha256:591a9b4ec81c1f2042a97aa60564e0cb79d041c52faa7416acb38bc95bd2c76d";
      }
      {
        name = "expat-2.5.0.tar.gz";
        url = "https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.gz";
        sha256 = "sha256:6b902ab103843592be5e99504f846ec109c1abb692e85347587f237a4ffa1033";
      }
      {
        name = "ncurses-6.2.tar.gz";
        url = "https://ftp.gnu.org/gnu/ncurses/ncurses-6.2.tar.gz";
        sha256 = "sha256:30306e0c76e0f9f1f0de987cf1c82a5c21e1ce6568b9227f7da5b71cbea86c9d";
      }
      {
        name = "libiconv-1.16.tar.gz";
        url = "https://ftp.gnu.org/gnu/libiconv/libiconv-1.16.tar.gz";
        sha256 = "sha256:e6a1b1b589654277ee790cce3734f07876ac4ccfaecbee8afa0b649cf529cc04";
      }
      {
        name = "gettext-0.21.tar.gz";
        url = "https://ftp.gnu.org/gnu/gettext/gettext-0.21.tar.gz";
        sha256 = "sha256:c77d0da3102aec9c07f43671e60611ebff89a996ef159497ce8e59d075786b12";
      }
      {
        name = "picolibc-1.7.8.tar.gz";
        url = "https://github.com/picolibc/picolibc/releases/download/1.7.8/picolibc-1.7.8.tar.xz";
        sha256 = "sha256:b0bddaf1cafbe0fa72e55bd27895b24d30f2a03ebc0e5b3dd2046d4cefe1c158";
      }
      {
        name = "newlib-4.1.0.tar.gz";
        url = "https://sourceware.org/pub/newlib/newlib-4.1.0.tar.gz";
        sha256 = "sha256:f296e372f51324224d387cc116dc37a6bd397198756746f93a2b02e9a5d40154";
      }
      {
        name = "gnuprumcu-0.6.0.tar.gz";
        url = "https://github.com/dinuxbg/gnuprumcu/releases/download/v0.6.0/gnuprumcu-0.6.0.tar.gz";
        sha256 = "sha256:1f488578edfc7da404fe7d59d2864fffbc00a9cea540d43ac508a68741428a9b";
      }
      # TOOLS
      {
        name = "make-4.3.tar.gz";
        url = "https://ftp.gnu.org/gnu/make/make-4.3.tar.gz";
        sha256 = "sha256:e05fdde47c5f7ca45cb697e973894ff4f5d79e13b750ed57d7b66d8defc78e19";
      }
      {
        name = "m4-1.4.19.tar.gz";
        url = "https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.gz";
        sha256 = "sha256:3be4a26d825ffdfda52a56fc43246456989a3630093cced3fbddf4771ee58a70";
      }
      {
        name = "autoconf-2.71.tar.gz";
        url = "https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz";
        sha256 = "sha256:431075ad0bf529ef13cb41e9042c542381103e80015686222b8a9d4abef42a1c";
      }
      {
        name = "automake-1.16.1.tar.gz";
        url = "https://ftp.gnu.org/gnu/automake/automake-1.16.1.tar.gz";
        sha256 = "sha256:608a97523f97db32f1f5d5615c98ca69326ced2054c9f82e65bade7fc4c9dea8";
      }
      {
        name = "libtool-2.4.6.tar.gz";
        url = "https://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz";
        sha256 = "sha256:e3bd4d5d3d025a36c21dd6af7ea818a2afcd4dfc1ea5a17b39d7854bcd0c06e3";
      }
      {
        name = "dtc-1.6.0.tar.gz";
        url = "https://git.kernel.org/pub/scm/utils/dtc/dtc.git/snapshot/dtc-1.6.0.tar.gz";
        sha256 = "sha256:3d15dee7126a6c4a015ab47ec908cab13e39774b0315efaaebb223cb4a4d349c";
      }
      {
        name = "bison-3.5.tar.gz";
        url = "https://ftp.gnu.org/gnu/bison/bison-3.5.tar.gz";
        sha256 = "sha256:0b36200b9868ee289b78cefd1199496b02b76899bbb7e84ff1c0733a991313d1";
      }
    ]);
  in rec {
    devShells.${pkgs.system}.default = pkgs.mkShell {
      packages = with pkgs; [
        # deps of nix_inputs.sh:
        gnused
        gawk
        ripgrep
        python311Packages.west
      ];
    };

    # takes +-20 mins to build
    # nix build .#crosstool-ng
    packages."x86_64-linux".crosstool-ng = pkgs.stdenvNoCC.mkDerivation {
      name = "crosstool-ng";
      src = builtins.fetchGit {
        url = "https://github.com/zephyrproject-rtos/crosstool-ng";
        rev = "5dfdb4b04fba6188069e23c51624746e62e74397";
      };
      nativeBuildInputs = with pkgs; [
        gcc
        ninja
        meson
        gnumake42 # using make4.2, see github.com/crosstool-ng/crosstool-ng/issues/1932
        autoconf
        automake
        which
        perl
        libtool
        flex
        texinfo
        unzip
        help2man
        bison
        ncurses
      ];
      # largely copied from https://gist.github.com/wirew0rm/4881987e7549b390c3acd5767f3b8d6a
      configurePhase =
        ''
          bash ./bootstrap;
          ./configure --enable-local PACKAGE_VERSION=crosstool-ng-1.26.0-334f6d64;

          make;

          mkdir tars;
          mkdir ${toolchain}

          cat <<EOF >> ./samples/${architecture}/crosstool.config;
          CT_LOCAL_TARBALLS_DIR="''$(pwd)/tars"
          CT_FORBID_DOWNLOAD=y
          CT_PREFIX_DIR="$(pwd)/${toolchain}"
          EOF

          ./ct-ng ${architecture};
        ''
        + crosstool-ng-deps;
      # make sure to disable hardening that's enabled by default on NixOS, specifically -Wformat-security
      # see NixOS/nixpkgs/issues/18995 & https://nixos.org/manual/nixpkgs/stable/#sec-hardening-flags-enabled-by-default
      hardeningDisable = ["format"];
      buildPhase = ''
        unset CC;
        unset CXX;
        ./ct-ng build;
      '';
      installPhase = ''
        mkdir -p $out/;
        cp -r ct-ng paths.sh COPYING LICENSE licenses.d/ scripts/ samples/ kconfig/ config/ $out/;
        cp -avr ./${toolchain}/ $out;
      '';
    };

    # takes at least 1h15m
    # nix build .#zephyr-sdk --keep-failed
    packages."x86_64-linux".zephyr-sdk = let
      toolchain_minimal = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${zephyr-sdk-version}/zephyr-sdk-${zephyr-sdk-version}_linux-x86_64_minimal.tar.xz";
        sha256 = "sha256:02bbrygaj9c4pmk0rqm919lg6xv4dxnrz4w02in6gg6qq0s1n0bh";
      };
    in
      pkgs.stdenvNoCC.mkDerivation {
        name = "zephyr-sdk";
        src = builtins.fetchGit {
          url = "https://github.com/zephyrproject-rtos/sdk-ng";
          rev = "3e434173c283fbf808f825b8a88abbba7ca43d7c"; # 0.16.3
          submodules = true;
        };
        nativeBuildInputs = with pkgs; [
          gcc
          ninja
          meson
          gnumake42 # using make4.2, see github.com/crosstool-ng/crosstool-ng/issues/1932
          autoconf
          which
          perl
          flex
          texinfo
          gnum4
          python3
        ];
        # most of the following is copied from the github actions file in the original repo (zephyrproject-rtos/sdk-ng)
        configurePhase =
          ''
            # copy some things from the crosstool-ng derivation
            cp -r \
              ${self.packages.x86_64-linux.crosstool-ng}/ct-ng \
              ${self.packages.x86_64-linux.crosstool-ng}/paths.sh \
              ${self.packages.x86_64-linux.crosstool-ng}/COPYING \
              ${self.packages.x86_64-linux.crosstool-ng}/LICENSE \
              ${self.packages.x86_64-linux.crosstool-ng}/licenses.d/ \
              ${self.packages.x86_64-linux.crosstool-ng}/scripts \
              ${self.packages.x86_64-linux.crosstool-ng}/samples \
              ${self.packages.x86_64-linux.crosstool-ng}/kconfig \
              ${self.packages.x86_64-linux.crosstool-ng}/config \
              ./;

            # load default target configuration
            cat ./configs/common.config ./configs/${toolchain}.config > .config;

            # set version information
            cat <<EOF >> .config;
            CT_SHOW_CT_VERSION=n
            CT_TOOLCHAIN_PKGVERSION="Zephyr SDK $(<VERSION)"
            CT_TOOLCHAIN_BUGURL="https://github.com/zephyrproject-rtos/sdk-ng/issues"
            EOF

            # set logging configurations
            cat <<EOF >> .config;
            CT_LOG_PROGRESS_BAR=n
            CT_LOG_EXTRA=y
            CT_LOG_LEVEL_MAX="EXTRA"
            EOF

            # configure GDB Python scripting support
            cat <<EOF >> .config;
            CT_GDB_CROSS_PYTHON=y
            CT_GDB_CROSS_PYTHON_VARIANT=y
            CT_GDB_CROSS_PYTHON_BINARY="python3.11"
            EOF

            mkdir tars;
            mkdir ${toolchain};

            # don't download stuff
            cat <<EOF >> .config;
            CT_LOCAL_TARBALLS_DIR="''$(pwd)/tars"
            CT_FORBID_DOWNLOAD=y
            CT_PREFIX_DIR="$(pwd)/${toolchain}"
            EOF

            # .config contains a bunch of lines like this:
            # CT_<program>_CUSTOM_LOCATION="''${GITHUB_WORKSPACE}/<program>"
            # so we have to replace that with /build/source/<program>
            sed -i 's/''${GITHUB_WORKSPACE}/\/build\/source/' .config

            # merge configurations
            ./ct-ng savedefconfig DEFCONFIG=build.config;
            ./ct-ng distclean;
            ./ct-ng defconfig DEFCONFIG=build.config;
          ''
          + crosstool-ng-deps;
        # make sure to disable hardening that's enabled by default on NixOS, specifically -Wformat-security
        # see NixOS/nixpkgs/issues/18995 & https://nixos.org/manual/nixpkgs/stable/#sec-hardening-flags-enabled-by-default
        hardeningDisable = ["format"];
        buildPhase = ''
          unset CC;
          unset CXX;
          ./ct-ng build;
        '';
        installPhase = ''
          mkdir -p $out/;
          cp -avr ${toolchain_minimal}/* ${toolchain}/ $out/;
        '';
      };

    packages."x86_64-linux".zmk_left = zmkFirmware "left" "nice_nano_v2" "corne_left;nice_view_adapter;nice_view";
    packages."x86_64-linux".zmk_right = zmkFirmware "right" "nice_nano_v2" "corne_right;nice_view_adapter;nice_view";
    packages."x86_64-linux".zmk_reset = zmkFirmware "reset" "nice_nano_v2" "settings_reset";

    zmkFirmware = name: board: shields: let
      zmk = builtins.fetchGit {
        url = "https://github.com/zmkfirmware/zmk";
        rev = "e22bc7620cef763d9ad80e9b98182273de9973db";
      };
      zephyr = builtins.fetchGit {
        # ZMK's Zephyr fork
        url = "https://github.com/zmkfirmware/zephyr?ref=v3.5.0+zmk-fixes";
        rev = "8f87b3be1e7631332cd8b245fb94d24d0354d0cb";
      };
      # the following was generated using nix_inputs.sh
      # except for the things I had to fork & have not been merged
      # (some modules didn't have a name in zephyr/module.yml -> fork & MR to fix)
      zephyrproject-rtos_chre = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/chre/archive/3b32c76efee705af146124fb4190f71be5a4e36e.tar.gz";
        sha256 = "sha256:0gpdyji7380xi61lxdxzmmrdlab5wf37023rzanfwrwa6kvly9zd";
      };
      zephyrproject-rtos_lz4 = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/lz4/archive/8e303c264fc21c2116dc612658003a22e933124d.tar.gz";
        sha256 = "sha256:1kqs7gxg17gvws01rir8p6gmzp54y12s1898lflhsb418122v8nf";
      };
      zephyrproject-rtos_nanopb = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/nanopb/archive/42fa8b211e946b90b9d968523fce7b1cfe27617e.tar.gz";
        sha256 = "sha256:06a7h1bmq7yja3z5v00s5d5pdqf2f4yvqg3mpk3ah3n3z4g414gg";
      };
      zephyrproject-rtos_psa-arch-tests = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/psa-arch-tests/archive/6a17330e0dfb5f319730f974d5b05f7b7f04757b.tar.gz";
        sha256 = "sha256:0dmqfi1364arj5izbyyyc0031qrb3jg89s6rm918bfzb18p8sg18";
      };
      zephyrproject-rtos_sof = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/sof/archive/c0f20b69daa44e3563f970b366e49ccfcfa1b71c.tar.gz";
        sha256 = "sha256:0wnlr0a2b4fgghb9g62d60iwi7f66hvfyk4f9c91vrf74nf7sdpp";
      };
      zephyrproject-rtos_tf-m-tests = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/tf-m-tests/archive/a878426da78fbd1486dfc29d6c6b82be4ee79e72.tar.gz";
        sha256 = "sha256:13lrvx1vkwynxrf1dk3qcyziddhxsqkzich638khv1hmvb3i8bsf";
      };
      zephyrproject-rtos_tflite-micro = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/tflite-micro/archive/1a34dcab41e7e0e667db72d6a40999c1ec9c510c.tar.gz";
        sha256 = "sha256:194k1wh4fx49vymc3dhmmsg8wfq4jjhsp00rsrmax5vfhy7fjsi6";
      };
      zephyrproject-rtos_thrift = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/thrift/archive/10023645a0e6cb7ce23fcd7fd3dbac9f18df6234.tar.gz";
        sha256 = "sha256:1bpi64lk7sdidjqsq7rspbqk9k7z8s26mgg17c8sv6cr4h007raq";
      };
      zephyrproject-rtos_zscilib = builtins.fetchTarball {
        url = "https://github.com/jappie3/zscilib/archive/105874b2be06248d9bf3f33826e837e7074fed4f.tar.gz";
        sha256 = "sha256:0rb5f9wqll72f8yvih3r7c3mc94lxzq1lxfjznx30w6mm5rqd9nw";
      };
      zephyrproject-rtos_acpica = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/acpica/archive/0333c2af13179f9b33d495cf7cb9a509f751cbb1.tar.gz";
        sha256 = "sha256:04864is6iisjfasvlwgfsmgnlihdg43cfcc3hpqkzb446x2ix4iw";
      };
      zephyrproject-rtos_babblesim-manifest = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/babblesim-manifest/archive/384a091445c57b44ac8cbd18ebd245b47c71db94.tar.gz";
        sha256 = "sha256:065aa4zqrmr27hi2d84sqj98ni722qr8slvyq41hv4sl90p9wzbc";
      };
      BabbleSim_base = builtins.fetchTarball {
        url = "https://github.com/BabbleSim/base/archive/19d62424c0802c6c9fc15528febe666e40f372a1.tar.gz";
        sha256 = "sha256:0xaj7vr2zp4zswfkzp9a6vv5i9si73j841h64pchcrd26xnbzs7w";
      };
      BabbleSim_ext_2G4_libPhyComv1 = builtins.fetchTarball {
        url = "https://github.com/BabbleSim/ext_2G4_libPhyComv1/archive/9018113a362fa6c9e8f4b9cab9e5a8f12cc46b94.tar.gz";
        sha256 = "sha256:1z2jxjzb1i94rx53539i0snjk1xmdwfjngxrf95a9z9xlsyvvwia";
      };
      BabbleSim_ext_2G4_phy_v1 = builtins.fetchTarball {
        url = "https://github.com/BabbleSim/ext_2G4_phy_v1/archive/d47c6dd90035b41b14f6921785ccb7b8484868e2.tar.gz";
        sha256 = "sha256:01pk3wd6pjq0vy3xsc3xdgw8ylj4dgndd841c7aya6h3a8swnh2b";
      };
      BabbleSim_ext_2G4_channel_NtNcable = builtins.fetchTarball {
        url = "https://github.com/BabbleSim/ext_2G4_channel_NtNcable/archive/20a38c997f507b0aa53817aab3d73a462fff7af1.tar.gz";
        sha256 = "sha256:06dgcp84gpmfz2q5gyvs6qs2rdqbj8rzsn4y9z0wpswhfaabj7kf";
      };
      BabbleSim_ext_2G4_channel_multiatt = builtins.fetchTarball {
        url = "https://github.com/BabbleSim/ext_2G4_channel_multiatt/archive/bde72a57384dde7a4310bcf3843469401be93074.tar.gz";
        sha256 = "sha256:0ny8df1l9prd6awznxlaxz4x3a133n8hj7v13bpbsscgzi07dfr4";
      };
      BabbleSim_ext_2G4_modem_magic = builtins.fetchTarball {
        url = "https://github.com/BabbleSim/ext_2G4_modem_magic/archive/cb70771794f0bf6f262aa474848611c68ae8f1ed.tar.gz";
        sha256 = "sha256:17hywqdhmnn3zi4b35gya8kkxd5q5nq6xv2rxsj2lrzwpsicgwgy";
      };
      BabbleSim_ext_2G4_modem_BLE_simple = builtins.fetchTarball {
        url = "https://github.com/BabbleSim/ext_2G4_modem_BLE_simple/archive/809ab073159c9ab6686c2fea5749b0702e0909f7.tar.gz";
        sha256 = "sha256:0mn6qyhg3166cb6ww6pjh5hlzak4ckkd05ii6lgfqs1r0i5hsqcg";
      };
      BabbleSim_ext_2G4_device_burst_interferer = builtins.fetchTarball {
        url = "https://github.com/BabbleSim/ext_2G4_device_burst_interferer/archive/5b5339351d6e6a2368c686c734dc8b2fc65698fc.tar.gz";
        sha256 = "sha256:175mbwxnmynsjv06skgb64k287jbpmlan62l015ihkv1hzyica96";
      };
      BabbleSim_ext_2G4_device_WLAN_actmod = builtins.fetchTarball {
        url = "https://github.com/BabbleSim/ext_2G4_device_WLAN_actmod/archive/9cb6d8e72695f6b785e57443f0629a18069d6ce4.tar.gz";
        sha256 = "sha256:0d5b0vdd2n11q90f2mywyanybadvfi54pigiqvmwcp8kxlcmhd75";
      };
      BabbleSim_ext_2G4_device_playback = builtins.fetchTarball {
        url = "https://github.com/BabbleSim/ext_2G4_device_playback/archive/85c645929cf1ce995d8537107d9dcbd12ed64036.tar.gz";
        sha256 = "sha256:1z3z0qgcw7bkc0xja3x2zw797dls3yjww23llpfp76fbd9gicfl6";
      };
      BabbleSim_ext_libCryptov1 = builtins.fetchTarball {
        url = "https://github.com/BabbleSim/ext_libCryptov1/archive/eed6d7038e839153e340bd333bc43541cb90ba64.tar.gz";
        sha256 = "sha256:0ywy57ir2pn8zlhaph5q2rniycr180iv46n61yrnkazsb2id5vpk";
      };
      zephyrproject-rtos_canopennode = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/canopennode/archive/dec12fa3f0d790cafa8414a4c2930ea71ab72ffd.tar.gz";
        sha256 = "sha256:0x6l56q5zdrz78iarfwxiwc05wwq4krg9xhx1z8kjarkwf6q9f85";
      };
      cmsis = builtins.fetchTarball {
        url = "https://github.com/jappie3/cmsis/archive/7a20ed5bfe4f1def2e80d113aa55976f899fa012.tar.gz";
        sha256 = "sha256:1ljsxycwhf07m8h43qrs19825pspj9nfzwvw9li0h91f7yxfjjsz";
      };
      zephyrproject-rtos_cmsis-dsp = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/cmsis-dsp/archive/ff7b5fd1ea5f094665c090c343ec44e74dc0b193.tar.gz";
        sha256 = "sha256:0ycznb30fmh35sz3gsg3gzdh9shk8ad90k4849lmx21jzxr6jrai";
      };
      zephyrproject-rtos_cmsis-nn = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/cmsis-nn/archive/0c8669d81381ccf3b1a01d699f3b68b50134a99f.tar.gz";
        sha256 = "sha256:1bnlyklzlhjrx8b66y6fy9im9wipx4shkq3mla5k7iw7kn3kqs7z";
      };
      zephyrproject-rtos_edtt = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/edtt/archive/64e5105ad82390164fb73fc654be3f73a608209a.tar.gz";
        sha256 = "sha256:1p37147k1sdw4lmhsbxhmq8zcpwm6mm60z9r53j7klg7h5h37bh0";
      };
      zephyrproject-rtos_fatfs = builtins.fetchTarball {
        url = "https://github.com/jappie3/fatfs/archive/3afd3a7403d665bc5f098acd086755e051de3d4c.tar.gz";
        sha256 = "sha256:0pgplaw6amffn6b0lh6ki8w6h7df14jhdmsv1r5xjzmg9gxdydii";
      };
      zephyrproject-rtos_hal_altera = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_altera/archive/0d225ddd314379b32355a00fb669eacf911e750d.tar.gz";
        sha256 = "sha256:05f5a1sk8mp8vhbdsj31833n10kyd91f93hgk2zr62xc0kfbwq0z";
      };
      zephyrproject-rtos_hal_ambiq = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_ambiq/archive/0a7c99325aa73a1ef777501da91c2c6608661e56.tar.gz";
        sha256 = "sha256:1s1xv746p7c1ccyp2j1b36hrm9pp7dlpb8v4fclpd6wl3jcdjj74";
      };
      zephyrproject-rtos_hal_atmel = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_atmel/archive/5ab43007eda3f380c125f957f03638d2e8d1144d.tar.gz";
        sha256 = "sha256:0csnr0npgfraf4g11dn4f77ywm2qd80y65a12kx68f7bfm8flf9j";
      };
      zephyrproject-rtos_hal_espressif = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_espressif/archive/31fc5758f3507f8f0af00b1dea1a0df7af99bfc0.tar.gz";
        sha256 = "sha256:05b4hyrpzny07v1xfbnj503x9kybqiv0bhv603i57d2ab4rqwnz9";
      };
      zephyrproject-rtos_hal_ethos_u = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_ethos_u/archive/90ada2ea5681b2a2722a10d2898eac34c2510791.tar.gz";
        sha256 = "sha256:12nv46xhi8v6k36l7qgmlsp58vc1d0zw5wqizv30acj5si2bz3y3";
      };
      zephyrproject-rtos_hal_gigadevice = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_gigadevice/archive/2994b7dde8b0b0fa9b9c0ccb13474b6a486cddc3.tar.gz";
        sha256 = "sha256:16h3l09ikbb4sqql7nlnfdxqvsgcdywrwckf83r4mjs9pgxiq1qa";
      };
      zephyrproject-rtos_hal_infineon = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_infineon/archive/815e84a5150f95627201f192779a0180d5052de7.tar.gz";
        sha256 = "sha256:0h19zxi05hjmkmmgkd8wxb868xh0jxh4s1mnbajv0rpajdc8pdfr";
      };
      zephyrproject-rtos_hal_intel = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_intel/archive/b3b43d4e3da7ba483611bbbea7ef8af92c69df31.tar.gz";
        sha256 = "sha256:1m2d0vwa2iip80rfzip8av41lga2p8zm0gzxhd6x11b3lq05vkb2";
      };
      zephyrproject-rtos_hal_microchip = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_microchip/archive/5d079f1683a00b801373bbbbf5d181d4e33b30d5.tar.gz";
        sha256 = "sha256:11basljy0fsgcp3l7zvxklw6zqkmahm97pi156ndadrhr8g4v5q8";
      };
      zephyrproject-rtos_hal_nordic = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_nordic/archive/d054a315eb888ba70e09e5f6decd4097b0276d1f.tar.gz";
        sha256 = "sha256:0ypny416ylb2w5jg4bg55xvfg0yhqlbrakzvm0w23lnamg49kd6j";
      };
      zephyrproject-rtos_hal_nuvoton = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_nuvoton/archive/3e0a4c4d3328b2f72b164219add19d5308b53cb5.tar.gz";
        sha256 = "sha256:1xc1cr4c0d0zzmbdrfb7xr8zzq0aifki1l50wcrn9dsi9c1ww12g";
      };
      zephyrproject-rtos_hal_nxp = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_nxp/archive/ad142f5612d927e29b1f9606e8edade871b8a526.tar.gz";
        sha256 = "sha256:17z0i4nnnmkgsd3ahwkydml97nn38dvnxki3nciaxp08q58dynfx";
      };
      zephyrproject-rtos_hal_openisa = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_openisa/archive/d1e61c0c654d8ca9e73d27fca3a7eb3b7881cb6a.tar.gz";
        sha256 = "sha256:13lzg0k8snz1qk8mrm53p6ny6jzx4c0s1n1zsp50rqpf0azhn7a9";
      };
      zephyrproject-rtos_hal_quicklogic = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_quicklogic/archive/b3a66fe6d04d87fd1533a5c8de51d0599fcd08d0.tar.gz";
        sha256 = "sha256:0hk1x72kibaw3xkspy9822vh28ax3bk11b80qn8l4dwrm0wx34sy";
      };
      zephyrproject-rtos_hal_renesas = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_renesas/archive/a6cf2af9140e014fbbc48d2b6deb802231dd369f.tar.gz";
        sha256 = "sha256:000dmd1z72n9blw1pdjskkpz978k3pa6fzg60lhcaj9y24kl9y6z";
      };
      zephyrproject-rtos_hal_rpi_pico = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_rpi_pico/archive/fba7162cc7bee06d0149622bbcaac4e41062d368.tar.gz";
        sha256 = "sha256:165z9azm1k7b0mvhkd8dq0q6qwl8bcncccy4bc8100z6zymhz550";
      };
      zephyrproject-rtos_hal_silabs = builtins.fetchTarball {
        url = "https://github.com/jappie3/hal_silabs/archive/db67451f9f79bc330204e74f005e355c7ec09208.tar.gz";
        sha256 = "sha256:0c409bvadjcjjp24d33pa2b6k1p90g0qgypj282fd97088d0xi3k";
      };
      zephyrproject-rtos_hal_st = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_st/archive/fb8e79d1a261fd02aadff7c142729f1954163cf3.tar.gz";
        sha256 = "sha256:0x3sw8glgqidch3aijclzbalxc8767illkb24zhrmrls9ql7v1ij";
      };
      zephyrproject-rtos_hal_stm32 = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_stm32/archive/89ef0a3383edebf661073073bcdf6e2836fe90ee.tar.gz";
        sha256 = "sha256:0z7q5xg1rn9c3anjvi2kl0hgik3y3r25svwf97w1cjhjx1rhqmpv";
      };
      zephyrproject-rtos_hal_telink = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_telink/archive/38573af589173259801ae6c2b34b7d4c9e626746.tar.gz";
        sha256 = "sha256:1m5y6bhnhc6nnfd2pgxxhf30ny10vhiff4qaqililvg99b3wr0ca";
      };
      zephyrproject-rtos_hal_ti = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_ti/archive/b85f86e51fc4d47c4c383d320d64d52d4d371ae4.tar.gz";
        sha256 = "sha256:0694g9ggjjaklcjw6shap221rldyp1scg40vgf0ny63p2lrdr99m";
      };
      zephyrproject-rtos_hal_wurthelektronik = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_wurthelektronik/archive/24ca9873c3d608fad1fea0431836bc8f144c132e.tar.gz";
        sha256 = "sha256:0s2b3j40b7qd85np46n4vh0zjmwymnpxd8r42nhss6xznn11g2h8";
      };
      zephyrproject-rtos_hal_xtensa = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/hal_xtensa/archive/e6da34fc07dfe96161ab8743f5dbeb6e6307ab93.tar.gz";
        sha256 = "sha256:0mvr89ywk7bvxwwzgr4hl0gyvff7g1hkxzhcljx6nl5dc4cc22sj";
      };
      zephyrproject-rtos_libmetal = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/libmetal/archive/b91611a6f47dd29fb24c46e5621e797557f80ec6.tar.gz";
        sha256 = "sha256:0pj0g6zaxiylpdiizf03jil4q2sq1z9px7cfxlv95ddnbv6rjjcz";
      };
      zephyrproject-rtos_liblc3 = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/liblc3/archive/448f3de31f49a838988a162ef1e23a89ddf2d2ed.tar.gz";
        sha256 = "sha256:07r923k1y05sq1sl9740z33cz64pqm2n7x8rr2ws460fij64aixp";
      };
      zephyrproject-rtos_littlefs = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/littlefs/archive/57637ec57a409fb421a6de98915a6da35be5954d.tar.gz";
        sha256 = "sha256:0sy1pil1fc6aspj7gnp5zgw95sjrl562b3a3sqn0prgix7kq8c9r";
      };
      zephyrproject-rtos_loramac-node = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/loramac-node/archive/842413c5fb98707eb5f26e619e8e792453877897.tar.gz";
        sha256 = "sha256:1b8l4q2s280d0jqgh1z8dg8nh3n0l90i88mjbqiwhj38ylq4l6wx";
      };
      zephyrproject-rtos_lvgl = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/lvgl/archive/8a6a2d1d29d17d1e4bdc94c243c146a39d635fdd.tar.gz";
        sha256 = "sha256:0rsmlh358f4g2yidak916pxhkgckfrnck2a5hcsh9larsdnsnf24";
      };
      zephyrproject-rtos_mbedtls = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/mbedtls/archive/68c0da719ef9548432cc6a6e9b311def53ef6397.tar.gz";
        sha256 = "sha256:1ind0rc72qpny2r70x2zq1zg812qy8dkjgjrii9hj8i14z0i6yqh";
      };
      zephyrproject-rtos_mcuboot = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/mcuboot/archive/13767d0b72eb14ce42eb8aad1e5a133ef66afc54.tar.gz";
        sha256 = "sha256:0zj0dpy8yhvfxd48gfyj52bn6vdm4ymb3ynnq4gvbh7km7ccxkfh";
      };
      zephyrproject-rtos_mipi-sys-t = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/mipi-sys-t/archive/a819419603a2dfcb47f7f39092e1bc112e45d1ef.tar.gz";
        sha256 = "sha256:0v4vwdkgfslcg391qlby1srxip3ai5azprk79krziisr89q8wlr1";
      };
      zephyrproject-rtos_net-tools = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/net-tools/archive/d68ee9d17648a1bb3729c2023abfcb735dfe92fa.tar.gz";
        sha256 = "sha256:1m4rvwzc2n3hi56ip25d0asx0w1l49bgga67rc8lwzxc7ffgsvc6";
      };
      zephyrproject-rtos_nrf_hw_models = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/nrf_hw_models/archive/f4595802d32d103718bf50b3d390b7a450895843.tar.gz";
        sha256 = "sha256:04p6nfyrv38vq0dhdz0g11zqlrqhw43lydyyr06vlrijm0zja8p5";
      };
      zephyrproject-rtos_open-amp = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/open-amp/archive/42b7c577714b8f22ce82a901e19c1814af4609a8.tar.gz";
        sha256 = "sha256:0ch1iv4c3v3zx1l2clm4mawyd83kvxl3b5sd6m7r2sn6wpr456w9";
      };
      zephyrproject-rtos_openthread = builtins.fetchTarball {
        url = "https://github.com/jappie3/openthread/archive/8247704dd3ee9515e969e8dd216081113f8fa6ca.tar.gz";
        sha256 = "sha256:09kdn5zxqrkyxy9mgvnlzw1ipid5icjpgn8frpzgb1n151rwm9p4";
      };
      zephyrproject-rtos_percepio = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/percepio/archive/a3728efccc47dd372f40e6313589ca4c5cc7d5e9.tar.gz";
        sha256 = "sha256:0fhz6jwsni7s79p5pwmynxn4yzrr40yd8m51y20d8jf1ka6dh4gw";
      };
      zephyrproject-rtos_picolibc = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/picolibc/archive/d07c38ff051386f8e09a143ea0a6c1d6d66dd1d8.tar.gz";
        sha256 = "sha256:1pb4piwyib1mmqjyycq8xanvx9aps6mz4w2ijgrn1fjgfh5f7zpq";
      };
      zephyrproject-rtos_segger = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/segger/archive/9d0191285956cef43daf411edc2f1a7788346def.tar.gz";
        sha256 = "sha256:11wbzyd2n006ygh72ixhqcmgn1yrzk3kq3c0piqvrfgqmv7p8yzn";
      };
      zephyrproject-rtos_tinycrypt = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/tinycrypt/archive/3e9a49d2672ec01435ffbf0d788db6d95ef28de0.tar.gz";
        sha256 = "sha256:19d2q9y23yzz9i383q3cldjl3k5mryx9762cab23zy3ijdnmj2z6";
      };
      zephyrproject-rtos_trusted-firmware-m = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/trusted-firmware-m/archive/b168d92c7ed3c77c94d7ce3362bdde5dbffe8424.tar.gz";
        sha256 = "sha256:1k062jlnf3n0jfq65ill7kg6jjvkwq450n1366jm1d7yw1l3ym2q";
      };
      zephyrproject-rtos_trusted-firmware-a = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/trusted-firmware-a/archive/421dc050278287839f5c70019bd6aec617f2bbdb.tar.gz";
        sha256 = "sha256:029sha3dpagbvfnk5h6ad69pvs5ahwps3cxkzbfrdbq2xm8x3j2y";
      };
      zephyrproject-rtos_uoscore-uedhoc = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/uoscore-uedhoc/archive/5fe2cb613bd7e4590bd1b00c2adf181ac0229379.tar.gz";
        sha256 = "sha256:0h0zxfidf3a1vcixpmkafz4kylmk0zkpdg0kqsmjhj7r6lafj3q2";
      };
      zephyrproject-rtos_zcbor = builtins.fetchTarball {
        url = "https://github.com/zephyrproject-rtos/zcbor/archive/67fd8bb88d3136738661fa8bb5f9989103f4599e.tar.gz";
        sha256 = "sha256:16138k7xlahf63dfvplm8c2m0kxs1g17gcx1fa31y4gcfbi3b0k7";
      };
    in let
      zephyr-modules = "${zephyrproject-rtos_canopennode};${zephyrproject-rtos_chre};${zephyrproject-rtos_lz4};${zephyrproject-rtos_nanopb};${zephyrproject-rtos_psa-arch-tests};${zephyrproject-rtos_sof};${zephyrproject-rtos_tf-m-tests};${zephyrproject-rtos_tflite-micro};${zephyrproject-rtos_thrift};${zephyrproject-rtos_zscilib};${zephyrproject-rtos_acpica};${zephyrproject-rtos_babblesim-manifest};${BabbleSim_base};${BabbleSim_ext_2G4_libPhyComv1};${BabbleSim_ext_2G4_phy_v1};${BabbleSim_ext_2G4_channel_NtNcable};${BabbleSim_ext_2G4_channel_multiatt};${BabbleSim_ext_2G4_modem_magic};${BabbleSim_ext_2G4_modem_BLE_simple};${BabbleSim_ext_2G4_device_burst_interferer};${BabbleSim_ext_2G4_device_WLAN_actmod};${BabbleSim_ext_2G4_device_playback};${BabbleSim_ext_libCryptov1};${cmsis};${zephyrproject-rtos_cmsis-dsp};${zephyrproject-rtos_cmsis-nn};${zephyrproject-rtos_edtt};${zephyrproject-rtos_fatfs};${zephyrproject-rtos_hal_altera};${zephyrproject-rtos_hal_ambiq};${zephyrproject-rtos_hal_atmel};${zephyrproject-rtos_hal_espressif};${zephyrproject-rtos_hal_ethos_u};${zephyrproject-rtos_hal_gigadevice};${zephyrproject-rtos_hal_infineon};${zephyrproject-rtos_hal_intel};${zephyrproject-rtos_hal_microchip};${zephyrproject-rtos_hal_nordic};${zephyrproject-rtos_hal_nuvoton};${zephyrproject-rtos_hal_nxp};${zephyrproject-rtos_hal_openisa};${zephyrproject-rtos_hal_quicklogic};${zephyrproject-rtos_hal_renesas};${zephyrproject-rtos_hal_rpi_pico};${zephyrproject-rtos_hal_silabs};${zephyrproject-rtos_hal_st};${zephyrproject-rtos_hal_stm32};${zephyrproject-rtos_hal_telink};${zephyrproject-rtos_hal_ti};${zephyrproject-rtos_hal_wurthelektronik};${zephyrproject-rtos_hal_xtensa};${zephyrproject-rtos_libmetal};${zephyrproject-rtos_liblc3};${zephyrproject-rtos_littlefs};${zephyrproject-rtos_loramac-node};${zephyrproject-rtos_lvgl};${zephyrproject-rtos_mbedtls};${zephyrproject-rtos_mcuboot};${zephyrproject-rtos_mipi-sys-t};${zephyrproject-rtos_net-tools};${zephyrproject-rtos_nrf_hw_models};${zephyrproject-rtos_open-amp};${zephyrproject-rtos_openthread};${zephyrproject-rtos_percepio};${zephyrproject-rtos_picolibc};${zephyrproject-rtos_segger};${zephyrproject-rtos_tinycrypt};${zephyrproject-rtos_trusted-firmware-m};${zephyrproject-rtos_trusted-firmware-a};${zephyrproject-rtos_uoscore-uedhoc};${zephyrproject-rtos_zcbor};";
    in
      pkgs.stdenvNoCC.mkDerivation {
        name = "zmk_${name}";
        src = ./.;
        nativeBuildInputs = with pkgs; [gcc cmake ninja dtc python3] ++ (with python311Packages; [pyaml pykwalify packaging pyelftools]);

        # copy ZMK source, Zephyr source & Zephyr-sdk to build dir
        postPatch = ''
          cp -r ${zmk}/app/* .
          mkdir -p build/zephyr/ build/zephyr-sdk/
          cp -r ${zephyr}/* build/zephyr/
          cp -r ${self.packages.${pkgs.system}.zephyr-sdk}/* build/zephyr-sdk/
          chmod -R u+w *
        '';

        cmakeFlags = [
          "-Bbuild"
          "-GNinja"
          "-DSHIELD='${shields}'"
          "-DBOARD='${board}'"
          "-DZEPHYR_MODULES=${zephyr-modules}"
          "-DBUILD_VERSION=0.1"
          "-DCMAKE_VERBOSE_MAKEFILE=ON"
          "-DCMAKE_C_COMPILER=zephyr-sdk/${toolchain}/bin/${toolchain}-gcc"
          "-DCMAKE_CXX_COMPILER=zephyr-sdk/${toolchain}/bin/${toolchain}-c++"
          # "--trace-expand" # verbose log
        ];
        # ZMK_CONFIG & Zephyr_DIR need to be absolute paths -> set the variable in preConfigure so we can use pwd
        # ZEPHYR_SDK_INSTALL_DIR can be relative
        preConfigure = ''
          cmakeFlagsArray+=(
            "-DZMK_CONFIG=$(pwd)/config"
          )
          export Zephyr_DIR="$(pwd)/build/zephyr/"
          export ZEPHYR_SDK_INSTALL_DIR="$(pwd)/build/zephyr-sdk/"
        '';

        ninjaFlags = ["-Cbuild"];

        installPhase = ''
          mkdir -p $out/
          cp ./build/zephyr/zmk.uf2 $out/zmk_${name}.uf2
        '';
      };
  };
}
