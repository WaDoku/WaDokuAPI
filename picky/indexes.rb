#encoding:utf-8

# How text is indexed. Move to Index block to make it index specific.
#
indexing removes_characters: /[^a-zA-Z0-9\s\/\-\_\:\"\&\.]/i,
         stopwords:          /\b(and|the|of|it|in|for)\b/i,
         splits_text_on:     /[\s\/\-\_\:\"\&\/]/

# How query text is preprocessed. Move to Search block to make it search specific.
#
searching removes_characters: /[^\p{Han}\p{Katakana}\p{Hiragana}a-zA-Z0-9\s\/\-\_\&\.\"\~\*\:\,]/i, # Picky needs control chars *"~:, to pass through.
          stopwords:          /\b(and|the|of|it|in|for)\b/i,
          splits_text_on:     /[\s\/\-\&]+/

japanese_index = Picky::Index.new :japanese do
  source WadokuTabReader.new("source_data/WaDokuNormal.tab")

  indexing :removes_characters => /[^\p{Han}\p{Katakana}\p{Hiragana}\s;\(\)\[\]]/,
           :stopwords =>         /\b(and|the|of|it|in|for)\b/i,
           :splits_text_on =>    /[\s;\(\)\[\]]/

  category :writing
  category :kana
end

romaji_index = Picky::Index.new :latin do
  source WadokuTabReader.new("source_data/WaDokuNormal.tab")

  indexing :removes_characters => /[^a-zA-Z0-9\s;\(\)\[\]<>]/,
           :stopwords =>         /\b(und|der|ein|die|das|eine)\b/i,
           :splits_text_on =>    /[\s;\(\)\[\]<>]/

  category :romaji
  category :definition
end

wadoku_search = Picky::Search.new(japanese_index, romaji_index) do
     
  boost [:romaji] => +6

end

