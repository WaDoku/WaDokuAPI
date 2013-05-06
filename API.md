# GET /api/v1/search

## Mandatory parameters:

- query: The search query

## Optional paramaters:

- mode: May be 'fuzzy', 'forward' or 'backward'. Forward and backward search ONLY in headwords, fuzzy searches everywhere and tries to weigh the results. Defaults to fuzzy.
- format: May be html or plain. Defaults to html.
- offset: Start returning results from offset position. Defaults to 0.
- limit: How many records should be returned. Defaults to 30.
- callback: Returns everything wrapped in the given callback for JSONP.
- full_sub_entries: If true, sub_entries will be returned as full entries instead of just the WaDoku id. Defaults to false.

## Output

  Returns 30 results as default. Use total to see how many results there are
  overall.

  Example:
  ```
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
          "→ する", [9, 10],
          "▷": [1, 2, 3],
          "☆": [4, 5, 6],
          ...
        }
      }
    ]
  }
```
# GET /api/v1/parse

## Mandatory parameters:

- markup: The markup that should be parsed.

## Output

The parsed entry as a JSON object or a JSON object with the key "error".

# GET /api/v1/suggestions

## Mandatory parameters:

- query: The partial query

## Output

A JSON object containing a key 'suggestions' with the value of an array of strings.
