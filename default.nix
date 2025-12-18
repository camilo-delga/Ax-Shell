{
  stdenv,
  lib,
  self,
  ax-shell-python,
  runtimeDeps,
  wrapGAppsHook3,
  pkg-config,
  writeShellScript,
  gtk3,
  gtk4,
  glib,
  gobject-introspection,
  pango,
  gdk-pixbuf,
  cairo,
  harfbuzz,
  adwaita-icon-theme,
  tabler-icons-font,
}:

let
  ax-shell-unwrapped = writeShellScript "ax-shell-unwrapped" ''
    cd ${placeholder "out"}/share/ax-shell
    exec ${ax-shell-python}/bin/python -m main "$@"
  '';
in
stdenv.mkDerivation {
  pname = "ax-shell";
  version = "unstable-${self.shortRev or "dirty"}";

  src = self;

  nativeBuildInputs = [ wrapGAppsHook3 pkg-config ];
  
  buildInputs = [ 
    ax-shell-python 
    tabler-icons-font 
    gtk3
    gtk4
    glib
    gobject-introspection
    pango
    gdk-pixbuf
    cairo
    harfbuzz
  ] ++ runtimeDeps;

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall;
    mkdir -p $out/share/ax-shell
    mkdir -p $out/bin
    cp -r ./* $out/share/ax-shell/
    cp ${ax-shell-unwrapped} $out/bin/.ax-shell-unwrapped
    chmod +x $out/bin/.ax-shell-unwrapped
    runHook postInstall;
  '';

  preFixup = ''
    gappsWrapperArgs+=(--set AX_SHELL_WALLPAPERS_DIR_DEFAULT "$out/share/ax-shell/assets/wallpapers_example")
    gappsWrapperArgs+=(--set FABRIC_CSS_PATH "$out/share/ax-shell/main.css")
    gappsWrapperArgs+=(--prefix PATH : "${lib.makeBinPath runtimeDeps}")
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${tabler-icons-font}/share")
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${adwaita-icon-theme}/share")
  '';
  
  postFixup = ''
    wrapGApp $out/bin/.ax-shell-unwrapped
    mv $out/bin/.ax-shell-unwrapped $out/bin/ax-shell
  '';

  meta = {
    description = "A custom, flake-based package for Ax-Shell.";
    homepage = "https://github.com/poogas/Ax-Shell";
    license = lib.licenses.mit;
  };
}
