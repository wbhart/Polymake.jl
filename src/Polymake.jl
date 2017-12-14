module Polymake

using Cxx

const pkgdir = realpath(joinpath(dirname(@__FILE__), ".."))
const libdir = joinpath(pkgdir, "local", "lib")

prefix = joinpath(Pkg.dir("Polymake"), "local");

addHeaderDir(joinpath(prefix, "include"), kind = C_User)

const libpolymake = joinpath(pkgdir, "local", "lib", "libpolymake")

function __init__()
   push!(Libdl.DL_LOAD_PATH, libdir)

   if is_linux()
      Libdl.dlopen(libpolymake)
   end

   cxxinclude(joinpath("polymake/Main.h"), isAngled = false)
end

function init()
   icxx"""using namespace polymake; Main* polymake_main = new Main();"""
   #icxx"""using namespace polymake; greeting(2);"""
end

export init

end # module
