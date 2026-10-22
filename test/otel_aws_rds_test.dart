// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_aws_rds/otel_aws_rds.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness =
        await maybeInitializeOtelForTest(serviceName: 'otel_aws_rds-test');
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('createDBInstance records engine + class + multi-AZ', () async {
    await tracedAwsRds<String>(
      operation: 'createDBInstance',
      invoke: () async => const AwsRdsCallResult(
        value: 'ok',
        result: AwsRdsResult(
          region: 'us-east-1',
          surface: 'instance',
          dbInstanceId: 'prod-app',
          engine: 'postgres',
          engineVersion: '16.4',
          instanceClass: 'db.r7g.xlarge',
          allocatedStorageGb: 200,
          storageType: 'gp3',
          multiAz: true,
          encryptionAtRest: true,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('aws_rds createDBInstance')!);
    expect(a['aws_rds.engine'], 'postgres');
    expect(a['aws_rds.multi_az'], true);
    expect(a['aws_rds.storage_type'], 'gp3');
  });

  test('storage-full instance status sets span error', () async {
    await tracedAwsRds<String>(
      operation: 'describeDBInstances',
      invoke: () async => const AwsRdsCallResult(
        value: 'ok',
        result: AwsRdsResult(instanceStatus: 'storage-full'),
      ),
    );
    expect(
      spans.findSpanByName('aws_rds describeDBInstances')!.status,
      SpanStatusCode.Error,
    );
  });

  test('Aurora Serverless v2 records ACU range', () async {
    await tracedAwsRds<String>(
      operation: 'createDBCluster',
      invoke: () async => const AwsRdsCallResult(
        value: 'ok',
        result: AwsRdsResult(
          surface: 'cluster',
          dbClusterId: 'aurora-prod',
          engine: 'aurora-postgresql',
          serverlessV2MinCapacity: 0.5,
          serverlessV2MaxCapacity: 16.0,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('aws_rds createDBCluster')!);
    expect(a['aws_rds.serverless_v2.min_acu'], 0.5);
    expect(a['aws_rds.serverless_v2.max_acu'], 16.0);
  });

  test('suppression skips spans', () async {
    await runWithoutAwsRdsInstrumentationAsync(() async {
      await tracedAwsRds<String>(
        operation: 'describeDBInstances',
        invoke: () async => const AwsRdsCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('aws_rds '), isEmpty);
  });
}
