// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_aws_rds_suppression.dart';

const _tracerName = 'dartastic_otel_libs_aws_rds';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class AwsRdsResult {
  const AwsRdsResult({
    this.region,
    this.surface,
    this.dbInstanceId,
    this.dbClusterId,
    this.engine,
    this.engineVersion,
    this.instanceClass,
    this.allocatedStorageGb,
    this.iopsProvisioned,
    this.storageType,
    this.multiAz,
    this.availabilityZone,
    this.serverlessV2MinCapacity,
    this.serverlessV2MaxCapacity,
    this.publiclyAccessible,
    this.iamAuthEnabled,
    this.encryptionAtRest,
    this.kmsKeyId,
    this.endpoint,
    this.port,
    this.instanceStatus,
    this.clusterStatus,
    this.backupRetentionDays,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  final String? region;

  /// `instance`, `cluster`, `proxy`, `snapshot`, `option_group`,
  /// `parameter_group`, `subnet_group`, `event_subscription`,
  /// `db_data`.
  final String? surface;

  final String? dbInstanceId;
  final String? dbClusterId;

  /// `mysql`, `postgres`, `mariadb`, `oracle-ee`, `oracle-se2`,
  /// `sqlserver-ee`, `sqlserver-se`, `sqlserver-ex`, `sqlserver-web`,
  /// `aurora-mysql`, `aurora-postgresql`, `docdb`, `neptune`.
  final String? engine;
  final String? engineVersion;

  /// `db.t4g.micro`, `db.r7g.large`, `db.serverless`, ...
  final String? instanceClass;

  final int? allocatedStorageGb;
  final int? iopsProvisioned;

  /// `gp2`, `gp3`, `io1`, `io2`, `aurora`, `aurora-iopt1`.
  final String? storageType;

  final bool? multiAz;
  final String? availabilityZone;

  /// Aurora Serverless v2 capacity range (in ACUs).
  final double? serverlessV2MinCapacity;
  final double? serverlessV2MaxCapacity;

  final bool? publiclyAccessible;
  final bool? iamAuthEnabled;
  final bool? encryptionAtRest;
  final String? kmsKeyId;

  final String? endpoint;
  final int? port;

  /// `available`, `backing-up`, `creating`, `deleting`, `failed`,
  /// `inaccessible-encryption-credentials`, `incompatible-network`,
  /// `incompatible-parameters`, `maintenance`, `modifying`,
  /// `rebooting`, `renaming`, `restore-error`, `starting`,
  /// `stopped`, `stopping`, `storage-full`, `storage-optimization`,
  /// `upgrading`.
  final String? instanceStatus;

  final String? clusterStatus;

  final int? backupRetentionDays;

  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

class AwsRdsCallResult<T> {
  const AwsRdsCallResult({required this.value, this.result});
  final T value;
  final AwsRdsResult? result;
}

/// Wraps an AWS RDS control-plane or RDS Data API call in a CLIENT span.
/// [operation] is one of `createDBInstance`, `modifyDBInstance`,
/// `deleteDBInstance`, `rebootDBInstance`, `startDBInstance`,
/// `stopDBInstance`, `describeDBInstances`, `createDBCluster`,
/// `modifyDBCluster`, `deleteDBCluster`, `describeDBClusters`,
/// `failoverDBCluster`, `createDBClusterSnapshot`,
/// `createDBSnapshot`, `restoreDBInstanceFromDBSnapshot`,
/// `restoreDBClusterFromSnapshot`, `restoreDBClusterToPointInTime`,
/// `createDBProxy`, `describeDBProxies`, `deleteDBProxy`,
/// `applyPendingMaintenanceAction`, `describePendingMaintenanceActions`,
/// `data.executeStatement`, `data.batchExecuteStatement`,
/// `data.beginTransaction`, `data.commitTransaction`,
/// `data.rollbackTransaction`, `iam.generateAuthToken`,
/// `performanceInsights.getResourceMetrics`.
Future<T> tracedAwsRds<T>({
  required String operation,
  required Future<AwsRdsCallResult<T>> Function() invoke,
}) async {
  if (awsRdsInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'aws_rds',
    'rpc.method': operation,
    'aws_rds.operation': operation,
  };

  final span = _tracer().startSpan(
    'aws_rds $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.region != null) {
        extras.add(OTel.attributeString('aws_rds.region', res.region!));
      }
      if (res.surface != null) {
        extras.add(OTel.attributeString('aws_rds.surface', res.surface!));
      }
      if (res.dbInstanceId != null) {
        extras.add(OTel.attributeString(
          'aws_rds.db_instance.id',
          res.dbInstanceId!,
        ));
      }
      if (res.dbClusterId != null) {
        extras.add(OTel.attributeString(
          'aws_rds.db_cluster.id',
          res.dbClusterId!,
        ));
      }
      if (res.engine != null) {
        extras.add(OTel.attributeString('aws_rds.engine', res.engine!));
      }
      if (res.engineVersion != null) {
        extras.add(OTel.attributeString(
          'aws_rds.engine.version',
          res.engineVersion!,
        ));
      }
      if (res.instanceClass != null) {
        extras.add(OTel.attributeString(
          'aws_rds.instance_class',
          res.instanceClass!,
        ));
      }
      if (res.allocatedStorageGb != null) {
        extras.add(OTel.attributeInt(
          'aws_rds.allocated_storage_gb',
          res.allocatedStorageGb!,
        ));
      }
      if (res.iopsProvisioned != null) {
        extras.add(OTel.attributeInt(
          'aws_rds.iops_provisioned',
          res.iopsProvisioned!,
        ));
      }
      if (res.storageType != null) {
        extras.add(OTel.attributeString(
          'aws_rds.storage_type',
          res.storageType!,
        ));
      }
      if (res.multiAz != null) {
        extras.add(OTel.attributeBool('aws_rds.multi_az', res.multiAz!));
      }
      if (res.availabilityZone != null) {
        extras.add(OTel.attributeString(
          'aws_rds.availability_zone',
          res.availabilityZone!,
        ));
      }
      if (res.serverlessV2MinCapacity != null) {
        extras.add(OTel.attributeDouble(
          'aws_rds.serverless_v2.min_acu',
          res.serverlessV2MinCapacity!,
        ));
      }
      if (res.serverlessV2MaxCapacity != null) {
        extras.add(OTel.attributeDouble(
          'aws_rds.serverless_v2.max_acu',
          res.serverlessV2MaxCapacity!,
        ));
      }
      if (res.publiclyAccessible != null) {
        extras.add(OTel.attributeBool(
          'aws_rds.publicly_accessible',
          res.publiclyAccessible!,
        ));
      }
      if (res.iamAuthEnabled != null) {
        extras.add(OTel.attributeBool(
          'aws_rds.iam_auth.enabled',
          res.iamAuthEnabled!,
        ));
      }
      if (res.encryptionAtRest != null) {
        extras.add(OTel.attributeBool(
          'aws_rds.encryption_at_rest',
          res.encryptionAtRest!,
        ));
      }
      if (res.kmsKeyId != null) {
        extras.add(OTel.attributeString(
          'aws_rds.kms.key_id',
          res.kmsKeyId!,
        ));
      }
      if (res.endpoint != null) {
        extras.add(OTel.attributeString('aws_rds.endpoint', res.endpoint!));
      }
      if (res.port != null) {
        extras.add(OTel.attributeInt('aws_rds.port', res.port!));
      }
      if (res.instanceStatus != null) {
        extras.add(OTel.attributeString(
          'aws_rds.instance.status',
          res.instanceStatus!,
        ));
        if (res.instanceStatus == 'failed' ||
            res.instanceStatus == 'storage-full' ||
            res.instanceStatus == 'restore-error' ||
            res.instanceStatus == 'inaccessible-encryption-credentials' ||
            res.instanceStatus == 'incompatible-network' ||
            res.instanceStatus == 'incompatible-parameters') {
          span.setStatus(
            SpanStatusCode.Error,
            'RDS instance ${res.instanceStatus}',
          );
        }
      }
      if (res.clusterStatus != null) {
        extras.add(OTel.attributeString(
          'aws_rds.cluster.status',
          res.clusterStatus!,
        ));
      }
      if (res.backupRetentionDays != null) {
        extras.add(OTel.attributeInt(
          'aws_rds.backup_retention_days',
          res.backupRetentionDays!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'aws_rds.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'RDS ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'aws_rds.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(SpanStatusCode.Error, 'RDS HTTP ${res.statusCode}');
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
