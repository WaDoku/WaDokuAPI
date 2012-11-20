# /api/v1/search

## Mandatory parameters:

- query: The search query

## Optional paramaters:

- format: May be json. Defaults to json.
- definition\_format: May be html, text. Defaults to text.
- offset: Start returning results from offset position. Defaults to 0.
- include\_related: Include related entries in results.

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
        definition: "...."
        sub_entries: [2,3,4] // These are WaDoku IDs
      }
    ]
  }

