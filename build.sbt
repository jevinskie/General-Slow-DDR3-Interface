val spinalVersion = "1.7.1"
val spinalCore    = "com.github.spinalhdl" %% "spinalhdl-core" % spinalVersion
val spinalLib     = "com.github.spinalhdl" %% "spinalhdl-lib"  % spinalVersion
val spinalIdslPlugin = compilerPlugin(
  "com.github.spinalhdl" %% "spinalhdl-idsl-plugin" % spinalVersion
)

lazy val mylib = (project in file("."))
  .settings(
    name := "slowDDR3",
    libraryDependencies ++= Seq(spinalCore, spinalLib, spinalIdslPlugin)
  )

resolvers += Resolver.sonatypeRepo("releases")
libraryDependencies += "com.github.alexarchambault" %% "case-app" % "2.1.0-M14"

fork := true
