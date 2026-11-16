"""Download and normalize the 66-book King James Version for NERO."""
import json
import pathlib
import urllib.parse
import urllib.request

BOOKS = [
    "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth",
    "1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra", "Nehemiah",
    "Esther", "Job", "Psalms", "Proverbs", "Ecclesiastes", "Song of Solomon", "Isaiah", "Jeremiah",
    "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos", "Obadiah", "Jonah", "Micah", "Nahum",
    "Habakkuk", "Zephaniah", "Haggai", "Zechariah", "Malachi", "Matthew", "Mark", "Luke", "John", "Acts",
    "Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians",
    "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews",
    "James", "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude", "Revelation",
]
BASE_URL = "https://raw.githubusercontent.com/renniemaharaj/kjv-bible/main/"
OUTPUT = pathlib.Path("assets/bible")


def get_chapters(data):
    if not isinstance(data, dict):
        raise ValueError("The downloaded book is not a JSON object")
    chapters = data.get("chapters")
    if isinstance(chapters, (dict, list)):
        return chapters
    # This source stores chapter numbers directly at the top level.
    numeric = {str(key): value for key, value in data.items() if str(key).isdigit()}
    if numeric:
        return numeric
    # Also accept a book-name wrapper containing a chapters object.
    for value in data.values():
        if isinstance(value, dict):
            nested = value.get("chapters")
            if isinstance(nested, (dict, list)):
                return nested
            nested_numeric = {str(key): item for key, item in value.items() if str(key).isdigit()}
            if nested_numeric:
                return nested_numeric
    raise ValueError("No supported chapter data was found")


def normalize_chapter(chapter, book, chapter_number):
    if isinstance(chapter, dict) and "verses" in chapter:
        chapter = chapter["verses"]
    verses = {}
    if isinstance(chapter, list):
        for index, verse in enumerate(chapter, start=1):
            if isinstance(verse, dict):
                number = verse.get("verse", index)
                text = verse.get("text", verse.get("verse_text", ""))
            else:
                number, text = index, verse
            text = str(text).strip()
            if text:
                verses[str(number)] = text
    elif isinstance(chapter, dict):
        for number, verse in chapter.items():
            if isinstance(verse, dict):
                verse = verse.get("text", verse.get("verse_text", ""))
            text = str(verse).strip()
            if text:
                verses[str(number)] = text
    if not verses:
        raise ValueError(f"{book} chapter {chapter_number} has no verses")
    return dict(sorted(verses.items(), key=lambda item: int(item[0])))


def normalize(book, data):
    source = get_chapters(data)
    entries = enumerate(source, start=1) if isinstance(source, list) else source.items()
    chapters = {}
    for chapter_number, chapter_data in entries:
        key = str(chapter_number)
        if not key.isdigit():
            continue
        chapters[key] = normalize_chapter(chapter_data, book, key)
    chapters = dict(sorted(chapters.items(), key=lambda item: int(item[0])))
    if not chapters:
        raise ValueError(f"{book} contains no valid chapters")
    return {"book": book, "chapters": chapters}


def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    total_verses = 0
    for book in BOOKS:
        filename = urllib.parse.quote(book + ".json")
        url = BASE_URL + filename
        request = urllib.request.Request(url, headers={"User-Agent": "NERO-Offline-Bible/1.0"})
        print(f"Downloading {book}...", flush=True)
        with urllib.request.urlopen(request, timeout=60) as response:
            source = json.loads(response.read().decode("utf-8-sig"))
        normalized = normalize(book, source)
        total_verses += sum(len(items) for items in normalized["chapters"].values())
        output_name = book.lower().replace(" ", "_") + ".json"
        (OUTPUT / output_name).write_text(
            json.dumps(normalized, ensure_ascii=False, separators=(",", ":")), encoding="utf-8"
        )
        print(f"Prepared {book}: {len(normalized['chapters'])} chapters", flush=True)

    files = list(OUTPUT.glob("*.json"))
    if len(files) != 66:
        raise SystemExit(f"Expected 66 Bible books, found {len(files)}")
    print(f"Complete: 66 KJV books and {total_verses} verses are ready.")


if __name__ == "__main__":
    main()
