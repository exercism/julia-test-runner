# julia:1.4.2-alpine is not available and 1.5.0 is not stable yet.
FROM julia:1.4.2

WORKDIR /opt/test-runner/

COPY run.sh /opt/test-runner/bin/
COPY run.jl /opt/test-runner/

# Install Julia dependencies
COPY Manifest.toml ./
COPY Project.toml ./
RUN julia --project -e 'using Pkg; Pkg.instantiate()'

ENTRYPOINT ["sh", "/opt/test-runner/bin/run.sh"]
