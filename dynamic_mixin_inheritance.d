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
  import std.array  : join;
  import std.meta   : Filter;
  import std.format : format;
  import std.traits : hasUDA;
  import std.algorithm;

  enum isDynamic(alias mem) = hasUDA!(__traits(getMember, T, mem), dynamic);
  enum mix = [Filter!(isDynamic, __traits(allMembers, T))]
    .map!(s => "mixin %s;".format(s))
    .join;

  final static class Mixin : T
  {
    this(Args args) { super(args); }

    // static foreach(...)
    mixin(mix);
  }

  return new Mixin(args);
}

class Base
{
  this(int ex=0){}
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
  Base[] xs = [make!Base(1), make!Child, make!GrandChild];

  import std.stdio;
  foreach(x; xs)
    writeln(x.name);
}
