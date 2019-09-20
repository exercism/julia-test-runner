import Test: record, finish
using Test
using Test: AbstractTestSet, Result, Pass

struct RecordingTestSet <: AbstractTestSet
    desc::AbstractString
    results::Vector

    RecordingTestSet(desc) = new(desc, [])
end

function record(ts::RecordingTestSet, child::AbstractTestSet)
    push!(ts.results, child)
    # @info "Recording subtestset: $child"
end

function record(ts::RecordingTestSet, res::Result)
    push!(ts.results, res)
    @info "Recording test case: $res"
    @show res.test_type
    @show res.orig_expr
    @show res.data
    @show res.value
end

function finish(ts::RecordingTestSet)
    if Test.get_testset_depth() > 0
        record(Test.get_testset(), ts)
    end
    ts
end
