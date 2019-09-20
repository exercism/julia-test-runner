module ExercismTestReports

include("types.jl")
include("reporting_testset.jl")
include("report-generator.jl")

export ReportingTestSet, generate_json_report

end # module
