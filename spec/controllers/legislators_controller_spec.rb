require 'spec_helper'

describe LegislatorsController do

  describe "GET#index" do
    before(:each) do
      FactoryGirl.create(:legislator)
      get :index
    end
    
    it "renders the index template." do 
      response.should render_template 'index'
    end
    
    it "gets a list of all the legislators" do
      assigns[:legislators].length.should==1
    end
  end# of get#index
  
  describe "GET#show/:id"
  
  describe "legislator_lookup" do 
  # Commented to avoid hitting the OpenStates servers unnecessarily. 
    # it "returns a Legislator from a leg_id" do
#       controller = LegislatorsController.new
#       leg = controller.legislator_lookup("ARL000109")
#       leg.class.should==Legislator
#     end
  
  end# of legislator_lookup



end