package ghost

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class GhostFrontend extends Simulation {
  // Expected parameters: -Dusers=10 -Dramp=20 -DbaseUrl=...
  val nbUsers = Integer.getInteger("users", 10)
  val myRamp = java.lang.Long.getLong("ramp", 20)

  // Will request default posts created by ghost install, with 
  // 1- Base URL (Needs to be passed through JAVA_OPTS="-DbaseUrl=...")
  val baseUrl = System.getProperty("baseUrl")

  // 2- Posts URIs
  // https://stackoverflow.com/q/35730086
  val uriFeeder = Array(
    Map("URIKey" -> s"welcome"),
    Map("URIKey" -> s"the-editor"),
    Map("URIKey" -> s"using-tags"),
    Map("URIKey" -> s"managing-users"),
    Map("URIKey" -> s"private-sites"),
    Map("URIKey" -> s"advanced-markdown"),
    Map("URIKey" -> s"themes")
  ).random

  // HTTP connection setup
  val header  = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
  val httpConf = http
    .baseURL(baseUrl)
    .inferHtmlResources()
    .acceptHeader(header)
    .doNotTrackHeader("1")
    .acceptLanguageHeader("en-US,en;q=0.5")
    .acceptEncodingHeader("gzip, deflate")
    .userAgentHeader("Gatling")
    .disableCaching
    .disableClientSharing
    .maxConnectionsPerHostLikeChrome

  // A scenario is a chain of requests and pauses
  val scn = scenario("GhostFrontend")
    .feed(uriFeeder)
    .exec(http("GET /${URIKey}")
    .get("/${URIKey}/")
  )

  // Execute
  setUp(
    scn.inject(
      atOnceUsers(nbUsers),
      rampUsers(nbUsers) over (myRamp seconds),
      constantUsersPerSec(20) during (myRamp seconds),
      heavisideUsers(100) over (myRamp seconds)
    ).protocols(httpConf)
  )
}
