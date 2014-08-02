require 'spec_helper'

describe TagsController do

  describe "#index" do
    it "renders all the tags." do 
      get :index
      response.should render_template 'index'  
    end
    
  end# of #index

end# of spec 