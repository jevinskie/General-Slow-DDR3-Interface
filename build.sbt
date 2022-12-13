val spinalVersion = "1.8.0b"
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

resolvers ++= Resolver.sonatypeOssRepos("snapshots")
libraryDependencies += "com.github.alexarchambault" %% "case-app" % "2.1.0-M21"

fork          := true
scalacOptions := Seq("-deprecation")
