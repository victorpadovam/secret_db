# secret_db

<img src="https://i.ibb.co/DPb94w7R/Secret-DB.png" width="650"/>



`secret_db` is a Flutter package that allows secure and encrypted data storage using an [SQLite database](https://pub.dev/packages/sqflite)

It provides a convenient way to store sensitive data with encryption and protection against data extraction on rooted/jailbroken devices.

## Purpose

This package was developed to provide secure data storage in Flutter by using AES (Advanced Encryption Standard) for data encryption to protect information in the database

- Encryption of data before storing it in the SQLite database.
- AES Encryption: Provides stronger encryption for storing sensitive data securely.
- Protection against data extraction on rooted/jailbroken devices.
- Support for storing simple data (like `String`) or objects (like serialized classes).

## 6 Cybersecurity Benefits of Using secret_db

These benefits make secret_db a robust solution for ensuring the security of sensitive data in your Flutter application, protecting against a wide range of cyber threats.

> 1 - Strong AES Encryption Data is encrypted using AES (Advanced Encryption Standard), providing robust protection

> 2 - Protection on Rooted/Jailbroken Devices: Ensures data remains secure even on compromised devices, reducing risks from malware

> 3- Dynamic Key Management: Encryption keys are securely generated and stored, avoiding hardcoding or exposure in the codebase.

> 4 - Secure Data Serialization: Prevents tampering with complex objects by securely serializing and deserializing data, ensuring integrity.

> 5 -  Data Protection in Storage: Stored data is encrypted before being written to the database, ensuring it’s unreadable even if the database is accessed.

> 6 - Prevents Data Leakage: Even if an attacker gains physical access to the device, encrypted data stays protected.

  
## Example Initialization:
```
import 'package:secret_db/secret_db.dart';

void main() async {
  // Initialize the database with custom parameters
  await SecretDB.init(
    dbName: "secure_data.db",  // Database name
    tableName: "secure_info",  // Table name
    key: "super_secure_key",   // Encryption key (can be dynamically generated)
  );
}
```

## 1.0 Usage Example with Simple Data
```
void saveUserToken() async {
  await SecretDB.saveData('user_token', 'my_secure_token');
}
```
## 1.1 Retrieve Data
```
void getUserToken() async {
  String? token = await SecretDB.getData('user_token');
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
void saveUser() async {
  // If needed, and if you wish to set the desired ID, you can use it without the GeneratedID
  // and generate your preferred ID. Otherwise, by using the GeneratedID, the package will 
  // automatically generate a random ID for the record.

  // 1   - Exemplo SaveData with GeneratedID
  User user = User(name: "John Doe", email: "john.doe@example.com");
  // Saving the user to the database with an automatically generated ID
  await SecretDB.saveDataWithGeneratedID(user);

  // 2   - Exemplo SaveData WithoutGeneratedID
  User user = User(id: 2, name: "John Doe", email: "john.doe@example.com");
  await SecretDB.saveData(user);
}

}
```
## 2.2 Retrieve Object (Deserialization):
```
void getUser() async {
  // Retrieve the stored user
  String? userJson = await SecretDB.getData('user_info');
  
  if (userJson != null) {
    // Deserialize the object
    User user = SecretDB._deserialize(userJson, (json) => User.fromJson(json));
    
    print('Username: ${user.username}, Email: ${user.email}');
  }
}
```
## 3. Delete Data
```
If you want to securely delete data, you can use the deleteData method.

await SecretDB.deleteData('user_token');
```
## 4. Close the Database
```
await SecretDB.closeDB();
```
