{ pkgs, lib, writeShellScriptBin, fetchurl }:

let
  kernelVersion = "5.18.1";

  kernelTarball = fetchurl {
    url = "mirror://kernel/linux/kernel/v5.x/linux-${kernelVersion}.tar.xz";
    sha256 = "g9FBJsZgGGp6F3SkpcKdOOFw+l5Sz9LQj9NE3PH1fSI=";
  };

  fhsEnv = pkgs.buildFHSUserEnv {
      name = "fhs-env";
      targetPkgs = pkgs: with pkgs; [
        gcc binutils
        gnumake coreutils patch zlib zlib.dev curl git m4 bison flex acpica-tools
        ncurses.dev
        elfutils.dev
        openssl openssl.dev
        cpio pahole gawk perl bc nettools rsync
        gmp gmp.dev
        libmpc
        mpfr mpfr.dev
        zstd python3Minimal
        file unzip
      ];
  };
in writeShellScriptBin "build-kernel" ''
   export PATH="${lib.makeBinPath (with pkgs; [ coreutils libarchive fhsEnv ])}"

   set -ex

   echo ">>> Unpacking Linux kernel..."
   bsdtar xf ${kernelTarball}

   cd linux-${kernelVersion}
   fhs-env -c 'make mrproper'
   fhs-env -c 'make defconfig'
   sync

   time fhs-env -c 'make -j$(nproc) bzImage &> /dev/null'

''
