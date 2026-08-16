# @mentora/runtime-tracing

The sampled shadow (F5.3 O-4): "la chaîne éternelle n'est pas la trace —
c'est la provenance des faits et la corrélation des journaux ; l'audit se
refait sans traces." `TraceId`/`SpanId` are telemetry DIALECTS (F5.3 §10) —
never domain vocabulary; `SessionId` is reserved to I&A and never appears in
telemetry. W3C traceparent propagation as pure encoding — no vendor SDK
(O-10: "aucun vendor ne possède la télémétrie"). Sampling applies to the
perdable only (F5.3 §9); an unsampled span records nothing.
