class TreFilter < Parslet::Transform

  rule(:text => simple(:x)) {String.new(x)}
  #rule(:genus => simple(:g), :text => simple(:t)) {"<span class='genus #{g}'>#{g}</span> #{t}"}
  rule(:genus => simple(:g)){nil}
  rule(:wrong => simple(:wrong), :genus => simple(:g), :text => simple(:t)) {[wrong + t]}
  rule(:hw => sequence(:contents)) {contents.reverse.compact.join(" ")}
  rule(:emph => simple(:emph)) {nil}
  rule(:topic => simple(:topic)) {nil}
  rule(:dom => simple(:dom)) {nil}
  rule(:transl => simple(:transl)) {nil}
  rule(:descr => sequence(:contents)) {nil}
  rule(:fore => sequence(:contents)) {nil}
  rule(:pos => sequence(:contents)) {nil} 
  rule(:tre => sequence(:contents)) {contents.compact.join(" ")}
  rule(:mgr => sequence(:contents)) {contents.compact.join("; ")}
  rule(:transcr => sequence(:contents)) {nil}
  rule(:title => sequence(:contents)) {contents.compact.join}
  rule(:tags_with_parens => sequence(:contents)) do
    nil
  end
  rule(:title_type => simple(:title_type)) {nil}
  rule(:kimulem => simple(:kimulem)) {nil}
  rule(:dij => simple(:dij)) {nil}
  rule(:scientif => sequence(:contents)) {contents.compact.join}
  rule(:date => simple(:date)) {date}
  rule(:usage => simple(:usage)) {nil}
  rule(:langniv => simple(:langniv)) {nil}
  rule(:seasonw => simple(:seasonw)) {nil}
  rule(:birthdeath => simple(:birthdeath)) {nil}
  rule(:famn => simple(:famn)) {famn}
  rule(:expl => sequence(:contents)) {nil}
  rule(:defi=> sequence(:contents)) {nil}
  rule(:preamble => sequence(:contents)) {nil}
  rule(:todo => simple(:todo)) {nil}
  rule(:fore => sequence(:contents)) {nil}
  rule(:etym=> sequence(:contents)) {nil}
  rule(:specchar=> simple(:specchar)) {specchar.to_s}

  rule(:lang => simple(:lang), :keyword => simple(:keyword)) {nil }
  rule(:wiki => simple(:wiki)) {nil}

  rule(:audio => simple(:audio)) {nil}
  rule(:unknown => simple(:unknown)) {nil}
  rule(:s_number => simple(:s_number)) { nil }
  rule(:steinhaus => sequence(:contents)) {nil}
  rule(:number => simple(:n), :mgr => sequence(:contents)) do
    contents.compact.join("; ")
  end

  rule(:number => simple(:n), :dom => simple(:dom), :mgr => sequence(:contents)) do
    contents.compact.join("; ")
  end
  rule(:number => simple(:n), :tags_with_parens => sequence(:tags_content), :mgr => sequence(:contents)) do
    tags_content.compact!
    contents.compact.join("; ")
  end

  rule(:wrong_number => simple(:n), :mgr => sequence(:contents)) do
    contents.compact.join("; ")
  end

  rule(:thing => simple(:thing)){ "[#{thing}]" }
  rule(:thing => simple(:thing), :tags_with_parens => sequence(:contents)){ "[#{thing}] (#{contents.compact.join("; ")})" }

  rule(:marker => simple(:n)) {nil}
  rule(:jwd => simple(:jwd)) {nil}

  rule(:url => simple(:url)) {nil}


  rule(:pict => subtree(:x)) { nil }

  rule(:transcr => sequence(:t_content), :jap => simple(:jap), :daid => simple(:d)) do
    nil
  end

  rule(:jap => simple(:jap)) {nil}

  rule(:impli => simple(:impli)) {nil}
  rule(:expli => sequence(:content)){nil}
  rule(:literal => sequence(:content)){nil}

  rule(:relation => simple(:relation), :transcr => sequence(:t_content), :jap => simple(:jap), :daid => simple(:d)) do
    nil
  end


  rule(:numbered_mgr => simple(:numbered_mgr)) {numbered_mgr }

  rule(:full_entry => sequence(:contents)) do
    res = contents.compact.join(" ")
    res += "." unless res[/\.(<\/span>)*$/]
    res
  end


  # drop it.
  rule(:seperator => simple(:seperator)){nil}
end

