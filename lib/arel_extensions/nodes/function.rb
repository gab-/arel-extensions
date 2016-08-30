module ArelExtensions
  module Nodes
    class Function < Arel::Nodes::Function
      include Arel::Math
      include Arel::Expressions

    	# overrides as to make new Node like AliasPredication
      def as other
        Arel::Nodes::As.new(self, Arel.sql(other))
      end

      def expr
       	@expressions.first
      end

      def left
        @expressions.first
      end

      def right
        @expressions[0]
      end

      protected
      def convert_to_node(object)
        case object
        when Arel::Attributes::Attribute, Arel::Nodes::Node, Fixnum, Integer
          object
        when DateTime, Time
          Arel::Nodes.build_quoted(Date.new(object.year, object.month, object.day), self)
        when String
          Arel::Nodes.build_quoted(object)
        when Date
          Arel::Nodes.build_quoted(object, self)
        when ActiveSupport::Duration
          object.to_i
        else
          raise(ArgumentError, "#{object.class} can not be converted to CONCAT arg")
        end
      end

    end
  end
end