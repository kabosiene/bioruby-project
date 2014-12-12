#SUSPENDED
#require 'bio'
#require 'bio-graphics'
#
#
#
#class SeqAlignGraphController < ApplicationController
#
#  def seq_align_graph
#    if request.post?
#      @sequence_input = params[:input]
#      @results = bio_sequences_graph
#    end
#  end
#
#  protected
#
#  def bio_sequences_graph
#    results = {}
#    seqs = @sequence_input
#    #seqs = [ 'atgcaaaa', 'ataaagca', 'acgcattt', 'acttgcga' ]
#    seqs = seqs.collect{ |x| Bio::Sequence::NA.new(x) }
#
#    sequence_l = Bio::Alignment.new(seqs)
#
#    result_seq =[]
#    factory = Bio::ClustalW.new
#    sequence_2 = sequence_l.do_align(factory)
#    sequence_2.each_seq { |seq| result_seq << seq.seq}
#    results[:sec_clustal_dup] = result_seq
#
#    #iteracija per poras
#    result_seq_1 =[]
#    matching =[]
#
#    sequence_2.each_site { |x| result_seq_1 << x }
#    results[:sec_site_dup]= result_seq_1
#    seq_length = result_seq_1.length
#    seq_range = "1..#{seq_length}"
#    result_seq_1.each_with_index { |array,index|
#      do_match = true
#      array.each {|i|
#        do_match = false if i=='-'
#      }
#      matching << if do_match
#        index
#      else
#        false
#      end
#    }
#    ranges =[]
#    current_range=[]
#    matching.each { |item|
#      if item.is_a?(Fixnum)
#        current_range << item
#      else
#        ranges << "#{current_range.first+1}..#{current_range.last+1}" if current_range.any?{|x| x.is_a?(Fixnum)}
#        current_range = []
#      end
#    }
#    ranges << "#{current_range.first+1}..#{current_range.last+1}" if current_range.any?{|x| x.is_a?(Fixnum)}
#    #results[:lenght_site]= ranges
#
#
#    #atvaizdavimas
#    g = Bio::Graphics::Panel.new(seq_length+6, :clickable=>true)
#    track = g.add_track('seku sutapimas', :label => false, :colour => [0,0,1], :glyph => {'unmatch' => :line, 'matching' => :generic})
#    unmatch = Bio::Feature.new('unmatch', seq_range)
#    subfeatures = [unmatch]
#    ranges.each { |item| subfeatures << Bio::Feature.new('matching', item)  }
#    transcript = Bio::Feature.new('composite_features', seq_range, [], nil, subfeatures)
#    track.add_feature(transcript, :label => 'my_transcript',:link=> 'http://bioruby.open-bio.org/')
#
#
#    g.draw("#{RAILS_ROOT}/public/images/test.png")
#
#    contents = File.read("#{RAILS_ROOT}/public/images/test.html")
#    contents.gsub!("#{RAILS_ROOT}/public", '')
#    FileUtils.rm("#{RAILS_ROOT}/public/images/test.html")
#    File.open("#{RAILS_ROOT}/public/images/test.html", 'w') do |f|
#      f.write contents
#    end
#
#
#    results
#  end
#
#end
