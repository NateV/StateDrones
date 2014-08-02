require 'rubygems'
require 'mongo_mapper'
require 'net/http'

class Bill
  include MongoMapper::Document
  
  many :actions  
  many :votes
  many :documents
  many :companions
  many :sponsors
  many :tags
  many :notes
  
  key :sources, Array
  key :session, String
  key :open_states_id, String
  key :title, String
  key :state, String
  key :chamber, String
  key :summary, String
  key :bill_id, String
  
  ##Methods to import a bill from OpenStates.org
  def add_openstates_json (bill_json)
    if bill_json.class==String then
      bill_json = JSON.parse(bill_json)
    end
    self.bill_id = bill_json["bill_id"]
    self.summary = bill_json["summary"]
    self.chamber = bill_json["chamber"]
    self.state = bill_json["state"]
    self.title = bill_json["title"]
    self.open_states_id = bill_json["id"]
    self.session = bill_json["session"]
    self.sources = bill_json["sources"]
    
    self.sponsors = bill_json["sponsors"].map do |sponsor|
      Sponsor.new(:leg_id => sponsor["leg_id"],
      			  :official_type => sponsor["official_type"],
      			  :type => sponsor["type"],
      			  :name => sponsor["name"])
    end
    
    self.companions = bill_json["companions"].map do |companion|
      Companion.new(:chamber => companion["chamber"], 
      				:session => companion["session"],
      				:bill_id => companion["bill_id"],
      				:internal_id => companion["internal_id"])
    end
    
    self.documents = bill_json["documents"].map do |document|
      Document.new(:url => document["url"],
      			   :doc_id => document["doc_id"],
      			   :name => document["name"])      
    end
    
    self.actions = bill_json["actions"].map do |action|
      Action.new(:date => action["date"],
      			 :action => action["action"],
      			 :type => action["type"],
      			 :actor => action["actor"])
    end
    #self.votes
    
  end# of add_openstates_json

  def update_actions
    bill_id_for_uri = bill_id.gsub(" ","%20")
    session_for_uri = session.gsub(" ","%20")
    actions_uri = URI("http://openstates.org/api/v1/bills/#{state}/#{session_for_uri}/#{bill_id_for_uri}/?apikey=#{ENV['OPENSTATES_API']}&fields=actions")
    actions_response =  JSON.parse(Net::HTTP.get(actions_uri))
    actions_response = actions_response["actions"]
    #actions_response is a json object. I need to check each element in 
    # action_response. Turn that object into an Action, 
    # and then if that action is in self.actions, then I don't keep that action.
    # if that action is not in self.actions, I save the action and keep the action
    # in an array of new actions to be returned from the function.
    new_actions = actions_response.map do |action|
      action = Action.new(:date => action["date"],
      			 :action => action["action"],
      			 :type => action["type"],
      			 :actor => action["actor"])
      response = nil
      if action.is_new?(self.actions) then
    	response = action
      end
      response
    end
    new_actions.compact!

    new_actions.each do |new_action|
      self.actions << new_action
    end
  
    new_actions
  end# of update_actions
end# of Bill

class Action
  include MongoMapper::EmbeddedDocument
  
  key :date, String
  key :action, String
  key :type, Array
  key :actor, String
  
  def is_new?(old_actions)
    response = true
    old_actions.each do |old_action|
      if ((self.date==old_action.date) && (self.action==old_action.action) && (self.type==old_action.type) && (self.actor==old_action.actor))
        response = false
      end
    end
    response
  end# of is_new?

end

class Vote
  include MongoMapper::EmbeddedDocument
   
end

class Companion
  include MongoMapper::EmbeddedDocument
  
  key :chamber, String
  key :session, String
  key :bill_id, String
  key :internal_id, String
end

class Document
  include MongoMapper::EmbeddedDocument
  
  key :url, String
  key :doc_id, String
  key :name, String
end

class Sponsor
  include MongoMapper::EmbeddedDocument
  
  key :leg_id, String
  key :official_type, String
  key :type, String
  key :name, String
end

class Tag
  include MongoMapper::EmbeddedDocument
  key :text, String
  
  def self.display(tags)
    response_string = ""
      tags.each_with_index do |tag, i|
        if i<(tags.length-1) then
          response_string += tag["text"] + ", "
        else
          response_string += tag["text"]
        end
      end
    response_string
  end# of Tag.display
end# of class Tag

 class Note
   include MongoMapper::EmbeddedDocument
   key :text, String
   
   def self.display(notes)
     response_string = ""
     notes.each_with_index do |note, i|
       if(i<notes.length-1) then
         response_string += note["text"] + "\r\n"
       else
         response_string += note["text"]
       end
     end
     response_string
   end# of Note.display
 end# of class Note
 
 
 
 
 
 
 
 
 