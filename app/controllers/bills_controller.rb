require 'net/http'

class BillsController < ApplicationController

  def index
    if params[:state] then
      @all_bills = Bill.where("state" => params[:state])
    else
      @all_bills = Bill.all.sort {|bill1, bill2|  
      if bill1.state!=bill2.state
        bill1.state <=> bill2.state
      else
        bill1.bill_id <=> bill2.bill_id
      end
    }
    end
  end# of #index


  def new
    @new_bill = Bill.new
    if params["commit"] then
      @new_bill = bill_lookup params["openstates_link"]
    end
  end# of new

  def show
    @bill = Bill.find_by_id(params[:id])
    if (@bill.tags.length>0)
      @new_tags = @bill.tags
    else 
      @new_tags = [Tag.new()]
    end
  end# of show

  def update_tags
    @bill = Bill.find_by_id(params[:id])
    @bill.tags = params[:new_tags].split(",").map do |tag|
      tag.strip!
      Tag.new ({text: tag})
    end
    @bill.save
    redirect_to bill_path params[:id]
  end

  def update_notes
    @bill = Bill.find_by_id(params[:id])
    notes = params[:notes].split("\r\n")
    @bill.notes = notes.map do |note|
      Note.new({text: note})
    end
    @bill.save
    redirect_to bill_path params[:id]
  end# of BillController#update_notes

  def previous_bill
    @current_bill = Bill.find_by_id(params[:id])
    all_bills = Bill.all.sort {|bill1, bill2|  
      if bill1.state!=bill2.state
        bill1.state <=> bill2.state
      else
        bill1.bill_id <=> bill2.bill_id
      end
    }
    current_index = all_bills.find_index {|bill| bill._id==@current_bill._id}
    if current_index==0 
      @prev_bill = all_bills.last
    else
      @prev_bill = all_bills[current_index-1]
    end
    redirect_to bill_path @prev_bill
  end# of #previous_bill

  def next_bill
    @current_bill = Bill.find_by_id(params[:id])
    all_bills = Bill.all.sort {|bill1, bill2|  
      if bill1.state!=bill2.state
        bill1.state <=> bill2.state
      else
        bill1.bill_id <=> bill2.bill_id
      end
    }
    current_index = all_bills.find_index {|bill| bill._id==@current_bill._id}
    if current_index==(all_bills.length-1) 
      @next_bill = all_bills[0]
    else
      @next_bill = all_bills[current_index+1]
    end
    redirect_to bill_path @next_bill
  end# of #next_bill

  def get_bulk
    @links = ["nothing"]
  end

  def post_bulk
    @links = params[:links].split(/\n/)
    @links.each do |link|
      if (/http:\/\/openstates\.org\/.*\/bills\/.*\/.*\//.match link) then
        @bill = bill_lookup(link)
        @bill.save
      end
    end
    redirect_to bills_path
  end

  private 
    def bill_lookup(link)
	  #link format: http://openstates.org/al/bills/2014rs/SB240/
	  #  http://openstates.org/[state]/bills/[session]/[bill]
	  match = Regexp.new(/http:\/\/openstates\.org\/(.*)\/bills\/(.*)\/(.*)\//i).match(link)
	  state = match[1]
	  session = match[2]
	  bill_id = match[3]
	  bill_id.insert(bill_id.index(/[0-9]/),"%20")
	  
	  #  http://openstates.org/api/v1/bills/[state]/[session]/[bill_id]/?apikey=[apikey]
	  uri = URI("http://openstates.org/api/v1/bills/" + state + "/" + 
	  					session + "/" + bill_id + "/?apikey=" + ENV['OPENSTATES_API'])
	  bill_response = Net::HTTP.get(uri)
	  bill = Bill.new
	  bill.add_openstates_json(bill_response)
	  bill.sources << {url: link}
	  bill
	end

end# of class

