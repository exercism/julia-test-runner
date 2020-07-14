# Julia Test Runner

## Julia-specific files

| File | Purpose |
|------|---------|
| `Project.toml` | Specify `ExercismTestReports` as sole dependency. We're always going to use `ExercismTestReports#master`, so it is not necessary to specify compat bounds. |
| `Manifest.toml` | Pin the dependency versions that the container is meant to use. Should be updated somewhat regularly. |
| `run.jl` | Call the `ExercismTestReports` package to run the tests and create the `results.json` file. |
