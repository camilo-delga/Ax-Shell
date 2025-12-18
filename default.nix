{
  stdenv,
  lib,
  self,
  ax-shell-python,
  runtimeDeps,
  wrapGAppsHook3,
  pkg-config,
  makeWrapper,
  gtk3,
  gtk4,
  glib,
  gobject-introspection,
  adwaita-icon-theme,
  tabler-icons-font,
}:

stdenv.mkDerivation {
  pname = "ax-shell";
  version = "unstable-${self.shortRev or "dirty"}";

  src = self;

  nativeBuildInputs = [ wrapGAppsHook3 pkg-config makeWrapper ];
  
  buildInputs = [ 
    ax-shell-python 
    tabler-icons-font 
    gtk3
    gtk4
    glib
    gobject-introspection
  ] ++ runtimeDeps;

  dontWrapQtApps = true;
  dontWrapGApps = true;  # Deshabilitamos el autowrap porque usamos makeWrapper manualmente

  installPhase = ''
    runHook preInstall;
    mkdir -p $out/share/ax-shell
    cp -r ./* $out/share/ax-shell/
    makeWrapper ${ax-shell-python}/bin/python $out/bin/ax-shell \
      --prefix PYTHONPATH : "$out/share/ax-shell" \
      --prefix PATH : "${ax-shell-python}/bin" \
      --prefix GI_TYPELIB_PATH : "${glib.out}/lib/girepository-1.0:${gtk3}/lib/girepository-1.0:${gtk4}/lib/girepository-1.0:${gobject-introspection}/lib/girepository-1.0" \
      --add-flags "-m main"
    runHook postInstall;
  '';

  preFixup = ''
    gappsWrapperArgs+=(--set AX_SHELL_WALLPAPERS_DIR_DEFAULT "${placeholder "out"}/share/ax-shell/assets/wallpapers_example");
    gappsWrapperArgs+=(--set FABRIC_CSS_PATH "${placeholder "out"}/share/ax-shell/main.css");
    gappsWrapperArgs+=(--prefix PATH : "${lib.makeBinPath runtimeDeps}");
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${tabler-icons-font}/share");
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${adwaita-icon-theme}/share");
    
    # Aplicar gappsWrapperArgs al wrapper que ya creamos
    wrapGAppsHook
  '';

  meta = {
    description = "A custom, flake-based package for Ax-Shell.";
    homepage = "https://github.com/poogas/Ax-Shell";
    license = lib.licenses.mit;
  };
}
