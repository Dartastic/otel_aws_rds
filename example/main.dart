// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_rds/otel_aws_rds.dart';

/// Traces AWS RDS control-plane or RDS Data calls with OpenTelemetry.
///
/// `otel_aws_rds` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each AWS RDS control-plane or RDS Data call in
/// [tracedAwsRds]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-rds-example');

  // Wraps an AWS RDS control-plane or RDS Data API call in a CLIENT span.
  final awsRdsId = await tracedAwsRds<String>(
    operation: 'create',
    invoke: () async {
      // Make the AWS RDS control-plane or RDS Data call here, then report what it returned.
      const id = 'aws_rds_8f3a2c';
      return const AwsRdsCallResult(
          value: id,
          result: AwsRdsResult(
              region: 'us-east-1',
              surface: 'instance',
              dbInstanceId: 'dbinstance_8f3a2c',
              dbClusterId: 'dbcluster_8f3a2c',
              engine: 'mysql',
              engineVersion: '1',
              instanceClass: 'db.t4g.micro',
              allocatedStorageGb: 1,
              iopsProvisioned: 1,
              storageType: 'gp2',
              multiAz: true,
              availabilityZone: 'example',
              serverlessV2MinCapacity: 0.5,
              serverlessV2MaxCapacity: 0.5,
              publiclyAccessible: true,
              iamAuthEnabled: true,
              encryptionAtRest: true,
              kmsKeyId: 'kmskey_8f3a2c',
              endpoint: 'example',
              port: 443,
              instanceStatus: 'available',
              clusterStatus: 'succeeded',
              backupRetentionDays: 1,
              errorCode: 'example',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedAwsRds create returned $awsRdsId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsRdsInstrumentationAsync.
  await runWithoutAwsRdsInstrumentationAsync(
    () => tracedAwsRds<String>(
      operation: 'create',
      invoke: () async {
        const id = 'aws_rds_8f3a2c';
        return const AwsRdsCallResult(
            value: id,
            result: AwsRdsResult(
                region: 'us-east-1',
                surface: 'instance',
                dbInstanceId: 'dbinstance_8f3a2c',
                dbClusterId: 'dbcluster_8f3a2c',
                engine: 'mysql',
                engineVersion: '1',
                instanceClass: 'db.t4g.micro',
                allocatedStorageGb: 1,
                iopsProvisioned: 1,
                storageType: 'gp2',
                multiAz: true,
                availabilityZone: 'example',
                serverlessV2MinCapacity: 0.5,
                serverlessV2MaxCapacity: 0.5,
                publiclyAccessible: true,
                iamAuthEnabled: true,
                encryptionAtRest: true,
                kmsKeyId: 'kmskey_8f3a2c',
                endpoint: 'example',
                port: 443,
                instanceStatus: 'available',
                clusterStatus: 'succeeded',
                backupRetentionDays: 1,
                errorCode: 'example',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
