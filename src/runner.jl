using Suppressor
using Test

"""
    runtests(testfile)

Wrap the testfile in a ReportingTestSet and capture all output.
Returns the output, ReportingTestSet, and a Bool indicating type of exercise: true for concept, false for practice or unspecified.
"""
function runtests(testfile)
    # The Suppressor macro wraps everything in a try...finally block, therefore rts and concept need to be introduced before
    local rts
    local concept
    output = @capture_out rts = @testset ReportingTestSet "" begin
        include(testfile)
        concept = (@isdefined EXERCISM_CONCEPT_EXERCISE) ? EXERCISM_CONCEPT_EXERCISE : false
    end

    output, rts, concept
end
