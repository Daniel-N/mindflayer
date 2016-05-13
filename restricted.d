//          Copyright Daniel Nielsen 2014 - 2015.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

// Implements a field with restricted access
mixin template restricted(alias T)
{
  mixin(restricted_impl!T);
}

template restricted_impl(alias T)
{
  import std.uni    : toLower, toUpper;
  import std.traits : FunctionTypeOf;
  import std.format : format;
  import std.string : strip;

  static if(is(FunctionTypeOf!T P == __parameters))
  {
    enum decl = P.stringof[1..$-1]; // strip parenthesis
    enum type = P[0].stringof;
    enum name = decl[type.length..$].strip();
    enum priv = name[0..1].toLower() ~ name[1..$];
    enum publ = name[0..1].toUpper() ~ name[1..$];
    enum init = T(P[0].init);

    enum restricted_impl =
    q{
      union
      {
        private       %s  %s = %s;
        public  const(%s) %s;
      }
    }.format(type, priv, init, type, publ);
  }
}

unittest
{
  struct Struct
  {
    // C# 6.0 ~= public uint Size { get; private set; } = 777;
    mixin restricted!((uint Size) => 777);
  }
  static assert(is(typeof(Struct.size) == uint));
  static assert(is(typeof(Struct.Size) == const(uint)));

  auto test = Struct();
  assert(test.size == 777 && test.Size == 777);
  test.size = 555;
  assert(test.size == 555 && test.Size == 555);
  static assert(!__traits(compiles, {test.Size = 333;}));
}
