# encoding:utf-8
require 'spec_helper'

describe Entry do
  it 'is versioned' do
    new_entry = Entry.create(:writing => "Something")
    expect(new_entry.versions.count).to eq(0)
    new_entry.writing = "Something else"
    DataMapper.finalize # Workaround for some DataMapper bug.
    new_entry.save
    expect(new_entry.versions.count).to eq(1)
    new_entry.destroy
  end
end

describe WadokuSearchAPI do

  def app
    @app ||= WadokuSearchAPI
  end

  def last_json
    Yajl::Parser.parse(last_response.body)
  end

  describe JsonEntry do
    it 'has a picture property iff one is present in the entry' do
      hash = JsonEntry.new(Entry.get(13)).to_hash
      expect(hash[:picture]).not_to be_nil
      hash = JsonEntry.new(Entry.get(1)).to_hash
      expect(hash[:picture]).to be_nil
    end

    it 'adds a subentry midashigo if appropriate' do
      hash = JsonEntry.new(Entry.get(7)).to_hash
      expect(hash[:subentry_midashigo]).to eq "~男"
    end

    it 'has an audio property iff one is present in the entry' do
      hash = JsonEntry.new(Entry.get(4)).to_hash
      expect(hash[:audio]).not_to be_nil
      hash = JsonEntry.new(Entry.get(3)).to_hash
      expect(hash[:audio]).to be_nil
    end

    it 'contains a field with subentries' do
      hash = JsonEntry.new(Entry.get(22)).to_hash
      expect(hash[:sub_entries]).not_to be_empty

      hash = JsonEntry.new(Entry.get(1)).to_hash
      expect(hash[:sub_entries]).to be_empty
    end

    it 'has an option to enable full subentries' do
      hash = JsonEntry.new(Entry.get(8772)).to_hash
      expect(hash[:sub_entries].first[:entries].first[:wadoku_id]).not_to be_nil
      expect(hash[:sub_entries].first[:entries].first[:midashigo]).to be_nil

      hash = JsonEntry.new(Entry.get(8772)).to_hash({'full_subentries' => true})
      expect(hash[:sub_entries].first[:entries].first[:midashigo]).not_to be_nil
    end

    it 'groups subentries' do
      hash = JsonEntry.new(Entry.get(8772)).to_hash
      expect(hash[:sub_entries].size).to be 3
    end
  end

  describe "API v1" do

    describe "authentication" do

      let!(:client) { User.create(:client_id => "SOME_CLIENT_ID", :client_secret => "SOME_CLIENT_SECRET") }
      let!(:params) { {random_params: "Something Something"} }
      let!(:signed_params) { sign_request params, client }
      let!(:invalid_params) { i = signed_params.dup; i[:signature] = 'INVALID'; i}

      it 'returns 403 if authentication fails' do
        get '/api/v1/check_authentication', params
        expect(last_response.status).to eq(403)

        get '/api/v1/check_authentication', invalid_params
        expect(last_response.status).to eq(403)
      end

      it 'returns normally with a valid authentication' do
        get '/api/v1/check_authentication', signed_params
        expect(last_response.status).to eq(200)
      end
    end

    describe "exact searches" do
      it 'does forward searches' do
        get "/api/v1/search", {query: 'ああ', mode: 'forward'}
        expect(last_json["total"]).to be 13
      end

      it 'does backward searches' do
        get "/api/v1/search", {query: 'と', mode: 'backward'}
        expect(last_json["total"]).to be 33
      end
    end

    describe "suggestions" do
      it 'returns suggestions for partial keywords' do
        get "/api/v1/suggestions", {query: 'ああ'}
        expect(last_json["suggestions"].count).to be 12
      end
    end

    describe "direct Picky" do
      it 'answers direct picky queries' do
        get "/api/v1/picky?query=japan"
        expect(last_json["total"]).not_to be_nil
      end
    end

    describe "parsing" do
      it 'returns a JSON object for valid markup' do
        entry = Entry.get 5372
        get '/api/v1/parse', {markup: entry.definition}
        expect(last_json['error']).to be_nil
      end

      it 'returns an error for invalid markup' do
        markup = '''
          <<<>ALL WRONG
        '''
        get '/api/v1/parse', {markup: markup}
        expect(last_json['error']).not_to be_nil
      end
    end

    describe "searches" do
      it 'gives a total amount of results' do
        get '/api/v1/search?query=japan'
        expect(last_json['total'].is_a?(Integer)).to eq(true)
      end

      it 'returns 30 entries by default' do
        get '/api/v1/search', {query: 'あ'}
        expect(last_json["entries"].count).to be <= 30 # 29 because one entry doesn't parse
      end

      it 'returns the amount of entries given in the limit option' do
        get '/api/v1/search?query=japan&limit=15'
        expect(last_json['entries'].count <= 15).to eq(true)

        get '/api/v1/search?query=japan&limit=60'
        expect(last_json['entries'].count <= 60).to eq(true) # 57 because some entries dont parse.
      end

      it 'does not contain errored entries' do
        get '/api/v1/search?query=japan'
        last_json["entries"].each {|entry| expect(entry["error"]).to be_nil}
      end

      it 'returns different definition fields depending on the format' do
        # HTML is the default
        get '/api/v1/search?query=japan'
        expect(last_json["entries"].first["definition"]).to include('span class=')

        get '/api/v1/search?query=japan&format=plain'
        expect(last_json["entries"].first["definition"]).not_to include('span class=')

        get '/api/v1/search?query=japan&format=html'
        expect(last_json["entries"].first["definition"]).to include('span class=')
      end

      it 'wraps the entries with a callback when given the parameter' do
        get '/api/v1/search?query=japan&callback=rspec'
        expect(last_response.body.to_s).to start_with('rspec(')
      end

      it 'returns full subentries when they are requested' do
        get '/api/v1/search?query=aoi'
        #last_json["entries"][1]["sub_entries"][0]["entries"][0]["midashigo"].should be_nil
        #last_json["entries"][1]["sub_entries"][0]["entries"][0]["wadoku_id"].should_not be_nil
        last_json["entries"].each do |entry|
          entry["sub_entries"] ||= []
          entry["sub_entries"].each do |relation|
            relation['entries'].each do |sub_entry|
              expect(sub_entry["midashigo"]).to be_nil
              expect(sub_entry["wadoku_id"]).not_to be_nil
            end
          end
        end

        get '/api/v1/search?query=aoi&full_subentries=true'
        #last_json["entries"][1]["sub_entries"][0]["entries"][0]["midashigo"].should_not be_nil
        last_json["entries"].each do |entry|
          entry["sub_entries"] ||= []
          entry["sub_entries"].each do |relation|
            relation['entries'].each do |sub_entry|
              expect(sub_entry["midashigo"]).not_to be_nil
              expect(sub_entry["wadoku_id"]).not_to be_nil
            end
          end
        end
      end

    end

    describe "entries" do

      context 'creation' do

        let!(:client) { User.create(:client_id => "SOME_CLIENT_ID", :client_secret => "SOME_CLIENT_SECRET") }
        let(:params) do
          {
            writing: '賢者タイム',
            kana: 'けんじゃたいむ',
            pos: '名',
            definition: '(<POS: N.>) <MGr: <Def.: Something something>>.'
          }
        end
        let(:signed_params) { sign_request params, client}
        let(:malformed_entry_params) { h = params.dup; h[:definition] = '>>><<<>>>INVALID'; sign_request h, client}

        it 'requires authentications' do
          expect(Entry.first(writing: '賢者タイム')).to be_nil

          post '/api/v1/entry', params

          expect(last_response.status).to be 403
          expect(last_json['error']).to eql "Could not authenticate!"
          expect(Entry.first(writing: '賢者タイム')).to be_nil
        end

        it 'returns the created entry' do
          expect(Entry.first(writing: '賢者タイム')).to be_nil

          post '/api/v1/entry', signed_params

          expect(last_json['entry']).to be
          expect(Entry.first(writing: '賢者タイム')).to be
        end

        it 'rejects malformed entries' do
          expect(Entry.first(writing: '賢者タイム')).to be_nil

          post '/api/v1/entry', malformed_entry_params

          expect(last_response.status).to be 400
          expect(last_json['error']).to eql 'Could not parse entry, rejecting.'
          expect(Entry.first(writing: '賢者タイム')).to be_nil
        end
      end

      it 'returns a representation of an entry when given a valid wadoku id' do
        get '/api/v1/entry/0946913'
        expect(last_json["writing"]).to eq "アナクロニズム"
      end

      it 'returns an error for an invalid wadoku id' do
        get '/api/v1/entry/invalid'
        expect(last_json["error"]).not_to be_nil
      end

      it 'returns different definition fields depending on the format' do
        # HTML is the default
        get '/api/v1/entry/6843503'
        expect(last_json["definition"]).to include('span class=')

        get '/api/v1/entry/6843503?format=plain'
        expect(last_json["definition"]).not_to include('span class=')

        get '/api/v1/entry/6843503?format=html'
        expect(last_json["definition"]).to include('span class=')
      end

      it 'wraps the entries with a callback when given the parameter' do
        get '/api/v1/entry/6843503?callback=rspec'
        expect(last_response.body.to_s).to start_with('rspec(')
      end
    end
  end

end
