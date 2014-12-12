require 'bio'
require 'bio-graphics'

class SequencesController < ApplicationController
  def sequence
    if request.post?
      @results = bio_sequence
    end
  end

  def sequences
    if request.post?
      @sequence_input = params[:input]
      @results = bio_sequences
    end
  end

  protected

  def bio_sequences
    results = {}
    seqs = @sequence_input
    #    seqs = [ 'atgcaaaa', 'ataaagca', 'acgcattt', 'acttgcga' ]
    seqs = seqs.collect{ |x| Bio::Sequence::NA.new(x) }

    sequence_c = Bio::Alignment.new(seqs)
    results[:s_consensus] = sequence_c.consensus

    results[:s_c_iupac] =  sequence_c.consensus_iupac

    cumulative = []
    sequence_c.each { |x| cumulative << x }
    results[:seq_each] = cumulative

    cumulative2 = []
    sequence_c.each_site { |x| cumulative2 << x }
    results[:sec_site]= cumulative2

    cumulative3 =[]
    factory = Bio::ClustalW.new
    sequence_c2 = sequence_c.do_align(factory)
    sequence_c2.each_seq { |seq| cumulative3 << seq.seq}
    results[:sec_clustal] = cumulative3
    results[:s_c_iupac2] =  sequence_c2.consensus_iupac
    
   ##

    #iteracija per poras
    result_seq_1 =[]
    matching =[]

    sequence_c2.each_site { |x| result_seq_1 << x }
    results[:sec_site_dup]= result_seq_1
    seq_length = result_seq_1.length
    seq_range = "1..#{seq_length}"
    result_seq_1.each_with_index { |array,index|
      do_match = true
      array.each {|i|
        do_match = false if i=='-'
      }
      matching << if do_match
        index
      else
        false
      end
    }
    ranges =[]
    current_range=[]
    matching.each { |item|
      if item.is_a?(Fixnum)
        current_range << item
      else
        ranges << "#{current_range.first+1}..#{current_range.last+1}" if current_range.any?{|x| x.is_a?(Fixnum)}
        current_range = []
      end
    }
    ranges << "#{current_range.first+1}..#{current_range.last+1}" if current_range.any?{|x| x.is_a?(Fixnum)}
    #results[:lenght_site]= ranges


    #atvaizdavimas
    g = Bio::Graphics::Panel.new(seq_length+6, :clickable=>true)
    track = g.add_track('Sekų sutapimas', :label => false, :colour => [0,0,1], :glyph => {'unmatch' => :line, 'matching' => :generic})
    unmatch = Bio::Feature.new('unmatch', seq_range)
    subfeatures = [unmatch]
    ranges.each { |item| subfeatures << Bio::Feature.new('matching', item)  }
    transcript = Bio::Feature.new('composite_features', seq_range, [], nil, subfeatures)
    track.add_feature(transcript, :label => 'my_transcript',:link=> 'http://bioruby.open-bio.org/')


    g.draw("#{RAILS_ROOT}/public/images/test.png")

    contents = File.read("#{RAILS_ROOT}/public/images/test.html")
    contents.gsub!("#{RAILS_ROOT}/public", '')
    FileUtils.rm("#{RAILS_ROOT}/public/images/test.html")
    File.open("#{RAILS_ROOT}/public/images/test.html", 'w') do |f|
      f.write contents
    end
   ##

    results
  end

  def bio_sequence
    results2 = {}
    codon= []
    seq_one = Bio::Sequence.auto(params[:input])
    @input_seq = seq_one
    results2[:sequence_length] = seq_one.length
    results2[:output_stile] = seq_one.output(:fasta)
    results2[:output_composition] = seq_one.composition
    results2[:output_weight] = seq_one.molecular_weight
    if seq_one.moltype == Bio::Sequence::NA
      results2[:output_complement] = seq_one.complement.reverse
      results2[:output_gc_percet] = seq_one.gc_percent
      results2[:output_at_percet] = seq_one.at_content
      results2[:codon_usage] = seq_one.codon_usage
      results2[:is_na] = true
      codon =[]
      seq_one.window_search(3,3) do |c|
        codon << c
      end
      results2[:sequence_window] = codon
    else if seq_one.moltype == Bio::Sequence::AA
        results2[:seq_codes]= seq_one.codes
        results2[:seq_names]= seq_one.names
      end
    end
    results2
  end
  

  
end
