//          Copyright Daniel Nielsen 2016 - 2016.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

//
// Named Parameters
//
import std.traits;
import std.typetuple;
import std.algorithm;

// Fix for Issue 13780
template ParameterIdentifierTuple(func...) if (func.length == 1 && isCallable!func)
{
  static if (is(FunctionTypeOf!func PT == __parameters))
  {
    template Get(size_t i)
    {
        // Unnamed parameters yield CT error.
        static if (is(typeof(__traits(identifier, PT[i..i+1]))))
        {
            enum Get = __traits(identifier, PT[i..i+1]);
        }
        else
        {
            enum Get = "";
        }
    }
  }
  else
  {
    static assert(0, func[0].stringof ~ "is not a function");

    // Define dummy entities to avoid pointless errors
    template Get(size_t i) { enum Get = ""; }
    alias PT = TypeTuple!();
  }

  template Impl(size_t i = 0)
  {
    static if (i == PT.length)
        alias Impl = TypeTuple!();
    else
        alias Impl = TypeTuple!(Get!i, Impl!(i+1));
  }

  alias ParameterIdentifierTuple = Impl!();
}

void fun_impl(int x, int y, int z)
{
  import std.stdio;

  writeln("x=", x);
  writeln("y=", y);
  writeln("z=", z);
}

auto fun(T...)()
{
  int x,y,z;
  foreach(t; T)
    static if(__traits(isTemplate, t))
      mixin(ParameterIdentifierTuple!(t!int)[0] ~ " = t(0);");
    else
      mixin(ParameterIdentifierTuple!t[0] ~ " = t(0);");
    
  return fun_impl(x, y, z);
}

void main()
{
  int i = 1;
  fun!(x=>i, y=>2, z=>3);
  fun!((int z)=>3, y=>2, x=>1); 
}
