FROM julia:1.13.1 AS build-sysimage

WORKDIR /tmp/image-builder/

# PackageCompiler needs gcc or clang
RUN apt-get update && apt-get install -y --no-install-recommends clang git

# Copy ExercismTestReports
COPY src/ ./src/
COPY Manifest.toml ./
COPY Project.toml ./

# PackageSpec requires a git repo
RUN git init && \
    git config --global user.email "you@example.com" && \
    git config --global user.name "Your Name" && \
    git add src Manifest.toml Project.toml && \
    git commit -m 'Initial commit'

# Prepare precompiliation files
COPY precompile_execution_file.jl ./precompile_execution_file.jl
COPY test/fixtures/everything_at_once/runtests.jl ./test/fixtures/everything_at_once/runtests.jl

# Compile sysimage
RUN julia --project=build-env -e 'using Pkg; Pkg.add("PackageCompiler"); Pkg.add(PackageSpec(path="."))'
RUN julia --project=build-env -e 'using PackageCompiler; create_sysimage(:ExercismTestReports; sysimage_path = "test-runner-sysimage.so", precompile_execution_file="precompile_execution_file.jl", cpu_target="x86-64")'

FROM julia:1.13.1 AS pruned-julia

# The runner has its own custom sysimage so we don't need the existing one.
# There are some other miscellaneous files we don't need at runtime.

RUN rm -rf \
        /usr/local/julia/include \
        /usr/local/julia/lib/julia/sys.so \
        /usr/local/julia/share/doc \
        /usr/local/julia/share/julia/test && \
    find /usr/local/julia/share/julia/compiled \
        -type f \( -name '*_LSldD.ji' -o -name '*_LSldD.so' \) -delete

FROM debian:trixie-slim@sha256:f6b08b09a05725f9431502d3b5714f5c4576e82c1a84fa1debe0c24a7e0c3ec4 AS runner

ENV JULIA_PATH=/usr/local/julia \
    PATH=/usr/local/julia/bin:$PATH

COPY --from=pruned-julia /usr/local/julia/ /usr/local/julia/

WORKDIR /opt/test-runner/

COPY --from=build-sysimage /tmp/image-builder/test-runner-sysimage.so ./test-runner-sysimage.so

# Copy ExercismTestReports
COPY src/ ./src/
COPY Manifest.toml ./
COPY Project.toml ./

COPY run.sh /opt/test-runner/bin/
COPY run.jl /opt/test-runner/

ENTRYPOINT ["sh", "/opt/test-runner/bin/run.sh"]
