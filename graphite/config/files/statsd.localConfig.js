{
  deleteIdleStats: true
, graphitePort: 2003
, graphiteHost: "localhost"
, port: 8125
, backends: [ "./backends/graphite" ]
, flushInterval: 1000
, graphite: {
        legacyNamespace: false
  }
}
