addSbtPlugin("com.typesafe.sbteclipse" % "sbteclipse-plugin" % "2.3.0")

addSbtPlugin("me.lessis" % "np" % "0.2.0")

addSbtPlugin("com.github.mpeltonen" % "sbt-idea" % "1.5.1")

addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.10.0")

addSbtPlugin("com.orrsella" % "sbt-stats" % "1.0.3")

addSbtPlugin("com.typesafe.sbt" % "sbt-pgp" % "0.8")

addSbtPlugin("com.typesafe.sbt" % "sbt-scalariform" % "1.1.0")

addSbtPlugin("org.xerial.sbt" % "sbt-pack" % "0.3.0")

//addSbtPlugin("com.typesafe.sbt" % "sbt-start-script" % "0.9.0")

addSbtPlugin("com.typesafe.sbt" % "sbt-site" % "0.7.1")

addSbtPlugin("net.virtual-void" % "sbt-dependency-graph" % "0.7.4")

addSbtPlugin("com.timushev.sbt" % "sbt-updates" % "0.1.2")

resolvers += "linter" at "http://hairyfotr.github.io/linteRepo/releases"

addCompilerPlugin("com.foursquare.lint" %% "linter" % "0.1-SNAPSHOT")

addSbtPlugin("org.scalastyle" %% "scalastyle-sbt-plugin" % "0.3.2")
