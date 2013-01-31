# /api/v1/search

## Mandatory parameters:

- query: The search query

## Optional paramaters:

- format: May be html or plain.
- offset: Start returning results from offset position. Defaults to 0.

## Output

  Returns 30 results. Use total to see how many results there are
  overall.

  Example:
  {
    total: 100,
    query: "Test",
    offset: 0,
    entries: [
      {
        wadoku_id: 1,
        midashigo: "...",
        writing: "...",
        kana: "...",
        romaji: "...",
        definition: "...." // In html or plain text
        sub_entries: {
          "Abl. mit <Umschr.: da>": [1, 2, 3],
          "Abl. mit <Umschr.: suru>": [4, 5, 6],
          ...
        }
        }
      }
    ]
  }

