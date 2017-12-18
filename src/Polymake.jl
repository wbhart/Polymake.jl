module Polymake

using Cxx

const pkgdir = realpath(joinpath(dirname(@__FILE__), ".."))
const libdir = joinpath(pkgdir, "local", "lib")

prefix = joinpath(Pkg.dir("Polymake"), "local");

addHeaderDir(joinpath(prefix, "include"), kind = C_User)

const libpolymake = joinpath(pkgdir, "local", "lib", "libpolymake")

global pmmain

function __init__()
   push!(Libdl.DL_LOAD_PATH, libdir)

   if is_linux()
      Libdl.dlopen(libpolymake,Libdl.RTLD_GLOBAL)
   end

   cxxinclude(joinpath("polymake/Main.h"), isAngled = false)
   global pmmain = @cxxnew pm::perl::Main()
   print(String(@cxx pmmain->greeting()))
   icxx"""$pmmain->set_application(std::string{$("polytope")});"""
end


function application(x)
   icxx"""$pmmain->set_application(std::string{$x});"""
end

export application

end # module

