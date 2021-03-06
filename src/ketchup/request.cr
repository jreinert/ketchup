require "json"

module Ketchup
  abstract class Request
    getter id

    def initialize(@id : Float64? | Int64? | Int32? | String?, params = nil)
      parse_params(params)
    end

    abstract def parse_params(params : String)

    def self.from_json(string)
      parser = RequestParser.new(string)
      parser.parse
    rescue e : JSON::ParseException
      raise ParseError.new(nil, e.message)
    end

    class RequestParser
      def initialize(string)
        @parser = JSON::PullParser.new(string)
      end

      def parse : Request
        version = nil
        id = nil
        method = nil
        params = nil

        @parser.read_object do |key|
          case key
          when "jsonrpc" then version = @parser.read_string
          when "id" then id = parse_id
          when "method" then method = @parser.read_string
          when "params" then params = parse_params
          end
        end

        if version != "2.0"
          raise InvalidRequestError.new(id, %{Unsupported JSON-RPC version #{version}. Supported versions: ["2.0"]})
        end
        if method.nil?
          raise InvalidRequestError.new(id, "No method specified")
        end

        {% begin %}
        case(method)
        {% for request in Request.subclasses %}
        when {{request.stringify.gsub(/Ketchup::|(Request$)/, "").underscore}} then {{request}}.new(id, params)
        {% end %}
        else raise UnknownMethodError.new(id, method)
        end
        {% end %}
      end

      def parse_params
        JSON.build { |json| @parser.read_raw(json) }
      end

      def parse_id
        @parser.read_next
        case @parser.kind
        when JSON::PullParser::Kind::Int then @parser.int_value
        when JSON::PullParser::Kind::Float then @parser.float_value
        when JSON::PullParser::Kind::String then @parser.string_value
        when JSON::PullParser::Kind::Null then nil
        else raise InvalidRequestError.new(
          "Type error for id: Expected int, float, string or null. Got #{@parser.kind}."
        )
        end
      end
    end

    class InvalidRequestError < Error
      def initialize(id, data = nil)
        super(id, -32600, "Invalid Request", data)
      end
    end

    class UnknownMethodError < Error
      def initialize(id, method)
        super(id, -32601, "Method not found", "No such method #{method}")
      end
    end

    class ParseError < Error
      def initialize(id, data = nil)
        super(id, -32700, "Parse error", data)
      end
    end
  end
end
