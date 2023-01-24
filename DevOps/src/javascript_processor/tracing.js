/*tracing.js*/
const { Resource } = require("@opentelemetry/resources");
const { SemanticResourceAttributes } = require("@opentelemetry/semantic-conventions");
const { NodeTracerProvider } = require("@opentelemetry/sdk-trace-node");
const { registerInstrumentations } = require("@opentelemetry/instrumentation");
const { ConsoleSpanExporter, BatchSpanProcessor } = require("@opentelemetry/sdk-trace-base");
const { ZipkinExporter } = require("@opentelemetry/exporter-zipkin");

// Optionally register instrumentation libraries
registerInstrumentations({
  instrumentations: [],
});

const resource =
  Resource.default().merge(
    new Resource({
      [SemanticResourceAttributes.SERVICE_NAME]: "processor",
      [SemanticResourceAttributes.SERVICE_VERSION]: "0.1.0",
    })
  );

const provider = new NodeTracerProvider({
    resource: resource,
});

provider.addSpanProcessor(new BatchSpanProcessor(new ZipkinExporter()));
provider.addSpanProcessor(new BatchSpanProcessor(new ConsoleSpanExporter()));

provider.register();