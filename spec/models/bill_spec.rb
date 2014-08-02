require 'spec_helper'

describe Bill do
  specify 'the class exists' do
    bill = Bill.create
    bill.class==Bill
  end
    
  describe "importing a bill from OpenStates" do
    describe "#get_openstates_json"
    
    describe "#add_openstates_json" do
      before (:each) do
        file = File.open("spec/fixtures/a6541.json", "rb")
        @json = JSON.parse(file.read)
        @bill = Bill.new
        @bill.add_openstates_json(@json)
        file.close
      end
      
      it "reads the json from a file for the test." do
        @json.class.should==Hash
      end
      
      it "correctly imports the json into a document." do
        @bill.bill_id.should=="A 6541"
        @bill.companions.length.should==2
        @bill.companions[0]["bill_id"].should=="S 4839"
        @bill.sources[0]["url"].should=="http://assembly.state.ny.us/leg/?default_fld=&bn=A6541&Summary=Y&Actions=Y&term=2013"
        @bill.sponsors[0]["name"].should=="Englebright"
        @bill.actions[0]["type"].should==["committee:referred"]
      end
      
    end# of #add_a_openstates_json_bill
  end# of describe importing a bill from OpenStates
  
  describe "Bill#update_actions for ab2306 fixture" do
	before(:all) do
      ab2306_response = File.open("spec/fixtures/ab2306_response.json", "rb").read
      FakeWeb.register_uri(:get, /http:\/\/openstates.org\/api\/v1\/bills\/[a-z]+\/.*\/.*\/.*&fields=actions/, :body=> ab2306_response)
    end
    
    before(:each) do 
      @bill = FactoryGirl.create(:bill, {bill_id: "AB 2306", state: "ca", session: "20132014", open_states_id: "CAB00013384"})
    end
    
   
    it "saves any actions that have not yet been saved." do
      @bill.actions.length.should == 0
      new_actions = @bill.update_actions
      @bill.actions.length.should > 0
    end
    
    it "collects an array of actions that are new" do
      @bill.actions.length.should==0
      @bill.update_actions
      @bill.actions.pop(2)
      new_actions = @bill.update_actions
      new_actions.length.should==2
    end
    
    it "persists updates to the database" do
      @bill.update_actions
      @bill.save
      @bill2 = Bill.find_by_open_states_id("CAB00013384")
      @bill.actions.length.should==@bill2.actions.length
    end
    
  end# of describe update_actions for ab2306 fixture
  
  describe "Bill#update_actions for hb1904 fixture" do
    before(:all) do
      hb1904_response = File.open("spec/fixtures/hb1904_response.json", "rb").read
      FakeWeb.register_uri(:get, /http:\/\/openstates.org\/api\/v1\/bills\/[a-z]+\/.*\/.*\/.*&fields=actions/, :body=> hb1904_response)
    end
    
    before(:each) do 
      @bill = FactoryGirl.create(:bill)
    end
    
   
    it "saves any actions that have not yet been saved." do
      @bill.actions.length.should == 0
      @bill.update_actions
      @bill.actions.length.should > 0
    end

	
    it "returns an empty array if there were no new actions." do
      @bill.actions.length.should==0
      @bill.update_actions
      @bill.update_actions.length.should==0
      @bill.actions.length.should==3
    end
    
    it "returns an array of the new actions if new actions were found, and also saves new actions to the bill." do
      @bill.update_actions
      @bill.actions.length.should==3
      # take one action off, then check with the server to see if there are any new
      # actions. There should be one new action.
      @bill.actions.pop
      @bill.actions.length.should==2
      new_actions = @bill.update_actions
      new_actions.length.should==1
      @bill.actions.length.should==3
    end
    
  end# of Bill#update_actions
  
  describe "Tag.display" do
    it "returns an array of Tag documents as a string of just the text." do
      @tags = Array.new
      @tags[0] = Tag.new({text: "one tag"})
      @tags[1] = Tag.new({text: "second tag"})
      Tag.display(@tags).should=="one tag, second tag"
    end
  end# of Tag.display
  
  describe "Note.display" do
    it "returns an array of Note documents as just the text, separated by returns." do
      @notes = Array.new
      @notes[0] = Note.new({text: "an important thing."})
      @notes[1] = Note.new({text: "also this is important!"})
      note1 = @notes[0].text
      note2 = @notes[1].text
      seperator = "\r\n"
      note1.class.should==String
      note2.class.should==String
      seperator.class.should==String
      result_string = note1 + seperator + note2
      result_string.class.should==String
      Note.display(@notes).should==result_string
    end
  end# of Note.display
  

end