module Entities
  module Errors
    class BadRequest < Error
      expose :error, documentation: { type: 'String', desc: 'Error message', required: true, example: 'Bad Request' }

      private

      def error
        'Bad Request'
      end
    end
  end
end