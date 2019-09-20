import Test: record, finish
using Test
using Test: AbstractTestSet, Result, Pass, Fail, Error
using Test: scrub_backtrace

# TODO
# If Manifest.toml or Project.toml submitted => throw error or show warning. For now.
# result.out as tar file? Full ]st, environment stack etc

struct ReportingTestSet <: AbstractTestSet
    description::AbstractString
    results::Vector
    cases::Vector{TestCase}

    ReportingTestSet(desc) = new(desc, [], TestCase[])
end

function record(ts::ReportingTestSet, child::AbstractTestSet)
    append!(ts.cases, child.cases)
    push!(ts.results, child)
end

# record(::AbstractTestSet, ::Result) is called after a @test macro completes
function record(ts::ReportingTestSet, t::Pass)
    push!(ts.results, t)
    t
end

function record(ts::ReportingTestSet, t::Fail)
    push!(ts.results, t)
    t
end

function record(ts::ReportingTestSet, t::Error)
    # kaputt
    push!(ts.results, t)
    t
end

# final processing for the testset, called after a @testset block executes
function finish(ts::ReportingTestSet)
    testset_depth = Test.get_testset_depth()
    if testset_depth > 0
        parent = Test.get_testset()

        # Only add the parent description if we're not at the first level of the wrapped testsets
        tc_name = testset_depth > 1 ? "$(parent.description) → $(ts.description)" : ts.description

        # According to rules.md, only the first fail should be displayed
        firstfail = findfirst(t -> t isa Fail, ts.results)

        if isnothing(firstfail)
            # No tests failed
            push!(ts.cases, TestCase(tc_name, :pass, nothing))
        else
            tc_message = repr(ts.results[firstfail]) * '\n' * sprint(Base.show_backtrace, scrub_backtrace(backtrace()))
            push!(ts.cases, TestCase(tc_name, :fail, tc_message))
        end


        # # All tests passed, create a TestCase
        # if all(t -> t isa Pass, ts.results)
        #     push!(ts.cases, TestCase("$(parent.description) → $(ts.description)", :pass, nothing))
        # end

        record(parent, ts)
    end
    ts
end
