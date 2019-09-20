using JSON3

JSON3.StructType(::Type{TestCase}) = JSON3.Struct()
JSON3.StructType(::Type{TestReport}) = JSON3.Struct()

function generate_json_report(testfile)
    # Run tests and save results in a TestReport
    cases = (@testset ReportingTestSet "$testfile" begin include(testfile) end).cases
    report = TestReport(cases)
    
    # Write JSON
    JSON3.write(report)
end

generate_json_report(io::IO, testfile) = nothing # TODO
