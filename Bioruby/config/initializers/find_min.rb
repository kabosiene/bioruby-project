module Enumerable
  [['min','-1'], ['max','1']].each do |name, comparator|

    module_eval %{
      def find_all_#{name}
        block = Proc.new do |object|
          block_given? ? yield(object) : object
        end

        self.inject([]) do |result, element|
          if result.empty?
            result << element
          else
            case block[element] <=> block[result.first]
            when 0
              result << element
            when #{comparator}
              [element]
            else
              result
            end
          end
        end
      end
    }
  end
end