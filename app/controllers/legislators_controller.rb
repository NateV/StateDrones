require 'net/http'

class LegislatorsController < ApplicationController

  def index
    @legislators = Legislator.all
  end

  
  def legislator_lookup (leg_id)
    uri = URI("http://openstates.org/api/v1/legislators/" + leg_id + 
      				"/?apikey=" + ENV['OPENSTATES_API'])
    response = Net::HTTP.get(uri) 
    legislator = Legislator.new
    legislator.add_openstates_json(response)
    legislator.save
  end# of #legislator_lookup

end# of class    