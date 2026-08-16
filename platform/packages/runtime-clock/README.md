# @mentora/runtime-clock

Implementations of the kernel `Clock` port — the port stays owned by its
consumers (F4.4 §3/I-4); these are the mechanisms below. **The ONE vestibule
where the machine clock is read** (A-6: "identité, temps, corrélation :
injectés, jamais ambiants"; "horloge lue" is an absolute interdiction inside
the rings). `SystemClock` (wall instants), `MonotonicClock` (technical
durations only — never an Instant of truth), `clockFactory`. No
`FakeClockRuntime`: the ratified test double is `FakeClock` in
`@mentora/testing-clock` (0C) — one definition per truth.
