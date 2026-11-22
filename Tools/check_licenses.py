"""Verifica se assets de terceiros possuem registro em LICENSES.csv."""
import csv
import pathlib
import sys

root = pathlib.Path(__file__).resolve().parent.parent / "Content" / "ThirdParty"
manifest = root / "LICENSES.csv"
if not manifest.exists():
    print("ERRO: Content/ThirdParty/LICENSES.csv não encontrado")
    sys.exit(1)

with manifest.open(encoding="utf-8", newline="") as handle:
    listed = {row["asset"] for row in csv.DictReader(handle) if row.get("asset")}

extensions = {".fbx", ".glb", ".gltf", ".obj", ".png", ".jpg", ".jpeg", ".exr",
              ".wav", ".ogg", ".mp3", ".uasset"}
missing = [str(path.relative_to(root)) for path in root.rglob("*")
           if path.is_file() and path.suffix.lower() in extensions
           and str(path.relative_to(root)) not in listed]

print("\n".join(f"SEM LICENÇA: {item}" for item in missing)
      or "OK: todos os assets têm licença registrada")
sys.exit(1 if missing else 0)