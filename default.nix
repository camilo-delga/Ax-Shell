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
  nativeBuildInputs = [ wrapGAppsHook3 pkg-config makeWrapper ];
  buildInputs = [ ax-shell-python tabler-icons-font gtk3 gtk4 glib gobject-introspection pango gdk-pixbuf cairo harfbuzz ] ++ runtimeDeps;
  dontWrapQtApps = true;
  dontWrapGApps = true;
  installPhase = ''
    mkdir -p $out/share/ax-shell $out/bin
    cp -r ./* $out/share/ax-shell/
    makeWrapper ${ax-shell-python}/bin/python $out/bin/ax-shell \
      --add-flags "-m main" \
      --prefix PYTHONPATH : "$out/share/ax-shell" \
      --prefix GI_TYPELIB_PATH : "${glib}/lib/girepository-1.0:${gtk3}/lib/girepository-1.0:${gtk4}/lib/girepository-1.0:${pango}/lib/girepository-1.0:${gdk-pixbuf}/lib/girepository-1.0:${gobject-introspection}/lib/girepository-1.0" \
      --set AX_SHELL_WALLPAPERS_DIR_DEFAULT "$out/share/ax-shell/assets/wallpapers_example" \
      --set FABRIC_CSS_PATH "$out/share/ax-shell/main.css" \
      --prefix PATH : "${lib.makeBinPath runtimeDeps}" \
      --prefix XDG_DATA_DIRS : "${tabler-icons-font}/share:${adwaita-icon-theme}/share"
  '';
  meta = { description = "Ax-Shell"; homepage = "https://github.com/poogas/Ax-Shell"; license = lib.licenses.mit; };
}
