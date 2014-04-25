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