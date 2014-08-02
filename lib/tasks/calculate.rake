require 'rake'
require 'csv'
require 'Network' # this is the gem I made!!

begin
  def partisanship(bill)
    parties = bill.sponsors.map do |sponsor|
      if sponsor.leg_id
        Legislator.find_by_leg_id(sponsor.leg_id).party
      else 
        sponsor.name
      end
    end
    unique_parties = parties.uniq
    results = unique_parties.map do |party|
      {"#{party}"=>parties.count(party)}
    end
  end# of partisanship(bill)
  
  def state_link(bill)
	#find the index of the first url that is not openstates.
    index = bill.sources.index {|source| /openstates/.match(source["url"]) == nil}
    response = ""
    if index==nil then 
      response = bill.sources[0]["url"]
    else
      response = bill.sources[index]["url"]
    end
    response
  end# of state_link(bill)
  
  def status(bill)
    {action: bill.actions.last.action, date: bill.actions.last.date, actor: bill.actions.last.actor}
  end# of status(bill)
  
  def ignore_tag? (tag)
    ignore_list = ["adopted", "vetoed", "empty", "vetoed", "passed one chamber"]
    if ignore_list.include? tag
      return true
    else
      return false
    end
  end# of ignore_tag?
  
  namespace :calculate do
    task :calculate_sponsor_portions => :environment do
      filters = ["promoting industry"]
      counter = 0
      csvRows = Array.new
      Bill.all.each do |bill|
        # if the tags array has any elements in common with the filters I'm interested in,
        #   OR there are no filters and I want everything.
        if (((bill.tags.map {|tag| tag.text}) & filters).length > 0) || (filters.length==0) then 
          counter +=1
          puts "#{bill.bill_id} has at least one of these tags: #{filters}"
          bill.sponsors.each do |sponsor|
            puts "#{sponsor.name}, #{sponsor.leg_id}"
            if sponsor.leg_id then
              party = Legislator.find_by_leg_id(sponsor.leg_id)["party"]
            else 
              party = sponsor.name
            end
            csvRows << {bill_id: bill.bill_id, state: bill.state, leg_id: sponsor.leg_id, party: party}
          end# breaking up the sponsors of each bill
        else
          puts "#{bill.bill_id} does not have any of these tags: #{filters}"
        end# of if/then/end
      end# of processing each bill
      CSV.open("sponsor_portions.csv","w") do |csv|
        csv << csvRows[0].keys
        csvRows.each do |row|
          csv << CSV::Row.new(row.keys, row.values)
        end
      end
      puts "Completed. Found #{counter} bills with the selected tags: #{filters.to_s}"
    end# of task calculate_sponsor_portions
    
    task :generate_appendix => :environment do 
      today = Date.today
      today = "#{today.month}-#{today.day}-#{today.year}"
      CSV.open("AppendixChart-#{today}.csv","w") do |csv|
        keys = ["Bill","State", "Session", "Tags","Partisanship","Link","Status_as_of-#{today}"]
        csv << keys
        Bill.all.each do |bill|
          #row needs to be an array matching the keys array:
          # ["Bill","State","Tags","Partisanship","Link","Status_as_of-#{today}"]
          row = [bill.bill_id, bill.state.upcase, bill.session, Tag.display(bill.tags), partisanship(bill), state_link(bill), status(bill)]
          csv << CSV::Row.new(keys,row)
        end
      end# of csv.open
    end# of task generate_appendix
    
    task :generate_graph_of_bills_with_tags => :environment do
      #model nodes: {name: "#{bill.state}-#{bill.bill_id}-#{bill.session}", type: "bill", state: bill.state, session: bill.session}
      #             {name: "#{tag}", type: "tag"}
      
      @network = Network.new
      Bill.all.each do |bill|
        puts "Processing #{bill.bill_id}"
        #add a node for the bill
        begin
          adopted = false
          bill.tags.each do |tag| 
            if tag.text=="adopted"
              adopted = true
            end
          end
          @network.add_node({name: "#{bill.state}-#{bill.bill_id}-#{bill.session}", type: "bill", state: bill.state, session: bill.session, adopted: adopted})
        rescue StandardError
          puts "Found a duplicate node. Ignoring." 
        end
        #add a node for each tag (the network won't repeat nodes, so don't need to worry about that.)
        #  and an edge between the bill and the tag.
        bill.tags.each do |tag|
          unless ignore_tag? tag.text
            begin      
                @network.add_node({name: "#{tag.text.capitalize}", type: "tag"})
            rescue StandardError
              puts "Found a duplicate node. Ignoring."
            end
            @network.add_edge({from_name: "#{bill.state}-#{bill.bill_id}-#{bill.session}", to_name: "#{tag.text}"})
          else
            puts "Found a tag to ignore in #{bill.bill_id}"
          end
        end
    
      end# of all bills
      today = Date.today()
      @network.print_to_gdf("bill_graph-#{today.year}-#{today.month}-#{today.day}.gdf")
    end# of task generate_graph
    
  end# of namespace calculate
end# of rakefile