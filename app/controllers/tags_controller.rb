
class TagsController < ApplicationController

  def index
    @tags = Bill.distinct("tags.text")  
  end# of #index

  def show
    @tag = params[:id]
    @bills = Bill.where("tags.text" => {:$in => [@tag]})
  end

end# of class