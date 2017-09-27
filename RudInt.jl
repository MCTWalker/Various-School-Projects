module RudInt

push!(LOAD_PATH, ".")

using Error
using Lexer
export interp

opDict = Dict(:+ => +, :- => -, :mod => mod, :* => *, :/ => /)

abstract type OWL end

type Num <: OWL
	n::Real
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

function parse( expr::Number )
    return Num( expr )
end

function parse( expr::Array{Any} )
    if expr[1] == :+ || expr[1] == :- || expr[1] == :/ || expr[1] == :* || expr[1] == :mod || expr[1] == :collatz
        return Binop(opDict[expr[1]], parse( expr[2] ), parse( expr[3] ) )
    elseif expr[1] == :-
        return MinusNode(expr[1], parse( expr[2] ), parse( expr[3] ) )
    end
    error("Unknown operator!")
end

function interp( cs::AbstractString )
    lxd = Lexer.lex( cs )
    ast = parse( lxd )
    return calc( ast )
end

function calc( ast::Num )
    return ast.n
end

function calc( ast::Binop )
    return ast.op(calc( ast.lhs ), calc( ast.rhs ))
end

function calc( ast::Unop )
    return ast.op(calc( ast.rhs ))
end

end #module
