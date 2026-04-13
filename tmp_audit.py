import sys

f = open('lib/l10n/app_localizations.dart', 'r', encoding='utf-8')
c = f.read()
f.close()

maps = ['_hindiStrings', '_malayalamStrings', '_kannadaStrings', '_tamilStrings', '_bengaliStrings', '_teluguStrings']
for m in maps:
    idx = c.find(m)
    if idx < 0:
        print(f"{m}: NOT_FOUND")
        continue
    chunk = c[idx:idx+8000]
    has_key = 'historySubtitle' in chunk
    print(f"{m}: {has_key}")
