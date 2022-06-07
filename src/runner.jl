using IOCapture
using Test

const test_outputs = Dict()

macro test(expr)
    f(result, output) = test_outputs[result] = (output=output, expr=expr);
    :(
      c = $IOCapture.capture() do
          $Test.@test $(esc(expr));
      end;
      $f(c.value, c.output);
      c.value
     )
end

macro test_throws(extype, expr)
    f(result, output) = test_outputs[result] = (output=output, expr=expr);
    :(
      c = $IOCapture.capture() do
          $Test.@test_throws $extype $(esc(expr));
      end;
      $f(c.value, c.output);
      c.value
     )
end

# test_logs is difficult.

"""
    runtests(testfile)

Wrap the testfile in a ReportingTestSet and capture all output.
Returns the output and ReportingTestSet.
"""
function runtests(testfile)
    c = IOCapture.capture() do
        @testset ReportingTestSet "" begin
            include(testfile)
        end
    end

    c.output, c.value
end
