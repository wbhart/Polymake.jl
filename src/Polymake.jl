module Polymake

using Cxx

const pkgdir = realpath(joinpath(dirname(@__FILE__), ".."))
const libdir = joinpath(pkgdir, "local", "lib")

prefix = joinpath(Pkg.dir("Polymake"), "local");

addHeaderDir(joinpath(prefix, "include"), kind = C_User)

const libpolymake = joinpath(pkgdir, "local", "lib", "libpolymake")

global pmmain

function include(file)
   eval(Cxx.process_cxx_string("""
   #pragma clang diagnostic push
   #pragma clang diagnostic ignored "-Wlogical-op-parentheses"
   #pragma clang diagnostic ignored "-Wshift-op-parentheses"
   #include "polymake/$file"
   #pragma clang diagnostic pop
   """,true,false))
end

function __init__()
   push!(Libdl.DL_LOAD_PATH, libdir)

   if is_linux()
      Libdl.dlopen(libpolymake,Libdl.RTLD_GLOBAL)
   end

   include("Main.h")
   global pmmain = @cxxnew pm::perl::Main()
   print(String(@cxx pmmain->greeting()))
   icxx"""$pmmain->set_application(std::string{$("polytope")});"""
end


function application(x)
   icxx"""$pmmain->set_application(std::string{$x});"""
end

function cube(d)
   return icxx"""polymake::perl::Object x = polymake::call_function("cube",$d); return x;"""
end

function give_int(p,property)
   return icxx"""return int($p.give(std::string{$property}));"""
end

export application, cube, give_int

end # module

