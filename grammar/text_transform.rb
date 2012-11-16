class TextTransform < Parslet::Transform

  rule(:text => simple(:x)) {String.new(x)} 
  #rule(:genus => simple(:g), :text => simple(:t)) {"<span class='genus #{g}'>#{g}</span> #{t}"}
  rule(:genus => simple(:g)){"(#{g})"}
  rule(:wrong => simple(:wrong), :genus => simple(:g), :text => simple(:t)) {"<span class='genus #{g}'>#{g}</span> #{wrong + t}"}
  rule(:todo => subtree(:todo)) {""}
  rule(:hw => sequence(:contents)) {contents[1] + " " + contents[0]}
  rule(:emph => simple(:emph)) {emph}
  rule(:topic => simple(:topic)) {topic}
  rule(:dom => simple(:dom)) {"{Dom.: #{dom}}"}
  rule(:transl => simple(:transl)) {transl}
  rule(:descr => sequence(:contents)) {contents.compact.join}
  rule(:fore => sequence(:contents)) {contents.compact.join}
  rule(:pos => sequence(:contents)) {"(#{contents.compact.join("")})" } 
  rule(:tre => sequence(:contents)) {contents.compact.join("")}
  rule(:mgr => sequence(:contents)) {"#{contents.compact.join("; ").gsub("};", "}")}."} 
  rule(:transcr => sequence(:contents)) {contents.compact.join}
  rule(:title => sequence(:contents)) {contents.compact.join}
  rule(:tags_with_parens => sequence(:contents)) do
    contents.compact!
    contents.empty? ? nil :  "(#{contents.compact.join("; ")})" 
  end
  rule(:title_type => simple(:title_type)) {nil}
  rule(:scientif => sequence(:contents)) {"Scientif.: " + contents.compact.join}
  rule(:date => simple(:date)) {date}
  rule(:usage => simple(:usage)) {usage}
  rule(:langniv => simple(:langniv)) {langniv}
  rule(:seasonw => simple(:seasonw)) {seasonw}
  rule(:birthdeath => simple(:birthdeath)) {birthdeath}
  rule(:famn => simple(:famn)) {famn.to_s.upcase}
  rule(:expl => sequence(:contents)) {contents.compact.join}
  rule(:defi=> sequence(:contents)) {"Def.: " + contents.compact.join}
  rule(:preamble => sequence(:contents)) {contents.compact.join}
  rule(:fore => sequence(:contents)) {contents.compact.join}
  rule(:etym=> sequence(:contents)) {contents.compact.join}
  rule(:specchar=> simple(:specchar)) {specchar.to_s}

  rule(:lang => simple(:lang), :keyword => simple(:keyword)) {"Wikipedia: <a href='http://#{lang.to_s.downcase}.wikipedia.org/wiki/#{keyword}'>#{keyword}</a>" }
  rule(:wiki => simple(:wiki)) {"#{wiki}"}

  rule(:audio => simple(:audio)) {nil}
  rule(:unknown => simple(:unknown)) {nil}
  rule(:s_number => simple(:s_number)) {s_number.to_s}
  rule(:steinhaus => sequence(:contents)) {"<Steinhaus: #{contents.compact.join(',')}>"}
  rule(:number => simple(:n), :mgr => sequence(:contents)) do
    "#{n} #{contents.compact.join("; ")}."
  end

  rule(:number => simple(:n), :dom => simple(:dom), :mgr => sequence(:contents)) do
    "#{n} #{dom} #{contents.compact.join("; ")}."
  end
  rule(:number => simple(:n), :tags_with_parens => sequence(:tags_content), :mgr => sequence(:contents)) do
    tags_content.compact!
    "#{n} #{tags_content.empty? ? '' : "(#{tags_content.compact.join("; ")})"} #{contents.compact.join("; ")}."
  end

  rule(:wrong_number => simple(:n), :mgr => sequence(:contents)) do
    "#{n.to_s[/\d+/]} #{contents.compact.join("; ")}."
  end

  rule(:thing => simple(:thing)){ "[#{thing}]" }
  rule(:thing => simple(:thing), :tags_with_parens => sequence(:contents)){ "[#{thing}] (#{contents.compact.join("; ")})" }

  rule(:marker => simple(:n)) {nil}
  rule(:jwd => simple(:jwd)) {nil}

  rule(:url => simple(:url)) {"<a href='#{url}'>#{url}</a>"}


  rule(:pict => subtree(:x)) { nil }

  rule(:transcr => sequence(:t_content), :jap => simple(:jap), :daid => simple(:d)) do
    "'#{t_content.compact.join} / #{jap}'"  
  end

  rule(:jap => simple(:jap)) {jap}

  rule(:impli => simple(:impli)) {impli}
  rule(:expli => sequence(:content)){" #{content.compact.join}"}
  rule(:literal => sequence(:content)){" #{content.compact.join}"}

  rule(:relation => simple(:relation), :transcr => sequence(:t_content), :jap => simple(:jap), :daid => simple(:d)) do
    "#{relation} '#{t_content.compact.join} / #{jap}'"  
  end


  rule(:numbered_mgr => simple(:numbered_mgr)) {numbered_mgr}

  rule(:full_entry => sequence(:contents)) do
    res = contents.compact.join(" ")
    res += "." unless res[/\.(<\/span>)*$/]
    res
  end

  
  # drop it.
  rule(:seperator => simple(:seperator)){nil}
end

