import re
import collections

try:
    with open('lib/l10n/app_localizations.dart', 'r', encoding='utf-8') as f:
        c = f.read()

    maps = ['_kannadaStrings', '_tamilStrings', '_bengaliStrings', '_teluguStrings', '_hindiStrings', '_malayalamStrings']

    for m in maps:
        start = c.find(m)
        if start == -1:
            print(f'Map {m} not found')
            continue
        end = c.find('};', start)
        text = c[start:end]
        
        # Extract keys from the map
        keys = re.findall(r"^\s*'([^']+)'\s*:", text, re.MULTILINE)
        
        dups = [item for item, count in collections.Counter(keys).items() if count > 1]
        if dups:
            for d in dups:
                print(f'Duplicate key found: {d} in {m}')
        else:
            print(f'No duplicates in {m}')

except Exception as e:
    print(f'Error: {e}')
