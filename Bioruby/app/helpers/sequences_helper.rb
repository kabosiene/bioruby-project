module SequencesHelper
  def breaking_wrap(txt, col = 70)
    txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/,"\\1\\3<br/>")
  end
    def sequence_wrap(txt, col = 100)
    txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/,"\\1\\3<br/>")
  end

end
