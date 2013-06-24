addSbtPlugin("com.typesafe.sbteclipse" % "sbteclipse-plugin" % "2.2.0")

addSbtPlugin("me.lessis" % "np" % "0.2.0")

addSbtPlugin("com.github.mpeltonen" % "sbt-idea" % "1.4.0")

addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.9.0")

addSbtPlugin("com.orrsella" % "sbt-stats" % "1.0.2")

resolvers += Resolver.url("sbt-plugin-releases", new URL("http://scalasbt.artifactoryonline.com/scalasbt/sbt-plugin-releases/"))(Resolver.ivyStylePatterns)

addSbtPlugin("com.typesafe.sbt" % "sbt-pgp" % "0.8")

addSbtPlugin("com.typesafe.sbt" % "sbt-scalariform" % "1.0.1")
