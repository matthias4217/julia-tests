using Printf

#= import Pkg
Pkg.add("JuMP")
Pkg.add("Ipopt") =#

using Ipopt, JuMP

β::Real = 100

#= This function takes two variables (x and y) and a parameter (alpha), and returns x^2 + y^2 + 3 * alpha =#
function test(var_x::Real, var_y::Real, param_alpha=42.)
    res = var_x^2 + var_y^2 + 3param_alpha + β
    @printf "test: var_x :       %.2f\n" var_x
    @printf "test: var_y :       %.2f\n" var_y
    @printf "test: param_alpha : %.2f\n" param_alpha
    @printf "test: param_res   : %.2f\n" res
    return res
end

#= This is a wrapper around test. It takes a tuple of two variables, and a tuple of one parameter and feeds them to test. =#
function test_wrapper((var_x, var_y), (param_alpha,))
    test(var_x, var_y, param_alpha)
    
end

function solver(o_param_alpha)
    @printf "Begin solver execution\n"

    @printf "Initializing model in solver\n"
    model = Model(Ipopt.Optimizer)

    register(model, :test, 3, test; autodiff = true)

    @variable(model, x, start=10.)
    @variable(model, y, start=100.)
    @constraint(model, x >= 0)
    @NLparameter(model, param_alpha == o_param_alpha)

    @NLobjective(model, Min, test(x, y, param_alpha))
    @printf "Model initialized\n"

    @printf "Launching optimization\n"
    JuMP.optimize!(model)
    @printf "Optimization complete\n"
    @printf "Results\n"
    println("$(x) = $(JuMP.value(x))")
    println("$(y) = $(JuMP.value(y))")
    println("var_x^2 + var_y^2 + 3*param_alpha = $(test(JuMP.value(x),JuMP.value(y),o_param_alpha))")
end

test_wrapper((763., 42.), (666.,))

solver(27.)