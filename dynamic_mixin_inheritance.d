//          Copyright Daniel Nielsen 2016 - 2016.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

//
// Dynamic Mixin Inheritance - proof of concept
//
// This technique can be used to implement a fully automatic visitor pattern!
//
enum dynamic;

T make(T, Args...)(Args args)
{
  import std.traits;

  // xxx - generate string mixin
  alias mix = getSymbolsByUDA!(T, dynamic)[0];

  final static class Mixin : T
  {
    this(Args args) { super(args); }

    // static foreach(...)
    mixin mix;
  }

  return new Mixin(args);
}

class Base
{
  this(int ex=0){}
  abstract string name();

  @dynamic mixin template Name()
  {
    alias This = typeof(super);
    static if(__traits(isAbstractFunction, This.name))
      override string name() { return This.stringof; }
  }
}
class Child : Base {}
class GrandChild : Child {}

void main()
{
  Base[] xs = [make!Base(1), make!Child, make!GrandChild];

  import std.stdio;
  foreach(x; xs)
    writeln(x.name);
}
