//          Copyright Daniel Nielsen 2016 - 2017.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

//
// Dynamic Mixin Inheritance - proof of concept
//
// This technique can be used to implement a fully automatic visitor pattern!
//
enum dynamic;

template Dynamic(T)
{
  import std.traits : getSymbolsByUDA;

  final static class Dynamic : T
  {
    this(){}

    // Reintroduce super constructors
    static if(is(typeof(super.__ctor)))
      alias __ctor = super.__ctor;

    static foreach(mix; getSymbolsByUDA!(T, dynamic))
      mixin mix;
  }
}

T make(T, A...)(auto ref A args)
{
  return new Dynamic!T(args);
}

class Base
{
  this(int x = 10, int y=20){}
  this(string str){}
  abstract string name();

  @dynamic mixin template Name()
  {
    alias Dynamic = typeof(super);
    static if(__traits(isAbstractFunction, Dynamic.name))
      override string name() { return Dynamic.stringof; }
  }
}
class Child : Base {}
class GrandChild : Child {}

void main()
{
  Base[] xs = [make!Base, make!Child, make!GrandChild];

  import std.stdio;
  foreach(x; xs)
    writeln(x.name);
}
