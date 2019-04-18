module Entities
  module Errors
    class NotFound < Error
      expose :error, documentation: { type: 'String', desc: 'Error message', required: true, example: 'Not Found' }
      expose :details, documentation: { type: 'String', desc: 'Error description', example: 'Incorrect path' }

      private

      def error
        'Not Found'
      end

      def details
        object.fetch(:details, 'Incorrect path')
      end
    end
  end
end