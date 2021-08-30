using Suppressor
using Test

"""
    runtests(testfile)

Wrap the testfile in a ReportingTestSet and capture all output.
Returns the output and ReportingTestSet.
"""
function runtests(testfile)
    # The Suppressor macro wraps everything in a try...finally block, therefore rts needs to be introduced before
    local rts
    output = @capture_out rts = @testset ReportingTestSet "" begin
        include(testfile)
    end

    output, rts
end
