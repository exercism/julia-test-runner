using Test
using JSON

"""
    tojson(output::String, ts::ReportingTestSet)

Takes user output and a ReportingTestSet and converts it to a JSON string as expected by the interface.
"""
function tojson(output::String, ts::ReportingTestSet)
    tests = Dict{String, Union{String, Nothing}}[]
    for s in ts.results
        status = "pass"
        message = nothing
        for t in s.results
            if typeof(t) == Test.Fail
                status = "fail"
                message = string(t)
            elseif typeof(t) == Test.Error
                status = "error"
                message = t.backtrace

                # status "error" supersedes "fail", therefore the loop does not need to continue
                break
            end
        end

        # test object
        push!(tests, Dict(
            "name" => s.description,
            "status" => status,
            "message" => message,
            "output" => isempty(output) ? nothing : first(output, 500), # only show the first 500 characters
        ))
    end

    status = "pass"
    message = nothing
    for t in tests
        if t["status"] == "fail"
            status = t["status"]
        elseif t["status"] == "error"
            status = t["status"]
            message = t["message"]

            # status "error" supersedes "fail", therefore the loop does not need to continue
            break
        end
    end
    
    JSON.json(Dict(
        "status" => status,
        "message" => message,
        "tests" => tests,
    ))
end
