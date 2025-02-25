import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecretDB {
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
            "CREATE TABLE $_tableName (id INTEGER PRIMARY KEY, key TEXT, value TEXT)");
      },
    );
  }

  // Gera chave de criptografia usando AES
  static encrypt.Key _generateEncryptionKey() {
    var keyBytes =
        utf8.encode(_key.padRight(32, '0')); // Garante chave de 32 bytes
    return encrypt.Key(keyBytes);
  }

  /// Criptografa os dados antes de armazená-los usando AES
  static String _encrypt(String value) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_generateEncryptionKey()));
    final encrypted = encrypter.encrypt(value);
    return encrypted.base64;
  }

  /// Descriptografa os dados antes de retorná-los usando AES
  static String _decrypt(String value) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_generateEncryptionKey()));
    final decrypted = encrypter.decrypt64(value);
    return decrypted;
  }

  /// Serializa um objeto para string (JSON)
  static String _serialize(Object value) {
    return jsonEncode(value);
  }

  /// Desserializa um JSON para um objeto
  static T _deserialize<T>(
      String jsonString, T Function(Map<String, dynamic>) fromJson) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return fromJson(jsonMap);
  }

  /// Gera um ID aleatório único
  static Future<String> generateID() async {
    final random = Random();
    String id;
    bool isUnique;

    // Gera um ID aleatório e verifica se já existe
    do {
      id = (random.nextInt(1000000))
          .toString(); // Gerar ID aleatório de até 6 dígitos
      final List<Map<String, dynamic>> result = await _database!.query(
        _tableName,
        where: "key = ?",
        whereArgs: [id],
      );

      isUnique = result.isEmpty; // Verifica se o ID já existe
    } while (!isUnique); // Continua tentando até gerar um ID único

    return id; // Retorna o ID único
  }

  /// Salva dados de forma segura no banco de dados com ID gerado aleatoriamente
  static Future<void> saveDataWithGeneratedID(dynamic value) async {
    if (_database == null) await init();
    String generatedID = await generateID(); // Gera um ID único
    String serializedValue =
        _serialize(value); // Converte o objeto para uma string JSON
    String encryptedValue = _encrypt(serializedValue); // Criptografa o valor

    // Salva o dado no banco com o ID gerado
    await _database!.insert(
      _tableName,
      {"key": generatedID, "value": encryptedValue},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Salva dados de forma segura no banco de dados, usando um ID fornecido
  static Future<void> saveData(String key, dynamic value) async {
    if (_database == null) await init();
    String serializedValue =
        _serialize(value); // Converte o objeto para uma string JSON
    String encryptedValue = _encrypt(serializedValue); // Criptografa o valor
    await _database!.insert(
      _tableName,
      {"key": key, "value": encryptedValue},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Recupera dados de forma segura do banco de dados
  static Future<T?> getData<T>(
      String key, T Function(Map<String, dynamic>) fromJson) async {
    if (_database == null) await init();
    final List<Map<String, dynamic>> result = await _database!.query(
      _tableName,
      where: "key = ?",
      whereArgs: [key],
    );

    if (result.isNotEmpty) {
      String encryptedValue = result.first["value"];
      String decryptedValue = _decrypt(encryptedValue); // Descriptografa
      return _deserialize<T>(
          decryptedValue, fromJson); // Converte de volta para o objeto
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

  /// Atualiza os dados de forma segura no banco de dados
  static Future<void> updateData(String key, dynamic value) async {
    if (_database == null) await init();
    String serializedValue =
        _serialize(value); // Converte o objeto para uma string JSON
    String encryptedValue = _encrypt(serializedValue); // Criptografa o valor
    await _database!.update(
      _tableName,
      {"value": encryptedValue},
      where: "key = ?",
      whereArgs: [key],
    );
  }

  /// Fecha o banco de dados
  static Future<void> closeDB() async {
    await _database?.close();
  }
}
