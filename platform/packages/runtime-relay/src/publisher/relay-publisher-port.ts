import type { RelayEnvelope } from '../dispatch/relay-envelope.js';

/**
 * RelayPublisherPort — the relay's door to the Bus, ABSTRACT by law: no
 * Kafka, no RabbitMQ, no NATS, no cloud here — "le Bus ne possède ni les
 * événements ni les abonnements: il possède des tuyaux" (F4.3 §3); the
 * routing fan-out to declared subscribers is the Bus's projection (M-5),
 * never the relay's knowledge. A throw = a failed delivery attempt
 * (technical — the retry engine's food, M-8).
 */
export interface RelayPublisherPort {
  publish(envelope: RelayEnvelope): Promise<void>;
}
