# julia:1.4.2-alpine is not available and 1.5.0 is not stable yet.
FROM julia:1.4.2 AS build-sysimage

WORKDIR /tmp/image-builder/

# PackageCompiler needs gcc or clang
RUN apt update && apt install -y clang

# Copy ExercismTestReports
COPY src/ ./src/
COPY Manifest.toml ./
COPY Project.toml ./
# PackageSpec requires a git repo
COPY .git/ ./.git/

# Compile sysimage
RUN julia --project=build-env -e 'using Pkg; Pkg.add("PackageCompiler"); Pkg.add(PackageSpec(path="."))'
RUN julia --project=build-env -e 'using PackageCompiler; create_sysimage(:ExercismTestReports; sysimage_path = "test-runner-sysimage.so")'

FROM julia:1.4.2

WORKDIR /opt/test-runner/

COPY --from=build-sysimage /tmp/image-builder/test-runner-sysimage.so ./test-runner-sysimage.so

# Copy ExercismTestReports
COPY src/ ./src/
COPY Manifest.toml ./
COPY Project.toml ./

COPY run.sh /opt/test-runner/bin/
COPY run.jl /opt/test-runner/

ENTRYPOINT ["sh", "/opt/test-runner/bin/run.sh"]
