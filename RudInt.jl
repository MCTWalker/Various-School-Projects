module RudInt

push!(LOAD_PATH, ".")

using Error
using Lexer
export interp

opDict = Dict(:+ => +, :- => -)

abstract type OWL end

type NumNode <: OWL
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

type PlusNode <: OWL
    lhs::OWL
    rhs::OWL
end

type MinusNode <: OWL
    lhs::OWL
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
    return NumNode( expr )
end

function parse( expr::Array{Any} )
    if expr[1] == :+
        return PlusNode( parse( expr[2] ), parse( expr[3] ) )
    elseif expr[1] == :-
        return MinusNode( parse( expr[2] ), parse( expr[3] ) )
    end
    error("Unknown operator!")
end

function interp( cs::AbstractString )
    lxd = Lexer.lex( cs )
    ast = parse( lxd )
    return calc( ast )
end

function calc( ast::NumNode )
    return ast.n
end

function calc( ast::PlusNode )
    return calc( ast.lhs ) + calc( ast.rhs )
end

function calc( ast::MinusNode )
    return calc( ast.lhs ) - calc( ast.rhs )
end


end #module
