import Lake
open Lake DSL

package «egg-tactic»

def buildCargo
    (pkg : Package) (targetFile : FilePath) (targetDest : FilePath)
    (oFileJobs : Array (BuildJob FilePath)) : SpawnM (BuildJob FilePath) :=
  buildFileAfterDepArray targetFile oFileJobs fun _ => do
    proc { cmd := "cargo", args := #["rustc", "--release", "--", "-C", "relocation-model=pic"], cwd := pkg.dir / "json-egg" }
    -- hack (and not very portable)
    createParentDirs targetDest
    proc {
      cmd := "cp"
      args := #[targetFile.toString, targetDest.toString]
    }

target «egg-herbie» pkg : FilePath := do
  let buildDir := pkg.dir / "json-egg"
  let binFile := buildDir / "target" / "release" / "egg-herbie"
  let dest := pkg.dir / "utils" / "egg-herbie"
  buildCargo pkg binFile dest #[]

@[default_target]
lean_lib EggTactic where
  roots := #[`EggTactic]
  precompileModules := true
