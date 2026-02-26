import '../domain/vault_entry_model.dart';

/// Regex to detect email-like strings (contains @ with text on both sides)
final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Regex to detect a PIN (pure digits, 3-6 chars)
final _pinRegex = RegExp(r'^\d{3,6}$');

/// Known key: value labels (case-insensitive) used in structured format
const _knownLabels = {
  'login',
  'password',
  'pin',
  'email',
  'username',
  'title',
  'category',
  'url',
  'character',
  'notes',
  'tags',
};

class TxtImportParser {
  /// Parse a .txt file that can be in either:
  ///  1. Structured format  —  `key: value` lines, blocks separated by `---`
  ///  2. Freeform format    —  blocks separated by blank lines, with heuristic
  ///     detection of title / email / password / pin / notes
  List<VaultEntry> parse(String content) {
    // If the file contains `---` separators, prefer structured mode
    if (content.contains('---')) {
      final structured = _parseStructured(content);
      if (structured.isNotEmpty) return structured;
    }

    return _parseFreeform(content);
  }

  // ───────────────────────── Structured format ─────────────────────────

  List<VaultEntry> _parseStructured(String content) {
    final entries = <VaultEntry>[];
    final blocks = content.split('---');
    for (final block in blocks) {
      final trimmed = block.trim();
      if (trimmed.isEmpty) continue;
      final entry = _parseStructuredBlock(trimmed);
      if (entry != null) entries.add(entry);
    }
    return entries;
  }

  VaultEntry? _parseStructuredBlock(String block) {
    final lines = block.split('\n');
    final fields = <String, String>{};
    final customFields = <String, String>{};

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) continue;
      final colonIndex = trimmedLine.indexOf(':');
      if (colonIndex <= 0) continue;
      final key = trimmedLine.substring(0, colonIndex).trim().toLowerCase();
      final value = trimmedLine.substring(colonIndex + 1).trim();
      if (_knownLabels.contains(key)) {
        // Normalise "login" → "email"/"username"
        if (key == 'login') {
          if (_emailRegex.hasMatch(value)) {
            fields['email'] = value;
          } else {
            fields['username'] = value;
          }
        } else {
          fields[key] = value;
        }
      } else {
        customFields[key] = value;
      }
    }
    if (fields.isEmpty && customFields.isEmpty) return null;

    final tags = (fields['tags'] ?? '')
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    return VaultEntry(
      title: fields['title'] ?? 'Untitled',
      category: fields['category'] ?? '',
      username: fields['username'] ?? '',
      password: fields['password'] ?? '',
      email: fields['email'] ?? '',
      url: fields['url'] ?? '',
      character: fields['character'] ?? '',
      notes: fields['notes'] ?? '',
      tags: tags,
      customFields: customFields.isNotEmpty
          ? {
              ...customFields,
              if (fields.containsKey('pin')) 'pin': fields['pin']!
            }
          : (fields.containsKey('pin') ? {'pin': fields['pin']!} : {}),
    );
  }

  // ───────────────────────── Freeform format ─────────────────────────
  // Blocks are separated by one or more blank lines.
  // Heuristics per block:
  //  - A line with "Label: value" is extracted by label.
  //  - A line matching email regex → email / login.
  //  - First non-email, non-label line → title (account name).
  //  - Line right after email that is NOT an email → password.
  //  - Pure digit line (3-6 digits) → pin (stored in customFields).
  //  - Remaining lines → notes.

  List<VaultEntry> _parseFreeform(String content) {
    final entries = <VaultEntry>[];
    final blocks = _splitByBlankLines(content);
    for (final block in blocks) {
      final entry = _parseFreeformBlock(block);
      if (entry != null) entries.add(entry);
    }
    return entries;
  }

  List<List<String>> _splitByBlankLines(String content) {
    final result = <List<String>>[];
    var current = <String>[];

    for (final line in content.split('\n')) {
      if (line.trim().isEmpty) {
        if (current.isNotEmpty) {
          result.add(current);
          current = <String>[];
        }
      } else {
        current.add(line.trimRight());
      }
    }
    if (current.isNotEmpty) result.add(current);
    return result;
  }

  VaultEntry? _parseFreeformBlock(List<String> lines) {
    if (lines.isEmpty) return null;

    String? title;
    String? email;
    String? password;
    String? pin;
    final notes = <String>[];

    // First pass: extract labeled lines (e.g. "Login: x", "Password: y", "Pin: z")
    final remaining = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      final colonIdx = trimmed.indexOf(':');
      if (colonIdx > 0) {
        final key = trimmed.substring(0, colonIdx).trim().toLowerCase();
        final value = trimmed.substring(colonIdx + 1).trim();
        if (value.isNotEmpty && _knownLabels.contains(key)) {
          switch (key) {
            case 'login':
            case 'email':
            case 'username':
              email = value;
            case 'password':
              password = value;
            case 'pin':
              pin = value;
            case 'title':
              title = value;
            default:
              remaining.add(trimmed);
          }
          continue;
        }
      }
      remaining.add(trimmed);
    }

    // Second pass: heuristic on remaining lines
    bool emailSeen = email != null;
    for (final line in remaining) {
      if (line.trim().isEmpty) continue;

      // Detect email
      if (!emailSeen && _emailRegex.hasMatch(line.trim())) {
        email = line.trim();
        emailSeen = true;
        continue;
      }

      // Line right after we identified an email → password
      if (emailSeen && password == null && !_emailRegex.hasMatch(line.trim())) {
        // Check if it's a PIN instead
        if (_pinRegex.hasMatch(line.trim())) {
          pin = line.trim();
          continue;
        }
        password = line.trim();
        continue;
      }

      // Pure digits after password → PIN
      if (password != null && pin == null && _pinRegex.hasMatch(line.trim())) {
        pin = line.trim();
        continue;
      }

      // First non-email line before the email → title
      if (title == null && !emailSeen) {
        title = line.trim();
        continue;
      }

      // Everything else → notes
      notes.add(line.trim());
    }

    // If we only have a single line that's not email/password, treat it as a note entry
    if (email == null && password == null && title == null && notes.isEmpty) {
      return null;
    }

    // Generate a title from email if none was found
    title ??= email ?? 'Untitled';

    return VaultEntry(
      title: title,
      email: email ?? '',
      username: email ?? '',
      password: password ?? '',
      notes: notes.join('\n'),
      customFields: pin != null ? {'pin': pin} : {},
    );
  }

  // ────────────────────────── Validation ──────────────────────────

  List<String> validate(String content) {
    final errors = <String>[];

    if (content.contains('---')) {
      // Structured validation
      final blocks = content.split('---');
      int blockIndex = 0;
      for (final block in blocks) {
        final trimmed = block.trim();
        if (trimmed.isEmpty) continue;
        blockIndex++;
        bool hasTitle = false;
        bool hasPassword = false;
        for (final line in trimmed.split('\n')) {
          final tl = line.trim();
          if (tl.isEmpty || tl.startsWith('#')) continue;
          final colonIndex = tl.indexOf(':');
          if (colonIndex > 0) {
            final key = tl.substring(0, colonIndex).trim().toLowerCase();
            if (key == 'title') hasTitle = true;
            if (key == 'password') hasPassword = true;
          }
        }
        if (!hasTitle) errors.add('Block $blockIndex: Missing title field');
        if (!hasPassword) {
          errors.add('Block $blockIndex: Missing password field (warning)');
        }
      }
    } else {
      // Freeform validation
      final blocks = _splitByBlankLines(content);
      int blockIndex = 0;
      for (final block in blocks) {
        blockIndex++;
        final hasEmail = block.any((l) => _emailRegex.hasMatch(l.trim()));
        if (!hasEmail) {
          // Check for labeled email
          final hasLabeledEmail = block.any((l) {
            final ci = l.indexOf(':');
            if (ci <= 0) {
              return false;
            }
            final key = l.substring(0, ci).trim().toLowerCase();
            return key == 'login' || key == 'email' || key == 'username';
          });
          if (!hasLabeledEmail) {
            errors.add('Entry $blockIndex: No email/login detected');
          }
        }
        if (block.length < 2) {
          errors.add(
              'Entry $blockIndex: May be incomplete (only ${block.length} line)');
        }
      }
    }

    return errors;
  }
}
