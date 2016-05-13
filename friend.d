//          Copyright Daniel Nielsen 2014 - 2015.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

import std.typecons;

class Awesome1
{
public:
  int val;
  this(string caller = __MODULE__)(int val) if(caller == "std.conv") // Use scoped!Awesome
  {
    this.val = val;
  }
}

class Awesome2
{
public:
  int val;
  this(string caller = __MODULE__)(int val)
  {
    static assert(caller == "std.conv", "Use scoped!Awesome(...)!");

    this.val = val;
  }
}

unittest
{
  static assert(__traits(compiles, scoped!Awesome1(1)));
  static assert(__traits(compiles, scoped!Awesome2(1)));
  static assert(!__traits(compiles, new Awesome1(1)));
  static assert(!__traits(compiles, new Awesome2(1)));
}
