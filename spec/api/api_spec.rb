# encoding:utf-8
require 'spec_helper'

describe Entry do
  it 'should be versioned' do
    new_entry = Entry.create(:writing => "Something")
    new_entry.versions.count.should == 0
    new_entry.writing = "Something else"
    DataMapper.finalize # Workaround for some DataMapper bug.
    new_entry.save
    new_entry.versions.count.should == 1
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
    it 'should have a picture property iff one is present in the entry' do
      hash = JsonEntry.new(Entry.get(13)).to_hash
      hash[:picture].should_not be_nil
      hash = JsonEntry.new(Entry.get(1)).to_hash
      hash[:picture].should be_nil
    end

    it 'should add a subentry midashigo if appropriate' do
      hash = JsonEntry.new(Entry.get(7)).to_hash
      hash[:subentry_midashigo].should eq "~男"
    end

    it 'should have an audio property iff one is present in the entry' do
      hash = JsonEntry.new(Entry.get(4)).to_hash
      hash[:audio].should_not be_nil
      hash = JsonEntry.new(Entry.get(3)).to_hash
      hash[:audio].should be_nil
    end

    it 'should contain a field with subentries' do
      hash = JsonEntry.new(Entry.get(22)).to_hash
      hash[:sub_entries].should_not be_empty

      hash = JsonEntry.new(Entry.get(1)).to_hash
      hash[:sub_entries].should be_empty
    end

    it 'should have an option to enable full subentries' do
      hash = JsonEntry.new(Entry.get(8772)).to_hash
      hash[:sub_entries].first[:entries].first[:wadoku_id].should_not be_nil
      hash[:sub_entries].first[:entries].first[:midashigo].should be_nil

      hash = JsonEntry.new(Entry.get(8772)).to_hash({'full_subentries' => true})
      hash[:sub_entries].first[:entries].first[:midashigo].should_not be_nil
    end

    it 'should group subentries' do
      hash = JsonEntry.new(Entry.get(8772)).to_hash
      hash[:sub_entries].size.should be 3
    end
  end

  describe "API v1" do

    describe "authentication" do

      let!(:client) { User.create(:client_id => "SOME_CLIENT_ID", :client_secret => "SOME_CLIENT_SECRET") }
      let!(:params) { {random_params: "Something Something"} }
      let!(:signed_params) { sign_request params, client }
      let!(:invalid_params) { i = signed_params.dup; i[:signature] = 'INVALID'; i}

      it 'should return 403 if authentication fails' do
        get '/api/v1/check_authentication', params
        last_response.status.should == 403

        get '/api/v1/check_authentication', invalid_params
        last_response.status.should == 403
      end

      it 'should return normally with a valid authentication' do
        get '/api/v1/check_authentication', signed_params
        last_response.status.should == 200
      end
    end

    describe "exact searches" do
      it 'should do forward searches' do
        get "/api/v1/search", {query: 'ああ', mode: 'forward'}
        last_json["total"].should be 13
      end

      it 'should do backward searches' do
        get "/api/v1/search", {query: 'と', mode: 'backward'}
        last_json["total"].should be 33
      end
    end

    describe "suggestions" do
      it 'should return suggestions for partial keywords' do
        get "/api/v1/suggestions", {query: 'ああ'}
        last_json["suggestions"].count.should be 12
      end
    end

    describe "direct Picky" do
      it 'should answer direct picky queries' do
        get "/api/v1/picky?query=japan"
        last_json["total"].should_not be_nil
      end
    end

    describe "parsing" do
      it 'should return a JSON object for valid markup' do
        entry = Entry.get 5372
        get '/api/v1/parse', {markup: entry.definition}
        last_json['error'].should be_nil
      end

      it 'should return an error for invalid markup' do
        markup = '''
          <<<>ALL WRONG
        '''
        get '/api/v1/parse', {markup: markup}
        last_json['error'].should_not be_nil
      end
    end

    describe "searches" do
      it 'should give a total amount of results' do
        get '/api/v1/search?query=japan'
        last_json["total"].should == 3
      end

      it 'should return 30 entries by default' do
        get '/api/v1/search', {query: 'あ'}
        last_json["entries"].count.should <= 30 # 29 because one entry doesn't parse
      end

      it 'should return the amount of entries given in the limit option' do
        get '/api/v1/search?query=japan&limit=15'
        (last_json['entries'].count <= 15).should be_true

        get '/api/v1/search?query=japan&limit=60'
        (last_json['entries'].count <= 60).should be_true # 57 because some entries dont parse.
      end

      it 'should not contain errored entries' do
        get '/api/v1/search?query=japan'
        last_json["entries"].each {|entry| entry["error"].should be_nil}
      end

      it 'should return different definition fields depending on the format' do
        # HTML is the default
        get '/api/v1/search?query=japan'
        last_json["entries"].first["definition"].should include('span class=')

        get '/api/v1/search?query=japan&format=plain'
        last_json["entries"].first["definition"].should_not include('span class=')

        get '/api/v1/search?query=japan&format=html'
        last_json["entries"].first["definition"].should include('span class=')
      end

      it 'should wrap the entries with a callback when given the parameter' do
        get '/api/v1/search?query=japan&callback=rspec'
        last_response.body.to_s.should start_with('rspec(')
      end

      it 'should return full subentries when they are requested' do
        get '/api/v1/search?query=aoi'
        #last_json["entries"][1]["sub_entries"][0]["entries"][0]["midashigo"].should be_nil
        #last_json["entries"][1]["sub_entries"][0]["entries"][0]["wadoku_id"].should_not be_nil
        last_json["entries"].each do |entry|
          entry["sub_entries"] ||= []
          entry["sub_entries"].each do |relation|
            relation['entries'].each do |sub_entry|
              sub_entry["midashigo"].should be_nil
              sub_entry["wadoku_id"].should_not be_nil
            end
          end
        end

        get '/api/v1/search?query=aoi&full_subentries=true'
        #last_json["entries"][1]["sub_entries"][0]["entries"][0]["midashigo"].should_not be_nil
        last_json["entries"].each do |entry|
          entry["sub_entries"] ||= []
          entry["sub_entries"].each do |relation|
            relation['entries'].each do |sub_entry|
              sub_entry["midashigo"].should_not be_nil
              sub_entry["wadoku_id"].should_not be_nil
            end
          end
        end
      end

    end

    describe "entries" do

      context 'creation' do

        let!(:client) { User.create(:client_id => "SOME_CLIENT_ID", :client_secret => "SOME_CLIENT_SECRET") }
        let!(:invalid_client) { User.new() }
        let!(:params) do
          {
            writing: '賢者タイム',
            kana: 'けんじゃたいむ',
            pos: '名',
            definition: '(<POS: N.>) <MGr: <Def.: Something something>>.'
          }
        end
        let!(:signed_params) { sign_request params, client}

        it 'should require authentications' do
          expect(Entry.first(writing: '賢者タイム')).to be_nil

          post '/api/v1/entry', params

          expect(last_response.status).to be 403
          expect(last_json['error']).to eql "Could not authenticate!"
          expect(Entry.first(writing: '賢者タイム')).to be_nil
        end

        it 'should return the created entry' do
          expect(Entry.first(writing: '賢者タイム')).to be_nil

          post '/api/v1/entry', signed_params

          expect(last_json['entry']).to be
          expect(Entry.first(writing: '賢者タイム')).to be
        end
      end

      it 'should return a representation of an entry when given a valid wadoku id' do
        get '/api/v1/entry/0946913'
        last_json["writing"].should eq "アナクロニズム"
      end

      it 'should return an error for an invalid wadoku id' do
        get '/api/v1/entry/invalid'
        last_json["error"].should_not be_nil
      end

      it 'should return different definition fields depending on the format' do
        # HTML is the default
        get '/api/v1/entry/6843503'
        last_json["definition"].should include('span class=')

        get '/api/v1/entry/6843503?format=plain'
        last_json["definition"].should_not include('span class=')

        get '/api/v1/entry/6843503?format=html'
        last_json["definition"].should include('span class=')
      end

      it 'should wrap the entries with a callback when given the parameter' do
        get '/api/v1/entry/6843503?callback=rspec'
        last_response.body.to_s.should start_with('rspec(')
      end
    end
  end

end
