/// Parses OSRS Wiki wikitext to extract item creation / obtaining info.
class WikiItemInfo {
  final String name;
  final bool members;
  final String? examine;
  final String? quest;
  final bool tradeable;
  final String? weight;
  final List<CreationMethod> creationMethods;
  final List<String> obtainMethods;

  const WikiItemInfo({
    required this.name,
    this.members = false,
    this.examine,
    this.quest,
    this.tradeable = true,
    this.weight,
    this.creationMethods = const [],
    this.obtainMethods = const [],
  });
}

class CreationMethod {
  final String? facility;
  final List<SkillReq> skills;
  final List<MaterialReq> materials;
  final int? ticks;
  final int outputQuantity;
  final String? notes;

  const CreationMethod({
    this.facility,
    this.skills = const [],
    this.materials = const [],
    this.ticks,
    this.outputQuantity = 1,
    this.notes,
  });
}

class SkillReq {
  final String skill;
  final int level;
  final bool boostable;
  final String? xp;

  const SkillReq({
    required this.skill,
    required this.level,
    this.boostable = true,
    this.xp,
  });
}

class MaterialReq {
  final String name;
  final int quantity;

  const MaterialReq({required this.name, this.quantity = 1});
}

/// Parse OSRS Wiki wikitext into structured item info.
WikiItemInfo parseWikitext(String title, String wikitext) {
  final infobox = _parseInfobox(wikitext);
  final creations = _parseCreationTemplates(wikitext);
  final obtainMethods = _parseObtainMethods(wikitext);

  return WikiItemInfo(
    name: infobox['name'] ?? title,
    members: _isTruthy(infobox['members']),
    examine: infobox['examine'],
    quest: infobox['quest'],
    tradeable: infobox['tradeable'] != 'No',
    weight: infobox['weight'],
    creationMethods: creations,
    obtainMethods: obtainMethods,
  );
}

bool _isTruthy(String? v) {
  if (v == null) return false;
  final l = v.toLowerCase().trim();
  return l == 'yes' || l == 'true' || l == '1';
}

/// Extract key=value pairs from the first {{Infobox Item}} or {{Infobox ...}}
Map<String, String> _parseInfobox(String wikitext) {
  final result = <String, String>{};

  // Find the infobox template
  final infoboxMatch =
      RegExp(r'\{\{Infobox\s+\w+', caseSensitive: false).firstMatch(wikitext);
  if (infoboxMatch == null) return result;

  // Extract the full template content by matching braces
  final start = infoboxMatch.start;
  final content = _extractTemplate(wikitext, start);
  if (content == null) return result;

  // Parse pipe-delimited key=value pairs
  final paramRegex = RegExp(r'\|([^=|{}]+?)\s*=\s*([^|{}]*?)(?=\||$)',
      multiLine: true, dotAll: true);
  for (final match in paramRegex.allMatches(content)) {
    final key = match.group(1)?.trim().toLowerCase() ?? '';
    var value = match.group(2)?.trim() ?? '';
    // Strip wiki markup like [[...]] and {{...}}
    value = _stripWikiMarkup(value);
    if (key.isNotEmpty && value.isNotEmpty) {
      result[key] = value;
    }
  }
  return result;
}

/// Parse all {{Creation}} templates in the wikitext.
List<CreationMethod> _parseCreationTemplates(String wikitext) {
  final methods = <CreationMethod>[];

  // Find all {{Creation ...}} templates
  final regex = RegExp(r'\{\{Creation', caseSensitive: false);
  for (final match in regex.allMatches(wikitext)) {
    final content = _extractTemplate(wikitext, match.start);
    if (content == null) continue;

    final params = _parseTemplateParams(content);

    // Parse facility
    final facility = _stripWikiMarkup(params['facility'] ?? '');

    // Parse skills
    final skills = <SkillReq>[];
    for (int i = 1; i <= 5; i++) {
      final skillKey = i == 1 ? 'skill1' : 'skill$i';
      final lvlKey = i == 1 ? 'skill1lvl' : 'skill${i}lvl';
      final xpKey = i == 1 ? 'skill1exp' : 'skill${i}exp';
      // Also try "skills" param which may contain {{Skill clickpic|Name|Level}}
      final String? skillName = params[skillKey];
      final String? skillLvl = params[lvlKey];
      final String? skillXp = params[xpKey];

      if (skillName != null && skillLvl != null) {
        skills.add(SkillReq(
          skill: _stripWikiMarkup(skillName),
          level: int.tryParse(skillLvl) ?? 0,
          xp: skillXp,
        ));
      }
    }

    // Fallback: parse "skills" param for {{Skill clickpic|Name|Level}}
    if (skills.isEmpty) {
      final skillsParam = params['skills'] ?? '';
      final skillClickpic =
          RegExp(r'\{\{Skill[^}]*\|(\w+)\|(\d+)');
      for (final sm in skillClickpic.allMatches(skillsParam)) {
        skills.add(SkillReq(
          skill: sm.group(1) ?? '',
          level: int.tryParse(sm.group(2) ?? '0') ?? 0,
        ));
      }
    }

    // Parse materials
    final materials = <MaterialReq>[];
    for (int i = 1; i <= 15; i++) {
      final matKey = 'mat$i';
      final qtyKey = 'mat${i}qty';
      // Some templates use "matNquantity" instead of "matNqty"
      final qtyAlt = 'mat${i}quantity';
      final matName = params[matKey];
      if (matName == null || matName.isEmpty) continue;
      final qty = int.tryParse(params[qtyKey] ?? params[qtyAlt] ?? '1') ?? 1;
      materials.add(MaterialReq(
        name: _stripWikiMarkup(matName),
        quantity: qty,
      ));
    }

    // Parse output quantity
    final outQty =
        int.tryParse(params['output1qty'] ?? params['output1quantity'] ?? '1') ?? 1;

    // Parse ticks
    final ticks = int.tryParse(params['ticks'] ?? '');

    if (materials.isNotEmpty || skills.isNotEmpty || facility.isNotEmpty) {
      methods.add(CreationMethod(
        facility: facility.isNotEmpty ? facility : null,
        skills: skills,
        materials: materials,
        ticks: ticks,
        outputQuantity: outQty,
      ));
    }
  }

  return methods;
}

/// Extract "how to obtain" info from the wikitext body.
List<String> _parseObtainMethods(String wikitext) {
  final methods = <String>[];

  // Look for common section headers that describe obtaining
  final sectionRegex = RegExp(
    r'==+\s*(Creation|Products|Obtaining|How to obtain|Dropping monsters|'
    r'Item sources|Shop locations|Treasure Trails|Store locations)\s*==+',
    caseSensitive: false,
  );

  for (final match in sectionRegex.allMatches(wikitext)) {
    final sectionName = match.group(1) ?? '';
    // Get content up to next section header
    final afterSection = wikitext.substring(match.end);
    final nextSection = RegExp(r'==+\s*\w').firstMatch(afterSection);
    final sectionContent = nextSection != null
        ? afterSection.substring(0, nextSection.start)
        : afterSection;

    // Extract bullet points and key sentences
    final lines = sectionContent.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('*') || trimmed.startsWith('#')) {
        final clean = _stripWikiMarkup(
            trimmed.replaceFirst(RegExp(r'^[*#]+\s*'), ''));
        if (clean.length > 3) {
          methods.add('$sectionName: $clean');
        }
      }
    }

    // If no bullet points found, take the first meaningful paragraph
    if (methods.isEmpty) {
      final paragraph = lines
          .where((l) => l.trim().isNotEmpty && !l.trim().startsWith('{'))
          .take(3)
          .map((l) => _stripWikiMarkup(l.trim()))
          .where((l) => l.length > 5)
          .join(' ');
      if (paragraph.isNotEmpty) {
        methods.add('$sectionName: $paragraph');
      }
    }
  }

  // Look for {{DropsLine}} templates (monster drops)
  final dropsRegex = RegExp(
      r'\{\{DropsLine\s*\|[^}]*name\s*=\s*([^|}]+)',
      caseSensitive: false);
  final dropMonsters = <String>{};
  for (final m in dropsRegex.allMatches(wikitext)) {
    dropMonsters.add(_stripWikiMarkup(m.group(1)?.trim() ?? ''));
  }
  if (dropMonsters.isNotEmpty && dropMonsters.length <= 10) {
    methods.add('Dropped by: ${dropMonsters.join(', ')}');
  } else if (dropMonsters.length > 10) {
    methods.add('Dropped by: ${dropMonsters.take(10).join(', ')} and more');
  }

  // Look for shop info {{StoreLine}}
  final storeRegex = RegExp(
      r'\{\{StoreLine\s*\|[^}]*name\s*=\s*([^|}]+)',
      caseSensitive: false);
  final shops = <String>{};
  for (final m in storeRegex.allMatches(wikitext)) {
    shops.add(_stripWikiMarkup(m.group(1)?.trim() ?? ''));
  }
  if (shops.isNotEmpty) {
    methods.add('Sold at: ${shops.join(', ')}');
  }

  return methods;
}

/// Extract a full {{Template...}} by balancing braces from startIndex.
String? _extractTemplate(String text, int startIndex) {
  int depth = 0;
  int? contentStart;
  for (int i = startIndex; i < text.length - 1; i++) {
    if (text[i] == '{' && text[i + 1] == '{') {
      if (depth == 0) contentStart = i;
      depth++;
      i++; // skip second brace
    } else if (text[i] == '}' && text[i + 1] == '}') {
      depth--;
      if (depth == 0) {
        return text.substring(contentStart! + 2, i);
      }
      i++;
    }
  }
  return null;
}

/// Parse pipe-delimited parameters from template content.
Map<String, String> _parseTemplateParams(String content) {
  final result = <String, String>{};
  // Remove the template name (first segment before |)
  final firstPipe = content.indexOf('|');
  if (firstPipe < 0) return result;
  final params = content.substring(firstPipe + 1);

  // Split on top-level pipes (not inside {{ }})
  int depth = 0;
  int start = 0;
  for (int i = 0; i < params.length; i++) {
    if (i < params.length - 1 && params[i] == '{' && params[i + 1] == '{') {
      depth++;
      i++;
    } else if (i < params.length - 1 &&
        params[i] == '}' &&
        params[i + 1] == '}') {
      depth--;
      i++;
    } else if (params[i] == '|' && depth == 0) {
      _addParam(result, params.substring(start, i));
      start = i + 1;
    }
  }
  _addParam(result, params.substring(start));

  return result;
}

void _addParam(Map<String, String> map, String segment) {
  final eq = segment.indexOf('=');
  if (eq < 0) return;
  final key = segment.substring(0, eq).trim().toLowerCase();
  final value = segment.substring(eq + 1).trim();
  if (key.isNotEmpty) map[key] = value;
}

/// Strip common wiki markup: [[links]], {{templates}}, '''bold''', etc.
String _stripWikiMarkup(String text) {
  var s = text;
  // [[Link|Display]] -> Display, [[Link]] -> Link
  s = s.replaceAllMapped(
      RegExp(r'\[\[([^|\]]*\|)?([^\]]+)\]\]'), (m) => m.group(2) ?? '');
  // {{sic}}, {{*}}, simple templates -> empty
  s = s.replaceAll(RegExp(r'\{\{[^}]*\}\}'), '');
  // Bold/italic
  s = s.replaceAll(RegExp(r"'{2,3}"), '');
  // HTML tags
  s = s.replaceAll(RegExp(r'<[^>]*>'), '');
  // Collapse whitespace
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}
