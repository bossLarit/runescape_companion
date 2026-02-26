import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class VaultCryptoService {
  static const int _saltLength = 32;
  static const int _nonceLength = 12;
  static const int _pbkdf2Iterations = 100000;

  Future<Uint8List> encrypt(String plaintext, String masterPassword) async {
    final salt = _secureRandomBytes(_saltLength);
    final nonce = _secureRandomBytes(_nonceLength);
    final key = await _deriveKey(masterPassword, salt);

    final algorithm = AesGcm.with256bits();
    final secretBox = await algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
      nonce: nonce,
    );

    // Format: salt + nonce + mac + ciphertext
    final result = BytesBuilder();
    result.add(salt);
    result.add(nonce);
    result.add(secretBox.mac.bytes);
    result.add(secretBox.cipherText);
    return result.toBytes();
  }

  Future<String> decrypt(Uint8List data, String masterPassword) async {
    if (data.length < _saltLength + _nonceLength + 16) {
      throw const FormatException('Vault data is corrupted or too short');
    }

    final salt = data.sublist(0, _saltLength);
    final nonce = data.sublist(_saltLength, _saltLength + _nonceLength);
    final mac = Mac(data.sublist(
        _saltLength + _nonceLength, _saltLength + _nonceLength + 16));
    final cipherText = data.sublist(_saltLength + _nonceLength + 16);

    final key = await _deriveKey(masterPassword, salt);

    final algorithm = AesGcm.with256bits();
    try {
      final secretBox = SecretBox(
        cipherText,
        nonce: nonce,
        mac: mac,
      );
      final plainBytes = await algorithm.decrypt(secretBox, secretKey: key);
      return utf8.decode(plainBytes);
    } catch (e) {
      throw const FormatException('Wrong master password or corrupted vault');
    }
  }

  Future<SecretKey> _deriveKey(String password, List<int> salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _pbkdf2Iterations,
      bits: 256,
    );
    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  static Uint8List _secureRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
        List<int>.generate(length, (_) => random.nextInt(256)));
  }
}
