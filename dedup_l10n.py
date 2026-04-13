import re

try:
    with open('lib/l10n/app_localizations.dart', 'r', encoding='utf-8') as f:
        c = f.read()

    maps = ['_englishStrings', '_hindiStrings', '_malayalamStrings', '_kannadaStrings', '_tamilStrings', '_bengaliStrings', '_teluguStrings']

    for m in maps:
        start = c.find(f'const Map<String, String> {m} = {{')
        if start == -1:
            continue
        
        end = c.find('};', start)
        if end == -1:
            continue
            
        map_text = c[start:end+2]
        
        # We need to extract the lines inside the map.
        # Lines generally look like: 'key': 'value',
        # First isolate the dict contents
        content_start = map_text.find('{') + 1
        content_end = map_text.rfind('}')
        content = map_text[content_start:content_end]
        
        # We process line by line or find key/value pairs
        # Since string values might span multiple lines, let's use a regex to match keys
        # We'll build a parsed dictionary, keeping the FIRST occurrence of a key
        # and deleting subsequent lines that start with that key.
        # Actually it's easier to find lines that start with the duplicated keys and remove them.
        import collections
        keys = re.findall(r"^\s*'([^']+)'\s*:", content, re.MULTILINE)
        dup_counts = collections.Counter(keys)
        dups = [item for item, count in dup_counts.items() if count > 1]
        
        if dups:
            print(f"Dups in {m}: {dups}")
            for d in dups:
                # Find all occurrences of this key
                pattern = re.compile(r"^\s*'" + re.escape(d) + r"'\s*:\s*.*?(?:\\n.*?)?',", re.MULTILINE)
                matches = list(pattern.finditer(content))
                if len(matches) > 1:
                    # Keep the first, remove the rests
                    for match in reversed(matches[1:]):
                        content = content[:match.start()] + content[match.end():]
            
            # Reconstruct map
            new_map_text = map_text[:content_start] + content + map_text[content_end:]
            c = c.replace(map_text, new_map_text)

    with open('lib/l10n/app_localizations.dart', 'w', encoding='utf-8') as f:
        f.write(c)

    print("Deduplication complete")
except Exception as e:
    print(f"Error: {e}")
