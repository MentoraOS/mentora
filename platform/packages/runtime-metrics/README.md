# @mentora/runtime-metrics

Technical metrics for the OPERATIONS side. F5.3 O-3, verbatim: "aucune
métrique n'entre dans une Séquence" — structurally, no metric port exists in
a ring; instruments live in adapters, relays and the Runtime. Business
metrics come free from the Reasons (F4.1 §9), derived from journals.
`Counter`/`Gauge`/`Histogram`/`Timer` (over the INJECTED clock),
`MetricsRegistry` (closed, deterministic sorted snapshot, no global
singleton), `MetricsSink` — deliberately NOT "Exporter": « Export » is a
reserved word (the person's data right, F5.2 §12/P9.6).
