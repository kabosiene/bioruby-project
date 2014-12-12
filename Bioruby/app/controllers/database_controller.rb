require 'bio'

class DatabaseController < ApplicationController
  def swissp
    begin
      if request.post?
        @results = bio_database
      end
    rescue NoMethodError => e
      flash[:notice] = "Neteisingas ID"
      redirect_to :back
    end
  end

  protected
  def bio_database
    results = {}
    entry = params[:entry]
    reg = Bio::Registry.new
    serv = reg.get_database('swissprot')
    entry = serv.get_by_id(entry)
    obj = Bio::SwissProt.new(entry)
    results[:entry_id] = obj.entry_name
    results[:protein_name] = obj.protein_name
    results[:oc] = obj.oc
    results[:gene_name] = obj.gene_names
    results[:ac] = obj.ac
    results[:dt] = obj.dt
    results[:seq] = obj.seq


    results
  end
end
