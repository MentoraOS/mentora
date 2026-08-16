import { RuntimeContainer } from './runtime-container.js';
import { RuntimeRegistry } from './runtime-module.js';
import type { BootValidator, RuntimeModule } from './runtime-module.js';

/**
 * RuntimeBuilder — the declarative assembly the Root writes: modules in
 * DEPENDENCY ORDER (they will die in reverse — I-11), proofs declared
 * before life. The build yields a readable RuntimeAssembly inside its
 * container — legible tables are a frozen property (F4.1.99).
 */
export class RuntimeBuilder {
  private readonly registry = new RuntimeRegistry();
  private readonly validators: BootValidator[] = [];

  withModule(module: RuntimeModule): this {
    this.registry.register(module);
    return this;
  }

  withValidator(validator: BootValidator): this {
    this.validators.push(validator);
    return this;
  }

  build(): RuntimeContainer {
    return new RuntimeContainer({
      modules: this.registry.modules(),
      validators: [...this.validators],
    });
  }
}
