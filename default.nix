{
  stdenv,
  lib,
  self,
  ax-shell-python,
  runtimeDeps,
  wrapGAppsHook3,
  pkg-config,
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
    
    cat > $out/bin/.ax-shell-unwrapped <<EOF
#!/bin/sh
export PYTHONPATH="$out/share/ax-shell:\''${PYTHONPATH}"
exec ${ax-shell-python}/bin/python -m main "\$@"
