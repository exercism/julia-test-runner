# This file is derived from Julia's stdlib's DefaultTestSet implementation[1] released under the MIT licence [2].
# A full copy of the licence is attached below.
# [1] https://github.com/JuliaLang/julia/blob/v1.4.2/stdlib/Test/src/Test.jl#L742
# [2] https://github.com/JuliaLang/julia/blob/v1.4.2/LICENSE.md
# Copyright (c) 2009-2019: Jeff Bezanson, Stefan Karpinski, Viral B. Shah, and other contributors:
#
# https://github.com/JuliaLang/julia/contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Test: AbstractTestSet, Broken, Pass, Fail, Error, LogTestFailure
import Test: record, finish, scrub_backtrace, get_testset_depth, get_testset

mutable struct ReportingTestSet <: AbstractTestSet
    description::String
    results::Vector
end
ReportingTestSet(desc; args...) = ReportingTestSet(desc, [])

# Store _all_ results
record(ts::ReportingTestSet, t::Union{Fail, Error, Broken, Pass, LogTestFailure}) =
    (push!(ts.results, t); t)

# When a ReportingTestSet finishes, it records itself to its parent
# testset, if there is one. This allows for recursive printing of
# the results at the end of the tests
record(ts::ReportingTestSet, t::AbstractTestSet) = push!(ts.results, t)

# Called at the end of a @testset, behaviour depends on whether
# this is a child of another testset, or the "root" testset
function finish(ts::ReportingTestSet)
    # If we are a nested test set, do not print a full summary
    # now - let the parent test set do the printing
    if get_testset_depth() != 0
        # Attach this test set to the parent test set
        parent_ts = get_testset()
        record(parent_ts, ts)
        return ts
    end

    # return the testset so it is returned from the @testset macro
    ts
end
