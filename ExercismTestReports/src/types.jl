struct TestCase
    name::AbstractString
    status::Symbol
    message::Union{Nothing, AbstractString}

    function TestCase(name, status, message)
        valid_states = (:pass, :fail, :error, :skip)

        if status ∉ valid_states
            throw(DomainError(status, "Only the following states are allowed: $valid_states"))
        end

        new(name, status, message)
    end
end

struct TestReport
    status::Symbol
    message::Union{Nothing, AbstractString}
    tests::Vector{TestCase}

    function TestReport(status, message, tests)
        valid_states = (:pass, :fail, :error)
        
        if status ∉ valid_states
            throw(DomainError(status, "Only the following states are allowed: $valid_states"))
        end
        new(status, message, tests)
    end
end
TestReport(status::Symbol, tests::Vector{TestCase}) = TestReport(status, nothing, tests)

function TestReport(tests::Vector{TestCase})
    for t in tests
        if t.status == :fail
            return TestReport(:fail, t.message, tests)
        elseif t.status == :error
            return TestReport(:error, t.message, tests)
        elseif t.status == :skip
            error("IMPLEMENT THIS")
        end
    end

    # All tests passed
    TestReport(:pass, nothing, tests)
end
