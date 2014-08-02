require 'rake'
require 'csv'
require 'json'

begin
  namespace :update_db do

    

    task :delete_blank_tags => :environment do
      Bill.all.each do |bill|
        bill.tags.each do |tag|
          unless /[a-z,0-9]+/i.match(tag.text)
            puts "Found blank tag in #{bill.bill_id}"
            bill.tags.delete_if{|tag2| tag2.text == tag.text}
            bill.save
          else
            #puts "#{tag.text} is not blank."
          end
        end
      end
    end# of delete_blank_tags

    task :delete_bills => :environment do
      Bill.all.each do |bill|
        if bill.tags.index {|tag| tag.text=="delete"} then
          puts "Found a bill to delete: #{bill.bill_id}"
          #bill.delete # Commented just to be super safe about deleting anything.
        end
      end
    end# of :delete_bills
    
    task :update_legislators => :environment do
      puts "Updating legislators"
      #I'm gonna make it stop after 30 updates, so that I don't hit the servers too often.
      limit = 500
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
          sleep 4
          puts "And breathe out..."
          counter += 1
          if counter >= limit
            puts "Breaking because counter is above #{limit}"
            break
          end
        else
          puts leg_id + " is in the database."
        end# of the unless block
      end# of the .each block
	  puts "Done. There are now #{Bill.distinct("sponsors.leg_id").count - Legislator.count} legislators left to update."
    end# of task
  
    task :update_actions => :environment do
      counter = 0
      limit = 500 
      new_now = [] 
       
      Bill.all.each do |bill|
        if counter > limit then
          break
        end
        puts "Updating actions for #{bill.open_states_id}"
        new_actions = bill.update_actions
        #this will limit the number of updates, but still allow the rake to not just
        # check the same bills ever time.
        if new_actions.length > 0 then
          counter +=1
          bill.save
        end
        
        puts "Found #{new_actions.length} new actions."
        sleep 5
        new_actions = new_actions.map do |action|
          {action: action.action, actor: action.actor, date: action.date, type: action.type}
        end
        
        new_now << {bill_id: bill.bill_id, state: bill.state, new_actions: new_actions}
      end
      today = Date.today
      today = "#{today.month}-#{today.day}-#{today.year}"
      File.open("new_actions_#{today}", "w") do |f|
        new_now.each do |action|
          f.write(JSON.pretty_generate action)
        end
      end
      
    end# of task update_actions
    
    task :combine_tags => :environment do
      tags = {old_tag: "minimization", new_tag: "data minimization"}
      Bill.all.each do |bill|
        bill.tags.each do |tag| 
          if tag.text==tags[:old_tag] 
            puts "Replacing #{tag.text} with "
            #tag.text = tags[:new_tag]
            puts "  #{tag.text}"
          end
        end
      end
    end # of task replace_tags
    
  end# of namespace :update_db



end# of rakefile