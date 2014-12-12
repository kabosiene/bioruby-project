require 'bio'

class SchemesController < ApplicationController
  include Bio::ColorScheme
  
  def codon
    if request.post?
      @data_inputs = params[:c_seq]
      @results = codon_t
    end
  end

  def scheme
    if request.post?
      @data_input = params[:input]
      @results = bio_scheme
    end
  end

  protected

  def codon_t
    result={}
    sequence = @data_inputs
    cumulative=[]
    cumulative2=[]
    cumulative3=[]
    sequence.scan(/.{3}/).each {|x|
      
      cumulative << Bio::CodonTable[1].[](x)
      if Bio::CodonTable[1].start_codon?(x)
        cumulative2 << x
      elsif
        Bio::CodonTable[1].stop_codon?(x)
        cumulative3 << x        
      end
    }   
    result[:c_table] = cumulative 
    result[:start_codon?] = cumulative2
    result[:stop_codon?] = cumulative3
    result
  end

  def bio_scheme
    seq = params[:seq]
    lscheme = "Bio::ColorScheme::#{@data_input}".constantize
    postfix = '</span> '
    html = ''
    seq.each_byte do |c|
      color = lscheme[c.chr]
      #prefix = %Q(<span style="background:##{color};">)
      prefix = "<span style=\"background:##{color}\">"
      html += prefix + c.chr + postfix
    end

    html
  end
end
