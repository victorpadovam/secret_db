library secret_db;


import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class EncryptedDB {
  static Database? _database;
  static String _dbName = "secure_database.db";
  static String _tableName = "secure_data";
  static String _key = "my_secure_key"; // A chave será gerada dinamicamente

  // Inicializa o banco de dados com parâmetros personalizados
  static Future<void> init({
    String dbName = "secure_database.db",
    String tableName = "secure_data",
    String key = "my_secure_key",
  }) async {
    _dbName = dbName;
    _tableName = tableName;
    _key = key;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE $_tableName (id INTEGER PRIMARY KEY, key TEXT, value TEXT)"
        );
      },
    );
  }

  /// Criptografa os dados antes de armazená-los
  static String _encrypt(String value) {
    var bytes = utf8.encode(value + _key);
    return base64Encode(sha256.convert(bytes).bytes);
  }

  /// Descriptografa os dados antes de retorná-los
  static String _decrypt(String value) {
    var bytes = base64Decode(value);
    return utf8.decode(sha256.convert(bytes).bytes);
  }

  /// Serializa um objeto para string (JSON)
  static String _serialize(Object value) {
    return jsonEncode(value);
  }

  /// Desserializa um JSON para um objeto
  static T _deserialize<T>(String jsonString, T Function(Map<String, dynamic>) fromJson) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return fromJson(jsonMap);
  }

  /// Salva dados de forma segura no banco de dados
  static Future<void> saveData(String key, dynamic value) async {
    if (_database == null) await init();
    String serializedValue = _serialize(value);  // Converte o objeto para uma string JSON
    String encryptedValue = _encrypt(serializedValue); // Criptografa o valor
    await _database!.insert(
      _tableName,
      {"key": key, "value": encryptedValue},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Recupera dados de forma segura do banco de dados
  static Future<T?> getData<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    if (_database == null) await init();
    final List<Map<String, dynamic>> result = await _database!.query(
      _tableName,
      where: "key = ?",
      whereArgs: [key],
    );

    if (result.isNotEmpty) {
      String encryptedValue = result.first["value"];
      String decryptedValue = _decrypt(encryptedValue); // Descriptografa
      return _deserialize<T>(decryptedValue, fromJson); // Converte de volta para o objeto
    } else {
      return null;
    }
  }

  /// Deleta um dado do banco de dados
  static Future<void> deleteData(String key) async {
    if (_database == null) await init();
    await _database!.delete(
      _tableName,
      where: "key = ?",
      whereArgs: [key],
    );
  }

  /// Fecha o banco de dados
  static Future<void> closeDB() async {
    await _database?.close();
  }
}
