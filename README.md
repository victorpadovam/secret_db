# secret_db

<img src="https://i.ibb.co/DPb94w7R/Secret-DB.png" width="650"/>


`secret_db` is a Flutter package that allows secure and encrypted data storage using an SQLite database. It provides a convenient way to store sensitive data with encryption and protection against data extraction on rooted/jailbroken devices.

## Purpose

This package was developed to provide secure data storage in Flutter by using SHA-256 encryption to protect information in the database. It offers:

- Encryption of data before storing it in the SQLite database.
- Protection against data extraction on rooted/jailbroken devices.
- Support for storing simple data (like `String`) or objects (like serialized classes).
  
## Example Initialization:
```
import 'package:encrypted_db_storage/encrypted_db_storage.dart';

void main() async {
  // Initialize the database with custom parameters
  await EncryptedDB.init(
    dbName: "secure_data.db",  // Database name
    tableName: "secure_info",  // Table name
    key: "super_secure_key",   // Encryption key
  );
}
```

## 1.0 Usage Example with Simple Data
```
void saveUserToken() async {
  await EncryptedDB.saveData('user_token', 'my_secure_token');
}
```
## 1.1 Retrieve Data
```
void getUserToken() async {
  String? token = await EncryptedDB.getData('user_token');
  print('Token retrieved: $token');
}
```
## 2.0 Usage Example with Objects
```
class User {
  final String username;
  final String email;

  User({required this.username, required this.email});

  // Converts the object to a map (for serialization)
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
    };
  }

  // Converts the map back to an object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
    );
  }
}

```
## 2.1 Save Object (Serialization):
```
import 'package:encrypted_db_storage/encrypted_db_storage.dart';

void saveUser() async {
  User user = User(username: 'john_doe', email: 'john@example.com');
  
  // Serialize the object to a JSON String
  String serializedUser = EncryptedDB._serialize(user);
  
  // Save the object in the database
  await EncryptedDB.saveData('user_info', serializedUser);
}
```
## 2.2 Retrieve Object (Deserialization):
```
import 'package:encrypted_db_storage/encrypted_db_storage.dart';

void getUser() async {
  // Retrieve the stored user
  String? userJson = await EncryptedDB.getData('user_info');
  
  if (userJson != null) {
    // Deserialize the object
    User user = EncryptedDB._deserialize(userJson, (json) => User.fromJson(json));
    
    print('Username: ${user.username}, Email: ${user.email}');
  }
}
```
## 3. Delete Data
```
If you want to securely delete data, you can use the deleteData method.

await EncryptedDB.deleteData('user_token');
```
## 4. Close the Database
```
await EncryptedDB.closeDB();
```
