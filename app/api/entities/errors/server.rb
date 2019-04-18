module Entities
  module Errors
    class Server < Error
      expose :error, documentation: { type: 'String', desc: 'Error message', required: true, example: 'Internal Error' }

      private

      def error
        'Internal Error'
      end
    end
  end
end