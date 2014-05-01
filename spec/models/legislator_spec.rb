require 'spec_helper'

describe Legislator do
  specify "the class exists" do
    FactoryGirl.create(:legislator).class.should==Legislator   
  end

  describe "importing a Legislator from openStates" do
    describe "getting a legislators json string from openstates api"
    
    describe "creating a legislator from a json string" do
      before(:each) do
        file = File.open("spec/fixtures/legislator_example.json")
        json = JSON.parse(file.read)
        @legislator = Legislator.new
        @legislator.add_openstates_json(json)
        file.close
      end
      
      it "creates a new bill with embedded documents" do
        @legislator.class.should==Legislator
        @legislator.full_name.should=="Nate Steel"
        @legislator.sources.length.should==1
        @legislator.old_roles.length.should==13
        @legislator.old_roles[11].subcommittee.should=="ELECTIONS SUBCOMMITTEE"
        @legislator.roles.class.should==Array
      end
    end
  end# of describe importing from OpenStates

  describe "Legislator.present?" do
    before(:each) do
      @leg = FactoryGirl.create(:legislator)
    end
  
    it "returns true if a legislator's id is already in the database." do
      Legislator.present?(@leg.leg_id).should==true
    end
    
    it "return false if a legislator's id is not alraedy in the database." do
      Legislator.present?("EK00024").should==false
    end
  end# of Legislator.present?

end# of describe Legislator