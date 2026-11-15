import json, pathlib, urllib.request, urllib.error, urllib.parse, re, sys

BOOKS = [
"Genesis","Exodus","Leviticus","Numbers","Deuteronomy","Joshua","Judges","Ruth",
"1 Samuel","2 Samuel","1 Kings","2 Kings","1 Chronicles","2 Chronicles","Ezra","Nehemiah",
"Esther","Job","Psalms","Proverbs","Ecclesiastes","Song of Solomon","Isaiah","Jeremiah",
"Lamentations","Ezekiel","Daniel","Hosea","Joel","Amos","Obadiah","Jonah","Micah","Nahum",
"Habakkuk","Zephaniah","Haggai","Zechariah","Malachi","Matthew","Mark","Luke","John","Acts",
"Romans","1 Corinthians","2 Corinthians","Galatians","Ephesians","Philippians","Colossians",
"1 Thessalonians","2 Thessalonians","1 Timothy","2 Timothy","Titus","Philemon","Hebrews",
"James","1 Peter","2 Peter","1 John","2 John","3 John","Jude","Revelation"
]
OUT = pathlib.Path("assets/bible")
OUT.mkdir(parents=True, exist_ok=True)
BASE = "https://raw.githubusercontent.com/renniemaharaj/kjv-bible/main/"

def normalize(book, data):
    chapters = data.get("chapters") if isinstance(data, dict) else None
    if chapters is None and isinstance(data, dict):
        # Some KJV sources wrap the book in a named key.
        for value in data.values():
            if isinstance(value, dict) and "chapters" in value:
                chapters = value["chapters"]
                break
    if chapters is None:
        raise ValueError(f"{book}: no chapters object found")
    result = {}
    if isinstance(chapters, list):
        for ci, chapter in enumerate(chapters, 1):
            verses = chapter.get("verses", []) if isinstance(chapter, dict) else chapter
            if isinstance(verses, list):
                result[str(ci)] = {str(v.get("verse", i+1)): str(v.get("text", v.get("verse_text", ""))) if isinstance(v, dict) else str(v) for i,v in enumerate(verses)}
            elif isinstance(verses, dict):
                result[str(ci)] = {str(k): str(v) for k,v in verses.items()}
    elif isinstance(chapters, dict):
        for ck, verses in chapters.items():
            if isinstance(verses, list):
                result[str(ck)] = {str(v.get("verse", i+1)): str(v.get("text", v.get("verse_text", ""))) if isinstance(v, dict) else str(v) for i,v in enumerate(verses)}
            elif isinstance(verses, dict):
                result[str(ck)] = {str(k): str(v) for k,v in verses.items()}
    if not result or any(not verses for verses in result.values()):
        raise ValueError(f"{book}: chapter data is empty or unsupported")
    return {"book": book, "chapters": result}

for book in BOOKS:
    filename = book + ".json"
    url = BASE + urllib.parse.quote(filename)
    req = urllib.request.Request(url, headers={"User-Agent":"NERO-Bible-App/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=45) as response:
            raw = response.read()
        data = json.loads(raw.decode("utf-8-sig"))
        normalized = normalize(book, data)
        target = OUT / (book.lower().replace(" ", "_") + ".json")
        target.write_text(json.dumps(normalized, ensure_ascii=False, separators=(",",":")), encoding="utf-8")
        print(f"Downloaded {book}: {len(normalized['chapters'])} chapters")
    except Exception as exc:
        print(f"FAILED {book}: {exc}", file=sys.stderr)
        raise
print("KJV book data download complete: 66 books.")
