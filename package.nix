{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
}:

rustPlatform.buildRustPackage rec {
  pname = "rtk";
  version = "0.31.0";

  src = fetchFromGitHub {
    owner = "rtk-ai";
    repo = "rtk";
    rev = "v${version}";
    hash = "sha256-p4OX3SSDGKlHVLIWhgKpcme449wOHbfWbc3mxlCkaMI=";
  };

  cargoHash = "sha256-37YHhccgPNUrlFh35CoQv2H+Y4e41ax0ZoIvrIC0o6I=";

  nativeBuildInputs = [ installShellFiles ];

  doCheck = false;

  meta = with lib; {
    description = "High-performance CLI proxy to minimize LLM token consumption";
    homepage = "https://github.com/rtk-ai/rtk";
    license = licenses.mit;
    mainProgram = "rtk";
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
