/*
 * @Author: Cao Shixin
 * @Date: 2021-01-29 15:16:01
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-19 16:07:52
 * @Description: 
 */
import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteUtil {
  Database? _db;
  final String defaultTableName = 'bc_app_table';
  String? _basePath;
  bool _printScene = kDebugMode;
  late String _dbName;

  //获取数据库地址
  String? get bcGetDBPath => _basePath;

  SqfliteUtil({String? dbName}) {
    _dbName = dbName ?? 'brainco_database.db';
  }

  /// 初始化数据,初始化对象需要调用
  Future<void> initlize({String? basePath = ''}) async {
    if (basePath == null || basePath.isEmpty) {
      _basePath = await getDatabasesPath();
    } else {
      _basePath = basePath;
    }
  }

  //是否打印执行的sql语句
  void printSqlScene({bool scene = kDebugMode}) {
    _printScene = scene;
  }

  Future<Database> get db async {
    if (_db == null || File(_db!.path).parent.path != _basePath) {
      _db = await _initDb();
    } else if (!_db!.isOpen) {
      _db = await openDatabase(_db!.path);
    }
    return _db!;
  }

  /*创建表
   * 
   * columnDic:   需要新增的字段名key，和需要设置的类型value，（needDefault设置为true的时候这些value也同时设置为默认值）
   * tableName:   表名称，不传默认表名
   * needDefault: 是否把columnDic的value设置为该column的默认值，默认不设置
   */
  Future bcCreateTableName(Map<String, dynamic> columnDic,
      {String tableName = '', bool needDefault = false}) async {
    var tabName = await _getTableName(tableName: tableName);
    var sqlStr = '(dataId integer primary key autoincrement,';
    columnDic.forEach((key, value) async {
      var columnType = _changeTypeWithDart(value);
      if (needDefault) {
        sqlStr += ' $key $columnType DEFAULT $value,';
      } else {
        sqlStr += ' $key $columnType,';
      }
    });
    sqlStr +=
        ' create_time datetime not null DEFAULT CURRENT_TIMESTAMP, update_time datetime not null DEFAULT CURRENT_TIMESTAMP,remarks text)';

    return bcExecuteSQL('create table if not exists $tabName $sqlStr');
  }

  /*为表新增数据
   *
   * containArr: 批量更新数据，内部的每一个子元素map要包含本次新增数据的全部column(建议这里用模型直接转成map)
   * tableName:  表名称，不传默认取数据库中拿到的第一个表名
   */
  Future bcAddDataForTable(List<Map<String, dynamic>> containArr,
      {String tableName = ''}) async {
    var tabName = await _getTableName(tableName: tableName);
    // List<String> columnArr = await _getColumsWithTableName(tableName: tabName);
    // Map tempAddColumnMap = {};

    var keyArrStr = '(', valueArrStr = '';
    var firstMapKeys = containArr.first.keys.toList();
    if (containArr.isEmpty || firstMapKeys.isEmpty) {
      return;
    }
    for (var key in firstMapKeys) {
      keyArrStr = '$keyArrStr$key,';
    }
    keyArrStr = keyArrStr.substring(0, keyArrStr.length - 1);
    keyArrStr = '$keyArrStr)';
    for (var tempDic in containArr) {
      valueArrStr = '$valueArrStr(';
      for (var i = 0; i < firstMapKeys.length; i++) {
        var value = tempDic[firstMapKeys[i]];
        if (value is String) {
          valueArrStr = "$valueArrStr'$value',";
        } else {
          valueArrStr = '$valueArrStr$value,';
        }
        // if (!columnArr.contains(value)) {
        //   tempAddColumnMap[value] = value;
        // }
      }
      valueArrStr = valueArrStr.substring(0, valueArrStr.length - 1);
      valueArrStr = '$valueArrStr),';
    }
    valueArrStr = valueArrStr.substring(0, valueArrStr.length - 1);
    // 更新表升级操作
    // bcAlterTableAddForTable(tempAddColumnMap, tableName: tabName);

    //考虑到sql的长度问题，需要查看sql最长限制，不行的话分割多步执行，多步执行需要考虑到事务问题
    //这里先不考虑长度问题
    var insertSqlStr = 'INSERT INTO $tabName $keyArrStr VALUES $valueArrStr';
    await bcExecuteSQL(insertSqlStr);
  }

  /*删除数据
   *
   * filterDic: 筛选过滤条件，key对应column，value对应参数取值范围内容
   * tableName: 表名称，不传默认取数据库中拿到的第一个表名
   */
  Future bcDeleteDataForTable(Map<String, dynamic> filterDic,
      {String tableName = ''}) async {
    try {
      var tabName = await _getTableName(tableName: tableName);
      var filterSql = await _jointToSqlForMap(filterDic);
      var result = bcExecuteSQL('DELETE FROM $tabName $filterSql');
      return result;
    } catch (e, trace) {
      LogUtil.log(
          'sqflite_util bcDeleteDataForTable 捕获异常 $e \n$tableName $filterDic \n$trace');
      return null;
    }
  }

  /*删除表
   *
   * tableName: 表名称
   */
  Future bcDeleteTable({String tableName = ''}) async {
    var result = _dealTable(
      'DROP TABLE',
      tableName: tableName,
    );
    return result;
  }

  /*清空表
   *
   * tableName: 表名称
   */
  Future bcCleanTable({String tableName = ''}) async {
    var result = _dealTable('DELETE FROM', tableName: tableName);
    return result;
  }

  /*修改表，新增字段column
   *
   * columnDic:   需要新增的字段名key，和需要设置的类型value，（needDefault设置为true的时候这些value也同时设置为默认值）
   * tableName:   表名，可不传，默认取读取数据库中第一个表名
   * needDefault: 是否把value设置为该column的默认值
   */
  Future bcAlterTableAddForTable(Map<String, dynamic> columnDic,
      {String tableName = '', bool needDefault = false}) async {
    var tabName = await _getTableName(tableName: tableName);
    columnDic.forEach((key, value) async {
      var columnType = _changeTypeWithDart(value);
      if (needDefault) {
        //不支持批量alter
        await bcExecuteSQL(
            'ALTER TABLE $tabName ADD $key $columnType DEFAULT $value');
      } else {
        await bcExecuteSQL('ALTER TABLE $tabName ADD $key $columnType');
      }
    });
  }

  //修改表，删除字段column(手机数据库系统还不支持)
  // Future<void> bcAlterTableDropForTable(String column,
  //     {String tableName = ''}) async {
  //   var tabName = await _getTableName(tableName:tableName);
  //   var result = bcExecuteSQL('ALTER TABLE $tabName DROP COLUMN $column');
  //   return result;
  // }

  /*修改数据
   *
   * setDic:    要修改的内容
   * filterDic: 筛选条件
   * tableName: 表名，可不传，默认取读取数据库中第一个表名
   */
  Future bcChangeDataWithTableName(
      Map<String, dynamic> setDic, Map<String, dynamic> filterDic,
      {String tableName = ''}) async {
    var tabName = await _getTableName(tableName: tableName);
    var setSql = await _updateWithDic(setDic);
    var filterSql = await _jointToSqlForMap(filterDic);
    var result = bcExecuteSQL('UPDATE $tabName $setSql $filterSql');
    return result;
  }

  /*查询数据, 返回满足条件的内容(map建议用对应模型接收)list
   *
   * filterDic: 筛选条件
   * tableName: 表名，可不传，默认取读取数据库中第一个表名
   * column:    是否只查询满足筛选条件下的某个column的结果。默认为*，表示所有结果
   */
  Future<List<Map>> bcSelectDataForTab(Map<String, dynamic> filterDic,
      {String tableName = '', String? column}) async {
    var tabName = await _getTableName(tableName: tableName);
    var tempArr = <Map>[];
    var columnStr = '*';
    if (column != null) {
      columnStr = column;
    }
    var filterSql = await _jointToSqlForMap(filterDic);
    var resultTemp =
        await bcRawQuery('SELECT $columnStr FROM $tabName $filterSql;');
    for (var tempDic in resultTemp) {
      var tempMap = {};
      tempDic.forEach((key, value) {
        if (value != null) {
          tempMap.addAll(tempDic);
        }
      });
      tempArr.add(tempMap);
    }
    return tempArr;
  }

  /*
   * 查询表中的第一条数据，如果没有数据会返回null
   */
  Future<List<Map>> bcSelectFirstDataForTab({
    String tableName = '',
  }) async {
    var tabName = await _getTableName(tableName: tableName);
    var resultTemp = await bcRawQuery('SELECT * FROM $tabName LIMIT 1;');
    return resultTemp;
  }

  /*查询某表的某个column下的特殊条件下的枚举结果值
   *
   * type:      目前设定的可查询类型枚举
   * column:    要查询的字段
   * filterDic: 筛选条件
   * tableName: 表名，可不传，默认取读取数据库中第一个表名
   */
  Future<Object?> bcGetSpecialResultForColumn(
      NumericalValueType type, String column, Map<String, dynamic> filterDic,
      {String tableName = ''}) async {
    var tabName = await _getTableName(tableName: tableName);
    var dataSql = await _dealSqlSpecialResult(type, column);
    Object? result;
    var filterSql = await _jointToSqlForMap(filterDic);
    var resultTemp =
        await bcRawQuery('SELECT $dataSql FROM $tabName $filterSql;');
    // ignore: unused_local_variable
    for (var tempMap in resultTemp) {
      result = resultTemp.first[dataSql];
    }
    return result;
  }

  /*执行自定义sql语句
   *
   * sql: sql语句
   */
  Future bcExecuteSQL(String sql) async {
    try {
      return bcExecute(sql);
    } catch (e, trace) {
      LogUtil.log('sqflite_util bcExecuteSQL 捕获异常 $e \n$sql \n$trace');
      return null;
    }
  }

/*
 * 删除表格
database.execute('DROP table test');
清空表格
database.execute('DELETE FROM test');
重命名表格
database.execute('ALTER TABLE test RENAME TO test_1');
添加字段(如果有约束，需要先删除约束:ALTER TABLE test DROP constraint 约束名或键)
database.execute('ALTER TABLE test ADD age integer');
删除字段
database.execute('ALTER TABLE test DROP COLUMN age');
修改字段类型
database.execute('ALTER TABLE test ALTER COLUMN value TEXT');
 */

  //关闭
  Future _bcClose() async {
    // await _db.close();
  }

  Future<Database> _initDb() async {
    var databasesPath = _basePath ?? await getDatabasesPath();
    var path = join(databasesPath, _dbName);
    var ourDb = await openDatabase(path);
    return ourDb;
  }

  //表处理工具
  Future _dealTable(String dealMethod, {String tableName = ''}) async {
    var tabName = await _getTableName(tableName: tableName);
    var result = await bcExecuteSQL('$dealMethod $tabName');
    return result;
  }

  //获取数据库中表名，不设定表名，默认取第一个,否则给定默认表名
  Future<String> _getTableName({String? tableName = ''}) async {
    if (tableName == null || tableName.isEmpty) {
      var tableNames = await _getTableNames();
      tableName = tableNames.isNotEmpty ? tableNames.first : defaultTableName;
    }
    return tableName!;
  }

  //dart与sql数据类型转换
  String _changeTypeWithDart(dynamic value) {
    var columnType = 'text';
    if (value is int) {
      columnType = 'integer';
    } else if (value is DateTime) {
      columnType = 'datetime';
    } else if (value is double) {
      columnType = 'double';
    }
    return columnType;
  }

  // 获取数据库中的所有表名称
  Future<List> _getTableNames() async {
    var temp = <String>[];
    var result =
        await bcRawQuery("select * from Sqlite_master where type = 'table'");
    for (var item in result) {
      temp.add(item['name']);
    }
    return temp;
  }

  // //根据表名获取表名所有column字段
  // Future<List> _getColumsWithTableName({String tableName = ''}) async {
  //   var tabName = await _getTableName(tableName: tableName);
  //   var temp = <String>[];
  //   var result = await bcRawQuery(
  //       "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='$tabName';");
  //   for (var item in result) {
  //     temp.add(item.keys.first.toString());
  //   }
  //   return temp;
  // }

  //辅助特殊值sql语句工具
  Future<String> _dealSqlSpecialResult(
      NumericalValueType type, String column) async {
    var sql = '';
    switch (type) {
      case NumericalValueType.count:
        sql = 'COUNT ($column)';
        break;
      case NumericalValueType.avg:
        sql = 'AVG ($column)';
        break;
      case NumericalValueType.max:
        sql = 'MAX ($column)';
        break;
      case NumericalValueType.min:
        sql = 'MIN ($column)';
        break;
      case NumericalValueType.first:
        sql = 'FIRST ($column)';
        break;
      case NumericalValueType.last:
        sql = 'LAST ($column)';
        break;
      case NumericalValueType.sum:
        sql = 'SUM ($column)';
        break;
      default:
    }
    return Future.value(sql);
  }

  //修改数据的sql语句
  Future<String> _updateWithDic(Map<String, dynamic> setDic) async {
    var tempStr = 'SET';
    setDic.forEach((key, value) {
      if (value is String) {
        tempStr = "$tempStr $key = '$value',";
      } else {
        tempStr = '$tempStr $key = $value,';
      }
    });
    tempStr = '$tempStr update_time = CURRENT_TIMESTAMP';
    return tempStr;
  }

  //条件语句拼接成新的sql语句
  Future<String> _jointToSqlForMap(Map<String, dynamic> constraintMap) async {
    var constraintStr = '';
    if (constraintMap.isNotEmpty) {
      var tempArr = constraintMap.keys.toList();
      for (var i = 0; i < tempArr.length; i++) {
        var keyStr = tempArr[i];
        var value = constraintMap[keyStr];
        var valueStr = '';
        if (value is List) {
          valueStr = '(';
          for (var i = 0; i < value.length; i++) {
            var tempValue = value[i];
            if (tempValue is String) {
              valueStr = "$valueStr'$tempValue'";
            } else {
              valueStr = '$valueStr$tempValue';
            }
            if (i != value.length - 1) {
              valueStr += ',';
            }
          }
          valueStr = 'IN $valueStr)';
        } else if (value is LinkedHashMap) {
          //抛出异常，条件编写存在问题
          AssertionError('条件参数有问题');
        } else {
          if (value is String) {
            valueStr = "= '$value'";
          } else {
            valueStr = '= $value';
          }
        }

        if (i == 0) {
          constraintStr = 'WHERE $keyStr $valueStr';
        } else if (!valueStr.contains('IN ()')) {
          constraintStr += ' AND $keyStr $valueStr';
        }
      }
    }
    return constraintStr;
  }

  //系统案例
  Future bcExecute(String sql, [List<dynamic>? arguments]) async {
    if (_printScene) {
      if (kDebugMode) {
        print('执行sql语句输出:$sql');
      }
    }
    var dbClient = await db;
    var result = await dbClient.execute(sql, arguments);
    await _bcClose();
    return result;
  }

  Future<int> bcRawInsert(String sql, [List<dynamic>? arguments]) async {
    var dbClient = await db;
    var result = await dbClient.rawInsert(sql, arguments);
    await _bcClose();
    return result;
  }

  Future<int> bcInsert(String table, Map<String, dynamic> values,
      {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async {
    var dbClient = await db;
    var result = await dbClient.insert(table, values,
        nullColumnHack: nullColumnHack, conflictAlgorithm: conflictAlgorithm);
    await _bcClose();
    return result;
  }

  Future<List<Map<String, dynamic>>> bcQuery(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<dynamic>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async {
    var dbClient = await db;
    var result = await dbClient.query(table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset);
    await _bcClose();
    return result;
  }

  Future<List<Map<String, dynamic>>> bcRawQuery(String sql,
      [List<dynamic>? arguments]) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery(sql, arguments);
    await _bcClose();
    return result;
  }

  Future<int> bcRawUpdate(String sql, [List<dynamic>? arguments]) async {
    var dbClient = await db;
    var result = await dbClient.rawUpdate(sql, arguments);
    await _bcClose();
    return result;
  }

  Future<int> bcUpdate(String table, Map<String, dynamic> values,
      {String? where,
      List<dynamic>? whereArgs,
      ConflictAlgorithm? conflictAlgorithm}) async {
    var dbClient = await db;
    var result = await dbClient.update(table, values,
        whereArgs: whereArgs,
        where: where,
        conflictAlgorithm: conflictAlgorithm);
    await _bcClose();
    return result;
  }

  Future<int> bcRawDelete(String sql, [List<dynamic>? arguments]) async {
    var dbClient = await db;
    var result = await dbClient.rawDelete(sql, arguments);
    await _bcClose();
    return result;
  }

  Future<int> bcDelete(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    var dbClient = await db;
    var result =
        await dbClient.delete(table, where: where, whereArgs: whereArgs);
    await _bcClose();
    return result;
  }
}

enum NumericalValueType {
  //返回数值列的数量
  count,
  //返回数值列的平均值
  avg,
  //返回数值列的总数
  sum,
  //查询结果的第一个
  first,
  //查询结果的最后一个
  last,
  //查询字段内容的最大值
  max,
  //查询字段内容的最小值
  min,
}
