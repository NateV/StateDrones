require 'rubygems'
require 'mongo_mapper'

class Legislator
  include MongoMapper::Document
  
  key :last_name, String
  key :updated_at, String
  key :full_name, String
  key :openstates_id, String
  key :first_name, String
  key :middle_name, String
  key :district, String
  key :chamber, String
  key :state, String
  key :votesmart_id, String
  key :party, String
  key :email, String
  key :leg_id, String
  key :active, String
  key :transparencydata_id, String
  key :photo_url, String
  key :level, String
  key :url, String
  key :country, String
  key :created_at, String
  key :occupation, String
  key :suffixes, String
  key :all_ids, Array
  
  
  many :roles
  many :old_roles
  many :sources
  many :offices
  
  timestamps!
  
  def add_openstates_json(leg_hash)
    self.last_name = leg_hash["last_name"]
    self.updated_at = leg_hash["updated_at"]
    self.full_name = leg_hash["full_name"]
    self.openstates_id = leg_hash["id"]
    self.first_name = leg_hash["first_name"]
    self.middle_name = leg_hash["middle_name"]
    self.district = leg_hash["district"]
    self.chamber = leg_hash["chamber"]
    self.state = leg_hash["state"]
    self.votesmart_id = leg_hash["votesmart_id"]
    self.party = leg_hash["party"]
    self.email = leg_hash["email"]
    self.leg_id = leg_hash["leg_id"]
    self.active = leg_hash["active"]
    self.transparencydata_id = leg_hash["transparencydata_id"]
    self.photo_url = leg_hash["photo_url"]
    self.level = leg_hash["level"]
    self.url = leg_hash["url"]
    self.country = leg_hash["country"]
    self.created_at = leg_hash["created_at"]
    self.occupation = leg_hash["occupation"]
    self.suffixes = leg_hash["suffixes"]
    self.all_ids = leg_hash["all_ids"]
    
    self.roles = leg_hash["roles"].map do |role|
       Role.new(
        :term => role["term"],
        :end_date => role["end_date"],
        :district => role["district"],
        :chamber => role["chamber"],
        :state => role["state"],
        :party => role["party"],
        :type => role["type"],
        :start_date => role["start_date"],
        :committee=>role["committee"],
        :subcommittee => role["subcommittee"],
        :position => role["subcommittee"]
       )
    end
      
    self.old_roles = []
    leg_hash["old_roles"].each do |session, roles|
	  roles.each do |role|
	    self.old_roles << OldRole.new(
		  :term => role["term"],
		  :end_date => role["end_date"],
		  :district => role["district"],
		  :chamber => role["chamber"],
		  :state => role["state"],
		  :party => role["party"],
		  :type => role["type"],
		  :start_date => role["start_date"],
		  :committee=>role["committee"],
		  :subcommittee => role["subcommittee"],
		  :position => role["subcommittee"]
	    )
	  end
    end

    self.sources = leg_hash["sources"].map do |source|
      Source.new(:url => source["url"])
    end
      
    self.offices = leg_hash["offices"].map do |office|
      Office.new(
          :fax => office["fax"],
          :name => office["name"],
          :phone => office["phone"],
          :address => office["address"],
          :type => office["type"],
          :email => office["email"]
      )
    end
  end# of Legislator#add_openstates_json
  
end# of class Legislator

class Role
  include MongoMapper::EmbeddedDocument 
  
  key :term, String
  key :end_date, String
  key :district, String
  key :chamber, String
  key :state, String
  key :party, String
  key :type, String
  key :start_date, String
  key :committee, String
  key :subcommittee, String
  key :position, String
end# of class Role

class OldRole
  include MongoMapper::EmbeddedDocument
  
  key :session, String
  many :old_session_roles
  
end#

class OldSessionRole < Role

end

class Source
  include MongoMapper::EmbeddedDocument

  key :url, String
end# of class Source

class Office
  include MongoMapper::EmbeddedDocument

  key :fax, String
  key :name, String
  key :phone, String
  key :address, String
  key :type, String
  key :email, String
end# of class Office