# If you're getting errors about not being able to load this, you may
# need to add the current directory to the module load path:
#
# push!(LOAD_PATH, ".")
#
# This is how I make sure it's reloaded when something changes:
# workspace(); reload("CITypes"); using CITypes
#
# This is a helper function to run through a bunch of tests in a file:
# CITypes.testf( "./tests.txt" )
#

module CITypes # based on the CI5 interpreter

push!(LOAD_PATH, ".")

using Error
using Lexer
export parse, type_of_expr, NumType, BoolType, FunType, NListType

# ===================================================

abstract AE
abstract TypeVal
abstract TypeEnvironment

# ===================================================

# AST nodes for expressions

type Num <: AE
  n::Real
end

type Boolean <: AE
  v::Bool
end

type Plus <: AE
  lhs::AE
  rhs::AE
end

type Minus <: AE
  lhs::AE
  rhs::AE
end

type IsZero <: AE
  arg::AE
end

type IfB <: AE
  condition::AE
  true_branch::AE
  false_branch::AE
end

type With <: AE
  name::Symbol
  binding_expr::AE
  body::AE
end

type Id <: AE
  name::Symbol
end

type FunDef <: AE
  formal_parameter::Symbol
  formal_type::TypeVal
  fun_body::AE
end

type FunApp <: AE
  fun_expr::AE
  arg_expr::AE
end

type NEmpty <: AE
end

type NIsEmpty <: AE
  list::AE
end

type NCons <: AE
  f::AE
  r::AE
end

type NFirst <: AE
  list::AE
end

type NRest <: AE
  list::AE
end

# ===================================================

# AST nodes for types (used for type information as well)

type NumType <: TypeVal
end

type BoolType <: TypeVal
end

type FunType <: TypeVal
  arg_type::TypeVal
  result_type::TypeVal
end

type NListType <: TypeVal
end

# ===================================================

# Type Environments

type mtTypeEnvironment <: TypeEnvironment
end

type CTypeEnvironment <: TypeEnvironment
  name::Symbol
  value::TypeVal
  parent::TypeEnvironment
end

# ===================================================

# Parser for expressions
# functional for valid input, doesn't fully reject bad input)

function parse( expr::Real )
  return Num( expr )
end

function parse( expr::Bool )
  return Boolean( expr )
end

function parse( expr::Symbol )
  if expr == :nempty
    return NEmpty()
  else
    return Id( expr )
  end
end

function parse( expr::Array{Any} )

  op_symbol = expr[1]

  if op_symbol == :+
    lhs = parse( expr[2] )
    rhs = parse( expr[3] )
    return Plus( lhs, rhs )

  elseif op_symbol == :-
    lhs = parse( expr[2] )
    rhs = parse( expr[3] )
    return Minus( lhs, rhs )

  elseif op_symbol == :iszero
    arg = parse( expr[2] )
    return IsZero( arg )

  elseif op_symbol == :ifb
    condition = parse( expr[2] )
    true_branch = parse( expr[3] )
    false_branch = parse( expr[4] )
    return IfB( condition, true_branch, false_branch )

  elseif op_symbol == :with    # (with x (+ 5 1) (+ x x) )
    sym = expr[2]
    binding_expr = parse( expr[3] )
    body = parse( expr[4] )
    return With( sym, binding_expr, body )

  elseif op_symbol == :lambda
    formal = expr[2]
    formal_type = parse_type(expr[4])
    body = parse(expr[5])
    return FunDef( formal, formal_type, body )

  elseif op_symbol == :ncons
    f = parse(expr[2])
    r = parse(expr[3])
    return NCons( f, r )

  elseif op_symbol == :nisempty
    list = parse(expr[2])
    return NIsEmpty( list )

  elseif op_symbol == :nfirst
    list = parse(expr[2])
    return NFirst( list )

  elseif op_symbol == :nrest
    list = parse(expr[2])
    return NRest( list )

  else
    return FunApp( parse(expr[1]), parse(expr[2]) )

  end
end

function parse( expr::Any )
  throw( LispError("Invalid expression $expr") )
end

# ===================================================

# Parser for type expressions

function parse_type( t::Symbol )
  if (t == :number)
    return NumType()
  elseif (t == :boolean)
    return BoolType()
  elseif (t == :nlist)
    return NListType()
  end
end

function parse_type( t :: Array{Any} )
  return FunType( parse_type(t[1]),
                  parse_type(t[3]))
end

function parse_type( expr::Any )
  throw( LispError("Invalid type $expr") )
end

# ===================================================

# Type checking functions (modeled after the earlier calc)

function type_of_expr( ast::AE )
  return type_of_expr( ast, mtTypeEnvironment() )
end

function type_of_expr( ae::Num, env::TypeEnvironment )
  return NumType()
end

function type_of_expr( ae::Boolean, env::TypeEnvironment )
  return BoolType()
end

function type_of_expr( ae::Plus, env::TypeEnvironment )
  left = type_of_expr( ae.lhs, env )
  right = type_of_expr( ae.rhs, env )
  return type_of_math_expr( left, right )
end

function type_of_expr( ae::Minus, env::TypeEnvironment )
  left = type_of_expr( ae.lhs, env )
  right = type_of_expr( ae.rhs, env )
  return type_of_math_expr( left, right )
end

# the rest of your type-checking functions go here...

function type_of_expr( ae::IsZero, env::TypeEnvironment )
  return type_of_iszero_expr(ae.arg)
end

function type_of_expr( ae::IfB, env::TypeEnvironment )
  cond = type_of_expr(ae.condition, env)
  true_branch = type_of_expr(ae.true_branch, env)
  false_branch = type_of_expr(ae.false_branch, env)
  return type_of_IfB_expr(cond, true_branch, false_branch)
end

function type_of_expr( ae::With, env::TypeEnvironment )
  binding_expr_type = type_of_expr(ae.binding_expr)
  new_env = CTypeEnvironment(ae.name, binding_expr_type, env)
  body_expr_type = type_of_expr(ae.body, new_env)
  return body_expr_type
end

function type_of_expr( ae::Id, env::TypeEnvironment )
  if typeof(env) == mtTypeEnvironment
    throw( LispError("Couldn't find Id in scope") )
  end

  if (env.name == ae.name)
    return env.value
  else
    return (type_of_expr(ae, env.parent))
  end
end

function type_of_expr( ae::FunDef, env::TypeEnvironment )
  new_env = CTypeEnvironment(ae.formal_parameter, ae.formal_type, env)
  body_expr_type = type_of_expr(ae.fun_body, new_env)
  return FunType(ae.formal_type, body_expr_type)
end

function type_of_expr( ae::FunApp, env::TypeEnvironment )
  fun_expr_type = type_of_expr(ae.fun_expr, env)
  arg_expr_type = type_of_expr(ae.arg_expr, env)

  if (typeof(fun_expr_type) == FunType )
    if same_type(fun_expr_type.arg_type, agr_expr_type)
      return fun_expr_type.result_type
    else
      throw(LispError("Argument type must match function argument type"))
    end
  else
    throw(LispError("Function expressions must be of type FunType"))
  end
end

function type_of_expr( ae::NEmpty, env::TypeEnvironment )
  return NListType()
end

function type_of_expr( ae::NIsEmpty, env::TypeEnvironment )
  list_type = type_of_expr(ae.list)
  if same_type(list_type, NListType())
    return BoolType()
  else
    throw(LispError("Invalid list passed in to NIsEmpty"))
  end
end

function type_of_expr( ae::NCons, env::TypeEnvironment )
  f_type = type_of_expr(ae.f)
  r_type = type_of_expr(ae.r)
  if same_type(f_type, NumType()) && same_type(r_type, NListType())
    return NListType()
  else
    throw(LispError("Invalid parameters passed in to NCons"))
  end
end

function type_of_expr( ae::NFirst, env::TypeEnvironment )
  list_type = type_of_expr(ae.list)
  if same_type(list_type, NListType())
    return NumType()
  else
    throw(LispError("Invalid list passed in to NFirst"))
  end
end

function type_of_expr( ae::NRest, env::TypeEnvironment )
  list_type = type_of_expr(ae.list)
  if same_type(list_type, NListType())
    return NListType()
  else
    throw(LispError("Invalid list passed in to NRest"))
  end
end

# ===================================================

# Helper function for comparing two type values recursively if necessary

same_type( t1::FunType, t2::FunType ) =
    (same_type( t1.arg_type, t2.arg_type )
  && same_type( t1.result_type, t2.result_type ))

same_type{ T <: TypeVal }( t1::T, t2::T ) = true

same_type( t1::TypeVal, t2::TypeVal ) = false

# ===================================================

# Type judgments (could be folded into type checking functions)

function type_of_math_expr( left::NumType, right::NumType )
  return NumType()
end

function type_of_math_expr( left::Any, right::Any )
  throw( LispError("Operands for + or - must be numbers") )
end

# the rest of your type-judgement functions (if you choose to separate them) go here...

function type_of_iszero_expr( arg::NumType)
  return BoolType()
end

function type_of_iszero_expr( arg::Any)
  throw( LispError("Param for iszero must be a number") )
end

function type_of_IfB_expr(condition::BoolType, true_branch::TypeVal, false_branch::TypeVal)
  if (same_type(true_branch, false_branch))
    return true_branch
  else
    throw( LispError("The true branch and false branch of IfB must both return the same type") )
  end
end

function type_of_IfB_expr(condition::Any, true_branch::Any, false_branch::Any)
  throw( LispError("The condition of an IfB must be a boolean") )
end
# ===================================================

# convenience function to make everything easier
function type_of_expr( expr::AbstractString )
  return type_of_expr( parse( Lexer.lex(expr) ) )
end

# ===================================================

end # module
