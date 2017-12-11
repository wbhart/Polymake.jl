const oldwdir = pwd()
const pkgdir = Pkg.dir("Polymake")
const nemodir = Pkg.dir("Nemo")

wdir = "$pkgdir/deps"
vdir = "$pkgdir/local"
nemovdir = "$nemodir/local"

LDFLAGS = "-Wl,-rpath,$vdir/lib -Wl,-R$vdir/lib -Wl,-R$nemovdir/lib -Wl,-R\$\$ORIGIN/../share/julia/site/v$(VERSION.major).$(VERSION.minor)/Polymake/local/lib"

cd(wdir)

const polymake = joinpath(wdir, "polymake")

try
  run(`git clone https://github.com/polymake/polymake.git`)
catch
  cd(polymake)
  try
     run(`git pull --rebase`)
  catch
  end
  cd(wdir)
end

cd(polymake)

withenv("CPP_FLAGS"=>"-I$vdir/include", "LD_LIBRARY_PATH"=>"$vdir/lib:$nemodir/lib") do
   run(`$polymake/configure --prefix=$vdir --with-gmp=$nemovdir --with-mpfr=$nemovdir`)
   withenv("LDFLAGS"=>LDFLAGS) do
      run(`make -j4`)
      run(`make install`)
   end
end

cd(wdir)

push!(Libdl.DL_LOAD_PATH, "$pkgdir/local/lib")

cd(oldwdir)
