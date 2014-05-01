require 'rake'


begin
  namespace :update_db do

    task :update_legislators => :environment do
      puts "Updating legislators"
      #I'm gonna make it stop after 30 updates, so that I don't hit the servers too often.
      limit = 1
      counter = 1

      #Need a LegislatorsController to lookup the legislators.
      controller = LegislatorsController.new

      Bill.distinct("sponsors.leg_id").each do |leg_id|
        #unless the legislator is already in the database,
        unless Legislator.present?(leg_id) 
          puts leg_id + " is not in the database. Downloading..."

          # download the openstates json for the legislator and save it as a new document.
          controller.legislator_lookup(leg_id)
          puts "Added #{Legislator.find_by_leg_id(leg_id).full_name} to the database."
          
          # pause to be be nice to the server
          puts "And breathe in..."
          sleep 10
          puts "And breathe out..."
          counter += 1
          if counter >= limit
            puts "Breaking because counter is above 30"
            break
          end
        else
          puts leg_id + " is in the database."
        end# of the unless block
      end# of the .each block
	  puts "Done. There are now #{Bill.distinct("sponsors.leg_id").count} legislators left to update."
    end# of task
  
  end# of namespace :update_db

end# of rakefile