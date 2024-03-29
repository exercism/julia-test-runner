#!/usr/bin/env bash
set -e

# Synopsis:
# Test the test runner Docker image by running it against a predefined set of 
# solutions with an expected output.
# The test runner Docker image is built automatically.

# Output:
# Outputs the diff of the expected test results against the actual test results
# generated by the test runner Docker image.

# Example:
# ./bin/run-tests-in-docker.sh

# Build the Docker image
docker build --rm -t exercism/julia-test-runner .

# Run the Docker image using the settings mimicking the production environment
docker run \
    --network none \
    --read-only \
    --mount type=bind,src="${PWD}/test",dst=/opt/test-runner/test \
    --mount type=bind,src="${PWD}/bin/run-tests.sh",dst=/opt/test-runner/bin/run-tests.sh \
    --mount type=tmpfs,dst=/tmp \
    --workdir /opt/test-runner \
    --entrypoint /opt/test-runner/bin/run-tests.sh \
    exercism/julia-test-runner
