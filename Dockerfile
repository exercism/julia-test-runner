FROM julia:1.5.2

WORKDIR /opt/test-runner/

COPY run.sh /opt/test-runner/bin/
COPY run.jl /opt/test-runner/

# Install Julia dependencies
COPY src/ ./src/
COPY Manifest.toml ./
COPY Project.toml ./
RUN julia --project -e 'using Pkg; Pkg.instantiate()'

ENTRYPOINT ["sh", "/opt/test-runner/bin/run.sh"]
