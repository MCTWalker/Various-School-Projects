
module ExtInt

push!(LOAD_PATH, ".")

using Error
using Lexer
export interp

DEBUG = false;

abstract type OWL end

type NumNode <: OWL
	n::Real
end

type SymbolNode <: OWL
  the_sym::Symbol
end

type Binop <: OWL
	op::Function
	lhs::OWL
	rhs::OWL
end

type Unop <: OWL
	op::Function
	rhs::OWL
end

type If0Node <: OWL
  condition::OWL
  zero_branch::OWL
  nonzero_branch::OWL
end

type BindingEnv <:OWL
  names::Array{Symbol}
  binding_exprs::Array{OWL}
end

type WithNode <: OWL
  binding_env::BindingEnv
  body::OWL
end

type IdNode <: OWL
  name::Symbol
end

type FunDefNode <: OWL
    formal_parameters::Array{Symbol}
    fun_body::OWL
end

type FunAppNode <: OWL
    fun_expr::OWL
    arg_exprs::Array{OWL}
end

# Rejigger our type hierarchy to better support return values

abstract type RetVal end

type NumVal <: RetVal
  n::Real
end

# Definitions for our environment data structures

abstract type Environment end

type mtEnv <: Environment
end

type CEnvironment <: Environment
  names::Array{Symbol}
  values::Array{RetVal}
  parent::Environment
end

type ClosureVal <: RetVal
    params::Array{Symbol}
    body::OWL
    env::Environment  # this is the environment at definition time!
end

function printlnD(str::String)
  if (DEBUG)
    println(str)
  end
end

function collatz( n::Real )
  return collatz_helper( n, 0 )
end

function collatz_helper( n::Real, num_iters::Int )
  if n == 1
    return num_iters
  end
  if mod(n,2)==0
    return collatz_helper( n/2, num_iters+1 )
  else
    return collatz_helper( 3*n+1, num_iters+1 )
  end
end

opDict = Dict(:+ => +, :- => -, :mod => mod, :* => *, :/ => /, :collatz => collatz)

function parse( expr::Number )
    return NumNode( expr )
end

function parse( expr::Symbol )
    printlnD("Making symbol node")
    return SymbolNode( expr )
end

function addToBindingArray(expr::Array{Any}, env::BindingEnv)
  if (length(expr) < 2)
    throw( LispError("Invalid arity for with node binding expression"))
  end

  if (typeof(expr[1]) == Symbol)
    if (expr[1] in env.names)
      throw( LispError("Duplicate identifiers in with expression"))
    end
    push!(env.names, expr[1])
  else
    throw( LispError("Expected symbol as first item in binding expression"))
  end

  push!(env.binding_exprs, parse(expr[2]))
end

function parse( expr::Array{Any} )

    printlnD("length expr: " * string(length(expr)))
    if (expr[1] == :+ || expr[1] == :/ || expr[1] == :* || expr[1] == :mod || expr[1] == :-) && length(expr) == 3
        return Binop(opDict[expr[1]], parse( expr[2] ), parse( expr[3] ) )

    elseif (expr[1] == :- || expr[1] == :collatz) && length(expr) == 2
        return Unop(opDict[expr[1]], parse( expr[2] ))

    elseif expr[1] == :with && length(expr) == 3
        printlnD("With node beginning")
        if (typeof(expr[2]) == Vector{Any})
          printlnD("Got an array of any")
          bEnv = BindingEnv(Symbol[], OWL[])
          for i in 1:(length(expr[2]))
            addToBindingArray(expr[2][i], bEnv)
          end
          return WithNode(bEnv, parse(expr[3]))
        else
          throw( LispError("Invalid syntax for with"))
        end
    elseif expr[1] == :if0 && length(expr) == 4
        return If0Node( parse(expr[2]), parse(expr[3]) , parse(expr[4]) )

    elseif expr[1] == :lambda && length(expr) == 3
        printlnD("lambda beginning")
        if typeof(expr[2]) == Vector{Any}
          for i in 1:length(expr[2])
            if typeof(expr[2][i]) != Symbol
              throw( LispError("Invalid formal parameter in lambda"))
            end
          end
        else
          throw( LispError("lambda formal parameters must be in parentheses"))
        end
        return FunDefNode(expr[2], parse(expr[3]) )

    elseif typeof(expr[1]) == Vector{Any} || typeof(expr[1]) == Array{Any}
       printlnD("FunAppNode beginning")
       actual_param_exprs = OWL[];
       for i in 2:(length(expr))
         push!(actual_param_exprs, parse(expr[i]))
       end
       return FunAppNode( parse(expr[1]), actual_param_exprs )
    end
    throw( LispError("Unknown operator or invalid function arity"))
end

function interp( cs::AbstractString )
    lxd = Lexer.lex( cs )
    ast = parse( lxd )
    return calc( ast, mtEnv() )
end

function calc( ast::NumNode, env::Environment )
    return ast.n
end

function calc( ast::NumVal, env::Environment )
    return ast.n
end

function calc( ast::Binop, env::Environment )
    printlnD("Calculating binop")
    result = calc( ast.rhs, env )
    printlnD(string(result))
    if (ast.op == opDict[:/] && result == 0)
        throw( LispError("Division by zero"))
    end
    return ast.op(calc( ast.lhs, env ), result)
end

function calc( ast::Unop, env::Environment )
    result = calc( ast.rhs, env )
    if (ast.op == collatz && result <= 0 )
        throw( LispError("collatz of a negative number or zero was attempted"))
    end
    return ast.op(result)
end

function calc( ast::WithNode, env::Environment )
    ext_env = CEnvironment(Symbol[], RetVal[], mtEnv())
    for i in 1:length(ast.binding_env.names)
        ze_binding_val = calc( ast.binding_env.binding_exprs[i], env )
        push!(ext_env.names, ast.binding_env.names[i])
        push!(ext_env.values, NumVal(ze_binding_val))
    end
    printlnD("ext_env names length = " * string(length(ext_env.names)))
    return calc( ast.body, ext_env )
end

function calc( ast::SymbolNode, env::mtEnv )
    throw( LispError("Undefined variable!"))
end

function calc( ast::SymbolNode, env::CEnvironment )
    if ast.the_sym in env.names
        return calc(env.values[findfirst(env.names, ast.the_sym)], env)
    else
        return calc( ast, env.parent )
    end
end

function calc( ast::If0Node, env::Environment )
    cond = calc( ast.condition, env )
    if cond == 0
        return calc( ast.zero_branch, env )
    else
        return calc( ast.nonzero_branch, env )
    end
end

function calc( ast::FunDefNode, env::Environment )
    return ClosureVal( ast.formal_parameters, ast.fun_body, env )
end

function calc( ast::FunAppNode, env::Environment )
    actual_parameters = NumVal[]
    for i in 1:length(ast.arg_exprs)
      push!(actual_parameters, NumVal(calc(ast.arg_exprs[i], env)))
    end
    #todo check if actual_parameters length matches formal parameters length
    the_closure_val = calc( ast.fun_expr, env )  # will always be a closureval!
    #parent = env
    parent = the_closure_val.env
    ext_env = CEnvironment(the_closure_val.params, actual_parameters, parent )
    return calc( the_closure_val.body, ext_env )
    #return ext_env
end

end #module
