require 'spec_helper'

describe BillsController do

  describe "GET #index" do
    before(:each) do
      @bill = FactoryGirl.create(:bill)
      get :index
    end
    it "returns a list of all bills." do
      assigns[:all_bills].class.should==Array
    end    
  end

  describe "GET #show/:id" do 
    before(:each) do
      @bill = FactoryGirl.create(:bill)
      get :show, {id: @bill._id}
    end
    
    it 'gets the desired bill.' do
      assigns[:bill]._id.should==@bill._id
    end
    
    it 'renders the show template' do
      response.should render_template :show
    end
  
    it 'gets the bills tags' do
      assigns[:new_tags].should_not be_nil
    end
  
  end# of describe get show/id
  
  describe "POST #show/update_tags" do
    before(:each) do
      @bill = FactoryGirl.create(:bill)
      new_tags = 'surveillance'  
      post :update_tags, {id: @bill._id, new_tags: new_tags}
    end
    
    it "saves a set of tags to a document." do
      Bill.find_by_id(@bill._id).tags[0].text.should=='surveillance'
    end
  end# of post#show/update_tags
  
  describe "POST #show/update_notes" do
    before(:each) do
      @bill = FactoryGirl.create(:bill)
      @notes = "A note \n and another note"
      post :update_notes, {id: @bill._id, notes: @notes} 
    end
    
    it "adds notes to a bill." do
      
    end
  end# of post#update_notes
  
  describe "GET #show/previous" do
    before(:each) do
      @first_bill = FactoryGirl.create(:bill)
      @second_bill = FactoryGirl.create(:bill, bill_id: "A0005")
      get :show, {id: @first_bill._id}
      get :previous_bill, {id: @first_bill.id}
    end
  
    it "redirects to the the previous bill." do
      assigns[:prev_bill]._id.should==@second_bill._id
    end
  
  end# of show/previous
  
  describe "GET #show/next" do
    before(:each) do
      @first_bill = FactoryGirl.create(:bill)
      @second_bill = FactoryGirl.create(:bill, bill_id: "A0005")
      get :show, {id: @first_bill._id}
      get :next_bill, {id: @first_bill.id}
    end
    
    it "finds the next bill." do 
      assigns[:next_bill]._id.should==@second_bill._id
    end
  end# of show/next
  
  describe "creating a new bill" do
    describe "GET #new" do
      before (:each) do
        get :new
      end
      
      it "creates an empty Bill object." do
        assigns[:new_bill].class.should==Bill
      end
      
      it "creates an empty Link object to hold a link to a Openstates bill." do
        #assigns[:openstates_link].class.should==String
      end
    end# of get#NEW
  
    describe "POST #new" do
      describe "post#new, if the OpenStatesLink button was pressed."
      describe "post#new, if the main form submit button was pressed." 
    end# of describe POST#new
  end# of describe "creating a new bill"
    
  describe "editing a bill." do 
    describe "GET #edit"
    
    describe "POST #edit"
  end
  
  describe "adding bills by using openstates info in bulk." do
    describe "GET #get_bulk" do
      it "renders the bulk view" do
        get :get_bulk
        response.should render_template 'get_bulk'
      end
      it "creates an empty array" do
        get :get_bulk
        assigns[:links].class.should==Array
      end
    end# of describe get#get_bulk
    
    describe "POST #post_bulk" do
      it "turns the submitted links into an array" do
        post :post_bulk, {links: 'www.google.com
www.yahoo.com'}
        assigns[:links].class.should==Array
        assigns[:links].length.should==2
      end
#  Commented so that every time I run the tests, I don't hit openstates.org.       
# 		it "posts a new bill to the database if the link format is correct." do
#          post :post_bulk, {links: 'http://openstates.org/al/bills/2014rs/SB240/'} 
#          assigns[:bill].class.should==Bill
#        end
    end# of describe post#post_bulk
  end# of bulk updating. 
end# of tests.

