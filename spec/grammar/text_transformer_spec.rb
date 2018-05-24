require 'spec_helper'
require 'pry'

describe TextTransform do
  let(:grammar) { WadokuGrammar.new }
  let(:transformer) { TextTransform.new }
  it 'transforms steinhaus links' do
    steinhaus = grammar.steinhaus.parse('<Steinhaus: 28>')
    res = transformer.apply(steinhaus)
    expect(res).to eq('<Steinhaus: 28>')
  end
  it 'transforms text elements' do
    tree = { text: 'Ein einfacher Text' }
    res = transformer.apply(tree)
    expect(res).to eq('Ein einfacher Text')
  end

  it 'transforms HW elements' do
    tree = grammar.hw.parse('<HW f: Artischocke>')
    res = transformer.apply(tree)
    expect(res).to eq('Artischocke (f)')
  end

  it 'removes Kimulems and DIJ (for now)' do
    text = '(<POS: Interj.>) (<Usage: onomat.>) [1]<MGr: <TrE: ah!>; <TrE: ach!>; <TrE: ach ja!>; <TrE: huch!>; <TrE: oh!>; <TrE: oje!>; <TrE: nein!>; <TrE: oh nein!> (<Expl.: Ausruf bei Überraschung, Erstaunen, Erschrecken, Schmerz, Enttäuschung>)> // <MGr: <TrE: ach, ja>; <TrE: ja>; <TrE: ja, richtig>; <TrE: ja, genau>; <TrE: äh>; <TrE: ähm> (<Expl.: Ausruf, wenn einem etwas wieder einfällt>)>. (<Ref.: ⇒ <Transcr.: ă> <Jap.: あっ><DaID: 5646032>>；<Ref.: ⇒ <Transcr.: ā> <Jap.: ああ><DaID: 9277371>>). [2] <MGr: <TrE: he>; <TrE: heh>; <TrE: hallo> (<Expl.: Ausruf, um jmdn. anzusprechen>；<Ref.: ⇒ <Transcr.: ā> <Jap.: ああ><DaID: 9277371>>)>. [3]<MGr: <TrE: ja!>; <TrE: jawohl!>; <TrE: hier!> (<Expl.: Antwort darauf, dass man gerufen wird>；<Ref.: ⇒ <Transcr.: ā> <Jap.: ああ><DaID: 9277371>>)>. (<KimuLem: 1>；<DIJ: 33>).'
    parse = grammar.parse_with_debug(text)
    res = transformer.apply(parse).to_s
    expect(res).not_to include('kimulem')
    expect(res).not_to include('dij')
  end

  it 'transforms complete entries' do
    text = '(<POS: N.>) <MGr: {<Dom.: Bot.>} <TrE: <HW f: Artischocke>> (<Scientif.: Cynara scolymus>)>.'
    tree = grammar.parse(text)
    res = transformer.apply(tree)
    expect(res).to eq('(N.) {Dom.: Bot.} Artischocke (f); (Scientif.: Cynara scolymus).')

    text = '(<POS: Adv. mit <Transcr.: to> und intrans. V. mit <Transcr.: suru>>) <MGr: <TrE: leuchtend grün>; <TrE: frisch>; <TrE: blass>>.'
    tree = grammar.parse(text)
    res = transformer.apply(tree)
    expect(res).to eq('(Adv. mit to und intrans. V. mit suru) leuchtend grün; frisch; blass.')

    text = '(<POS: N.>) [1]<MGr: <TrE: grüne <HW f: Erde>>>. [2]<MGr: <TrE: grünes <HW n: Pigment>>>.'
    tree = grammar.parse(text)
    res = transformer.apply(tree)
    expect(res).to eq('(N.) [1] grüne Erde (f). [2] grünes Pigment (n).')

    text = '<MGr: {<Dom.: Bsp.>} <TrE: Der Schüler übertrifft den Lehrer>> (<Expl.: üblicher ist die Version: <Ref.: <Transcr.: Ao wa ai yori idete ai yori aoshi.> <Jap.: 青は藍よりいでて藍より青し。><DaID: 1127026>>>).'
    tree = grammar.parse(text)
    res = transformer.apply(tree)
    expect(res).to eq("{Dom.: Bsp.} Der Schüler übertrifft den Lehrer. (üblicher ist die Version: 'Ao wa ai yori idete ai yori aoshi. / 青は藍よりいでて藍より青し。').")

    text = '(<POS: N.>) <MGr: {<Dom.: Boxen>} <TrE: <HW f: Ecke> des Champions>; <TrE: <HW f: Ecke> des Titelverteidigers>> (<Ref.: ⇒ <Transcr.: ao·kōnā> <Jap.: 青コーナー><DaID: 0142840>>).'
    tree = grammar.parse(text)
    res = transformer.apply(tree)
    expect(res).to eq("(N.) {Dom.: Boxen} Ecke (f) des Champions; Ecke (f) des Titelverteidigers. (⇒ 'ao·kōnā / 青コーナー').")

    text = '(<POS: N.>) (<LangNiv.: schriftspr.>) <MGr: <TrE: <HW nNAr: Asien> und <HW nNAr: Europa>>; <TrE: <HW nNAr: Eurasien>>> (<Ref.: ⇒ <Transcr.: Ō·A> <Jap.: 欧亜><DaID: 4150094>>)'
    tree = grammar.parse(text)
    res = transformer.apply(tree)

    text = '(<POS: N.>) <MGr: {<Dom.: Kleidung>} <TrE: <HW f: Pijacke>>; <TrE: <HW m: Kolani>>> (<Def.: blaue Seemannsüberjacke>；<Etym.: von engl. <For.: pea coat>>).'
    tree = grammar.parse(text)
    res = transformer.apply(tree)
    expect(res).to eq('(N.) {Dom.: Kleidung} Pijacke (f); Kolani (m). (Def.: blaue Seemannsüberjacke; von engl. pea coat).')

    text = '(<POS: N.>) [A](<Descr.: als Nomen>) [1]<MGr: <TrE: <JLPT2> <HW n: Blau>>> // <MGr: <TrE: <JLPT2><HW n: Grün>>>. [2]<MGr: <TrE: rote <HW f: Ampel>>>. [3]<MGr: <TrE: schwarzes <HW n: Pferd>>; <TrE: blauschwarzes <HW n: Pferd>>>. [4]<MGr: <TrE: <HW n: Aotan> (<Expl.: japan. Kartenspiel>；<Ref.: ⇒ <Transcr.: ao·tan> <Jap.: 青短；青丹><DaID: 3852075>>)>>. [5]<MGr: {<Dom.: Literaturw.>} <TrE: <HW n: Ao·hon> (<Def.: Genre illustrierter Geschichtenbücher mit Kabuki, Jōruri und Kriegsgeschichten>；<Ref.: ⇒ <Transcr.: ao·hon> <Jap.: 青本><DaID: 0116162>>)>>. [6]<MGr: <TrE: <HW f: Bronzemünze> (<Ref.: ⇒ <Transcr.: ao·sen> <Jap.: 青銭><DaID: 1168206>>)>>. [B]<MGr: <TrE: (<Descr.: als Präfix>) unreif>; <TrE: unerfahren>; <TrE: grün>> // <MGr: <TrE: <HW f: Unreife>>; <TrE: <HW f: Unerfahrenheit>>; <TrE: <HW f: Grünheit>. (<Ref.: ⇔ <Transcr.: aka> <Jap.: 赤><DaID: 9345046>>)>>.'
    tree = grammar.parse(text)
    res = transformer.apply(tree)
    expected = "(N.) [A] (als Nomen) [1]  Blau (n). Grün (n). [2] rote Ampel (f). [3] schwarzes Pferd (n); blauschwarzes Pferd (n). [4] Aotan (n) (japan. Kartenspiel; ⇒ 'ao·tan / 青短；青丹'). [5] {Dom.: Literaturw.}; Ao·hon (n) (Def.: Genre illustrierter Geschichtenbücher mit Kabuki, Jōruri und Kriegsgeschichten; ⇒ 'ao·hon / 青本'). [6] Bronzemünze (f) (⇒ 'ao·sen / 青銭'). [B] (als Präfix) unreif; unerfahren; grün. Unreife (f); Unerfahrenheit (f); Grünheit (f). (⇔ 'aka / 赤')."
    expect(res).to eq(expected)

    text = '(<POS: N.>) <MGr: {<Dom.: Persönlichk.>} <TrE: Peter Michael <FamN.: Blau>>> (<Def.: amerik. Politiksoziologe österr. Abstammung>；<BirthDeath: 1918–>).'
    tree = grammar.parse(text)
    res = transformer.apply(tree)
    expect(res).to eq('(N.) {Dom.: Persönlichk.} Peter Michael BLAU. (Def.: amerik. Politiksoziologe österr. Abstammung; 1918–).')

    text = '(<POS: Adj.>) [1]<MGr: <TrE: <Prior_1><JLPT2><GENKI_K9, GENKI_K9 _s_>blau>> // <MGr: <TrE: <Prior_1>grün (<Expl.: z. B. Ampel, Blattwerk>)>>. [2]<MGr: <TrE: <Prior_1>blass>; <TrE: bleich>>. [3]<MGr: <TrE: <Prior_1>unerfahren>>. (<Audio: aoi_Ac2>).'
    tree = grammar.parse(text)
    res = transformer.apply(tree)
    expect(res).to eq('(Adj.) [1] blau. grün (z. B. Ampel, Blattwerk). [2] blass; bleich. [3] unerfahren.')

    text = '(<POS: N.>) <MGr: {<Dom.: Werktitel>} <TrE: <Title ORIG L_ENG: The Blue <HW NAr: Boy>>>; <TrE: <Title L_DEU: Der <HW NAr: Knabe> in Blau>>> (<Def.: Gemälde von Gainsborough>；<Date: um 1770>).'
    tree = grammar.parse(text)
    res = transformer.apply(tree)
    expect(res).to eq('(N.) {Dom.: Werktitel} The Blue Boy (NAr); Der Knabe (NAr) in Blau. (Def.: Gemälde von Gainsborough; um 1770).')

    text = '(<POS: N.>) [1]<MGr: <TrE: <HW m: Doktor>>; <TrE: Dr. (<Expl.: akad. Titel>)>>. [2]<MGr: <TrE: <HW m: Arzt>>; <TrE: <HW m: Doktor>>>. [3]<MGr: <TrE: <HW n: Oberseminar>>; <TrE: <HW m: Graduiertenkurs>>; <TrE: <HW m: Doktorkurs> (<Etym.: Abk. für <Ref.: <Transcr.: <Emph.:dokutā>·kōsu> <Jap.: ドクター･コース><DaID: 0005780>>>). (<Etym.: von engl. <For.: doctor>>)>>.'
    tree = grammar.parse(text)
    res = transformer.apply(tree)
    expect(res).to eq("(N.) [1] Doktor (m); Dr. (akad. Titel). [2] Arzt (m); Doktor (m). [3] Oberseminar (n); Graduiertenkurs (m); Doktorkurs (m) (Abk. für 'dokutā·kōsu / ドクター･コース'). (von engl. doctor).")

    text = '(<POS: N.>) [A] (<Descr.: als N.>) [1]<MGr: <TrE: <HW n: Rot>>; <TrE: rote <HW f: Farbe> (<Def.: eine der drei Grundfarben>；<Expl.: Farbe des Blutes bzw. Farbton von rosa, orange, rötlich-braun bis braun>；<Expl.: rot kann weiter Goldfarbe symbolisieren>)>>. [2]<MGr: <TrE: rote <HW f: Ampel> (<Ref.: ⇔ <Transcr.: ao> <Jap.: 青><DaID: 2391562>>)>>. [3]<MGr: <TrE: (<LangNiv.: ugs.>) <HW m: Kommunist>>; <TrE: <HW m: Sozialist>>; <TrE: <HW m: Sozi>>; <TrE: <HW m: Roter>>>. [B] <MGr: (<Descr.: als Na.-Adj. mit <Transcr.: no>>) <TrE: vollkommen (<Expl.: nackt, fremd etc.>)>>. [5]<MGr: <TrE: rote <HW f: Zahl>>; <TrE: <HW n: Minus> (<Etym.: Abk. für <Ref.: <Transcr.: akaji> <Jap.: 赤字><DaID: 8114248>>>)>>. [6]<MGr: <TrE: <HW f: Auzki-Bohne> (<Expl.: ursprüngl. in der Geheimsprache der Hofdamen>)>>. [7]<MGr: <TrE: <Def.: eine rote <HW f: Karte> bei den japanischen Spielkarten> (<Etym.: Abk. für <Ref.: <Transcr.: aka·tan> <Jap.: 赤短；赤丹><DaID: 2030089>>>)>>. [8]<MGr: <TrE: rotes <HW n: Team>>; <TrE: die <HW mpl: Roten> (<Expl.: wenn es zwei Teams gibt, von denen das eine weiß und das andere rot ist>)>>. [9]<MGr: <TrE: <Def.: minderwertiger <HW m: Reis> der sich rot verfärbt, wenn er alt wird> (<Etym.: Abk. für <Ref.: <Transcr.: aka·gome> <Jap.: 赤米><DaID: 2339861>>>)>>. [C] <MGr: (<Descr.: als Präfix vor Nomen>) <TrE: vollkommen>; <TrE: vollständig>; <TrE: ganz>; <TrE: offensichtlich>; <TrE: klar>; <TrE: deutlich>>.'
    tree = grammar.parse(text)
    res = transformer.apply(tree)
    expect(res).to eq("(N.) [A] (als N.) [1] Rot (n); rote Farbe (f) (Def.: eine der drei Grundfarben; Farbe des Blutes bzw. Farbton von rosa, orange, rötlich-braun bis braun; rot kann weiter Goldfarbe symbolisieren). [2] rote Ampel (f) (⇔ 'ao / 青'). [3] (ugs.) Kommunist (m); Sozialist (m); Sozi (m); Roter (m). [B] (als Na.-Adj. mit no); vollkommen (nackt, fremd etc.). [5] rote Zahl (f); Minus (n) (Abk. für 'akaji / 赤字'). [6] Auzki-Bohne (f) (ursprüngl. in der Geheimsprache der Hofdamen). [7] Def.: eine rote Karte (f) bei den japanischen Spielkarten (Abk. für 'aka·tan / 赤短；赤丹'). [8] rotes Team (n); die Roten (mpl) (wenn es zwei Teams gibt, von denen das eine weiß und das andere rot ist). [9] Def.: minderwertiger Reis (m) der sich rot verfärbt, wenn er alt wird (Abk. für 'aka·gome / 赤米'). [C] (als Präfix vor Nomen); vollkommen; vollständig; ganz; offensichtlich; klar; deutlich.")

    text = '(<POS: N.>) <MGr: {<Dom.: Anat., Med.>} <TrE: <HW f: Diastase>>> (<Def.: Lücke zwischen Knochen od. Muskeln>；<Etym.: <impli.: aus d. Dtsch.><expli.: von engl. <For.: Diastase>>>).'
    tree = grammar.parse(text)
    res = transformer.apply(tree)

    text = '(<POS: N.>) <MGr: <TrE: <HW f: Identifikationsnummer>>> (<Etym.: von engl. <For.: <Emph.:id>entification> und japan. „<Transl.: Nummer>“；Abk.>).'
    tree = grammar.parse(text)
    res = transformer.apply(tree)

    text = '(<POS: N.>) {<Dom.: Persönlichk.>} [1]<MGr: <TrE: William George <FamN.: Armstrong>>> (<Def.: engl. Industrieller>；<BirthDeath: 1810–1900>). [2]<MGr: <TrE: Louis <FamN.: Armstrong>>> (<Def.: amerik. Trompeter und Sänger>；<BirthDeath: 1900–1971>).'
    tree = grammar.parse(text)
    res = transformer.apply(tree)

    text = '(<POS: N.>) [1]{<Dom.: Anat.>} <MGr: <TrE: <HW n: Knochengerüst>>; <TrE: <HW n: Gerippe>>; <TrE: <HW n: Skelett>>> // <MGr: <TrE: <HW m: Körperbau>>; <TrE: <HW m: Bau>>>. [2]<MGr: <TrE: <HW n: Gerüst>>; <TrE: <HW m: Aufbau>>; <TrE: <HW f: Struktur>>; <TrE: <HW m: Rahmen>>; <TrE: <HW mpl: Grundzüge>>>. (<Steinhaus: 27>).'
    tree = grammar.parse(text)
    res = transformer.apply(tree)

    text = '(<POS: N.>) <MGr: {<Dom.: Firmenn.>} <TrE: AT <SpecChar.: &> <HW NAr: T>>; <TrE: American Telephone and Telegraph <HW NAr: Company>>> (<Def.: amerik. Telefongesellschaft>；<Expl.: hervorgegangen aus der Bell Telephone Company>).'
    tree = grammar.parse(text)
    res = transformer.apply(tree)

    text = '<MGr: {<Dom.: Med.>} <TrE: <HW n: Dumping-Syndrom>>> (<Def.: Sturzentleerung von Nahrung vom Magen in den Dünndarm>；<WikiDE: Dumping-Syndrom>).'
    tree = grammar.parse(text)
    res = transformer.apply(tree)
  end
end
